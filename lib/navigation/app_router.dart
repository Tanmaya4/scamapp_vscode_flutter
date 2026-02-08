import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/history_screen.dart';
import '../features/settings/permissions_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stranger_mode/incident_report_screen.dart';
import '../features/stranger_mode/stranger_mode_screen.dart';

/// SafeCall app routes.
abstract class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String strangerMode = '/stranger-mode';
  static const String settings = '/settings';
  static const String permissions = '/settings/permissions';
  static const String history = '/settings/history';
  static const String about = '/settings/about';
  static const String incidentReport = '/incident-report';
}

/// GoRouter configuration for SafeCall.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.strangerMode,
      name: 'stranger_mode',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const StrangerModeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      name: 'permissions',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const PermissionsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const HistoryScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.about,
      name: 'about',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const AboutScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.incidentReport,
      name: 'incident_report',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const IncidentReportScreen(),
      ),
    ),
  ],
);

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
