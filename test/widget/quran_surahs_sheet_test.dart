import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/quran_models.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/quran/views/quran_surahs_sheet.dart';

class _FakeContentRepository extends ContentRepository {
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
      const QuranSurah(
        number: 3,
        nameArabic: 'آل عمران',
        nameEnglish: "Ali 'Imran",
        nameTranslation: 'Family of Imran',
        ayahCount: 200,
        revelationType: 'Medinan',
      ),
    ];
  }
}

void main() {
  testWidgets('QuranSurahsSheet displays surahs, filters by search, and triggers onSelectSurah', (tester) async {
    QuranSurah? selected;

    final scope = AppScope(
      contentRepository: _FakeContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  QuranSurahsSheet.show(
                    context,
                    currentSurahNumber: 1,
                    onSelectSurah: (surah) => selected = surah,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify header and items
    expect(find.text('Jump to Surah'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text("Ali 'Imran"), findsOneWidget);
    expect(find.text('READING NOW'), findsOneWidget);

    // Filter by search query
    await tester.enterText(find.byType(TextField), 'Baqarah');
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);

    // Tap Al-Baqarah
    await tester.tap(find.text('Al-Baqarah'));
    await tester.pumpAndSettle();

    // Verify callback was triggered with selected surah
    expect(selected, isNotNull);
    expect(selected!.number, 2);
    expect(selected!.nameEnglish, 'Al-Baqarah');
  });

  testWidgets('QuranSurahsSheet filters by revelation type', (tester) async {
    final scope = AppScope(
      contentRepository: _FakeContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  QuranSurahsSheet.show(
                    context,
                    currentSurahNumber: 1,
                    onSelectSurah: (_) {},
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Tap Medinan filter chip
    await tester.tap(find.text('Medinan (28)'));
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text("Ali 'Imran"), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);
  });
}
