import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';

/// Session history list screen.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<StrangerModeSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final repo = ref.read(sessionRepositoryProvider);
    final sessions = await repo.getAllSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will delete all session records. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear',
                style: TextStyle(color: AppColors.warningRed)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.clearHistory();
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Session History'),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _emptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) =>
                      _SessionCard(session: _sessions[index]),
                ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activate Stranger Mode to start recording sessions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final StrangerModeSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy – hh:mm a');
    final startDate = DateTime.fromMillisecondsSinceEpoch(session.startTime);

    final durationMs = session.actualDurationMs ??
        (session.endTime != null
            ? session.endTime! - session.startTime
            : DateTime.now().millisecondsSinceEpoch - session.startTime);
    final durationMins = (durationMs / 60000).round();

    final reasonText = switch (session.endReason) {
      SessionEndReason.userRequested => 'Ended by user',
      SessionEndReason.timerExpired => 'Timer expired',
      SessionEndReason.criticalThreat => 'Critical threat',
      SessionEndReason.callEnded => 'Call ended',
      SessionEndReason.error => 'Error',
      null => session.isActive ? 'Active' : 'Unknown',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & status
            Row(
              children: [
                Icon(
                  session.isActive ? Icons.circle : Icons.history,
                  size: 12,
                  color: session.isActive
                      ? AppColors.safetyGreen
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(startDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Stats row
            Row(
              children: [
                _stat(context, Icons.timer, '$durationMins min'),
                const SizedBox(width: 24),
                _stat(context, Icons.warning_amber,
                    '${session.threatsDetected} threats'),
                const SizedBox(width: 24),
                _stat(context, Icons.info_outline, reasonText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _stat(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}
