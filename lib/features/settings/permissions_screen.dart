import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';

/// Permissions management screen.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<Permission, bool> _permissionStatus = {};

  final _requiredPermissions = [
    (Permission.phone, 'Phone State', 'To detect when a call starts/ends'),
    (Permission.microphone, 'Microphone',
        'To monitor call audio for suspicious phrases\n⚠️ Audio is processed ON YOUR DEVICE only'),
    (Permission.notification, 'Notifications',
        'To show security alerts and protection status'),
  ];

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    for (final (perm, _, _) in _requiredPermissions) {
      final status = await perm.isGranted;
      if (mounted) {
        setState(() => _permissionStatus[perm] = status);
      }
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    _refreshPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Permissions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _allGranted
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: _allGranted
                        ? AppColors.safetyGreen
                        : AppColors.alertOrange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _allGranted
                          ? 'All permissions granted'
                          : 'Some permissions are needed for full protection',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Permission items
          ..._requiredPermissions.map((entry) {
            final (perm, title, desc) = entry;
            final granted = _permissionStatus[perm] ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  granted ? Icons.check_circle : Icons.cancel,
                  color: granted ? AppColors.safetyGreen : AppColors.warningRed,
                ),
                title: Text(title),
                subtitle: Text(desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                trailing: granted
                    ? null
                    : TextButton(
                        onPressed: () => _requestPermission(perm),
                        child: const Text('Grant'),
                      ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Open settings
          OutlinedButton.icon(
            onPressed: () => openAppSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('Open App Settings'),
          ),

          const SizedBox(height: 16),

          // Privacy note
          Row(
            children: [
              const Icon(Icons.lock, size: 14, color: AppColors.safetyGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We only request permissions essential for scam protection. '
                  'Your data never leaves your device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _allGranted =>
      _permissionStatus.values.isNotEmpty &&
      _permissionStatus.values.every((v) => v);
}
