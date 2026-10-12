import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/quran_models.dart';
import 'package:quran_hadis/domain/models/reading_progress_model.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/quran/views/quran_reader_view.dart';

class _FakeQuranContentRepository extends ContentRepository {
  @override
  Future<List<QuranSurah>> getSurahs() async {
    return [
      const QuranSurah(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'Al-Fatihah',
        nameTranslation: 'The Opening',
        ayahCount: 7,
        revelationType: 'Meccan',
      ),
      const QuranSurah(
        number: 2,
        nameArabic: 'البقرة',
        nameEnglish: 'Al-Baqarah',
        nameTranslation: 'The Cow',
        ayahCount: 286,
        revelationType: 'Medinan',
      ),
    ];
  }

  @override
  Future<QuranSurah?> getSurah(int number) async {
    final list = await getSurahs();
    return list.firstWhere((s) => s.number == number);
  }

  @override
  Future<List<QuranAyah>> getAyahs(int surahNumber) async {
    if (surahNumber == 1) {
      return [
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          englishTranslation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          englishTranslation: '[All] praise is [due] to Allah, Lord of the worlds -',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 3,
          arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
          englishTranslation: 'The Entirely Merciful, the Especially Merciful,',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 4,
          arabicText: 'مَالِكِ يَوْمِ الدِّينِ',
          englishTranslation: 'Sovereign of the Day of Recompense.',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 5,
          arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          englishTranslation: 'It is You we worship and You we ask for help.',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 6,
          arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          englishTranslation: 'Guide us to the straight path -',
        ),
        const QuranAyah(
          surahNumber: 1,
          ayahNumber: 7,
          arabicText: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          englishTranslation: 'The path of those upon whom You have bestowed favor...',
        ),
      ];
    }
    return [];
  }
}

class _FakeReadingProgressRepository extends ReadingProgressRepository {
  ReadingProgress? _progress;
  @override
  Future<ReadingProgress?> getProgress(ContentType contentType) async => _progress;
  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    _progress = progress;
  }
}

class _FakeBookmarkRepository extends BookmarkRepository {
  final List<Bookmark> _bookmarks = [];
  @override
  Future<List<Bookmark>> getBookmarks() async => _bookmarks;
  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    _bookmarks.add(bookmark);
  }
  @override
  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
  }
  @override
  Future<bool> isBookmarked(String id) async {
    return _bookmarks.any((b) => b.id == id);
  }
}

void main() {
  testWidgets('QuranReaderView renders surah header, ayahs, and actions', (tester) async {
    const surah = QuranSurah(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameTranslation: 'The Opening',
      ayahCount: 7,
      revelationType: 'Meccan',
    );

    final scope = AppScope(
      contentRepository: _FakeQuranContentRepository(),
      bookmarkRepository: _FakeBookmarkRepository(),
      readingProgressRepository: _FakeReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: const MaterialApp(
          home: QuranReaderView(surah: surah),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Surah title and header banner
    expect(find.text('1. Al-Fatihah'), findsOneWidget);
    expect(find.text('The Opening • الفاتحة'), findsOneWidget);
    expect(find.text('Meccan • 7 Verses'), findsOneWidget);

    // Verify Ayah 1
    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsWidgets);
    expect(find.text('In the name of Allah, the Entirely Merciful, the Especially Merciful.'), findsOneWidget);

    // Verify AppBar actions
    expect(find.byTooltip('Jump to Verse'), findsOneWidget);
    expect(find.byTooltip('Typography Controls'), findsOneWidget);

    // Tap Typography controls
    await tester.tap(find.byTooltip('Typography Controls'));
    await tester.pumpAndSettle();

    expect(find.text('Typography & Display'), findsOneWidget);
    expect(find.text('Plain Reading Mode'), findsOneWidget);

    // Close typography sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify Mark as reading position button exists and tap it
    final markButton = find.byTooltip('Mark as reading position').first;
    await tester.tap(markButton);
    await tester.pumpAndSettle();

    expect(find.text('LAST READ'), findsWidgets);

    // Test Jump to Verse Dialog
    await tester.tap(find.byTooltip('Jump to Verse'));
    await tester.pumpAndSettle();

    expect(find.text('Jump to Verse (1 - 7)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Jump'));
    await tester.pumpAndSettle();

    // Verify Chapter Navigation button to Surah 2 by scrolling down
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Surah 2'), findsOneWidget);
  });

  testWidgets('QuranReaderView title tap opens QuranSurahsSheet and switches Surah', (tester) async {
    const surah = QuranSurah(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameTranslation: 'The Opening',
      ayahCount: 7,
      revelationType: 'Meccan',
    );

    final scope = AppScope(
      contentRepository: _FakeQuranContentRepository(),
      bookmarkRepository: _FakeBookmarkRepository(),
      readingProgressRepository: _FakeReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: const MaterialApp(
          home: QuranReaderView(surah: surah),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap title to open Surah switcher sheet
    await tester.tap(find.text('1. Al-Fatihah'));
    await tester.pumpAndSettle();

    expect(find.text('Jump to Surah'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('READING NOW'), findsOneWidget);

    // Tap Al-Baqarah to switch
    await tester.tap(find.text('Al-Baqarah'));
    await tester.pumpAndSettle();

    // Verify switched to Surah 2
    expect(find.text('2. Al-Baqarah'), findsOneWidget);
  });
}
