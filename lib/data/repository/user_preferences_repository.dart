import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../core/models/models.dart';

/// Repository for user preferences using SharedPreferences.
class UserPreferencesRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Read settings ─────────────────────────────────────────────

  Future<UserSettings> getUserSettings() async {
    final prefs = await _preferences;
    return UserSettings(
      onboardingCompleted:
          prefs.getBool(AppConstants.prefOnboardingCompleted) ?? false,
      defaultDurationMinutes:
          prefs.getInt(AppConstants.prefDefaultDuration) ??
              AppConstants.defaultDurationMinutes,
      threatAction: _parseThreatAction(
          prefs.getString(AppConstants.prefThreatLevelAction)),
      autoModeEnabled:
          prefs.getBool(AppConstants.prefAutoModeEnabled) ?? false,
      hapticFeedbackEnabled:
          prefs.getBool(AppConstants.prefHapticFeedback) ?? true,
      autoReportEnabled:
          prefs.getBool(AppConstants.prefAutoReport) ?? false,
      language: prefs.getString(AppConstants.prefLanguage) ?? 'en',
    );
  }

  // ── Write settings ────────────────────────────────────────────

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefOnboardingCompleted, completed);
  }

  Future<void> setDefaultDuration(int minutes) async {
    final prefs = await _preferences;
    final clamped = minutes.clamp(
      AppConstants.minDurationMinutes,
      AppConstants.maxDurationMinutes,
    );
    await prefs.setInt(AppConstants.prefDefaultDuration, clamped);
  }

  Future<void> setThreatAction(ThreatAction action) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.prefThreatLevelAction, action.name);
  }

  Future<void> setAutoModeEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefAutoModeEnabled, enabled);
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefHapticFeedback, enabled);
  }

  Future<void> setAutoReportEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefAutoReport, enabled);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.prefLanguage, language);
  }

  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  // ── Helpers ───────────────────────────────────────────────────

  ThreatAction _parseThreatAction(String? value) {
    if (value == null) return ThreatAction.alertAndMute;
    try {
      return ThreatAction.values.byName(value);
    } catch (_) {
      return ThreatAction.alertAndMute;
    }
  }
}
