/// Represents a canonical Hadith collection (e.g., Sahih al-Bukhari, Sahih Muslim).
class HadithCollection {
  const HadithCollection({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.author,
    required this.description,
    required this.totalHadiths,
    required this.attribution,
  });

  final String id;
  final String nameEnglish;
  final String nameArabic;
  final String author;
  final String description;
  final int totalHadiths;
  final String attribution;

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'] as String,
      nameEnglish: json['name_en'] as String,
      nameArabic: json['name_ar'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      totalHadiths: (json['total_hadiths'] as num).toInt(),
      attribution: json['attribution'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEnglish,
      'name_ar': nameArabic,
      'author': author,
      'description': description,
      'total_hadiths': totalHadiths,
      'attribution': attribution,
    };
  }
}

/// Represents an authentic prophetic Hadith narration.
class HadithItem {
  const HadithItem({
    required this.id,
    required this.collectionId,
    required this.hadithNumber,
    required this.bookNumber,
    required this.bookNameEnglish,
    required this.bookNameArabic,
    required this.chapterName,
    required this.narrator,
    required this.arabicText,
    required this.englishTranslation,
    required this.grading,
    required this.attribution,
  });

  final String id;
  final String collectionId;
  final int hadithNumber;
  final int bookNumber;
  final String bookNameEnglish;
  final String bookNameArabic;
  final String chapterName;
  final String narrator;
  final String arabicText;
  final String englishTranslation;
  final String grading;
  final String attribution;

  String get reference => '$collectionTitle $hadithNumber';

  String get collectionTitle =>
      collectionId == 'bukhari' ? 'Sahih al-Bukhari' : 'Sahih Muslim';

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      hadithNumber: (json['hadith_number'] as num).toInt(),
      bookNumber: (json['book_number'] as num).toInt(),
      bookNameEnglish: json['book_name_en'] as String,
      bookNameArabic: json['book_name_ar'] as String,
      chapterName: json['chapter_name'] as String,
      narrator: json['narrator'] as String,
      arabicText: json['ar'] as String,
      englishTranslation: json['en'] as String,
      grading: json['grading'] as String,
      attribution: json['attribution'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'hadith_number': hadithNumber,
      'book_number': bookNumber,
      'book_name_en': bookNameEnglish,
      'book_name_ar': bookNameArabic,
      'chapter_name': chapterName,
      'narrator': narrator,
      'ar': arabicText,
      'en': englishTranslation,
      'grading': grading,
      'attribution': attribution,
    };
  }
}

/// Represents a thematic Book / Section within a Hadith collection (e.g. Book 1: Revelation).
class HadithBook {
  const HadithBook({
    required this.collectionId,
    required this.bookNumber,
    required this.nameEnglish,
    required this.nameArabic,
    required this.hadithCount,
    required this.firstHadithNumber,
    required this.lastHadithNumber,
  });

  final String collectionId;
  final int bookNumber;
  final String nameEnglish;
  final String nameArabic;
  final int hadithCount;
  final int firstHadithNumber;
  final int lastHadithNumber;
}

