import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/content_item.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/share_cards/views/share_card_sheet.dart';

void main() {
  testWidgets('ShareCardSheet displays preview, options, and actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const item = ContentItem(
      id: 'quran_1_1',
      contentType: ContentType.quran,
      reference: 'Surah Al-Fatihah [1:1]',
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      englishTranslation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      attribution: 'Saheeh International',
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
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareCardSheet.show(context, item),
                child: const Text('Open Share Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Share Sheet'));
    await tester.pumpAndSettle();

    // Verify sheet title and content preview
    expect(find.text('Share Card'), findsOneWidget);
    expect(find.text('QURAN'), findsOneWidget);
    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.text('In the name of Allah, the Entirely Merciful, the Especially Merciful.'), findsOneWidget);

    // Scroll down to reveal format and display controls
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify format and display controls
    expect(find.text('Square 1:1'), findsOneWidget);
    expect(find.text('Wallpaper 9:16'), findsOneWidget);
    expect(find.text('Arabic & English'), findsOneWidget);

    // Verify actions
    expect(find.byTooltip('Copy Plain Text'), findsOneWidget);
    expect(find.text('Share Text'), findsOneWidget);
    expect(find.text('Share Image'), findsOneWidget);
  });
}
