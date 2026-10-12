import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/bootstrap.dart';
import 'package:quran_hadis/core/widgets/auto_scroll_bar.dart';
import 'package:quran_hadis/data/repositories/bookmark_repository.dart';
import 'package:quran_hadis/data/repositories/content_repository.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/data/repositories/reading_progress_repository.dart';
import 'package:quran_hadis/data/repositories/reflection_notes_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/hadith_models.dart';
import 'package:quran_hadis/domain/models/quran_models.dart';
import 'package:quran_hadis/domain/models/reflection_note_model.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/features/hadith/views/hadith_reader_view.dart';
import 'package:quran_hadis/features/quran/views/quran_reader_view.dart';

class _MockBookmarkRepository extends BookmarkRepository {
  final List<Bookmark> _items = [];
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
  @override
  Future<List<ReflectionNote>> getNotes() async => List.unmodifiable(_notes);
  @override
  Future<ReflectionNote?> getNoteForContent(String contentId) async => null;
}

class _FakeContentRepository extends ContentRepository {
  @override
  Future<List<QuranAyah>> getAyahs(int surahNumber) async {
    return const [
      QuranAyah(
        surahNumber: 1,
        ayahNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        englishTranslation: 'In the name of Allah...',
      ),
    ];
  }

  @override
  Future<List<HadithItem>> getHadiths({String? collectionId, int? bookNumber}) async {
    return const [];
  }
}

void main() {
  AppScope makeScope({UserPreferences prefs = const UserPreferences()}) {
    return AppScope(
      contentRepository: _FakeContentRepository(),
      bookmarkRepository: _MockBookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      reflectionNotesRepository: _MockReflectionNotesRepository(),
      initialPreferences: prefs,
    );
  }

  group('AutoScrollBar Component Tests', () {
    testWidgets('renders play state, all speed options, and close button',
        (tester) async {
      var isPlaying = true;
      var currentSpeed = 1.0;
      var closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollBar(
              isPlaying: isPlaying,
              speed: currentSpeed,
              onPlayPauseToggle: () => isPlaying = !isPlaying,
              onSpeedSelected: (s) => currentSpeed = s,
              onClose: () => closeCalled = true,
            ),
          ),
        ),
      );

      // Play / Pause icon (currently playing, so pause icon is rendered)
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      // Speeds: 0.5x, 1x, 1.5x, 2x
      expect(find.text('0.5x'), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);

      // Close button
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap speed 1.5x
      await tester.tap(find.text('1.5x'));
      await tester.pump();
      expect(currentSpeed, 1.5);

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(isPlaying, false);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(closeCalled, true);
    });
  });

  group('QuranReaderView Auto-Scroll Integration Tests', () {
    const testSurah = QuranSurah(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameTranslation: 'The Opening',
      ayahCount: 7,
      revelationType: 'Meccan',
    );

    testWidgets('toggles auto-scroll bar and dismisses with close button',
        (tester) async {
      final scope = makeScope();
      await tester.pumpWidget(
        AppScopeProvider(
          scope: scope,
          child: const MaterialApp(
            home: QuranReaderView(surah: testSurah),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially AutoScrollBar is not present
      expect(find.byType(AutoScrollBar), findsNothing);

      // Tap auto scroll button in AppBar
      final autoScrollBtn = find.byTooltip('Start Auto-Scroll');
      expect(autoScrollBtn, findsOneWidget);
      await tester.tap(autoScrollBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // AutoScrollBar is now visible with play/pause and speeds
      expect(find.byType(AutoScrollBar), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);

      // Tap close button on AutoScrollBar
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // AutoScrollBar is dismissed
      expect(find.byType(AutoScrollBar), findsNothing);
    });
  });

  group('HadithReaderView Auto-Scroll Integration Tests', () {
    const testHadith = HadithItem(
      id: 'bukhari_1',
      collectionId: 'bukhari',
      hadithNumber: 1,
      bookNumber: 1,
      bookNameArabic: 'كتاب بدء الوحي',
      bookNameEnglish: 'Revelation',
      chapterName: 'How divine inspiration began',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      englishTranslation: 'Actions are by intentions.',
      narrator: 'Umar bin Al-Khattab',
      grading: 'Sahih',
      attribution: 'Sahih al-Bukhari',
    );

    testWidgets('toggles auto-scroll bar and dismisses with close button',
        (tester) async {
      final scope = makeScope();
      await tester.pumpWidget(
        AppScopeProvider(
          scope: scope,
          child: MaterialApp(
            home: HadithReaderView(hadith: testHadith),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially AutoScrollBar is not present
      expect(find.byType(AutoScrollBar), findsNothing);

      // Tap auto scroll button in AppBar
      final autoScrollBtn = find.byTooltip('Start Auto-Scroll');
      expect(autoScrollBtn, findsOneWidget);
      await tester.tap(autoScrollBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // AutoScrollBar is now visible
      expect(find.byType(AutoScrollBar), findsOneWidget);

      // Tap close on AutoScrollBar
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // AutoScrollBar dismissed
      expect(find.byType(AutoScrollBar), findsNothing);
    });
  });
}
