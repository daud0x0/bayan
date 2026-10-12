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
import 'package:quran_hadis/features/reflections/views/reflection_note_sheet.dart';

class _FakeReflectionNotesRepository extends ReflectionNotesRepository {
  final Map<String, ReflectionNote> _storage = {};

  @override
  Future<List<ReflectionNote>> getNotes() async => _storage.values.toList();

  @override
  Future<ReflectionNote?> getNoteForContent(String contentId) async {
    for (final note in _storage.values) {
      if (note.contentId == contentId) return note;
    }
    return null;
  }

  @override
  Future<void> saveNote(ReflectionNote note) async {
    _storage[note.id] = note;
  }

  @override
  Future<void> deleteNote(String id) async {
    _storage.remove(id);
  }

  @override
  Future<bool> hasNote(String contentId) async {
    return _storage.values.any((n) => n.contentId == contentId);
  }
}

void main() {
  late _FakeReflectionNotesRepository repo;
  late AppScope scope;

  setUp(() {
    repo = _FakeReflectionNotesRepository();
    scope = AppScope(
      contentRepository: ContentRepository(),
      bookmarkRepository: BookmarkRepository(),
      readingProgressRepository: ReadingProgressRepository(),
      preferencesRepository: PreferencesRepository(),
      reflectionNotesRepository: repo,
      initialPreferences: const UserPreferences(),
    );
  });

  Widget wrap(Widget child) {
    return AppScopeProvider(
      scope: scope,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('ReflectionNoteSheet renders excerpt, input field, and saves new note', (tester) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ReflectionNoteSheet.show(
                context,
                contentId: 'quran_1_1',
                contentType: ContentType.quran,
                reference: 'Surah Al-Fatihah [1:1]',
                arabicExcerpt: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                translationExcerpt: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );

    // Tap to open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Reflection (Tadabbur)'), findsOneWidget);
    expect(find.text('Surah Al-Fatihah [1:1]'), findsOneWidget);
    expect(find.text('Save Reflection'), findsOneWidget);

    // Enter reflection text
    await tester.enterText(
      find.byType(TextField),
      'Reflecting on beginning all actions in the divine name.',
    );
    await tester.pump();

    // Tap Save Reflection
    await tester.tap(find.text('Save Reflection'));
    await tester.pumpAndSettle();

    // Verify saved in repository
    final savedNotes = await repo.getNotes();
    expect(savedNotes.length, 1);
    expect(savedNotes.first.contentId, 'quran_1_1');
    expect(savedNotes.first.noteText, 'Reflecting on beginning all actions in the divine name.');
  });

  testWidgets('ReflectionNoteSheet pre-fills existing note and supports editing', (tester) async {
    final now = DateTime.now();
    final existing = ReflectionNote(
      id: 'note_existing',
      contentId: 'hadith_bukhari_1',
      contentType: ContentType.hadith,
      reference: 'Sahih al-Bukhari 1',
      arabicExcerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      translationExcerpt: 'Actions are according to intentions.',
      noteText: 'Purifying intentions before every deed.',
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveNote(existing);

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ReflectionNoteSheet.show(
                context,
                contentId: 'hadith_bukhari_1',
                contentType: ContentType.hadith,
                reference: 'Sahih al-Bukhari 1',
                arabicExcerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
                translationExcerpt: 'Actions are according to intentions.',
                existingNote: existing,
              );
            },
            child: const Text('Edit Sheet'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Tadabbur Reflection'), findsOneWidget);
    expect(find.text('Update Note'), findsOneWidget);
    expect(find.text('Purifying intentions before every deed.'), findsOneWidget);

    // Update text
    await tester.enterText(
      find.byType(TextField),
      'Always align your heart before any action.',
    );
    await tester.pump();

    await tester.tap(find.text('Update Note'));
    await tester.pumpAndSettle();

    final updated = await repo.getNoteForContent('hadith_bukhari_1');
    expect(updated?.noteText, 'Always align your heart before any action.');
  });
}
