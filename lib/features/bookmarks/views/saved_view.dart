import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../hadith/views/hadith_reader_view.dart';
import '../../quran/views/quran_reader_view.dart';

/// Saved items screen managing bookmarks and reading positions.
/// Complies with Section 4.3 of the Product Plan with illuminated Islamic styling.
class SavedView extends StatefulWidget {
  const SavedView({super.key});

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {
  int _selectedSegment = 0; // 0: Bookmarks, 1: Reading History
  ContentType? _filterType;

  Future<void> _openBookmarkContext(BuildContext context, Bookmark bookmark, AppScope scope) async {
    if (bookmark.contentType == ContentType.quran) {
      // contentId is like "quran_1_5"
      final parts = bookmark.contentId.replaceFirst('quran_', '').split('_');
      final surahNum = int.tryParse(parts[0]) ?? 1;
      final ayahNum = parts.length > 1 ? int.tryParse(parts[1]) : 1;

      final surah = await scope.contentRepository.getSurah(surahNum);
      if (surah != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuranReaderView(surah: surah, initialAyahNumber: ayahNum),
          ),
        );
      }
    } else {
      // contentId is like "hadith_bukhari_1"
      final hadithId = bookmark.contentId.replaceFirst('hadith_', '');
      final hadith = await scope.contentRepository.getHadith(hadithId);
      if (hadith != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HadithReaderView(hadith: hadith),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scope = AppScope.of(context);
    final lastQuran = scope.lastQuranProgress;
    final lastHadith = scope.lastHadithProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Bookmark>>(
        future: scope.bookmarkRepository.getBookmarks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookmarks = snapshot.data!;
          final quranCount = allBookmarks.where((b) => b.contentType == ContentType.quran).length;
          final hadithCount = allBookmarks.where((b) => b.contentType == ContentType.hadith).length;

          var displayBookmarks = allBookmarks;
          if (_filterType != null) {
            displayBookmarks = displayBookmarks.where((b) => b.contentType == _filterType).toList();
          }

          return Column(
            children: [
              // Clean Segmented Navigation (Bookmarks vs History)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        icon: const Icon(Icons.bookmark_rounded, size: 16),
                        label: Text('Bookmarks (${allBookmarks.length})'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: const Icon(Icons.history_rounded, size: 16),
                        label: const Text('Reading History'),
                      ),
                    ],
                    selected: {_selectedSegment},
                    onSelectionChanged: (set) => setState(() => _selectedSegment = set.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),

              // View Contents
              Expanded(
                child: _selectedSegment == 0
                    ? _buildBookmarksSection(
                        context,
                        scope,
                        allBookmarks,
                        displayBookmarks,
                        quranCount,
                        hadithCount,
                      )
                    : _buildHistorySection(
                        context,
                        scope,
                        lastQuran,
                        lastHadith,
                        isDark,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookmarksSection(
    BuildContext context,
    AppScope scope,
    List<Bookmark> allBookmarks,
    List<Bookmark> displayBookmarks,
    int quranCount,
    int hadithCount,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        // Filter Chips Row
        if (allBookmarks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                FilterChip(
                  label: Text('All (${allBookmarks.length})'),
                  selected: _filterType == null,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Quran ($quranCount)'),
                  selected: _filterType == ContentType.quran,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _filterType = ContentType.quran),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Hadith ($hadithCount)'),
                  selected: _filterType == ContentType.hadith,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _filterType = ContentType.hadith),
                ),
              ],
            ),
          ),

        // Empty State or Bookmarks List
        if (displayBookmarks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: 0.20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    size: 40,
                    color: Color(0xFFC5A059),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  allBookmarks.isEmpty
                      ? 'No saved bookmarks yet'
                      : 'No ${_filterType!.displayName} bookmarks',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  allBookmarks.isEmpty
                      ? 'Tap the bookmark icon on any verse or narration while reading to save it here offline.'
                      : 'Try switching filters to view all your bookmarks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          ...displayBookmarks.map((b) {
            final isQuran = b.contentType == ContentType.quran;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openBookmarkContext(context, b, scope),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Tag + Reference + Delete Button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: (isQuran
                                      ? Theme.of(context).colorScheme.primary
                                      : const Color(0xFFC5A059))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (isQuran
                                        ? Theme.of(context).colorScheme.primary
                                        : const Color(0xFFC5A059))
                                    .withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              b.contentType.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isQuran
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFC5A059),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b.reference,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            tooltip: 'Remove bookmark',
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              await scope.bookmarkRepository.removeBookmark(b.id);
                              await scope.loadBookmarks();
                              setState(() {});
                            },
                          ),
                        ],
                      ),

                      // Arabic excerpt
                      if (b.arabicExcerpt.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            b.arabicExcerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.arabic(
                              fontSize: 16,
                              height: 1.45,
                              color: const Color(0xFFC5A059),
                            ),
                          ),
                        ),
                      ],

                      // Translation excerpt
                      const SizedBox(height: 8),
                      Text(
                        b.translationExcerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    AppScope scope,
    dynamic lastQuran,
    dynamic lastHadith,
    bool isDark,
  ) {
    final hasHistory = lastQuran != null || lastHadith != null;

    if (!hasHistory) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFC5A059).withValues(alpha: 0.20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 40,
                  color: Color(0xFFC5A059),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No reading history yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Your reading positions in the Holy Quran and Hadith Collections will automatically be recorded here as you read.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Quran Resume Card
        if (lastQuran != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                        Theme.of(context).colorScheme.surface,
                      ]
                    : [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        Theme.of(context).colorScheme.surface,
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'NOBLE QURAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastQuran.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        lastQuran.subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final surahNum = int.tryParse(lastQuran.targetId) ?? 1;
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
                  },
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Resume'),
                ),
              ],
            ),
          ),

        // Hadith Resume Card
        if (lastHadith != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFFC5A059).withValues(alpha: 0.18),
                        const Color(0xFF091712),
                      ]
                    : [
                        const Color(0xFFF9F5EC),
                        const Color(0xFFFAF8F5),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFFC5A059),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'PROPHETIC SUNNAH',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC5A059),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastHadith.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        lastHadith.subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final hadiths = await scope.contentRepository.getHadiths(
                      collectionId: lastHadith.targetId,
                    );
                    final hadith = hadiths.firstWhere(
                      (h) => h.hadithNumber == lastHadith.itemNumber,
                      orElse: () => hadiths.first,
                    );
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HadithReaderView(hadith: hadith),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Resume'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
