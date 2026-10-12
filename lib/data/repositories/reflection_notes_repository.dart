import 'package:sqflite/sqflite.dart';
import '../../domain/models/reflection_note_model.dart';
import '../database/app_database.dart';

/// Repository for persisting and querying personal reflection notes (Tadabbur Journal).
/// Stored offline on the device via local SQLite.
class ReflectionNotesRepository {
  ReflectionNotesRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<ReflectionNote>> getNotes() async {
    final database = await _db.database;
    final rows = await database.query(
      'reflection_notes',
      orderBy: 'updated_at DESC',
    );
    return rows.map((r) => ReflectionNote.fromMap(r)).toList();
  }

  Future<ReflectionNote?> getNoteForContent(String contentId) async {
    final database = await _db.database;
    final rows = await database.query(
      'reflection_notes',
      where: 'content_id = ?',
      whereArgs: [contentId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReflectionNote.fromMap(rows.first);
  }

  Future<void> saveNote(ReflectionNote note) async {
    final database = await _db.database;
    await database.insert(
      'reflection_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final database = await _db.database;
    await database.delete(
      'reflection_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNoteForContent(String contentId) async {
    final database = await _db.database;
    await database.delete(
      'reflection_notes',
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
  }

  Future<bool> hasNote(String contentId) async {
    final database = await _db.database;
    final count = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COUNT(*) FROM reflection_notes WHERE content_id = ?',
        [contentId],
      ),
    );
    return (count ?? 0) > 0;
  }
}
