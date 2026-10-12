import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/reading_progress_model.dart';
import '../../../domain/models/reflection_note_model.dart';
import '../../hadith/views/hadith_reader_view.dart';
import '../../quran/views/quran_reader_view.dart';
import '../../reflections/views/reflection_note_sheet.dart';
import '../../share_cards/views/share_card_sheet.dart';

class _SavedData {
  const _SavedData({required this.bookmarks, required this.notes});
  final List<Bookmark> bookmarks;
  final List<ReflectionNote> notes;
}

/// Saved items screen managing bookmarks, reading positions, and Tadabbur reflections.
/// Complies with Section 4.3 of the Product Plan with illuminated Islamic styling.
class SavedView extends StatefulWidget {
  const SavedView({super.key});

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {
  int _selectedSegment = 0; // 0: Bookmarks, 1: Reading History, 2: Reflections
  ContentType? _filterType;
  ContentType? _reflectionsFilterType;
  final TextEditingController _reflectionSearchController = TextEditingController();

  @override
  void dispose() {
    _reflectionSearchController.dispose();
    super.dispose();
  }

  Future<void> _openContext(
    BuildContext context,
    String contentId,
    ContentType contentType,
    AppScope scope,
  ) async {
    if (contentType == ContentType.quran) {
      final parts = contentId.replaceFirst('quran_', '').split('_');
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
      final hadithId = contentId.replaceFirst('hadith_', '');
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

  ContentItem _contentItemFromBookmark(Bookmark b) {
    return ContentItem(
      id: b.contentId,
      contentType: b.contentType,
      reference: b.reference,
      arabicText: b.arabicExcerpt,
      englishTranslation: b.translationExcerpt,
      attribution: b.contentType == ContentType.quran
          ? 'The Quran: Saheeh International'
          : 'Authentic Hadith Tradition',
    );
  }

  ContentItem _contentItemFromNote(ReflectionNote n) {
    return ContentItem(
      id: n.contentId,
      contentType: n.contentType,
      reference: n.reference,
      arabicText: n.arabicExcerpt,
      englishTranslation: n.translationExcerpt,
      attribution: n.contentType == ContentType.quran
          ? 'The Quran: Saheeh International'
          : 'Authentic Hadith Tradition',
    );
  }

  Future<void> _removeBookmarkWithUndo(
    BuildContext context,
    Bookmark b,
    AppScope scope,
  ) async {
    if (scope.preferences.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
    await scope.bookmarkRepository.removeBookmark(b.id);
    await scope.loadBookmarks();
    setState(() {});

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${b.reference} from bookmarks'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFC5A059),
          onPressed: () async {
            await scope.bookmarkRepository.addBookmark(b);
            await scope.loadBookmarks();
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _removeReflectionWithUndo(
    BuildContext context,
    ReflectionNote note,
    AppScope scope,
  ) async {
    if (scope.preferences.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
    await scope.reflectionNotesRepository.deleteNote(note.id);
    setState(() {});

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed reflection for ${note.reference}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFC5A059),
          onPressed: () async {
            await scope.reflectionNotesRepository.saveNote(note);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Future<_SavedData> _fetchSavedData(AppScope scope) async {
    final bookmarks = await scope.bookmarkRepository.getBookmarks();
    final notes = await scope.reflectionNotesRepository.getNotes();
    return _SavedData(bookmarks: bookmarks, notes: notes);
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
      body: FutureBuilder<_SavedData>(
        future: _fetchSavedData(scope),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookmarks = snapshot.data!.bookmarks;
          final allNotes = snapshot.data!.notes;

          final quranCount = allBookmarks.where((b) => b.contentType == ContentType.quran).length;
          final hadithCount = allBookmarks.where((b) => b.contentType == ContentType.hadith).length;

          var displayBookmarks = allBookmarks;
          if (_filterType != null) {
            displayBookmarks = displayBookmarks.where((b) => b.contentType == _filterType).toList();
          }

          return Column(
            children: [
              // Clean Segmented Navigation (Bookmarks vs History vs Reflections)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        icon: const Icon(Icons.bookmark_rounded, size: 16),
                        label: Text(
                          'Bookmarks (${allBookmarks.length})',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                      const ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.history_rounded, size: 16),
                        label: Text(
                          'Reading History',
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ),
                      ButtonSegment(
                        value: 2,
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: Text(
                          'Reflections (${allNotes.length})',
                          style: const TextStyle(fontSize: 11.5),
                        ),
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
                    : _selectedSegment == 1
                        ? _buildHistorySection(
                            context,
                            scope,
                            lastQuran,
                            lastHadith,
                            isDark,
                          )
                        : _buildReflectionsSection(
                            context,
                            scope,
                            allNotes,
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
                      : 'No bookmarks in this category',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  allBookmarks.isEmpty
                      ? 'Bookmark verses and traditions to quickly revisit them here.'
                      : 'Try selecting "All" to view all your saved verses.',
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
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isQuran
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                                : const Color(0xFFC5A059).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isQuran ? 'QURAN' : 'HADITH',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: isQuran
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFC5A059),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b.reference,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (b.arabicExcerpt.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        b.arabicExcerpt,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.arabic(
                          fontSize: 18,
                          height: 1.8,
                          color: const Color(0xFFC5A059),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    Text(
                      '"${b.translationExcerpt}"',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.translation(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 4),

                    // Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => _openContext(context, b.contentId, b.contentType, scope),
                          icon: const Icon(Icons.auto_stories_outlined, size: 15),
                          label: const Text(
                            'Read in Context',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: 'Copy Text',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (scope.preferences.hapticFeedbackEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                Clipboard.setData(ClipboardData(
                                  text: '${b.arabicExcerpt.isNotEmpty ? '${b.arabicExcerpt}\n\n' : ''}${b.translationExcerpt}\n— ${b.reference}',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied ${b.reference} to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18),
                              tooltip: 'Share Card',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (scope.preferences.hapticFeedbackEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                final item = _contentItemFromBookmark(b);
                                ShareCardSheet.show(context, item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              tooltip: 'Remove bookmark',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _removeBookmarkWithUndo(context, b, scope),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildReflectionsSection(
    BuildContext context,
    AppScope scope,
    List<ReflectionNote> allNotes,
    bool isDark,
  ) {
    final query = _reflectionSearchController.text.trim().toLowerCase();
    var filteredNotes = allNotes;

    if (_reflectionsFilterType != null) {
      filteredNotes = filteredNotes.where((n) => n.contentType == _reflectionsFilterType).toList();
    }

    if (query.isNotEmpty) {
      filteredNotes = filteredNotes.where((n) {
        return n.reference.toLowerCase().contains(query) ||
            n.noteText.toLowerCase().contains(query) ||
            n.translationExcerpt.toLowerCase().contains(query);
      }).toList();
    }

    final quranNotesCount = allNotes.where((n) => n.contentType == ContentType.quran).length;
    final hadithNotesCount = allNotes.where((n) => n.contentType == ContentType.hadith).length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        if (allNotes.isNotEmpty) ...[
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                FilterChip(
                  label: Text('All (${allNotes.length})'),
                  selected: _reflectionsFilterType == null,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _reflectionsFilterType = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Quran ($quranNotesCount)'),
                  selected: _reflectionsFilterType == ContentType.quran,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _reflectionsFilterType = ContentType.quran),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Hadith ($hadithNotesCount)'),
                  selected: _reflectionsFilterType == ContentType.hadith,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => setState(() => _reflectionsFilterType = ContentType.hadith),
                ),
              ],
            ),
          ),

          // Search Field
          if (allNotes.length > 2) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _reflectionSearchController,
                decoration: InputDecoration(
                  hintText: 'Search your reflections...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _reflectionSearchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ],

        // Empty state
        if (filteredNotes.isEmpty)
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
                    Icons.edit_note_rounded,
                    size: 40,
                    color: Color(0xFFC5A059),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  allNotes.isEmpty
                      ? 'No Reflections Yet'
                      : 'No reflections match your search',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  allNotes.isEmpty
                      ? 'Tadabbur (deep contemplation) unlocks sacred wisdom.\nTap the reflection icon on any verse or hadith while reading to record your thoughts.'
                      : 'Try adjusting your search terms or filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
          ...filteredNotes.map((note) {
            final isQuran = note.contentType == ContentType.quran;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.28),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header badge & date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isQuran
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                                : const Color(0xFFC5A059).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isQuran ? 'QURAN' : 'HADITH',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: isQuran
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFC5A059),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.reference,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Content Excerpt Preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (note.arabicExcerpt.isNotEmpty) ...[
                            Text(
                              note.arabicExcerpt,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.arabic(
                                fontSize: 16,
                                color: const Color(0xFFC5A059),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '"${note.translationExcerpt}"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.translation(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // User Reflection Text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFFC5A059),
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: Text(
                        note.noteText,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 4),

                    // Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => _openContext(context, note.contentId, note.contentType, scope),
                          icon: const Icon(Icons.auto_stories_outlined, size: 15),
                          label: const Text(
                            'Read in Context',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Note',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () async {
                                final updated = await ReflectionNoteSheet.show(
                                  context,
                                  contentId: note.contentId,
                                  contentType: note.contentType,
                                  reference: note.reference,
                                  arabicExcerpt: note.arabicExcerpt,
                                  translationExcerpt: note.translationExcerpt,
                                  existingNote: note,
                                );
                                if (updated == true && mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: 'Copy Note',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (scope.preferences.hapticFeedbackEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                Clipboard.setData(ClipboardData(
                                  text: 'Reflection on ${note.reference}:\n"${note.noteText}"\n\nExcerpt:\n${note.translationExcerpt}',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied reflection for ${note.reference}'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18),
                              tooltip: 'Share Card',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (scope.preferences.hapticFeedbackEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                final item = _contentItemFromNote(note);
                                ShareCardSheet.show(context, item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              tooltip: 'Delete reflection',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _removeReflectionWithUndo(context, note, scope),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
    ReadingProgress? lastQuran,
    ReadingProgress? lastHadith,
    bool isDark,
  ) {
    if (lastQuran == null && lastHadith == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No reading history yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'When you read the Quran or Hadith, your latest position is recorded here so you can resume anytime.',
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
