import 'dart:convert';
import '../../domain/models/bookmark_model.dart';
import '../../domain/models/reflection_note_model.dart';
import '../../domain/models/user_preferences.dart';

/// Utility service to export user reflection notes, bookmarks, and preferences
/// into portable offline Markdown or JSON formats.
class UserDataExporter {
  const UserDataExporter();

  /// Generates a readable Markdown document containing user reflections and bookmarks.
  static String toMarkdown({
    required List<Bookmark> bookmarks,
    required List<ReflectionNote> notes,
    DateTime? exportDate,
  }) {
    final date = exportDate ?? DateTime.now();
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final buffer = StringBuffer()
      ..writeln('# Quran & Hadith — Tadabbur Journal & Bookmarks')
      ..writeln('*Exported offline on $dateStr*')
      ..writeln();

    // Reflections section
    buffer
      ..writeln('## 📝 Tadabbur Reflections (${notes.length})')
      ..writeln();

    if (notes.isEmpty) {
      buffer.writeln('_No reflection notes recorded yet._');
      buffer.writeln();
    } else {
      for (var i = 0; i < notes.length; i++) {
        final note = notes[i];
        final typeLabel =
            note.contentType == ContentType.quran ? 'Quran' : 'Hadith';
        buffer.writeln('### ${i + 1}. ${note.reference} ($typeLabel)');

        if (note.arabicExcerpt.trim().isNotEmpty) {
          buffer.writeln('> ${note.arabicExcerpt.trim()}');
          buffer.writeln('>');
        }
        if (note.translationExcerpt.trim().isNotEmpty) {
          buffer.writeln('> "${note.translationExcerpt.trim()}"');
          buffer.writeln();
        }

        buffer.writeln('**My Reflection:**');
        buffer.writeln(note.noteText.trim());
        buffer.writeln();

        final createdStr =
            '${note.createdAt.year}-${note.createdAt.month.toString().padLeft(2, '0')}-${note.createdAt.day.toString().padLeft(2, '0')}';
        buffer.writeln('*Recorded on $createdStr*');
        buffer.writeln();
        buffer.writeln('---');
        buffer.writeln();
      }
    }

    // Bookmarks section
    buffer
      ..writeln('## 🔖 Bookmarks (${bookmarks.length})')
      ..writeln();

    if (bookmarks.isEmpty) {
      buffer.writeln('_No bookmarks saved yet._');
      buffer.writeln();
    } else {
      for (var i = 0; i < bookmarks.length; i++) {
        final b = bookmarks[i];
        final typeLabel =
            b.contentType == ContentType.quran ? 'Quran' : 'Hadith';
        buffer.writeln('- **${b.reference}** ($typeLabel)');
        if (b.translationExcerpt.trim().isNotEmpty) {
          buffer.writeln('  > "${b.translationExcerpt.trim()}"');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('*Exported from Quran & Hadith Discovery (100% Offline-First)*');
    return buffer.toString();
  }

  /// Generates a structured JSON string containing user data for technical backups.
  static String toJsonString({
    required List<Bookmark> bookmarks,
    required List<ReflectionNote> notes,
    UserPreferences? preferences,
    DateTime? exportDate,
  }) {
    final date = exportDate ?? DateTime.now();
    final data = <String, dynamic>{
      'version': 1,
      'exportedAt': date.toIso8601String(),
      'reflections': notes.map((n) => n.toMap()).toList(),
      'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
      if (preferences != null) 'preferences': preferences.toMap(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
