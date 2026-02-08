import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/database.dart';
import '../data/repository/safecall_repositories.dart';
import '../data/repository/user_preferences_repository.dart';
import '../navigation/app_router.dart';
import '../services/native_bridge_service.dart';
import '../services/stranger_mode_service.dart';
import '../services/threat_detection_service.dart';

// ── SharedPreferences (overridden in main.dart) ─────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// ── Router ──────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((_) => appRouter);

// ── Database ────────────────────────────────────────────────────
final databaseProvider = Provider<SafeCallDatabase>((_) {
  return SafeCallDatabase.instance;
});

// ── Repositories ────────────────────────────────────────────────
final userPreferencesProvider = Provider<UserPreferencesRepository>((_) {
  return UserPreferencesRepository();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.read(databaseProvider));
});

final threatEventRepositoryProvider = Provider<ThreatEventRepository>((ref) {
  return ThreatEventRepository(ref.read(databaseProvider));
});

final blockedNotificationRepositoryProvider =
    Provider<BlockedNotificationRepository>((ref) {
  return BlockedNotificationRepository(ref.read(databaseProvider));
});

// ── Services ────────────────────────────────────────────────────
final nativeBridgeProvider = Provider<NativeBridgeService>((_) {
  return NativeBridgeService();
});

final threatDetectionProvider = Provider<ThreatDetectionService>((_) {
  return ThreatDetectionService();
});

final strangerModeServiceProvider = Provider<StrangerModeService>((ref) {
  return StrangerModeService(
    prefsRepo: ref.read(userPreferencesProvider),
    sessionRepo: ref.read(sessionRepositoryProvider),
    threatRepo: ref.read(threatEventRepositoryProvider),
    threatDetection: ref.read(threatDetectionProvider),
    nativeBridge: ref.read(nativeBridgeProvider),
  );
});
