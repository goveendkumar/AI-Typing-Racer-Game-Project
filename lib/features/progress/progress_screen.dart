import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../models/meditation_session.dart';
import '../../models/session_history.dart';
import '../../shared/widgets/reusable_widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historyList = ref.watch(historyNotifierProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    final completedHistory = historyList.where((h) => h.status == SessionStatus.completed).toList();

    // Calculations
    final totalCompletedSessions = completedHistory.length;
    final totalSeconds = completedHistory.fold<int>(0, (sum, item) => sum + item.actualDurationSeconds);
    final totalMinutes = (totalSeconds / 60).round();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sessionsToday = completedHistory.where((h) {
      final date = DateTime.tryParse(h.completedAt)?.toLocal();
      return date != null && date.isAfter(todayStart);
    }).length;

    // 7-day activity map
    final weekDays = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final dailyMinutesMap = <DateTime, int>{};
    for (final day in weekDays) {
      dailyMinutesMap[day] = 0;
    }

    int weeklyTotalSeconds = 0;
    for (final h in completedHistory) {
      final date = DateTime.tryParse(h.completedAt)?.toLocal();
      if (date != null) {
        final dayOnly = DateTime(date.year, date.month, date.day);
        if (dailyMinutesMap.containsKey(dayOnly)) {
          dailyMinutesMap[dayOnly] = (dailyMinutesMap[dayOnly] ?? 0) + h.actualDurationSeconds;
          weeklyTotalSeconds += h.actualDurationSeconds;
        }
      }
    }
    final weeklyMinutes = (weeklyTotalSeconds / 60).round();

    final maxDailySeconds = dailyMinutesMap.values.fold<int>(0, (max, v) => v > max ? v : max);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Total Time',
                      value: '$totalMinutes',
                      unit: 'mins',
                      icon: Icons.timer,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Completed',
                      value: '$totalCompletedSessions',
                      unit: 'sessions',
                      icon: Icons.check_circle_outline,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Today',
                      value: '$sessionsToday',
                      unit: 'sessions',
                      icon: Icons.today,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'This Week',
                      value: '$weeklyMinutes',
                      unit: 'mins',
                      icon: Icons.date_range,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 7-Day Visual Activity Bar Chart
              const SectionHeader(
                title: 'Last 7 Days',
                subtitle: 'Minutes spent in practice',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E463A) : AppColors.lightSage,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekDays.map((day) {
                    final seconds = dailyMinutesMap[day] ?? 0;
                    final mins = (seconds / 60).round();
                    final heightFactor = maxDailySeconds > 0 ? (seconds / maxDailySeconds).clamp(0.1, 1.0) : 0.1;
                    final dayLabel = DateFormat('E').format(day).substring(0, 1);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$mins',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 22,
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            color: mins > 0 ? AppColors.primarySage : (isDark ? const Color(0xFF2E463A) : AppColors.lightSage),
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Activity History Log
              const SectionHeader(
                title: 'Activity History',
                subtitle: 'Recent session logs',
              ),
              const SizedBox(height: 8),
              if (completedHistory.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.history,
                  title: 'No activity yet',
                  message: 'Complete your first meditation session or breathing exercise to see your history here.',
                )
              else
                sessionsAsync.when(
                  data: (sessions) {
                    final sortedHistory = List<SessionHistory>.from(completedHistory)
                      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

                    return Column(
                      children: sortedHistory.map((h) {
                        final session = sessions.firstWhere(
                          (s) => s.id == h.sessionId,
                          orElse: () => MeditationSession(
                            id: h.sessionId,
                            categoryId: 'cat_mindfulness',
                            title: h.sessionType == SessionType.breathingExercise
                                ? 'Mindful Breathing'
                                : 'Guided Session',
                            description: '',
                            durationSeconds: h.actualDurationSeconds,
                            audioSource: '',
                            artworkPath: '',
                            transcript: '',
                          ),
                        );

                        final date = DateTime.tryParse(h.completedAt)?.toLocal();
                        final formattedDate = date != null ? DateFormat('MMM d, h:mm a').format(date) : '';
                        final durationMins = (h.actualDurationSeconds / 60).round();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primarySage.withValues(alpha: 0.2),
                              child: Icon(
                                h.sessionType == SessionType.breathingExercise
                                    ? Icons.air
                                    : Icons.self_improvement,
                                color: AppColors.deepForest,
                              ),
                            ),
                            title: Text(
                              session.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedDate),
                            trailing: Text(
                              '$durationMins min',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.primarySage,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E463A) : AppColors.lightSage,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primarySage),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
