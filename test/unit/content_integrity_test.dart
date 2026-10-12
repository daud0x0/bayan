import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentIntegrity', () {
    test('quran_data.json has complete 114 surahs and valid Uthmani text', () {
      final file = File('assets/data/quran_data.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final surahs = data['surahs'] as List<dynamic>;
      expect(surahs.length, 114);

      // Verify Surah 1 and Surah 114
      expect(surahs.first['number'], 1);
      expect(surahs.first['name_en'], 'Al-Fatihah');
      expect(surahs.last['number'], 114);
      expect(surahs.last['name_en'], 'An-Nas');

      final ayahs = data['ayahs'] as List<dynamic>;
      expect(ayahs.length, 6236);
      for (final ayah in ayahs) {
        expect(ayah['ar'], isNotEmpty);
        expect(ayah['en'], isNotEmpty);
        expect(ayah['surah'], inInclusiveRange(1, 114));
      }
    });

    test('hadith_data.json has authentic Bukhari and Muslim collections', () {
      final file = File('assets/data/hadith_data.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final collections = data['collections'] as List<dynamic>;
      expect(collections.length, 2);

      final colIds = collections.map((c) => c['id']).toList();
      expect(colIds, containsAll(['bukhari', 'muslim']));

      final hadiths = data['hadiths'] as List<dynamic>;
      expect(hadiths.length, greaterThanOrEqualTo(14000));
      for (final h in hadiths) {
        expect(h['ar'], isNotEmpty);
        expect(h['en'], isNotEmpty);
        expect(h['grading'], 'Sahih');
        expect(h['attribution'], isNotEmpty);
      }
    });

    test('categories_data.json covers 15 editorial categories with valid source links', () {
      final file = File('assets/data/categories_data.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final categories = data['categories'] as List<dynamic>;
      expect(categories.length, 15);

      for (final cat in categories) {
        expect(cat['id'], isNotEmpty);
        expect(cat['title'], isNotEmpty);
        expect(cat['description'], isNotEmpty);
        final links = cat['content_links'] as List<dynamic>;
        expect(links, isNotEmpty);
        for (final l in links) {
          expect(l['content_type'], isIn(['quran', 'hadith']));
          expect(l['relationship'], isIn(['direct', 'thematic', 'contextual']));
          expect(l['rationale'], isNotEmpty);
        }
      }
    });
  });
}
