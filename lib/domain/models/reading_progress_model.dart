import 'bookmark_model.dart';

/// Local reading progress marker.
class ReadingProgress {
  const ReadingProgress({
    required this.contentType,
    required this.targetId,
    required this.itemNumber,
    required this.title,
    required this.subtitle,
    required this.updatedAt,
  });

  final ContentType contentType;
  final String targetId; // Surah number or Collection ID
  final int itemNumber; // Ayah number or Hadith number
  final String title;
  final String subtitle;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'content_type': contentType.name,
      'target_id': targetId,
      'item_number': itemNumber,
      'title': title,
      'subtitle': subtitle,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      contentType: ContentType.values.byName(map['content_type'] as String),
      targetId: map['target_id'] as String,
      itemNumber: map['item_number'] as int,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
