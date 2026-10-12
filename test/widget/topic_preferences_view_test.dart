import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/category_models.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/settings/views/topic_preferences_view.dart';

class _FakeCategoryContentRepository extends ContentRepository {
  @override
  Future<List<Category>> getCategories() async {
    return const [
      Category(
        id: 'hardship_and_hope',
        title: 'Hardship and Hope',
        description: 'Patience and relief during difficult trials.',
        iconName: 'healing',
        contentLinks: [],
      ),
      Category(
        id: 'gratitude',
        title: 'Gratitude (Shukr)',
        description: 'Thankfulness for divine blessings.',
        iconName: 'spa',
        contentLinks: [],
      ),
      Category(
        id: 'patience',
        title: 'Patience (Sabr)',
        description: 'Perseverance through adversity.',
        iconName: 'self_improvement',
        contentLinks: [],
      ),
    ];
  }
}

void main() {
  AppScope makeScope({UserPreferences prefs = const UserPreferences()}) {
    return AppScope(
      contentRepository: _FakeCategoryContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      initialPreferences: prefs,
    );
  }

  Widget wrap(AppScope scope) {
    return AppScopeProvider(
      scope: scope,
      child: const MaterialApp(home: TopicPreferencesView()),
    );
  }

  testWidgets('TopicPreferencesView shows screen title and save button', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));
    // Wait for FutureBuilder (ContentRepository loads from assets)
    await tester.pumpAndSettle();

    expect(find.text('Topic Preferences'), findsOneWidget);
    expect(find.text('Save Topic Preferences'), findsOneWidget);
  });

  testWidgets('TopicPreferencesView shows "All topics active" chip when nothing is selected',
      (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));
    await tester.pumpAndSettle();

    expect(find.text('All topics active'), findsOneWidget);
  });

  testWidgets(
      'TopicPreferencesView shows correct count chip when categories are pre-selected',
      (tester) async {
    final scope = makeScope(
      prefs: const UserPreferences(
        selectedCategoryIds: {'hardship_and_hope', 'gratitude'},
      ),
    );
    await tester.pumpWidget(wrap(scope));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 of'), findsOneWidget);
    expect(find.textContaining('prioritised'), findsOneWidget);
  });

  testWidgets('TopicPreferencesView disclaimer text is visible', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));
    await tester.pumpAndSettle();

    expect(find.textContaining('editorial discovery aids'), findsOneWidget);
    expect(find.textContaining('not authoritative rulings'), findsOneWidget);
  });
}
