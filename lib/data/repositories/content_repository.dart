import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/utils/arabic_utils.dart';
import '../../domain/models/bookmark_model.dart';
import '../../domain/models/category_models.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/hadith_models.dart';
import '../../domain/models/quran_models.dart';

/// Repository responsible for loading and querying offline Quran, Hadith, and Category data.
/// Complies with Section 6, 7, and 8 of the Product Plan.
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<QuranSurah>? _cachedSurahs;
  List<QuranAyah>? _cachedAyahs;
  List<HadithCollection>? _cachedCollections;
  List<HadithItem>? _cachedHadiths;
  List<Category>? _cachedCategories;
  List<ContentItem>? _cachedContentItems;

  Future<void> initialize() async {
    await Future.wait([
      _loadQuranData(),
      _loadHadithData(),
      _loadCategoriesData(),
    ]);
    _buildContentItems();
  }

  Future<void> _loadQuranData() async {
    if (_cachedSurahs != null && _cachedAyahs != null) return;
    final jsonStr = await _bundle.loadString('assets/data/quran_data.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    final surahList = (data['surahs'] as List<dynamic>)
        .map((e) => QuranSurah.fromJson(e as Map<String, dynamic>))
        .toList();
    final ayahList = (data['ayahs'] as List<dynamic>)
        .map((e) => QuranAyah.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedSurahs = surahList;
    _cachedAyahs = ayahList;
  }

  Future<void> _loadHadithData() async {
    if (_cachedCollections != null && _cachedHadiths != null) return;
    final jsonStr = await _bundle.loadString('assets/data/hadith_data.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    final colList = (data['collections'] as List<dynamic>)
        .map((e) => HadithCollection.fromJson(e as Map<String, dynamic>))
        .toList();
    final hadithList = (data['hadiths'] as List<dynamic>)
        .map((e) => HadithItem.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedCollections = colList;
    _cachedHadiths = hadithList;
  }

  Future<void> _loadCategoriesData() async {
    if (_cachedCategories != null) return;
    final jsonStr = await _bundle.loadString('assets/data/categories_data.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    final catList = (data['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedCategories = catList;
  }

  void _buildContentItems() {
    if (_cachedAyahs == null || _cachedHadiths == null || _cachedCategories == null) {
      return;
    }

    final items = <ContentItem>[];

    // Helper map: contentId -> list of (categoryId, rationale, relationship)
    final linkMap = <String, List<_CategoryLinkMetadata>>{};
    for (final cat in _cachedCategories!) {
      for (final link in cat.contentLinks) {
        final list = linkMap.putIfAbsent(link.contentId, () => []);
        list.add(_CategoryLinkMetadata(cat.id, link.rationale, link.relationship));
      }
    }

    // Map Quran Ayahs
    for (final ayah in _cachedAyahs!) {
      final surah = _cachedSurahs?.firstWhere(
        (s) => s.number == ayah.surahNumber,
        orElse: () => QuranSurah(
          number: ayah.surahNumber,
          nameArabic: '',
          nameEnglish: 'Surah ${ayah.surahNumber}',
          nameTranslation: '',
          ayahCount: 0,
          revelationType: 'Meccan',
        ),
      );

      final links = linkMap[ayah.id] ?? [];
      final categoryIds = links.map((l) => l.categoryId).toList();
      final rationales = {for (var l in links) l.categoryId: l.rationale};
      final relationships = {for (var l in links) l.categoryId: l.relationship};

      items.add(
        ContentItem(
          id: 'quran_${ayah.id}',
          contentType: ContentType.quran,
          reference: 'Surah ${surah?.nameEnglish ?? ayah.surahNumber} [${ayah.surahNumber}:${ayah.ayahNumber}]',
          arabicText: ayah.arabicText,
          englishTranslation: ayah.englishTranslation,
          attribution: 'The Quran: English Meanings by ${ayah.translationAttribution}',
          categoryIds: categoryIds,
          categoryRationales: rationales,
          relationshipTypes: relationships,
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
        ),
      );
    }

    // Map Hadiths
    for (final hadith in _cachedHadiths!) {
      final links = linkMap[hadith.id] ?? [];
      final categoryIds = links.map((l) => l.categoryId).toList();
      final rationales = {for (var l in links) l.categoryId: l.rationale};
      final relationships = {for (var l in links) l.categoryId: l.relationship};

      items.add(
        ContentItem(
          id: 'hadith_${hadith.id}',
          contentType: ContentType.hadith,
          reference: hadith.reference,
          arabicText: hadith.arabicText,
          englishTranslation: hadith.englishTranslation,
          attribution: hadith.attribution,
          narrator: hadith.narrator,
          grading: hadith.grading,
          categoryIds: categoryIds,
          categoryRationales: rationales,
          relationshipTypes: relationships,
          collectionId: hadith.collectionId,
          hadithNumber: hadith.hadithNumber,
        ),
      );
    }

    _cachedContentItems = items;
  }

  // --- Public APIs ---

  Future<List<QuranSurah>> getSurahs() async {
    await _loadQuranData();
    return _cachedSurahs ?? [];
  }

  Future<QuranSurah?> getSurah(int number) async {
    final list = await getSurahs();
    try {
      return list.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  Future<List<QuranAyah>> getAyahs(int surahNumber) async {
    await _loadQuranData();
    return _cachedAyahs?.where((a) => a.surahNumber == surahNumber).toList() ?? [];
  }

  Future<QuranAyah?> getAyah(int surahNumber, int ayahNumber) async {
    final list = await getAyahs(surahNumber);
    try {
      return list.firstWhere((a) => a.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  Future<List<HadithCollection>> getHadithCollections() async {
    await _loadHadithData();
    return _cachedCollections ?? [];
  }

  Future<List<HadithItem>> getHadiths({String? collectionId, int? bookNumber}) async {
    await _loadHadithData();
    var list = _cachedHadiths ?? [];
    if (collectionId != null) {
      list = list.where((h) => h.collectionId == collectionId).toList();
    }
    if (bookNumber != null) {
      list = list.where((h) => h.bookNumber == bookNumber).toList();
    }
    return list;
  }

  Future<HadithItem?> getHadith(String id) async {
    await _loadHadithData();
    try {
      return _cachedHadiths?.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Category>> getCategories() async {
    await _loadCategoriesData();
    return _cachedCategories ?? [];
  }

  Future<Category?> getCategory(String id) async {
    final list = await getCategories();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ContentItem>> getAllContentItems() async {
    if (_cachedContentItems == null) {
      await initialize();
    }
    return _cachedContentItems ?? [];
  }

  Future<List<ContentItem>> search(
    String query, {
    ContentType? contentType,
    String? categoryId,
  }) async {
    final items = await getAllContentItems();
    final q = query.trim().toLowerCase();

    return items.where((item) {
      if (contentType != null && item.contentType != contentType) {
        return false;
      }
      if (categoryId != null && !item.categoryIds.contains(categoryId)) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }

      final matchAr = ArabicUtils.containsNormalized(item.arabicText, q);
      final matchEn = item.englishTranslation.toLowerCase().contains(q);
      final matchRef = item.reference.toLowerCase().contains(q);
      final matchNarrator = item.narrator?.toLowerCase().contains(q) ?? false;

      return matchAr || matchEn || matchRef || matchNarrator;
    }).toList();
  }
}

class _CategoryLinkMetadata {
  _CategoryLinkMetadata(this.categoryId, this.rationale, this.relationship);
  final String categoryId;
  final String rationale;
  final RelationshipType relationship;
}
