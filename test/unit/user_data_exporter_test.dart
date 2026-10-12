import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/data/services/user_data_exporter.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/reflection_note_model.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';

void main() {
  group('UserDataExporter', () {
    final sampleBookmarks = [
      Bookmark(
        id: 'quran_1_1',
        contentType: ContentType.quran,
        contentId: 'quran_1_1',
        title: 'Surah Al-Fatihah [1:1]',
        reference: 'Surah Al-Fatihah [1:1]',
        arabicExcerpt: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translationExcerpt:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        createdAt: DateTime(2026, 10, 1, 10, 0),
      ),
      Bookmark(
        id: 'hadith_bukhari_1',
        contentType: ContentType.hadith,
        contentId: 'hadith_bukhari_1',
        title: 'Sahih al-Bukhari 1',
        reference: 'Sahih al-Bukhari 1',
        arabicExcerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        translationExcerpt: 'Actions are according to intentions.',
        createdAt: DateTime(2026, 10, 2, 11, 0),
      ),
    ];

    final sampleNotes = [
      ReflectionNote(
        id: 'note_1',
        contentId: 'quran_1_1',
        contentType: ContentType.quran,
        reference: 'Surah Al-Fatihah [1:1]',
        arabicExcerpt: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translationExcerpt:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        noteText: 'Every action must begin with sincere consciousness of divine mercy.',
        createdAt: DateTime(2026, 10, 10, 14, 30),
        updatedAt: DateTime(2026, 10, 10, 14, 30),
      ),
    ];

    test('toMarkdown generates clean markdown with notes and bookmarks', () {
      final md = UserDataExporter.toMarkdown(
        bookmarks: sampleBookmarks,
        notes: sampleNotes,
        exportDate: DateTime(2026, 10, 12),
      );

      expect(md, contains('# Quran & Hadith — Tadabbur Journal & Bookmarks'));
      expect(md, contains('Exported offline on 2026-10-12'));
      expect(md, contains('## 📝 Tadabbur Reflections (1)'));
      expect(md, contains('### 1. Surah Al-Fatihah [1:1] (Quran)'));
      expect(md, contains('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'));
      expect(md, contains('Every action must begin with sincere consciousness of divine mercy.'));
      expect(md, contains('## 🔖 Bookmarks (2)'));
      expect(md, contains('**Surah Al-Fatihah [1:1]** (Quran)'));
      expect(md, contains('**Sahih al-Bukhari 1** (Hadith)'));
    });

    test('toMarkdown handles empty lists gracefully', () {
      final md = UserDataExporter.toMarkdown(
        bookmarks: const [],
        notes: const [],
        exportDate: DateTime(2026, 10, 12),
      );

      expect(md, contains('## 📝 Tadabbur Reflections (0)'));
      expect(md, contains('_No reflection notes recorded yet._'));
      expect(md, contains('## 🔖 Bookmarks (0)'));
      expect(md, contains('_No bookmarks saved yet._'));
    });

    test('toJsonString formats valid JSON payload', () {
      final jsonStr = UserDataExporter.toJsonString(
        bookmarks: sampleBookmarks,
        notes: sampleNotes,
        preferences: const UserPreferences(arabicFontSize: 28.0),
        exportDate: DateTime(2026, 10, 12, 12, 0),
      );

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['version'], 1);
      expect(decoded['exportedAt'], isNotNull);
      expect((decoded['reflections'] as List).length, 1);
      expect((decoded['bookmarks'] as List).length, 2);
      expect((decoded['preferences'] as Map)['arabicFontSize'], 28.0);
    });
  });
}
