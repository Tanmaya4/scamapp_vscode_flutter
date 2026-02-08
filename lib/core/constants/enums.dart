/// Enums used throughout the SafeCall application.
library;

/// Threat levels for scam detection
enum ThreatLevel {
  none(0),
  low(1),
  medium(2),
  high(3),
  critical(4);

  const ThreatLevel(this.priority);
  final int priority;
}

/// Actions to take when a threat is detected
enum ThreatAction {
  muteOnly,
  alertAndMute,
  autoDisconnect;

  String get displayName {
    switch (this) {
      case ThreatAction.muteOnly:
        return 'Mute Only';
      case ThreatAction.alertAndMute:
        return 'Alert & Mute';
      case ThreatAction.autoDisconnect:
        return 'Auto Disconnect';
    }
  }

  String get description {
    switch (this) {
      case ThreatAction.muteOnly:
        return 'Silently mute the call';
      case ThreatAction.alertAndMute:
        return 'Show alert and mute';
      case ThreatAction.autoDisconnect:
        return 'Automatically end call';
    }
  }
}

/// Types of threats detected
enum ThreatType {
  keyword,
  intent,
  pattern,
}

/// Call states
enum CallState {
  idle,
  ringing,
  offhook,
}

/// Stranger Mode states
enum StrangerModeState {
  inactive,
  activating,
  active,
  deactivating,
  threatDetected,
}

/// Reasons for ending a Stranger Mode session
enum SessionEndReason {
  userRequested,
  timerExpired,
  criticalThreat,
  callEnded,
  error,
}
