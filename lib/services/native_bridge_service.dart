import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Service that bridges to native Android APIs for call monitoring.
///
/// Uses MethodChannel to communicate with the Android native side for:
/// - TelephonyManager call state monitoring
/// - AudioRecord microphone access
/// - Notification listener service control
class NativeBridgeService {
  static const _channel = MethodChannel('com.safecall/native_bridge');
  static const _eventChannel = EventChannel('com.safecall/call_events');

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  Stream<String>? _callEventsStream;

  /// Stream of call state events from native side.
  Stream<String> get callEvents {
    _callEventsStream ??=
        _eventChannel.receiveBroadcastStream().map((e) => e.toString());
    return _callEventsStream!;
  }

  // ── Call Monitoring ───────────────────────────────────────────

  Future<bool> startCallMonitoring() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('startCallMonitoring') ?? false;
      _logger.i('Call monitoring started: $result');
      return result;
    } on PlatformException catch (e) {
      _logger.e('Failed to start call monitoring: ${e.message}');
      return false;
    }
  }

  Future<void> stopCallMonitoring() async {
    try {
      await _channel.invokeMethod('stopCallMonitoring');
      _logger.i('Call monitoring stopped');
    } on PlatformException catch (e) {
      _logger.e('Failed to stop call monitoring: ${e.message}');
    }
  }

  // ── Audio Monitoring ──────────────────────────────────────────

  Future<bool> startAudioMonitoring() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('startAudioMonitoring') ?? false;
      _logger.i('Audio monitoring started: $result');
      return result;
    } on PlatformException catch (e) {
      _logger.e('Failed to start audio monitoring: ${e.message}');
      return false;
    }
  }

  Future<void> stopAudioMonitoring() async {
    try {
      await _channel.invokeMethod('stopAudioMonitoring');
      _logger.i('Audio monitoring stopped');
    } on PlatformException catch (e) {
      _logger.e('Failed to stop audio monitoring: ${e.message}');
    }
  }

  // ── Notification Blocking ─────────────────────────────────────

  Future<bool> startNotificationBlocking() async {
    try {
      return await _channel.invokeMethod<bool>('startNotificationBlocking') ??
          false;
    } on PlatformException catch (e) {
      _logger.e('Failed to start notification blocking: ${e.message}');
      return false;
    }
  }

  Future<void> stopNotificationBlocking() async {
    try {
      await _channel.invokeMethod('stopNotificationBlocking');
    } on PlatformException catch (e) {
      _logger.e('Failed to stop notification blocking: ${e.message}');
    }
  }

  // ── Mute Control ──────────────────────────────────────────────

  Future<bool> muteCallAudio() async {
    try {
      return await _channel.invokeMethod<bool>('muteCallAudio') ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to mute: ${e.message}');
      return false;
    }
  }

  Future<bool> unmuteCallAudio() async {
    try {
      return await _channel.invokeMethod<bool>('unmuteCallAudio') ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to unmute: ${e.message}');
      return false;
    }
  }

  // ── End Call ──────────────────────────────────────────────────

  Future<bool> endCall() async {
    try {
      return await _channel.invokeMethod<bool>('endCall') ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to end call: ${e.message}');
      return false;
    }
  }

  // ── Foreground Service ────────────────────────────────────────

  Future<bool> startForegroundService({
    required String sessionId,
    required int durationMinutes,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('startForegroundService', {
            'sessionId': sessionId,
            'durationMinutes': durationMinutes,
          }) ??
          false;
    } on PlatformException catch (e) {
      _logger.e('Failed to start foreground service: ${e.message}');
      return false;
    }
  }

  Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (e) {
      _logger.e('Failed to stop foreground service: ${e.message}');
    }
  }

  // ── Permission Checks ─────────────────────────────────────────

  Future<bool> isNotificationListenerEnabled() async {
    try {
      return await _channel
              .invokeMethod<bool>('isNotificationListenerEnabled') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openNotificationListenerSettings() async {
    try {
      await _channel.invokeMethod('openNotificationListenerSettings');
    } on PlatformException catch (e) {
      _logger.e('Failed to open settings: ${e.message}');
    }
  }

  Future<bool> canDrawOverlays() async {
    try {
      return await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      _logger.e('Failed to request overlay permission: ${e.message}');
    }
  }
}
