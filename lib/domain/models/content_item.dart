import 'bookmark_model.dart';
import 'category_models.dart';

/// Unified polymorphic content item representation for the Discovery Feed,
/// Search results, and Shareable Wallpaper cards.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.contentType,
    required this.reference,
    required this.arabicText,
    required this.englishTranslation,
    required this.attribution,
    this.narrator,
    this.grading,
    this.categoryIds = const [],
    this.categoryRationales = const {},
    this.relationshipTypes = const {},
    this.surahNumber,
    this.ayahNumber,
    this.collectionId,
    this.hadithNumber,
  });

  final String id;
  final ContentType contentType;
  final String reference;
  final String arabicText;
  final String englishTranslation;
  final String attribution;
  final String? narrator;
  final String? grading;
  final List<String> categoryIds;
  final Map<String, String> categoryRationales;
  final Map<String, RelationshipType> relationshipTypes;
  final int? surahNumber;
  final int? ayahNumber;
  final String? collectionId;
  final int? hadithNumber;

  bool get isQuran => contentType == ContentType.quran;
  bool get isHadith => contentType == ContentType.hadith;
}
