/// Content types recognized throughout the application.
enum ContentType {
  quran,
  hadith;

  String get displayName => this == ContentType.quran ? 'Quran' : 'Hadith';
}

/// Represents a locally saved bookmark.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.reference,
    required this.arabicExcerpt,
    required this.translationExcerpt,
    required this.createdAt,
  });

  final String id;
  final ContentType contentType;
  final String contentId;
  final String title;
  final String reference;
  final String arabicExcerpt;
  final String translationExcerpt;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content_type': contentType.name,
      'content_id': contentId,
      'title': title,
      'reference': reference,
      'arabic_excerpt': arabicExcerpt,
      'translation_excerpt': translationExcerpt,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      contentType: ContentType.values.byName(map['content_type'] as String),
      contentId: map['content_id'] as String,
      title: map['title'] as String,
      reference: map['reference'] as String,
      arabicExcerpt: (map['arabic_excerpt'] as String?) ?? '',
      translationExcerpt: (map['translation_excerpt'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
