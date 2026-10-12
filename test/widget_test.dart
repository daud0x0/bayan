import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/app.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';

void main() {
  testWidgets('App navigation scaffold displays 4 primary destinations', (WidgetTester tester) async {
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
        child: const QuranHadithApp(),
      ),
    );

    // Verify 4 bottom navigation tabs are present per Section 4 of the Product Plan
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
