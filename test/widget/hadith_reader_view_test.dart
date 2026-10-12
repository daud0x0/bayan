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
}
