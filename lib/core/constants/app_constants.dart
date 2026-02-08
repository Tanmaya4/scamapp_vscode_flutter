/// Safe Call (सुरक्षित कॉल) — Anti-Scam Mobile Application
/// Constants used throughout the app
library;

class AppConstants {
  AppConstants._();

  // ── Stranger Mode ─────────────────────────────────────────────
  static const int defaultDurationMinutes = 15;
  static const int minDurationMinutes = 5;
  static const int maxDurationMinutes = 60;
  static const int activationHoldDurationMs = 3000;

  // ── Threat Detection ──────────────────────────────────────────
  static const double keywordConfidenceThreshold = 0.7;
  static const double intentConfidenceThreshold = 0.8;
  static const int threatAccumulationThreshold = 3;
  static const int threatWindowMs = 30000; // 30 seconds

  // ── Audio Processing ──────────────────────────────────────────
  static const int audioSampleRate = 16000;
  static const int audioBufferSize = 512;
  static const int numIntentClasses = 3;
  static const int scamIntentIndex = 2;

  // ── Notification IDs ──────────────────────────────────────────
  static const int strangerModeNotificationId = 1001;
  static const int threatAlertNotificationId = 1002;
  static const int serviceNotificationId = 1003;

  // ── Notification Channels ─────────────────────────────────────
  static const String strangerModeChannelId = 'stranger_mode_channel';
  static const String threatAlertChannelId = 'threat_alert_channel';
  static const String serviceChannelId = 'service_channel';

  // ── SharedPreferences Keys ────────────────────────────────────
  static const String prefsName = 'safecall_prefs';
  static const String prefOnboardingCompleted = 'onboarding_completed';
  static const String prefDefaultDuration = 'default_duration';
  static const String prefThreatLevelAction = 'threat_level_action';
  static const String prefAutoModeEnabled = 'auto_mode_enabled';
  static const String prefHapticFeedback = 'haptic_feedback';
  static const String prefAutoReport = 'auto_report';
  static const String prefLanguage = 'language';

  // ── External Links ────────────────────────────────────────────
  static const String cybercrimePortalUrl = 'https://cybercrime.gov.in';
  static const String helplineNumber = '1930';

  // ── Database ──────────────────────────────────────────────────
  static const String databaseName = 'safecall_database.db';
  static const int databaseVersion = 1;

  // ── Log Retention ─────────────────────────────────────────────
  static const int logRetentionDays = 7;
}
