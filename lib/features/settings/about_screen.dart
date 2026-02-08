import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// About screen with app info, privacy, and trust messaging.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // App icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.trustBlue, AppColors.trustBlueDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),

            Text(
              'Safe Call',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'सुरक्षित कॉल',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Phone, Your Control\nAapka Phone, Aapka Niyantran',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 32),

            // Privacy first card
            _InfoCard(
              icon: Icons.lock,
              iconColor: AppColors.safetyGreen,
              title: 'Privacy First',
              items: const [
                'All processing happens on your device',
                'Your call audio never leaves your phone',
                'We cannot and do not listen to your calls',
                'No hidden data collection',
              ],
            ),
            const SizedBox(height: 12),

            // Made for India card
            _InfoCard(
              icon: Icons.flag,
              iconColor: AppColors.trustBlue,
              title: 'Made for India',
              items: const [
                'Designed for Indian scam patterns',
                'Hindi and English language support',
                'Compliant with Indian data protection laws (DPDP 2023)',
                'Integrated with cybercrime.gov.in',
              ],
            ),
            const SizedBox(height: 12),

            // Government aligned card
            _InfoCard(
              icon: Icons.verified,
              iconColor: AppColors.alertOrange,
              title: 'Government Aligned',
              items: const [
                'In line with MHA cybercrime guidelines',
                'One-tap access to Helpline 1930',
                'Report scams to cybercrime.gov.in',
              ],
            ),
            const SizedBox(height: 32),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(label: 'Daily Scams\nin India', value: '7,000+'),
                _Stat(label: 'Losses in\n4 months', value: '₹1,750Cr'),
                _Stat(label: 'Protection\nFeatures', value: '8+'),
              ],
            ),
            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2026 Safe Call. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
