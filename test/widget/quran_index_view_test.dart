import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/quran_models.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/quran/views/quran_index_view.dart';

class _MockContentRepository extends ContentRepository {
  @override
  Future<List<QuranSurah>> getSurahs() async => [
        const QuranSurah(
          number: 1,
          nameArabic: 'الفاتحة',
          nameEnglish: 'Al-Fatihah',
          nameTranslation: 'The Opener',
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

void main() {
  AppScope makeScope() {
    return AppScope(
      contentRepository: _MockContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );
  }

  Widget wrap(AppScope scope) {
    return AppScopeProvider(
      scope: scope,
      child: const MaterialApp(
        home: Scaffold(body: QuranIndexView(showAppBar: true)),
      ),
    );
  }

  testWidgets('QuranIndexView renders Surahs and toggles to Juz tab', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Holy Quran'), findsOneWidget);
    expect(find.text('Surahs (114)'), findsOneWidget);
    expect(find.text('Juz / Paras (30)'), findsOneWidget);

    // Initial view shows Surahs
    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);

    // Toggle to Juz tab
    await tester.tap(find.text('Juz / Paras (30)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Juz items appear
    expect(find.text('Juz 1 • Alif-Lam-Meem'), findsOneWidget);
    expect(find.text('Juz 2 • Sayaqool'), findsOneWidget);
    expect(find.text('Al-Fatihah 1:1 – Al-Baqarah 2:141'), findsOneWidget);

    // Search within Juz
    await tester.enterText(find.byType(TextField), 'Amma');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Juz 30 • 'Amma"), findsOneWidget);
  });
}
