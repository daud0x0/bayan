import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../reflections/views/reflection_note_sheet.dart';
import '../../share_cards/views/share_card_sheet.dart';

/// Full-text search across offline Quran and Hadith libraries with match highlighting and quick actions.
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

  static const List<String> _suggestedTopics = [
    'Mercy',
    'Patience',
    'Prayer',
    'Forgiveness',
    'Gratitude',
    'Hardship',
    'Paradise',
    'Charity',
  ];

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

  void _onSelectTopicChip(String topic) {
    _queryController.text = topic;
    _performSearch(topic);
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
    final scope = AppScope.of(context);

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
              tooltip: 'Clear search',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterType == null,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) {
                    setState(() => _filterType = null);
                    _performSearch(_queryController.text);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Quran'),
                  selected: _filterType == ContentType.quran,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) {
                    setState(() => _filterType = ContentType.quran);
                    _performSearch(_queryController.text);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Hadith'),
                  selected: _filterType == ContentType.hadith,
                  visualDensity: VisualDensity.compact,
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

          // Suggested Topic Quick Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedTopics.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final topic = _suggestedTopics[index];
                final isSelected = queryText.toLowerCase() == topic.toLowerCase();
                return ActionChip(
                  label: Text(topic, style: const TextStyle(fontSize: 11.5)),
                  avatar: const Icon(Icons.auto_awesome, size: 13, color: Color(0xFFC5A059)),
                  backgroundColor: isSelected
                      ? const Color(0xFFC5A059).withValues(alpha: 0.20)
                      : null,
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFC5A059)
                        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () => _onSelectTopicChip(topic),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),

          // Results List
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
                            const SizedBox(height: 6),
                            Text(
                              'Try searching for core topics like Mercy, Patience, or Prayer.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
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

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onSelectContentItem(item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header: Badge + Reference + Actions
                                  Row(
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
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, size: 17),
                                        tooltip: 'Copy',
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (scope.preferences.hapticFeedbackEnabled) {
                                            HapticFeedback.lightImpact();
                                          }
                                          Clipboard.setData(ClipboardData(
                                            text: '${item.arabicText.isNotEmpty ? '${item.arabicText}\n\n' : ''}${item.englishTranslation}\n— ${item.reference}',
                                          ));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Copied ${item.reference}'),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share_outlined, size: 17),
                                        tooltip: 'Share Card',
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (scope.preferences.hapticFeedbackEnabled) {
                                            HapticFeedback.lightImpact();
                                          }
                                          ShareCardSheet.show(context, item);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          scope.hasReflection(item.id)
                                              ? Icons.note_alt_rounded
                                              : Icons.edit_note_rounded,
                                          size: 18,
                                          color: scope.hasReflection(item.id)
                                              ? const Color(0xFFC5A059)
                                              : null,
                                        ),
                                        tooltip: scope.hasReflection(item.id)
                                            ? 'Edit Tadabbur Reflection'
                                            : 'Tadabbur Reflection',
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (scope.preferences.hapticFeedbackEnabled) {
                                            HapticFeedback.lightImpact();
                                          }
                                          ReflectionNoteSheet.show(
                                            context,
                                            contentId: item.id,
                                            contentType: item.contentType,
                                            reference: item.reference,
                                            arabicExcerpt: item.arabicText,
                                            translationExcerpt: item.englishTranslation,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.arabicText.isNotEmpty) ...[
                                    _buildHighlightedArabicText(
                                      text: item.arabicText,
                                      query: queryText,
                                      baseStyle: arabicBase,
                                      highlightStyle: arabicHighlight,
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  _buildHighlightedText(
                                    text: item.englishTranslation,
                                    query: queryText,
                                    baseStyle: enBase,
                                    highlightStyle: enHighlight,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
