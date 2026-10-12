import 'package:sqflite/sqflite.dart';
import '../../domain/models/bookmark_model.dart';
import '../../domain/models/reading_progress_model.dart';
import '../database/app_database.dart';

/// Repository for persisting reading progress.
class ReadingProgressRepository {
  ReadingProgressRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<ReadingProgress?> getProgress(ContentType contentType) async {
    final database = await _db.database;
    final rows = await database.query(
      'reading_progress',
      where: 'content_type = ?',
      whereArgs: [contentType.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReadingProgress.fromMap(rows.first);
  }

  Future<void> saveProgress(ReadingProgress progress) async {
    final database = await _db.database;
    await database.insert(
      'reading_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
