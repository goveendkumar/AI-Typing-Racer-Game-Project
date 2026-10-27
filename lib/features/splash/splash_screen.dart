import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onInitialized;

  const SplashScreen({
    super.key,
    required this.onInitialized,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await ref.read(settingsNotifierProvider.notifier).loadSettings();
      await ref.read(favoritesNotifierProvider.notifier).loadFavorites();
      await ref.read(historyNotifierProvider.notifier).loadHistory();

      if (mounted) {
        widget.onInitialized();
      }
    } catch (e) {
      if (mounted) {
        widget.onInitialized();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.softCream,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa,
                  size: 56,
                  color: AppColors.deepForest,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Find Your Calm',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.mainTextDark
                      : AppColors.mainTextLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mindfulness & Simple Meditation',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.secondaryTextDark
                      : AppColors.secondaryTextLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
