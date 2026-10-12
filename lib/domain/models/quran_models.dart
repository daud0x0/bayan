/// Represents a Surah (Chapter) in the Holy Quran.
class QuranSurah {
  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTranslation,
    required this.ayahCount,
    required this.revelationType,
  });

  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTranslation;
  final int ayahCount;
  final String revelationType;

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: (json['number'] as num).toInt(),
      nameArabic: json['name_ar'] as String,
      nameEnglish: json['name_en'] as String,
      nameTranslation: json['name_translation'] as String,
      ayahCount: (json['ayah_count'] as num).toInt(),
      revelationType: json['revelation_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_ar': nameArabic,
      'name_en': nameEnglish,
      'name_translation': nameTranslation,
      'ayah_count': ayahCount,
      'revelation_type': revelationType,
    };
  }
}

/// Represents an Ayah (Verse) in the Holy Quran.
class QuranAyah {
  const QuranAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.englishTranslation,
    this.translationAttribution = 'Saheeh International',
  });

  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String englishTranslation;
  final String translationAttribution;

  String get id => '${surahNumber}_$ayahNumber';
  String get reference => 'Surah $surahNumber:$ayahNumber';

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      surahNumber: (json['surah'] as num).toInt(),
      ayahNumber: (json['ayah'] as num).toInt(),
      arabicText: json['ar'] as String,
      englishTranslation: json['en'] as String,
      translationAttribution: (json['translation_attribution'] as String?) ?? 'Saheeh International',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surahNumber,
      'ayah': ayahNumber,
      'ar': arabicText,
      'en': englishTranslation,
      'translation_attribution': translationAttribution,
    };
  }
}
