import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'providers/providers.dart';

/// Entry point for the SafeCall Anti-Scam Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-load SharedPreferences for synchronous access via providers
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SafeCallApp(),
    ),
  );
}

/// Root widget of the SafeCall application.
class SafeCallApp extends ConsumerStatefulWidget {
  const SafeCallApp({super.key});

  @override
  ConsumerState<SafeCallApp> createState() => _SafeCallAppState();
}

class _SafeCallAppState extends ConsumerState<SafeCallApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh state when app comes to foreground
      // e.g. permission status may have changed
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the database
      await ref.read(databaseProvider).database;

      // Initialize native bridge
      ref.read(nativeBridgeProvider);

      // Restore active session if app was killed
      final strangerModeService = ref.read(strangerModeServiceProvider);
      await strangerModeService.restoreActiveSession();
    } catch (e) {
      debugPrint('SafeCall initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SafeCall',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router
      routerConfig: router,

      // Localization (basic)
      locale: const Locale('en', 'IN'),
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('hi', 'IN'),
      ],
    );
  }
}
