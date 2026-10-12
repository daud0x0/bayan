import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/core/utils/arabic_utils.dart';

void main() {
  group('ArabicUtils', () {
    test('stripTashkeel removes all harakat and diacritics', () {
      const input = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      final result = ArabicUtils.stripTashkeel(input);
      expect(result, 'بسم الله الرحمن الرحيم');
    });

    test('normalizeForSearch handles variants of Alif and Taa Marbuta', () {
      const input = 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ';
      final result = ArabicUtils.normalizeForSearch(input);
      // Alif variants normalized, harakat stripped, Taa Marbuta normalized
      expect(result, 'انما الاعمال بالنيات');
    });

    test('containsNormalized matches search query diacritic-insensitively', () {
      const source = 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا';
      expect(ArabicUtils.containsNormalized(source, 'العسر'), isTrue);
      expect(ArabicUtils.containsNormalized(source, 'يسرا'), isTrue);
      expect(ArabicUtils.containsNormalized(source, 'صبر'), isFalse);
    });
  });
}
