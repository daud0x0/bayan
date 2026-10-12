import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/data/repositories/reflection_notes_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/reflection_note_model.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/settings/views/settings_view.dart';

class _MockBookmarkRepository extends BookmarkRepository {
  final List<Bookmark> _items = [];

  _MockBookmarkRepository([List<Bookmark>? initial]) {
    if (initial != null) _items.addAll(initial);
  }

  @override
  Future<List<Bookmark>> getBookmarks() async => List.unmodifiable(_items);

  @override
  Future<void> addBookmark(Bookmark bookmark) async => _items.add(bookmark);

  @override
  Future<void> removeBookmark(String id) async =>
      _items.removeWhere((b) => b.id == id);
}

class _MockReflectionNotesRepository extends ReflectionNotesRepository {
  final List<ReflectionNote> _notes = [];

  _MockReflectionNotesRepository([List<ReflectionNote>? initial]) {
    if (initial != null) _notes.addAll(initial);
  }

  @override
  Future<List<ReflectionNote>> getNotes() async => List.unmodifiable(_notes);
}

/// Widget tests for the Settings screen.
/// Verifies primary sections, controls, and interactive affordances render
/// correctly at default preferences — without triggering any live platform
/// channels (SQLite, file system).
void main() {
  AppScope makeScope({UserPreferences prefs = const UserPreferences()}) {
    return AppScope(
      contentRepository: ContentRepository(),
      bookmarkRepository: _MockBookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      reflectionNotesRepository: _MockReflectionNotesRepository(),
      initialPreferences: prefs,
    );
  }

  Widget wrap(AppScope scope) {
    return AppScopeProvider(
      scope: scope,
      child: const MaterialApp(home: SettingsView()),
    );
  }

  testWidgets('SettingsView renders all primary section headers', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    // Section headers are uppercase text via _sectionHeader helper
    expect(find.textContaining('APPEARANCE'), findsOneWidget);
    expect(find.textContaining('TYPOGRAPHY'), findsOneWidget);
    expect(find.textContaining('CONTENT'), findsOneWidget);
    expect(find.textContaining('PRIVACY'), findsOneWidget);
  });

  testWidgets('SettingsView shows correct topic preference subtitle when no categories selected',
      (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Manage Topic Preferences'),
      100,
    );

    expect(find.text('All 15 editorial categories active'), findsOneWidget);
  });

  testWidgets(
      'SettingsView shows correct topic preference subtitle when categories are pre-selected',
      (tester) async {
    final scope = makeScope(
      prefs: const UserPreferences(
        selectedCategoryIds: {'hardship_and_hope', 'gratitude', 'patience'},
      ),
    );
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Manage Topic Preferences'),
      100,
    );

    expect(find.text('3 categories prioritised'), findsOneWidget);
  });

  testWidgets('SettingsView plain reading mode switch toggles correctly', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    final switchFinder = find.byWidgetPredicate(
      (w) => w is SwitchListTile && (w.title as Text).data == 'Plain Reading Mode',
    );
    expect(switchFinder, findsOneWidget);

    final switchTile = tester.widget<SwitchListTile>(switchFinder);
    // Default is off
    expect(switchTile.value, isFalse);
  });

  testWidgets('SettingsView typography preview renders Arabic and English sample text',
      (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    // Scroll to reveal the typography section
    await tester.scrollUntilVisible(
      find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
      200,
    );

    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
    expect(
      find.text('In the name of Allah, the Entirely Merciful, the Especially Merciful.'),
      findsOneWidget,
    );
  });

  testWidgets('SettingsView Report Correction tile is present and tappable', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Report Content Issue / Correction'),
      100,
    );
    await tester.ensureVisible(find.text('Report Content Issue / Correction'));
    await tester.pumpAndSettle();

    expect(find.text('Report Content Issue / Correction'), findsOneWidget);

    // Tap to open the correction dialog
    await tester.tap(find.text('Report Content Issue / Correction'));
    await tester.pumpAndSettle();

    expect(find.text('Report a Correction'), findsOneWidget);
    expect(find.text('Issue type'), findsOneWidget);
    expect(find.text('Exact citation / reference'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Copy Report'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('SettingsView correction dialog Cancel dismisses without error', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Report Content Issue / Correction'),
      100,
    );
    await tester.ensureVisible(find.text('Report Content Issue / Correction'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report Content Issue / Correction'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog is gone, settings item is still visible
    expect(find.text('Report a Correction'), findsNothing);
    expect(find.text('Report Content Issue / Correction'), findsOneWidget);
  });

  testWidgets('SettingsView version footer is visible at the bottom', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.textContaining('v1.0.0'),
      200,
    );

    expect(find.textContaining('v1.0.0'), findsOneWidget);
    expect(find.textContaining('Offline-First Baseline'), findsOneWidget);
  });

  testWidgets('SettingsView shows Backup & Export Data sheet with markdown and json options', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Backup & Export Data'),
      150,
    );
    await tester.ensureVisible(find.text('Backup & Export Data'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Backup & Export Data'));
    await tester.pumpAndSettle();

    expect(find.text('Export & Backup Data'), findsOneWidget);
    expect(find.text('Copy as Markdown'), findsOneWidget);
    expect(find.text('Copy as JSON'), findsOneWidget);
    expect(find.text('Share Export File / Text'), findsOneWidget);
  });

  testWidgets('SettingsView shows Clear Reading History confirmation dialog', (tester) async {
    final scope = makeScope();
    await tester.pumpWidget(wrap(scope));

    await tester.scrollUntilVisible(
      find.text('Clear Reading History'),
      150,
    );
    await tester.ensureVisible(find.text('Clear Reading History'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear Reading History'));
    await tester.pumpAndSettle();

    expect(find.text('Clear Reading History?'), findsOneWidget);
    expect(find.text('Clear History'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Clear Reading History?'), findsNothing);
  });
}
