import 'bookmark_model.dart';

/// Personal reflection / Tadabbur journal entry attached to an Ayah or Hadith.
/// Stored 100% offline in local SQLite.
class ReflectionNote {
  const ReflectionNote({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.reference,
    required this.arabicExcerpt,
    required this.translationExcerpt,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String contentId;
  final ContentType contentType;
  final String reference;
  final String arabicExcerpt;
  final String translationExcerpt;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content_id': contentId,
      'content_type': contentType.name,
      'reference': reference,
      'arabic_excerpt': arabicExcerpt,
      'translation_excerpt': translationExcerpt,
      'note_text': noteText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReflectionNote.fromMap(Map<String, dynamic> map) {
    return ReflectionNote(
      id: map['id'] as String,
      contentId: map['content_id'] as String,
      contentType: ContentType.values.byName(map['content_type'] as String),
      reference: map['reference'] as String,
      arabicExcerpt: (map['arabic_excerpt'] as String?) ?? '',
      translationExcerpt: (map['translation_excerpt'] as String?) ?? '',
      noteText: map['note_text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ReflectionNote copyWith({
    String? id,
    String? contentId,
    ContentType? contentType,
    String? reference,
    String? arabicExcerpt,
    String? translationExcerpt,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReflectionNote(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      reference: reference ?? this.reference,
      arabicExcerpt: arabicExcerpt ?? this.arabicExcerpt,
      translationExcerpt: translationExcerpt ?? this.translationExcerpt,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
