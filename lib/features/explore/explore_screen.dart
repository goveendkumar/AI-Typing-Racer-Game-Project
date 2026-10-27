import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../models/category.dart';
import '../../models/meditation_session.dart';
import '../../shared/widgets/reusable_widgets.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final Function(MeditationSession session) onSelectSession;
  final VoidCallback onStartBreathing;
  final String? initialCategoryId;

  const ExploreScreen({
    super.key,
    required this.onSelectSession,
    required this.onStartBreathing,
    this.initialCategoryId,
  });

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _durationFilter = 'all'; // 'all', 'under5', '5to10', 'over10'
  bool _showFavoritesOnly = false;
  String _sortBy = 'title'; // 'title', 'duration'

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Library'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filters Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search sessions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E463A) : AppColors.lightSage,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E463A) : AppColors.lightSage,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Duration & Favorite Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Favorites Only'),
                          selected: _showFavoritesOnly,
                          onSelected: (selected) {
                            setState(() {
                              _showFavoritesOnly = selected;
                            });
                          },
                          avatar: Icon(
                            _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: _showFavoritesOnly ? Colors.redAccent : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('All Durations'),
                          selected: _durationFilter == 'all',
                          onSelected: (selected) {
                            if (selected) setState(() => _durationFilter = 'all');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('< 5 mins'),
                          selected: _durationFilter == 'under5',
                          onSelected: (selected) {
                            if (selected) setState(() => _durationFilter = 'under5');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('5-10 mins'),
                          selected: _durationFilter == '5to10',
                          onSelected: (selected) {
                            if (selected) setState(() => _durationFilter = '5to10');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('> 10 mins'),
                          selected: _durationFilter == 'over10',
                          onSelected: (selected) {
                            if (selected) setState(() => _durationFilter = 'over10');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Category Selector Chips
                  categoriesAsync.when(
                    data: (categories) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('All Categories'),
                              selected: _selectedCategoryId == null,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedCategoryId = null);
                              },
                            ),
                            const SizedBox(width: 8),
                            ...categories.map((cat) {
                              final isSelected = _selectedCategoryId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategoryId = selected ? cat.id : null;
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sessions List & Sort Control
            Expanded(
              child: sessionsAsync.when(
                data: (allSessions) {
                  final categoriesMap = {
                    for (var cat in (categoriesAsync.asData?.value ?? <Category>[])) cat.id: cat.name
                  };

                  // Filter logic
                  var filtered = allSessions.where((session) {
                    if (_searchQuery.isNotEmpty) {
                      final matchTitle = session.title.toLowerCase().contains(_searchQuery.toLowerCase());
                      final matchDesc = session.description.toLowerCase().contains(_searchQuery.toLowerCase());
                      if (!matchTitle && !matchDesc) return false;
                    }
                    if (_selectedCategoryId != null && session.categoryId != _selectedCategoryId) {
                      return false;
                    }
                    if (_showFavoritesOnly && !favorites.contains(session.id)) {
                      return false;
                    }
                    final mins = session.durationSeconds / 60;
                    if (_durationFilter == 'under5' && mins >= 5) return false;
                    if (_durationFilter == '5to10' && (mins < 5 || mins > 10)) return false;
                    if (_durationFilter == 'over10' && mins <= 10) return false;

                    return true;
                  }).toList();

                  // Sort logic
                  if (_sortBy == 'title') {
                    filtered.sort((a, b) => a.title.compareTo(b.title));
                  } else {
                    filtered.sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
                  }

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No sessions found',
                      message: 'Try adjusting your search or filters to find a calm moment.',
                      actionText: 'Reset Filters',
                      onAction: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                          _selectedCategoryId = null;
                          _durationFilter = 'all';
                          _showFavoritesOnly = false;
                        });
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${filtered.length} ${filtered.length == 1 ? 'session' : 'sessions'} available',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: _sortBy,
                                icon: const Icon(Icons.sort, size: 20),
                                onSelected: (value) {
                                  setState(() {
                                    _sortBy = value;
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'title',
                                    child: Text('Sort by Title'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'duration',
                                    child: Text('Sort by Duration'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      final session = filtered[index - 1];
                      final catName = categoriesMap[session.categoryId] ?? 'Meditation';
                      final isFav = favorites.contains(session.id);

                      return SessionCard(
                        session: session,
                        categoryName: catName,
                        isFavorite: isFav,
                        onTap: () => widget.onSelectSession(session),
                        onFavoriteToggle: () {
                          ref.read(favoritesNotifierProvider.notifier).toggleFavorite(session.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load sessions',
                  message: 'Please try restarting the application.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
