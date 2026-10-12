import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/content_item.dart';
import 'package:quran_hadis/visual_engine/export/card_exporter.dart';

void main() {
  group('CardExporter', () {
    test('formats complete plain text representation with exact attribution and reference', () {
      final item = ContentItem(
        id: 'hadith_bukhari_1',
        contentType: ContentType.hadith,
        reference: 'Sahih al-Bukhari 1',
        arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        englishTranslation: 'Actions are but by intention.',
        attribution: 'Sahih al-Bukhari • English Translation: Dr. M. Muhsin Khan',
        narrator: 'Umar ibn al-Khattab',
        grading: 'Sahih',
      );

      final text = CardExporter.formatPlainText(item);

      expect(text, contains('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'));
      expect(text, contains('"Actions are but by intention."'));
      expect(text, contains('— Sahih al-Bukhari 1'));
      expect(text, contains('Narrated by: Umar ibn al-Khattab'));
      expect(text, contains('Grading: Sahih'));
      expect(text, contains('Attribution: Sahih al-Bukhari • English Translation: Dr. M. Muhsin Khan'));
    });
  });
}
