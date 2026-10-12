import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/use_cases/feed_algorithm.dart';
import '../../categories/category_explorer_sheet.dart';
import '../../search/views/search_view.dart';
import 'discovery_card.dart';

/// Discover screen providing a calm, personalized feed of Quran & Hadith teachings.
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
                        itemCount: rankedItems.length,
                        itemBuilder: (context, index) {
                          final item = rankedItems[index];
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: currentFilter == null,
            onSelected: (_) {
              scope.updatePreferences(scope.preferences.copyWith(
                contentTypeFilter: () => null,
              ));
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
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
            label: const Text('Hadith'),
            selected: currentFilter == ContentType.hadith,
            onSelected: (_) {
              scope.updatePreferences(scope.preferences.copyWith(
                contentTypeFilter: () => ContentType.hadith,
              ));
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Topics'),
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
}
