import 'dart:async';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/enums.dart';
import '../core/models/models.dart';
import '../data/repository/safecall_repositories.dart';
import '../data/repository/user_preferences_repository.dart';
import 'native_bridge_service.dart';
import 'threat_detection_service.dart';

/// Core orchestrator that manages all Stranger Mode protection features:
/// - Activating/deactivating Stranger Mode
/// - Coordinating call monitoring, audio analysis, and notification blocking
/// - Managing session lifecycle and threat responses
class StrangerModeService {
  final UserPreferencesRepository _prefsRepo;
  final SessionRepository _sessionRepo;
  final ThreatEventRepository _threatRepo;
  final ThreatDetectionService _threatDetection;
  final NativeBridgeService _nativeBridge;

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _uuid = const Uuid();

  // ── State streams ─────────────────────────────────────────────
  final _statusController = StreamController<StrangerModeStatus>.broadcast();
  Stream<StrangerModeStatus> get statusStream => _statusController.stream;

  StrangerModeStatus _status = const StrangerModeStatus();
  StrangerModeStatus get currentStatus => _status;

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  String? _currentSessionId;

  StrangerModeService({
    required UserPreferencesRepository prefsRepo,
    required SessionRepository sessionRepo,
    required ThreatEventRepository threatRepo,
    required ThreatDetectionService threatDetection,
    required NativeBridgeService nativeBridge,
  })  : _prefsRepo = prefsRepo,
        _sessionRepo = sessionRepo,
        _threatRepo = threatRepo,
        _threatDetection = threatDetection,
        _nativeBridge = nativeBridge;

  // ── Activate ──────────────────────────────────────────────────

  Future<bool> activate({int? durationMinutes}) async {
    if (_status.isActive) {
      _logger.w('Stranger Mode already active');
      return false;
    }

    try {
      // Get duration from settings if not provided
      final settings = await _prefsRepo.getUserSettings();
      final duration = durationMinutes ?? settings.defaultDurationMinutes;
      final durationMs = duration * 60 * 1000;

      // Create session
      final sessionId = _uuid.v4();
      _currentSessionId = sessionId;

      final session = StrangerModeSession(
        sessionId: sessionId,
        startTime: DateTime.now().millisecondsSinceEpoch,
        plannedDurationMs: durationMs,
      );

      // Persist session
      await _sessionRepo.startSession(session);

      // Start native services
      await _nativeBridge.startForegroundService(
        sessionId: sessionId,
        durationMinutes: duration,
      );
      await _nativeBridge.startNotificationBlocking();
      await _nativeBridge.startCallMonitoring();

      // Update status
      _updateStatus(StrangerModeStatus(
        state: StrangerModeState.active,
        currentSession: session,
      ));

      // Start countdown timer
      _startSessionTimer(durationMs);

      _logger.i('Stranger Mode activated: $sessionId, duration: $duration min');
      return true;
    } catch (e) {
      _logger.e('Failed to activate Stranger Mode: $e');
      _updateStatus(const StrangerModeStatus(state: StrangerModeState.inactive));
      return false;
    }
  }

  // ── Deactivate ────────────────────────────────────────────────

  Future<bool> deactivate({
    SessionEndReason reason = SessionEndReason.userRequested,
  }) async {
    final sessionId = _currentSessionId;
    if (sessionId == null) {
      _logger.w('No active session to deactivate');
      return false;
    }

    try {
      // Stop native services
      await _nativeBridge.stopCallMonitoring();
      await _nativeBridge.stopAudioMonitoring();
      await _nativeBridge.stopNotificationBlocking();
      await _nativeBridge.stopForegroundService();

      // End session in database
      await _sessionRepo.endSession(sessionId, reason.name);

      // Cancel timers
      _sessionTimer?.cancel();
      _countdownTimer?.cancel();

      // Update status
      _updateStatus(StrangerModeStatus(
        state: StrangerModeState.inactive,
        currentSession: _status.currentSession?.copyWith(
          endTime: DateTime.now().millisecondsSinceEpoch,
          endReason: reason,
        ),
      ));

      _currentSessionId = null;
      _logger.i('Stranger Mode deactivated: $sessionId, reason: $reason');
      return true;
    } catch (e) {
      _logger.e('Failed to deactivate: $e');
      return false;
    }
  }

  // ── Threat Handling ───────────────────────────────────────────

  /// Analyze text from speech-to-text and handle any detected threats.
  Future<ThreatEvent?> analyzeTranscribedText(String text) async {
    final result = _threatDetection.analyzeText(text);
    if (result == null) return null;

    final sessionId = _currentSessionId ?? '';
    final threat = result.copyWith(sessionId: sessionId);

    // Persist threat
    await _threatRepo.insertThreatEvent(threat);
    await _sessionRepo.incrementThreats(sessionId);

    // Update status
    final updatedThreats = [..._status.threatsInSession, threat];
    _updateStatus(_status.copyWith(
      state: StrangerModeState.threatDetected,
      activeThreat: threat,
      threatsInSession: updatedThreats,
    ));

    // Execute response
    await _handleThreatAction(threat);

    return threat;
  }

  Future<void> _handleThreatAction(ThreatEvent threat) async {
    switch (threat.actionTaken) {
      case ThreatAction.autoDisconnect:
        await _nativeBridge.muteCallAudio();
        _logger.w('HIGH THREAT – Auto-muted call audio');
        break;
      case ThreatAction.alertAndMute:
        await _nativeBridge.muteCallAudio();
        _logger.w('MEDIUM THREAT – Muted and alerting user');
        break;
      case ThreatAction.muteOnly:
        // Low threat – just log
        _logger.i('LOW THREAT – Logged only');
        break;
    }
  }

  void dismissThreat() {
    _updateStatus(_status.copyWith(
      state: StrangerModeState.active,
      activeThreat: null,
    ));
  }

  Future<void> endCall() async {
    await _nativeBridge.endCall();
  }

  // ── Mute Controls ─────────────────────────────────────────────

  Future<void> muteCall() async => _nativeBridge.muteCallAudio();
  Future<void> unmuteCall() async => _nativeBridge.unmuteCallAudio();

  // ── Timer ─────────────────────────────────────────────────────

  void _startSessionTimer(int durationMs) {
    _sessionTimer?.cancel();

    // Auto-deactivate when time expires
    _sessionTimer = Timer(
      Duration(milliseconds: durationMs),
      () => deactivate(reason: SessionEndReason.timerExpired),
    );

    // Update remaining time every second for UI
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = _status.currentSession;
      if (session != null && session.isActive) {
        // Trigger a status update so listeners rebuild
        _statusController.add(_status);
      }
    });
  }

  // ── Restore Session ───────────────────────────────────────────

  Future<void> restoreActiveSession() async {
    try {
      final activeSession = await _sessionRepo.getActiveSession();
      if (activeSession != null) {
        _currentSessionId = activeSession.sessionId;
        _updateStatus(StrangerModeStatus(
          state: StrangerModeState.active,
          currentSession: activeSession,
        ));
        // Re-start countdown with remaining time
        _startSessionTimer(activeSession.remainingTimeMs);
        _logger.i('Restored active session: ${activeSession.sessionId}');
      }
    } catch (e) {
      _logger.e('Failed to restore session: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  void _updateStatus(StrangerModeStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void dispose() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _statusController.close();
  }
}
