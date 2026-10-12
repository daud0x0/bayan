import 'package:sqflite/sqflite.dart';
import '../../domain/models/bookmark_model.dart';
import '../database/app_database.dart';

/// Repository for persisting and managing user bookmarks.
class BookmarkRepository {
  BookmarkRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<Bookmark>> getBookmarks() async {
    final database = await _db.database;
    final rows = await database.query(
      'bookmarks',
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Bookmark.fromMap(r)).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final database = await _db.database;
    await database.insert(
      'bookmarks',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(String id) async {
    final database = await _db.database;
    await database.delete(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isBookmarked(String contentId) async {
    final database = await _db.database;
    final count = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COUNT(*) FROM bookmarks WHERE content_id = ?',
        [contentId],
      ),
    );
    return (count ?? 0) > 0;
  }
}
