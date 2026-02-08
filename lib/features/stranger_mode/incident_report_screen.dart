import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Incident report screen – report scam to cybercrime portal / helpline.
class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  bool _submitted = false;

  Future<void> _openCybercrimePortal() async {
    final uri = Uri.parse(AppConstants.cybercrimePortalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callHelpline() async {
    final uri = Uri(scheme: 'tel', path: AppConstants.helplineNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _submitReport() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildConfirmation() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Icon(Icons.report_problem, color: AppColors.warningRed, size: 48),
        const SizedBox(height: 16),
        Text(
          'Report a Scam Attempt',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'If you suspect this was a scam, report it immediately to help protect others.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),

        // Quick actions
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.warningRed),
                title: const Text('Call Cybercrime Helpline'),
                subtitle: const Text('Dial 1930 for immediate help'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _callHelpline,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.trustBlue),
                title: const Text('Visit Cybercrime Portal'),
                subtitle: const Text('cybercrime.gov.in'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openCybercrimePortal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Report',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),

        // Privacy note
        Row(
          children: [
            const Icon(Icons.lock, size: 14, color: AppColors.safetyGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your report is anonymous. No personal data is shared.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        const Icon(Icons.check_circle, color: AppColors.safetyGreen, size: 80),
        const SizedBox(height: 24),
        Text(
          'Report Submitted',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for helping make India safer.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Return to Home'),
          ),
        ),
      ],
    );
  }
}
