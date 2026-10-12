import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/domain/models/quran_juz.dart';

void main() {
  test('QuranJuz contains exactly 30 Juz with canonical ranges', () {
    expect(QuranJuz.allJuz.length, 30);

    for (int i = 0; i < 30; i++) {
      final juz = QuranJuz.allJuz[i];
      expect(juz.number, i + 1);
      expect(juz.nameArabic, isNotEmpty);
      expect(juz.nameEnglish, isNotEmpty);
      expect(juz.startSurahNumber, greaterThanOrEqualTo(1));
      expect(juz.endSurahNumber, lessThanOrEqualTo(114));
      expect(juz.totalAyahs, greaterThan(0));
    }

    // Juz 1 begins at Al-Fatihah 1:1
    final juz1 = QuranJuz.byNumber(1);
    expect(juz1.startSurahNumber, 1);
    expect(juz1.startAyahNumber, 1);
    expect(juz1.startSurahName, 'Al-Fatihah');

    // Juz 30 ends at An-Nas 114:6
    final juz30 = QuranJuz.byNumber(30);
    expect(juz30.startSurahNumber, 78);
    expect(juz30.startAyahNumber, 1);
    expect(juz30.endSurahNumber, 114);
    expect(juz30.endAyahNumber, 6);

    // Total verses across all 30 Juz equals exact Quranic total of 6236
    final totalAyahs = QuranJuz.allJuz.map((j) => j.totalAyahs).reduce((a, b) => a + b);
    expect(totalAyahs, 6236);
  });
}
