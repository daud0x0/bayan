import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Local SQLite Database manager.
/// Complies with Section 9 of the Product Plan.
class AppDatabase {
  AppDatabase._({this.isInMemory = false});
  static final AppDatabase instance = AppDatabase._();
  factory AppDatabase.inMemory() => AppDatabase._(isInMemory: true);

  final bool isInMemory;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (isInMemory) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    }

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
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createReflectionNotesTable(db);
        }
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

    // Reflection notes table
    await _createReflectionNotesTable(db);

    // Create indexes for fast lookup
    await db.execute('CREATE INDEX idx_bookmarks_content_id ON bookmarks(content_id);');
  }

  Future<void> _createReflectionNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reflection_notes (
        id TEXT PRIMARY KEY,
        content_id TEXT NOT NULL,
        content_type TEXT NOT NULL,
        reference TEXT NOT NULL,
        arabic_excerpt TEXT,
        translation_excerpt TEXT,
        note_text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_content_id ON reflection_notes(content_id);');
  }

  Future<void> clearAllUserData() async {
    final db = await database;
    await db.delete('bookmarks');
    await db.delete('reading_progress');
    await db.delete('reflection_notes');
  }
}
