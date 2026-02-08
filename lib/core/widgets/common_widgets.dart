import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable hold-to-activate button with circular progress indicator.
class ActivationButton extends StatefulWidget {
  final String text;
  final bool enabled;
  final VoidCallback onActivated;
  final int holdDurationMs;

  const ActivationButton({
    super.key,
    required this.text,
    this.enabled = true,
    required this.onActivated,
    this.holdDurationMs = 3000,
  });

  @override
  State<ActivationButton> createState() => _ActivationButtonState();
}

class _ActivationButtonState extends State<ActivationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.holdDurationMs),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onActivated();
        _controller.reset();
        setState(() => _isHolding = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (!widget.enabled) return;
    setState(() => _isHolding = true);
    _controller.forward();
  }

  void _onPointerUp() {
    if (!_isHolding) return;
    _controller.reset();
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onPointerDown(),
      onLongPressEnd: (_) => _onPointerUp(),
      onLongPressCancel: _onPointerUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.enabled
                        ? (_isHolding
                            ? AppColors.safetyGreen.withValues(alpha: 0.3)
                            : AppColors.trustBlue.withValues(alpha: 0.1))
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.enabled
                          ? (_isHolding
                              ? AppColors.safetyGreen
                              : AppColors.trustBlue)
                          : Colors.grey,
                    ),
                  ),
                ),
                // Inner button
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.enabled
                          ? (_isHolding
                              ? [AppColors.safetyGreen, AppColors.safetyGreenDark]
                              : [AppColors.trustBlue, AppColors.trustBlueDark])
                          : [Colors.grey, Colors.grey.shade700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.enabled
                                ? (_isHolding
                                    ? AppColors.safetyGreen
                                    : AppColors.trustBlue)
                                : Colors.grey)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isHolding ? Icons.shield : Icons.security,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Animated builder that doesn't require a child.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}

/// Feature card with icon and description.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

/// Status chip badge.
class StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const StatusChip({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Timer display showing remaining minutes and seconds.
class TimerDisplay extends StatelessWidget {
  final int remainingTimeMs;

  const TimerDisplay({super.key, required this.remainingTimeMs});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (remainingTimeMs / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Threat alert card displayed during active Stranger Mode.
class ThreatAlertCard extends StatelessWidget {
  final String detectedPhrase;
  final String levelText;
  final Color levelColor;
  final VoidCallback onDismiss;
  final VoidCallback onEndCall;

  const ThreatAlertCard({
    super.key,
    required this.detectedPhrase,
    required this.levelText,
    required this.levelColor,
    required this.onDismiss,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: levelColor.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: levelColor),
                const SizedBox(width: 8),
                Text(
                  levelText,
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Suspicious phrase detected:',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              '"$detectedPhrase"',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Do NOT share any codes, OTPs, or passwords!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text("I'm Safe"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEndCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('End Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings row with icon, title, subtitle, and optional trailing widget.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
