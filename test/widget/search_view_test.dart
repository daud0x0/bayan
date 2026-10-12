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
import 'package:quran_hadis/features/search/views/search_view.dart';

class _FakeContentRepository extends ContentRepository {
  @override
  Future<List<ContentItem>> search(
    String query, {
    ContentType? contentType,
    String? categoryId,
  }) async {
    final list = [
      ContentItem(
        id: 'quran_94_5',
        contentType: ContentType.quran,
        reference: 'Surah Ash-Sharh [94:5]',
        arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
        englishTranslation: 'For indeed, with hardship will be ease.',
        attribution: 'Saheeh International',
      ),
      ContentItem(
        id: 'hadith_bukhari_1',
        contentType: ContentType.hadith,
        reference: 'Sahih al-Bukhari 1',
        arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        englishTranslation: 'Actions are but by intention.',
        attribution: 'Sahih al-Bukhari',
      ),
    ];

    return list.where((item) {
      if (contentType != null && item.contentType != contentType) return false;
      if (query.isEmpty) return true;
      return item.englishTranslation.toLowerCase().contains(query.toLowerCase()) ||
          item.arabicText.contains(query);
    }).toList();
  }
}

void main() {
  testWidgets('SearchView renders filters, triggers search, and highlights matched terms', (tester) async {
    final fakeRepo = _FakeContentRepository();
    final scope = AppScope(
      contentRepository: fakeRepo,
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: const UserPreferences(),
    );

    ContentItem? selectedItem;

    await tester.pumpWidget(
      AppScopeProvider(
        scope: scope,
        child: MaterialApp(
          home: SearchView(
            onSelectContentItem: (item) => selectedItem = item,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state: both results present
    expect(find.text('Surah Ash-Sharh [94:5]'), findsOneWidget);
    expect(find.text('Sahih al-Bukhari 1'), findsOneWidget);

    // Enter query 'hardship'
    await tester.enterText(find.byType(TextField), 'hardship');
    await tester.pumpAndSettle();

    // Only Quran item matches
    expect(find.text('Surah Ash-Sharh [94:5]'), findsOneWidget);
    expect(find.text('Sahih al-Bukhari 1'), findsNothing);
    expect(find.text('1 found'), findsOneWidget);

    // Check highlighted text contains the query
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    bool foundHighlightSpan = false;
    for (final rt in richTexts) {
      rt.text.visitChildren((span) {
        if (span is TextSpan && span.text == 'hardship') {
          foundHighlightSpan = true;
          return false;
        }
        return true;
      });
    }
    expect(foundHighlightSpan, isTrue);

    // Tap the result
    await tester.tap(find.text('Surah Ash-Sharh [94:5]'));
    await tester.pumpAndSettle();

    expect(selectedItem?.id, 'quran_94_5');
  });
}
