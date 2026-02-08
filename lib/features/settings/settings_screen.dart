import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../core/models/models.dart';
import '../../core/widgets/common_widgets.dart';
import '../../navigation/app_router.dart';
import '../../providers/providers.dart';

/// Settings screen with all app configuration options.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  UserSettings _settings = const UserSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = ref.read(userPreferencesProvider);
    final settings = await prefs.getUserSettings();
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _setDuration(int minutes) async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.setDefaultDuration(minutes);
    await _loadSettings();
  }

  Future<void> _setThreatAction(ThreatAction action) async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.setThreatAction(action);
    await _loadSettings();
  }

  Future<void> _toggleAutoMode(bool enabled) async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.setAutoModeEnabled(enabled);
    await _loadSettings();
  }

  Future<void> _toggleHaptic(bool enabled) async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.setHapticFeedbackEnabled(enabled);
    await _loadSettings();
  }

  Future<void> _toggleAutoReport(bool enabled) async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.setAutoReportEnabled(enabled);
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ── General ──────────────────────────────────────────
          _SectionHeader('General'),
          SettingsRow(
            icon: Icons.timer,
            title: 'Default Duration',
            subtitle: '${_settings.defaultDurationMinutes} minutes',
            onTap: () => _showDurationDialog(),
          ),
          SettingsRow(
            icon: Icons.security,
            title: 'Threat Response',
            subtitle: _settings.threatAction.displayName,
            onTap: () => _showThreatActionDialog(),
          ),
          const Divider(indent: 16, endIndent: 16),

          // ── Features ─────────────────────────────────────────
          _SectionHeader('Features'),
          _SwitchRow(
            icon: Icons.auto_awesome,
            title: 'Auto Mode',
            subtitle: 'Automatically activate when call starts',
            value: _settings.autoModeEnabled,
            onChanged: _toggleAutoMode,
          ),
          _SwitchRow(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on threat detection',
            value: _settings.hapticFeedbackEnabled,
            onChanged: _toggleHaptic,
          ),
          _SwitchRow(
            icon: Icons.report,
            title: 'Auto Report',
            subtitle: 'Automatically report detected scams',
            value: _settings.autoReportEnabled,
            onChanged: _toggleAutoReport,
          ),
          const Divider(indent: 16, endIndent: 16),

          // ── App ──────────────────────────────────────────────
          _SectionHeader('App'),
          SettingsRow(
            icon: Icons.admin_panel_settings,
            title: 'Permissions',
            subtitle: 'Manage app permissions',
            onTap: () => context.push(AppRoutes.permissions),
          ),
          SettingsRow(
            icon: Icons.history,
            title: 'Session History',
            subtitle: 'View past sessions and threats',
            onTap: () => context.push(AppRoutes.history),
          ),
          SettingsRow(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App info and privacy policy',
            onTap: () => context.push(AppRoutes.about),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDurationDialog() {
    final durations = [5, 10, 15, 20, 30, 45, 60];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations
              .map((d) => RadioListTile<int>(
                    title: Text('$d minutes'),
                    value: d,
                    groupValue: _settings.defaultDurationMinutes,
                    onChanged: (v) {
                      if (v != null) _setDuration(v);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showThreatActionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Threat Response'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThreatAction.values
              .map((a) => RadioListTile<ThreatAction>(
                    title: Text(a.displayName),
                    subtitle: Text(a.description),
                    value: a,
                    groupValue: _settings.threatAction,
                    onChanged: (v) {
                      if (v != null) _setThreatAction(v);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
