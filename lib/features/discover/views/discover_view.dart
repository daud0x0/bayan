import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/use_cases/feed_algorithm.dart';
import '../../categories/category_explorer_sheet.dart';
import '../../quran/views/quran_reader_view.dart';
import '../../search/views/search_view.dart';
import 'discovery_card.dart';

/// Discover screen providing an illuminated, calm, personalized feed of Quran & Hadith teachings.
/// Complies with Section 4.1 of the Product Plan.
class DiscoverView extends StatefulWidget {
  const DiscoverView({
    super.key,
    required this.onOpenContext,
  });

  final ValueChanged<ContentItem> onOpenContext;

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  String? _activeCategoryFilterId;

  Widget _buildHeroGreetingCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final scope = AppScope.of(context);
    final lastQuran = scope.lastQuranProgress;

    final gradColors = isDark
        ? [
            primary.withValues(alpha: 0.32),
            theme.colorScheme.surface,
          ]
        : [
            primary,
            Color.lerp(primary, Colors.black, 0.28)!,
          ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                  color: const Color(0xFFC5A059).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.40),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wb_sunny_outlined, size: 13, color: Color(0xFFE5C07B)),
                    SizedBox(width: 5),
                    Text(
                      'DAILY INSPIRATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFFE5C07B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Color(0xFFE5C07B),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Assalamu Alaikum',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome to Bayan — find peace, patience, and guidance in timeless verses and authentic traditions.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (lastQuran != null) ...[
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final surahNum = int.tryParse(lastQuran.targetId);
                if (surahNum != null) {
                  final surah = await scope.contentRepository.getSurah(surahNum);
                  if (surah != null && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderView(
                          surah: surah,
                          initialAyahNumber: lastQuran.itemNumber,
                        ),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, size: 16, color: Color(0xFFE5C07B)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Continue: ${lastQuran.title} (${lastQuran.subtitle})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              'Daily reflections and teachings',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Browse Categories',
            onPressed: () {
              CategoryExplorerSheet.show(
                context,
                onSelectCategory: (cat) {
                  setState(() => _activeCategoryFilterId = cat.id);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Library',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchView(onSelectContentItem: widget.onOpenContext),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<ContentItem>>(
        future: scope.contentRepository.getAllContentItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var allItems = snapshot.data!;

          // Filter by category chip if active
          if (_activeCategoryFilterId != null) {
            allItems = allItems
                .where((item) => item.categoryIds.contains(_activeCategoryFilterId))
                .toList();
          }

          final rankedItems = FeedAlgorithm.rankFeed(
            items: allItems,
            preferences: scope.preferences,
          );

          final showHero = _activeCategoryFilterId == null &&
              scope.preferences.contentTypeFilter == null;

          return Column(
            children: [
              // Filter Chips Carousel
              _buildFilterChips(scope),

              // Active category badge if filtered
              if (_activeCategoryFilterId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Filtered by: ',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                      ),
                      Chip(
                        label: Text(_activeCategoryFilterId!.replaceAll('_', ' ').toUpperCase()),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _activeCategoryFilterId = null),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

              // Discovery Card Feed
              Expanded(
                child: rankedItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off,
                                size: 48, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 12),
                            const Text('No teachings match current filters.'),
                            TextButton(
                              onPressed: () {
                                setState(() => _activeCategoryFilterId = null);
                                scope.updatePreferences(
                                  scope.preferences.copyWith(contentTypeFilter: () => null),
                                );
                              },
                              child: const Text('Reset filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: rankedItems.length + (showHero ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (showHero && index == 0) {
                            return _buildHeroGreetingCard(context);
                          }
                          final item = rankedItems[showHero ? index - 1 : index];
                          return DiscoveryCard(
                            key: ValueKey(item.id),
                            item: item,
                            onOpenContext: () => widget.onOpenContext(item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(AppScope scope) {
    final currentFilter = scope.preferences.contentTypeFilter;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: currentFilter == null && _activeCategoryFilterId == null,
            onSelected: (_) {
              setState(() => _activeCategoryFilterId = null);
              scope.updatePreferences(scope.preferences.copyWith(
                contentTypeFilter: () => null,
              ));
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(Icons.auto_stories_outlined, size: 15),
            label: const Text('Quran'),
            selected: currentFilter == ContentType.quran,
            onSelected: (_) {
              scope.updatePreferences(scope.preferences.copyWith(
                contentTypeFilter: () => ContentType.quran,
              ));
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(Icons.menu_book_outlined, size: 15),
            label: const Text('Hadith'),
            selected: currentFilter == ContentType.hadith,
            onSelected: (_) {
              scope.updatePreferences(scope.preferences.copyWith(
                contentTypeFilter: () => ContentType.hadith,
              ));
            },
          ),
          const SizedBox(width: 8),
          Container(
            height: 22,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          _buildTopicChip('hardship_and_hope', 'Hardship & Hope', Icons.healing_rounded),
          const SizedBox(width: 8),
          _buildTopicChip('patience', 'Patience (Sabr)', Icons.self_improvement_rounded),
          const SizedBox(width: 8),
          _buildTopicChip('gratitude', 'Gratitude (Shukr)', Icons.spa_rounded),
          const SizedBox(width: 8),
          _buildTopicChip('repentance_and_mercy', 'Repentance', Icons.favorite_rounded),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.grid_view_rounded, size: 15),
            label: const Text('All Topics'),
            onPressed: () {
              CategoryExplorerSheet.show(
                context,
                onSelectCategory: (cat) {
                  setState(() => _activeCategoryFilterId = cat.id);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String catId, String title, IconData icon) {
    final isSelected = _activeCategoryFilterId == catId;
    return FilterChip(
      avatar: Icon(icon, size: 15),
      label: Text(title),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _activeCategoryFilterId = isSelected ? null : catId;
        });
      },
    );
  }
}
