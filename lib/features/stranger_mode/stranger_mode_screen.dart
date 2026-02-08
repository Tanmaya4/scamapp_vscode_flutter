import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/enums.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../navigation/app_router.dart';
import '../../providers/providers.dart';

/// Stranger Mode screen – activation, active monitoring, threat alerts.
class StrangerModeScreen extends ConsumerStatefulWidget {
  const StrangerModeScreen({super.key});

  @override
  ConsumerState<StrangerModeScreen> createState() => _StrangerModeScreenState();
}

class _StrangerModeScreenState extends ConsumerState<StrangerModeScreen> {
  final _localAuth = LocalAuthentication();
  StrangerModeStatus _status = const StrangerModeStatus();
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    final service = ref.read(strangerModeServiceProvider);
    _status = service.currentStatus;
    _statusSub = service.statusStream.listen((s) {
      if (mounted) setState(() => _status = s);
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _activate() async {
    final service = ref.read(strangerModeServiceProvider);
    await service.activate();
  }

  Future<void> _requestDeactivation() async {
    // Require biometric auth before deactivating
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to exit Stranger Mode',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (authenticated) {
        final service = ref.read(strangerModeServiceProvider);
        await service.deactivate();
        if (mounted) context.go(AppRoutes.home);
      }
    } on PlatformException {
      // Biometric unavailable – fallback
      final service = ref.read(strangerModeServiceProvider);
      await service.deactivate();
      if (mounted) context.go(AppRoutes.home);
    }
  }

  void _dismissThreat() {
    ref.read(strangerModeServiceProvider).dismissThreat();
  }

  Future<void> _endCall() async {
    await ref.read(strangerModeServiceProvider).endCall();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _status.isActive;
    final hasThreat = _status.state == StrangerModeState.threatDetected;

    // Determine background gradient
    final List<Color> bgColors = hasThreat
        ? [AppColors.warningRed, AppColors.warningRedDark]
        : isActive
            ? [AppColors.safetyGreen, AppColors.safetyGreenDark]
            : [AppColors.trustBlue, AppColors.trustBlueDark];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: isActive || hasThreat
              ? _ActiveContent(
                  status: _status,
                  onDeactivate: _requestDeactivation,
                  onDismissThreat: _dismissThreat,
                  onEndCall: _endCall,
                  onReportIncident: () =>
                      context.push(AppRoutes.incidentReport),
                )
              : _ActivationContent(
                  onActivate: _activate,
                  onNavigateBack: () => context.pop(),
                ),
        ),
      ),
    );
  }
}

// ── Activation content (before activating) ──────────────────────
class _ActivationContent extends StatelessWidget {
  final VoidCallback onActivate;
  final VoidCallback onNavigateBack;

  const _ActivationContent({
    required this.onActivate,
    required this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: onNavigateBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(flex: 1),

        // Warning card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            color: Colors.white.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Activate Stranger Mode?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _featureItem(Icons.lock, 'Lock to calling-only interface'),
                  _featureItem(
                      Icons.notifications_off, 'Block OTP notifications'),
                  _featureItem(
                      Icons.hearing, 'Monitor for suspicious phrases'),
                  _featureItem(
                      Icons.fingerprint, 'Require your fingerprint to exit'),
                  const SizedBox(height: 12),
                  Text(
                    'Mode auto-expires after 15 minutes for your safety.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),

        // Activation button
        ActivationButton(
          text: 'Stranger\nMode',
          onActivated: onActivate,
        ),
        const SizedBox(height: 16),
        Text(
          'Hold for 3 seconds to activate',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  static Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ── Active mode content ─────────────────────────────────────────
class _ActiveContent extends StatelessWidget {
  final StrangerModeStatus status;
  final VoidCallback onDeactivate;
  final VoidCallback onDismissThreat;
  final VoidCallback onEndCall;
  final VoidCallback onReportIncident;

  const _ActiveContent({
    required this.status,
    required this.onDeactivate,
    required this.onDismissThreat,
    required this.onEndCall,
    required this.onReportIncident,
  });

  @override
  Widget build(BuildContext context) {
    final hasThreat = status.state == StrangerModeState.threatDetected;
    final remainingMs = status.currentSession?.remainingTimeMs ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 48),

          // Status icon
          Icon(
            hasThreat ? Icons.warning : Icons.shield,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),

          Text(
            hasThreat ? 'THREAT DETECTED' : 'STRANGER MODE ACTIVE',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Timer
          TimerDisplay(remainingTimeMs: remainingMs),
          Text(
            'remaining',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 32),

          // Threat card
          if (status.activeThreat != null)
            ThreatAlertCard(
              detectedPhrase: status.activeThreat!.detectedContent,
              levelText: status.activeThreat!.level == ThreatLevel.high
                  ? '🚨 SCAM DETECTED'
                  : '⚠️ Suspicious Activity',
              levelColor: status.activeThreat!.level == ThreatLevel.high
                  ? AppColors.warningRed
                  : AppColors.alertOrange,
              onDismiss: onDismissThreat,
              onEndCall: onEndCall,
            ),

          const Spacer(),

          // Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoChip(
                  Icons.notifications_off,
                  '${status.blockedNotificationCount} Blocked',
                  Colors.white),
              _infoChip(Icons.warning_amber,
                  '${status.threatsInSession.length} Threats', Colors.white),
            ],
          ),
          const SizedBox(height: 24),

          // Deactivate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onDeactivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
              icon: const Icon(Icons.fingerprint),
              label: const Text(
                'Authenticate to Exit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13)),
      ],
    );
  }
}
