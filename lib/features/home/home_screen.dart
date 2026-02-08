import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../navigation/app_router.dart';
import '../../providers/providers.dart';
import '../../core/models/models.dart';

/// Home screen showing protection status and activation button.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  UserSettings _settings = const UserSettings();
  StrangerModeState _modeState = StrangerModeState.inactive;
  bool _arePermissionsGranted = true; // simplified for now

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _listenToStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = ref.read(userPreferencesProvider);
    final settings = await prefs.getUserSettings();
    if (mounted) setState(() => _settings = settings);
  }

  void _listenToStatus() {
    final service = ref.read(strangerModeServiceProvider);
    service.statusStream.listen((status) {
      if (mounted) setState(() => _modeState = status.state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Safe Call', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status card
            _StatusCard(
              state: _modeState,
              arePermissionsGranted: _arePermissionsGranted,
            ),
            const SizedBox(height: 32),

            // Label
            Text(
              'Tap & Hold to Activate',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Activation button
            ActivationButton(
              text: 'Stranger\nMode',
              enabled: _arePermissionsGranted &&
                  _modeState == StrangerModeState.inactive,
              onActivated: () => context.push(AppRoutes.strangerMode),
            ),
            const SizedBox(height: 16),

            Text(
              'Duration: ${_settings.defaultDurationMinutes} minutes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Feature cards
            const FeatureCard(
              icon: Icons.notifications_off,
              title: 'OTP Protection',
              description: 'Block OTP notifications from SMS, WhatsApp & Email',
            ),
            const SizedBox(height: 8),
            const FeatureCard(
              icon: Icons.hearing,
              title: 'Threat Detection',
              description: 'Monitor calls for suspicious scam phrases',
            ),
            const SizedBox(height: 8),
            const FeatureCard(
              icon: Icons.fingerprint,
              title: 'Biometric Lock',
              description: 'Only you can exit Stranger Mode',
            ),
            const SizedBox(height: 16),

            // History button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.history),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View Session History'),
              ),
            ),
            const SizedBox(height: 24),

            // Privacy notice
            Card(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: AppColors.safetyGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All processing happens on your device. '
                        'Your call audio never leaves your phone.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Permission warning
            if (!_arePermissionsGranted) _PermissionWarningBanner(),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final StrangerModeState state;
  final bool arePermissionsGranted;

  const _StatusCard({required this.state, required this.arePermissionsGranted});

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = switch ((arePermissionsGranted, state)) {
      (false, _) => ('Setup Required', AppColors.alertOrange),
      (_, StrangerModeState.active) => ('Active', AppColors.safetyGreen),
      (_, StrangerModeState.threatDetected) =>
        ('Threat Detected', AppColors.warningRed),
      _ => ('Ready', AppColors.trustBlue),
    };

    final statusIcon = switch (state) {
      StrangerModeState.active => Icons.shield,
      StrangerModeState.threatDetected => Icons.warning,
      _ => Icons.security,
    };

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protection Status',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                ],
              ),
            ),
            StatusChip(
              text: arePermissionsGranted ? 'Enabled' : 'Setup',
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionWarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.alertOrange,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permissions Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Grant permissions in Settings to enable protection',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
