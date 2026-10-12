import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../hadith/views/hadith_reader_view.dart';
import '../../quran/views/quran_reader_view.dart';

/// Saved items screen managing bookmarks and reading positions.
/// Complies with Section 4.3 of the Product Plan.
class SavedView extends StatefulWidget {
  const SavedView({super.key});

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {
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

          var bookmarks = snapshot.data!;
          if (_filterType != null) {
            bookmarks = bookmarks.where((b) => b.contentType == _filterType).toList();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Reading Progress Hero Cards
              if (lastQuran != null || lastHadith != null) ...[
                Text(
                  'Reading Progress',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                if (lastQuran != null)
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25),
                    child: ListTile(
                      leading: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
                      title: Text(lastQuran.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(lastQuran.subtitle),
                      trailing: FilledButton.tonal(
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
                        child: const Text('Resume'),
                      ),
                    ),
                  ),
                if (lastHadith != null)
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.25),
                    child: ListTile(
                      leading: Icon(Icons.bookmark_added_outlined,
                          color: Theme.of(context).colorScheme.secondary),
                      title: Text(lastHadith.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(lastHadith.subtitle),
                      trailing: FilledButton.tonal(
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
                        child: const Text('Resume'),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],

              // Bookmarks Header & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookmarks (${bookmarks.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterType == null,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _filterType = null),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('Quran'),
                        selected: _filterType == ContentType.quran,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _filterType = ContentType.quran),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('Hadith'),
                        selected: _filterType == ContentType.hadith,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _filterType = ContentType.hadith),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bookmarks List
              if (bookmarks.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.bookmark_border_rounded,
                          size: 48, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      const Text(
                        'No saved bookmarks yet.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the bookmark icon on any verse or narration to save it here offline.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),
                )
              else
                ...bookmarks.map((b) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.contentType.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b.reference,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (b.arabicExcerpt.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              b.arabicExcerpt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTypography.arabic(fontSize: 16),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            b.translationExcerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Remove bookmark',
                        onPressed: () async {
                          await scope.bookmarkRepository.removeBookmark(b.id);
                          await scope.loadBookmarks();
                          setState(() {});
                        },
                      ),
                      onTap: () => _openBookmarkContext(context, b, scope),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
