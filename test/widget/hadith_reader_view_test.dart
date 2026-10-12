import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/hadith_models.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/hadith/views/hadith_reader_view.dart';

void main() {
  testWidgets('HadithReaderView displays hadith details, actions, and navigation', (tester) async {
    final hadith = HadithItem(
      id: 'bukhari_1',
      collectionId: 'bukhari',
      hadithNumber: 1,
      bookNumber: 1,
      bookNameEnglish: "Revelation (Bad' al-Wahy)",
      bookNameArabic: 'كتاب بدء الوحي',
      chapterName: 'How the Divine Inspiration started',
      narrator: 'Umar ibn al-Khattab',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      englishTranslation: 'Actions are but by intention...',
      grading: 'Sahih',
      attribution: 'Sahih al-Bukhari 1',
    );

    final scope = AppScope(
      contentRepository: ContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: MaterialApp(
          home: HadithReaderView(hadith: hadith),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header and metadata
    expect(find.text('Sahih al-Bukhari 1'), findsWidgets);
    expect(find.text('SAHIH'), findsOneWidget);
    expect(find.text('Narrated by Umar ibn al-Khattab'), findsOneWidget);
    expect(find.text('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'), findsOneWidget);
    expect(find.text('Actions are but by intention...'), findsOneWidget);

    // Verify AppBar action buttons
    expect(find.byTooltip('Jump to Hadith'), findsOneWidget);
    expect(find.byTooltip('Typography & Plain Mode'), findsOneWidget);
    expect(find.byTooltip('Bookmark Hadith'), findsOneWidget);
    expect(find.byTooltip('Share Card'), findsOneWidget);

    // Tap Typography Sheet
    await tester.tap(find.byTooltip('Typography & Plain Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Reading & Typography Settings'), findsOneWidget);
    expect(find.text('Plain Reading Mode'), findsOneWidget);
  });

  testWidgets('HadithReaderView title tap opens HadithBooksSheet and navigates to selected book', (tester) async {
    final hadith1 = HadithItem(
      id: 'bukhari_1',
      collectionId: 'bukhari',
      hadithNumber: 1,
      bookNumber: 1,
      bookNameEnglish: "Revelation (Bad' al-Wahy)",
      bookNameArabic: 'كتاب بدء الوحي',
      chapterName: 'How the Divine Inspiration started',
      narrator: 'Umar ibn al-Khattab',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      englishTranslation: 'Actions are but by intention...',
      grading: 'Sahih',
      attribution: 'Sahih al-Bukhari 1',
    );

    final hadith2 = HadithItem(
      id: 'bukhari_2',
      collectionId: 'bukhari',
      hadithNumber: 8,
      bookNumber: 2,
      bookNameEnglish: 'Belief (Iman)',
      bookNameArabic: 'كتاب الإيمان',
      chapterName: 'Belief and its characteristics',
      narrator: 'Ibn Umar',
      arabicText: 'بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ',
      englishTranslation: 'Islam is based on five principles...',
      grading: 'Sahih',
      attribution: 'Sahih al-Bukhari 8',
    );

    final books = [
      const HadithBook(
        collectionId: 'bukhari',
        bookNumber: 1,
        nameEnglish: 'Revelation',
        nameArabic: 'بدء الوحي',
        hadithCount: 7,
        firstHadithNumber: 1,
        lastHadithNumber: 7,
      ),
      const HadithBook(
        collectionId: 'bukhari',
        bookNumber: 2,
        nameEnglish: 'Belief',
        nameArabic: 'الإيمان',
        hadithCount: 50,
        firstHadithNumber: 8,
        lastHadithNumber: 58,
      ),
    ];

    final fakeRepo = _FakeHadithRepo(
      hadiths: [hadith1, hadith2],
      books: books,
    );

    final scope = AppScope(
      contentRepository: fakeRepo,
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: MaterialApp(
          home: HadithReaderView(hadith: hadith1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap title in AppBar to open HadithBooksSheet
    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Sahih al-Bukhari 1'),
    );
    await tester.tap(appBarTitle);
    await tester.pumpAndSettle();

    expect(find.text('Sahih al-Bukhari Books'), findsOneWidget);
    expect(find.text('Belief'), findsOneWidget);

    // Tap Book 2 (Belief)
    await tester.tap(find.text('Belief'));
    await tester.pumpAndSettle();

    // Verify reader navigated to hadith in Book 2
    expect(find.text('Sahih al-Bukhari 8'), findsWidgets);
    expect(find.text('Narrated by Ibn Umar'), findsOneWidget);
  });
}

class _FakeHadithRepo extends ContentRepository {
  _FakeHadithRepo({required this.hadiths, required this.books});
  final List<HadithItem> hadiths;
  final List<HadithBook> books;

  @override
  Future<List<HadithItem>> getHadiths({String? collectionId, int? bookNumber}) async {
    return hadiths;
  }

  @override
  Future<List<HadithBook>> getHadithBooks(String collectionId) async {
    return books;
  }
}
