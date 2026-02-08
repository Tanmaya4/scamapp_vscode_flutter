import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

/// Data class representing a single onboarding page.
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}

const _pages = [
  _OnboardingPage(
    icon: Icons.shield,
    title: 'Welcome to Safe Call',
    description:
        'Every day, 7,000 Indians fall victim to phone scams. '
        'Safe Call protects you when lending your phone to strangers.',
    backgroundColor: AppColors.trustBlue,
  ),
  _OnboardingPage(
    icon: Icons.lock,
    title: 'Lock Your Phone',
    description:
        'Stranger Mode locks your phone to calling-only interface. '
        'No access to messages, apps, or settings.',
    backgroundColor: AppColors.safetyGreen,
  ),
  _OnboardingPage(
    icon: Icons.notifications_off,
    title: 'Block OTP Notifications',
    description:
        'SMS, WhatsApp, and email codes will be hidden. '
        "Scammers can't see your OTPs.",
    backgroundColor: AppColors.alertOrange,
  ),
  _OnboardingPage(
    icon: Icons.hearing,
    title: 'Listen & Alert',
    description:
        "We monitor calls for suspicious phrases like 'OTP', 'code', 'verify' "
        'and alert you instantly.',
    backgroundColor: AppColors.trustBlueDark,
  ),
  _OnboardingPage(
    icon: Icons.fingerprint,
    title: 'Your Phone, Your Control',
    description:
        'Only you can unlock your phone with fingerprint or PIN. '
        'Your data stays on your device. Always.',
    backgroundColor: AppColors.safetyGreenDark,
  ),
];

/// 5-page onboarding screen shown on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    // Mark onboarding complete and navigate to home
    // In a real app, persist this via UserPreferencesRepository
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              page.backgroundColor,
              page.backgroundColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        )
                      : const SizedBox(height: 48),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon circle
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Icon(p.icon, size: 64, color: Colors.white),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            p.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom section – indicators + button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final selected = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 12 : 8,
                          height: selected ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _currentPage == _pages.length - 1
                            ? _onGetStarted
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
