import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';

/// Full-text search across offline Quran and Hadith libraries.
/// Complies with Section 10 of the Product Plan.
class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.onSelectContentItem});

  final ValueChanged<ContentItem> onSelectContentItem;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _queryController = TextEditingController();
  ContentType? _filterType;
  List<ContentItem> _results = [];
  bool _isSearching = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _performSearch('');
      _initialized = true;
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final scope = AppScope.of(context);
    final results = await scope.contentRepository.search(
      query,
      contentType: _filterType,
    );
    if (!mounted) return;
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Arabic, English, or reference...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_queryController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _queryController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterType == null,
                  onSelected: (_) {
                    setState(() => _filterType = null);
                    _performSearch(_queryController.text);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Quran'),
                  selected: _filterType == ContentType.quran,
                  onSelected: (_) {
                    setState(() => _filterType = ContentType.quran);
                    _performSearch(_queryController.text);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Hadith'),
                  selected: _filterType == ContentType.hadith,
                  onSelected: (_) {
                    setState(() => _filterType = ContentType.hadith);
                    _performSearch(_queryController.text);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 12),
                            const Text('No verses or narrations match your search.'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _results[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.contentType.displayName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.reference,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (item.arabicText.isNotEmpty)
                                    Text(
                                      item.arabicText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: AppTypography.arabic(fontSize: 17),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.englishTranslation,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onSelectContentItem(item);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
