import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/meditation_session.dart';
import '../../shared/widgets/reusable_widgets.dart';

class CompletionScreen extends StatelessWidget {
  final MeditationSession? session;
  final String title;
  final int durationSeconds;
  final VoidCallback onReturnHome;

  const CompletionScreen({
    super.key,
    this.session,
    required this.title,
    required this.durationSeconds,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final minutes = (durationSeconds / 60).floor();
    final seconds = durationSeconds % 60;
    final durationString = minutes > 0 ? '$minutes min ${seconds > 0 ? "$seconds sec" : ""}' : '$seconds seconds';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.deepForest,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'You made time for yourself.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Completed: $title',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primarySage,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: $durationString',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CalmButton(
                text: 'Return Home',
                onPressed: onReturnHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
