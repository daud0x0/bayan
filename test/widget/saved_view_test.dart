import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
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

void main() {
  AppScope makeScope({List<Bookmark>? bookmarks}) {
    return AppScope(
      contentRepository: ContentRepository(),
      bookmarkRepository: _MockBookmarkRepository(bookmarks),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
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
    final scope = makeScope(bookmarks: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Saved & History'), findsOneWidget);
    expect(find.text('Bookmarks (0)'), findsOneWidget);
    expect(find.text('Reading History'), findsOneWidget);
    expect(find.text('No saved bookmarks yet'), findsOneWidget);
  });

  testWidgets('SavedView toggles to Reading History segment', (tester) async {
    final scope = makeScope(bookmarks: []);
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Reading History segment
    await tester.tap(find.text('Reading History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No reading history yet'), findsOneWidget);
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

    final scope = makeScope(bookmarks: sampleBookmarks);
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
}
