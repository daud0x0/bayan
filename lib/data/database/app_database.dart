import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Local SQLite Database manager.
/// Complies with Section 9 of the Product Plan.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // If running on Desktop or during tests, configure FFI databaseFactory
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      final docDir = await getApplicationSupportDirectory();
      dbPath = p.join(docDir.path, 'quran_hadith_app.db');
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, 'quran_hadith_app.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migration hooks for future versions
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        content_type TEXT NOT NULL,
        content_id TEXT NOT NULL,
        title TEXT NOT NULL,
        reference TEXT NOT NULL,
        arabic_excerpt TEXT,
        translation_excerpt TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Reading progress table (one primary entry per content type)
    await db.execute('''
      CREATE TABLE reading_progress (
        content_type TEXT PRIMARY KEY,
        target_id TEXT NOT NULL,
        item_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for fast lookup
    await db.execute('CREATE INDEX idx_bookmarks_content_id ON bookmarks(content_id);');
  }

  Future<void> clearAllUserData() async {
    final db = await database;
    await db.delete('bookmarks');
    await db.delete('reading_progress');
  }
}
