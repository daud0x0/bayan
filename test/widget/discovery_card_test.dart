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
import 'package:quran_hadis/features/discover/views/discovery_card.dart';

void main() {
  testWidgets('DiscoveryCard displays content type badge, reference, and text', (tester) async {
    final item = ContentItem(
      id: 'quran_94_5',
      contentType: ContentType.quran,
      reference: 'Surah Ash-Sharh [94:5-6]',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      englishTranslation: 'For indeed, with hardship will be ease.',
      attribution: 'The Quran: English Meanings by Saheeh International',
      categoryIds: ['hardship_and_hope'],
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
            body: DiscoveryCard(
              item: item,
              onOpenContext: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('QURAN'), findsOneWidget);
    expect(find.text('Surah Ash-Sharh [94:5-6]'), findsOneWidget);
    expect(find.text('فَإِنَّ مَعَ الْعُسْرِ يُسْرًا'), findsOneWidget);
    expect(find.text('For indeed, with hardship will be ease.'), findsOneWidget);
    expect(find.text('Read in Context'), findsOneWidget);
  });
}
