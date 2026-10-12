import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/hadith_models.dart';
import 'package:quran_hadis/domain/models/quran_models.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/read/views/read_view.dart';

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
      ];

  @override
  Future<List<HadithCollection>> getHadithCollections() async => [
        const HadithCollection(
          id: 'bukhari',
          nameEnglish: 'Sahih al-Bukhari',
          nameArabic: 'صحيح البخاري',
          author: 'Imam Muhammad al-Bukhari',
          description: '',
          totalHadiths: 7563,
          attribution: 'Sahih al-Bukhari',
        ),
        const HadithCollection(
          id: 'muslim',
          nameEnglish: 'Sahih Muslim',
          nameArabic: 'صحيح مسلم',
          author: 'Imam Muslim ibn al-Hajjaj',
          description: '',
          totalHadiths: 7500,
          attribution: 'Sahih Muslim',
        ),
      ];

  @override
  Future<List<HadithItem>> getHadiths({String? collectionId, int? bookNumber}) async => [];

  @override
  Future<List<HadithBook>> getHadithBooks(String collectionId) async => [];
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

  Widget wrap(AppScope scope, {int initialTabIndex = 0}) {
    return AppScopeProvider(
      scope: scope,
      child: MaterialApp(
        home: ReadView(initialTabIndex: initialTabIndex),
      ),
    );
  }

  testWidgets('ReadView renders single Library header with Quran and Hadith tabs', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));
    await tester.pump();
    await tester.pump();

    // Verify unified Library title
    expect(find.text('Library'), findsOneWidget);

    // Verify tabs
    expect(find.text('Holy Quran'), findsOneWidget);
    expect(find.text('Hadith Collections'), findsOneWidget);

    // Only one AppBar in the widget tree (no duplicate AppBars)
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('ReadView can switch to Hadith tab seamlessly', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope, initialTabIndex: 1));
    await tester.pump();
    await tester.pump();

    // Only one AppBar in the widget tree
    expect(find.byType(AppBar), findsOneWidget);

    // Hadith segment controls visible
    expect(find.text('Sahih al-Bukhari'), findsOneWidget);
    expect(find.text('Sahih Muslim'), findsOneWidget);
  });
}
