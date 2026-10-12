import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/data/repositories/reflection_notes_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/reflection_note_model.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/bookmarks/views/saved_view.dart';

class _MockBookmarkRepository extends BookmarkRepository {
  final List<Bookmark> _items = [];

  _MockBookmarkRepository([List<Bookmark>? initial]) {
    if (initial != null) _items.addAll(initial);
  }

  @override
  Future<List<Bookmark>> getBookmarks() async => List.unmodifiable(_items);

  @override
  Future<void> addBookmark(Bookmark bookmark) async => _items.add(bookmark);

  @override
  Future<void> removeBookmark(String id) async => _items.removeWhere((b) => b.id == id);
}

class _MockReflectionNotesRepository extends ReflectionNotesRepository {
  final List<ReflectionNote> _notes = [];

  _MockReflectionNotesRepository([List<ReflectionNote>? initial]) {
    if (initial != null) _notes.addAll(initial);
  }

  @override
  Future<List<ReflectionNote>> getNotes() async => List.unmodifiable(_notes);

  @override
  Future<ReflectionNote?> getNoteForContent(String contentId) async {
    for (final n in _notes) {
      if (n.contentId == contentId) return n;
    }
    return null;
  }

  @override
  Future<void> saveNote(ReflectionNote note) async {
    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<bool> hasNote(String contentId) async {
    return _notes.any((n) => n.contentId == contentId);
  }
}

void main() {
  AppScope makeScope({
    List<Bookmark>? bookmarks,
    List<ReflectionNote>? notes,
  }) {
    return AppScope(
      contentRepository: ContentRepository(),
      bookmarkRepository: _MockBookmarkRepository(bookmarks),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      reflectionNotesRepository: _MockReflectionNotesRepository(notes),
      initialPreferences: const UserPreferences(),
    );
  }

  Widget wrap(AppScope scope) {
    return AppScopeProvider(
      scope: scope,
      child: const MaterialApp(home: SavedView()),
    );
  }

  testWidgets('SavedView renders segmented control and empty state when no bookmarks', (tester) async {
    final scope = makeScope(bookmarks: [], notes: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Saved & History'), findsOneWidget);
    expect(find.text('Bookmarks (0)'), findsOneWidget);
    expect(find.text('Reading History'), findsOneWidget);
    expect(find.text('Reflections (0)'), findsOneWidget);
    expect(find.text('No saved bookmarks yet'), findsOneWidget);
  });

  testWidgets('SavedView toggles to Reading History segment', (tester) async {
    final scope = makeScope(bookmarks: [], notes: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Reading History segment
    await tester.tap(find.text('Reading History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No reading history yet'), findsOneWidget);
  });

  testWidgets('SavedView toggles to Reflections segment and shows empty state', (tester) async {
    final scope = makeScope(bookmarks: [], notes: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Reflections segment
    await tester.tap(find.text('Reflections (0)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No Reflections Yet'), findsOneWidget);
  });

  testWidgets('SavedView displays bookmark cards and filter chips when bookmarks exist', (tester) async {
    final sampleBookmarks = <Bookmark>[
      Bookmark(
        id: 'bm_1',
        contentId: 'quran_1_1',
        contentType: ContentType.quran,
        title: 'Surah Al-Fatihah',
        reference: 'Surah Al-Fatihah [1:1]',
        arabicExcerpt: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translationExcerpt: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        createdAt: DateTime.now(),
      ),
      Bookmark(
        id: 'bm_2',
        contentId: 'hadith_bukhari_1',
        contentType: ContentType.hadith,
        title: 'Revelation',
        reference: 'Sahih al-Bukhari 1',
        arabicExcerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        translationExcerpt: 'Actions are according to intentions.',
        createdAt: DateTime.now(),
      ),
    ];

    final scope = makeScope(bookmarks: sampleBookmarks, notes: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bookmarks (2)'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Quran (1)'), findsOneWidget);
    expect(find.text('Hadith (1)'), findsOneWidget);

    expect(find.text('Surah Al-Fatihah [1:1]'), findsOneWidget);
    expect(find.text('Sahih al-Bukhari 1'), findsOneWidget);
  });

  testWidgets('SavedView displays reflection cards when notes exist', (tester) async {
    final now = DateTime.now();
    final sampleNotes = <ReflectionNote>[
      ReflectionNote(
        id: 'note_1',
        contentId: 'quran_2_255',
        contentType: ContentType.quran,
        reference: 'Surah Al-Baqarah [2:255]',
        arabicExcerpt: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        translationExcerpt: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
        noteText: 'Ayat al-Kursi reminds me to place absolute trust in the Sustainer of all existence.',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final scope = makeScope(bookmarks: [], notes: sampleNotes);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reflections (1)'), findsOneWidget);

    // Tap Reflections segment
    await tester.tap(find.text('Reflections (1)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Surah Al-Baqarah [2:255]'), findsOneWidget);
    expect(find.text('Ayat al-Kursi reminds me to place absolute trust in the Sustainer of all existence.'), findsOneWidget);
    expect(find.text('Read in Context'), findsOneWidget);
  });
}
