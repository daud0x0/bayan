import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';

/// Full-text search across offline Quran and Hadith libraries with match highlighting.
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

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    int maxLines = 2,
  }) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || text.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        textDirection: textDirection,
        style: baseStyle,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + trimmedQuery.length),
        style: highlightStyle,
      ));
      start = index + trimmedQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }

  Widget _buildHighlightedArabicText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    int maxLines = 2,
  }) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || text.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    // Check if exact substring exists in text
    if (text.contains(trimmedQuery)) {
      return _buildHighlightedText(
        text: text,
        query: trimmedQuery,
        baseStyle: baseStyle,
        highlightStyle: highlightStyle,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
      );
    }

    // Check normalized word-by-word matching for diacritic variance
    final normalizedQuery = ArabicUtils.normalizeForSearch(trimmedQuery);
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final words = text.split(' ');
    final spans = <InlineSpan>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final isMatch = ArabicUtils.containsNormalized(word, trimmedQuery);
      spans.add(TextSpan(
        text: word,
        style: isMatch ? highlightStyle : baseStyle,
      ));
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _queryController.text;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                const Spacer(),
                if (!_isSearching && queryText.trim().isNotEmpty)
                  Text(
                    '${_results.length} found',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.outline,
                    ),
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

                          final arabicBase = AppTypography.arabic(fontSize: 17);
                          final arabicHighlight = arabicBase.copyWith(
                            backgroundColor: primaryColor.withValues(alpha: 0.18),
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          );

                          final enBase = const TextStyle(fontSize: 13);
                          final enHighlight = enBase.copyWith(
                            backgroundColor: primaryColor.withValues(alpha: 0.18),
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          );

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.contentType.displayName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
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
                                    _buildHighlightedArabicText(
                                      text: item.arabicText,
                                      query: queryText,
                                      baseStyle: arabicBase,
                                      highlightStyle: arabicHighlight,
                                    ),
                                  const SizedBox(height: 4),
                                  _buildHighlightedText(
                                    text: item.englishTranslation,
                                    query: queryText,
                                    baseStyle: enBase,
                                    highlightStyle: enHighlight,
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
