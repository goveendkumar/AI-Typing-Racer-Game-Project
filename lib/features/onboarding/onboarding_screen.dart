import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../shared/widgets/reusable_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onOnboardingCompleted;

  const OnboardingScreen({
    super.key,
    required this.onOnboardingCompleted,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedDurationMinutes = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final currentSettings = ref.read(settingsNotifierProvider);
    final updatedSettings = currentSettings.copyWith(
      onboardingCompleted: true,
      defaultDurationMinutes: _selectedDurationMinutes,
    );
    await ref.read(settingsNotifierProvider.notifier).updateSettings(updatedSettings);
    widget.onOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentPage < 2)
            TextButton(
              onPressed: _finishOnboarding,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(context, isDark),
                  _buildMeditationIntroPage(context, isDark),
                  _buildPreferencePage(context, isDark),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primarySage
                              : (isDark ? AppColors.secondaryTextDark : AppColors.lightSage),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: CalmButton(
                            text: 'Back',
                            isSecondary: true,
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: CalmButton(
                          text: _currentPage == 2 ? 'Get Started' : 'Next',
                          onPressed: () {
                            if (_currentPage < 2) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _finishOnboarding();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primarySage.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 64,
              color: AppColors.deepForest,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Find a Moment of Calm',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Make a little space for yourself, one breath at a time.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationIntroPage(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primarySage.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 64,
              color: AppColors.deepForest,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Start Where You Are',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Meditation can begin with just a few minutes. You don’t need any previous experience to practice mindfulness.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencePage(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final durations = [3, 5, 10];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Preferred Session Length',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'How much time would you like to dedicate to your daily session?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: durations.map((duration) {
              final isSelected = _selectedDurationMinutes == duration;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDurationMinutes = duration;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.primarySage.withValues(alpha: 0.3) : AppColors.lightSage)
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primarySage : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.deepForest : AppColors.secondaryTextLight,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$duration minutes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
