import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/data/database/app_database.dart';
import 'package:quran_hadis/data/repositories/reflection_notes_repository.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/reflection_note_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ReflectionNotesRepository repo;

  setUp(() async {
    db = AppDatabase.inMemory();
    repo = ReflectionNotesRepository(db: db);
  });

  test('ReflectionNotesRepository stores, retrieves, and deletes notes in-memory', () async {
    expect(await repo.getNotes(), isEmpty);
    expect(await repo.hasNote('quran_1_1'), isFalse);

    final now = DateTime.now();
    final note = ReflectionNote(
      id: 'note_1',
      contentId: 'quran_1_1',
      contentType: ContentType.quran,
      reference: 'Surah Al-Fatihah [1:1]',
      arabicExcerpt: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      translationExcerpt: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      noteText: 'Reflecting on the infinite mercy of Ar-Rahman.',
      createdAt: now,
      updatedAt: now,
    );

    await repo.saveNote(note);

    expect(await repo.hasNote('quran_1_1'), isTrue);
    final notes = await repo.getNotes();
    expect(notes.length, 1);
    expect(notes.first.id, 'note_1');
    expect(notes.first.noteText, 'Reflecting on the infinite mercy of Ar-Rahman.');

    final single = await repo.getNoteForContent('quran_1_1');
    expect(single, isNotNull);
    expect(single?.id, 'note_1');

    // Update note
    final updated = note.copyWith(noteText: 'Updated contemplation on mercy.');
    await repo.saveNote(updated);
    final reloaded = await repo.getNoteForContent('quran_1_1');
    expect(reloaded?.noteText, 'Updated contemplation on mercy.');

    // Delete
    await repo.deleteNote('note_1');
    expect(await repo.hasNote('quran_1_1'), isFalse);
    expect(await repo.getNotes(), isEmpty);
  });
}
