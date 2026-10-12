import 'bookmark_model.dart';

/// Relationship nature of a category mapping per Section 5.2 of the Product Plan.
enum RelationshipType {
  direct,
  thematic,
  contextual;

  String get label {
    switch (this) {
      case RelationshipType.direct:
        return 'Direct subject';
      case RelationshipType.thematic:
        return 'Thematic lesson';
      case RelationshipType.contextual:
        return 'Contextual reflection';
    }
  }
}

/// Link mapping a specific Quran ayah or Hadith narration to an editorial category.
class CategoryLink {
  const CategoryLink({
    required this.contentType,
    required this.contentId,
    required this.reference,
    required this.relationship,
    required this.rationale,
  });

  final ContentType contentType;
  final String contentId;
  final String reference;
  final RelationshipType relationship;
  final String rationale;

  factory CategoryLink.fromJson(Map<String, dynamic> json) {
    return CategoryLink(
      contentType: ContentType.values.byName(json['content_type'] as String),
      contentId: json['content_id'] as String,
      reference: json['reference'] as String,
      relationship: RelationshipType.values.byName(json['relationship'] as String),
      rationale: json['rationale'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType.name,
      'content_id': contentId,
      'reference': reference,
      'relationship': relationship.name,
      'rationale': rationale,
    };
  }
}

/// Editorial discovery category.
class Category {
  const Category({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.contentLinks,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<CategoryLink> contentLinks;

  int get itemCount => contentLinks.length;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['icon'] as String,
      contentLinks: (json['content_links'] as List<dynamic>?)
              ?.map((e) => CategoryLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': iconName,
      'content_links': contentLinks.map((e) => e.toJson()).toList(),
    };
  }
}
