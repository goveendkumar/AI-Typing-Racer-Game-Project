import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../models/meditation_session.dart';
import '../../shared/widgets/reusable_widgets.dart';

class HomeScreen extends ConsumerWidget {
  final Function(MeditationSession session) onSelectSession;
  final VoidCallback onStartBreathing;
  final Function(String categoryId) onSelectCategory;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.onSelectSession,
    required this.onStartBreathing,
    required this.onSelectCategory,
    required this.onOpenSettings,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final favorites = ref.watch(favoritesNotifierProvider);
    final history = ref.watch(historyNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Take a moment for yourself.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: onOpenSettings,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daily Featured Meditation Card
              sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) return const SizedBox.shrink();
                  // Predictable daily featured session based on day of year
                  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
                  final featuredSession = sessions[dayOfYear % sessions.length];
                  final isFav = favorites.contains(featuredSession.id);

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.deepForest, AppColors.darkSurface]
                            : [AppColors.primarySage, AppColors.deepForest],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DAILY MEDITATION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : Colors.white,
                              ),
                              onPressed: () {
                                ref.read(favoritesNotifierProvider.notifier).toggleFavorite(featuredSession.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          featuredSession.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          featuredSession.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${(featuredSession.durationSeconds / 60).round()} mins',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.deepForest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              onPressed: () => onSelectSession(featuredSession),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Quick Breathing Exercise Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primarySage.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.air, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take a Breathing Break',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1 to 10 min calm breathwork',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: onStartBreathing,
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Browse Categories
              const SectionHeader(
                title: 'Browse Categories',
                subtitle: 'Find guided exercises for your mood',
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) {
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return GestureDetector(
                          onTap: () => onSelectCategory(cat.id),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.spa_outlined,
                                  color: AppColors.primarySage,
                                ),
                                Text(
                                  cat.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Continue Listening (History)
              if (history.isNotEmpty) ...[
                const SectionHeader(
                  title: 'Continue Listening',
                  subtitle: 'Pick up where you left off',
                ),
                const SizedBox(height: 8),
                sessionsAsync.when(
                  data: (sessions) {
                    final recentHistories = history.take(3).toList();
                    return Column(
                      children: recentHistories.map((h) {
                        final session = sessions.firstWhere(
                          (s) => s.id == h.sessionId,
                          orElse: () => sessions.first,
                        );
                        final categoryName = categoriesAsync.asData?.value
                                .firstWhere(
                                  (c) => c.id == session.categoryId,
                                  orElse: () => categoriesAsync.asData!.value.first,
                                )
                                .name ??
                            'Meditation';
                        final isFav = favorites.contains(session.id);

                        return SessionCard(
                          session: session,
                          categoryName: categoryName,
                          isFavorite: isFav,
                          onTap: () => onSelectSession(session),
                          onFavoriteToggle: () {
                            ref.read(favoritesNotifierProvider.notifier).toggleFavorite(session.id);
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
