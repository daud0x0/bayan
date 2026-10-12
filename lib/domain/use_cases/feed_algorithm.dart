import '../models/bookmark_model.dart';
import '../models/content_item.dart';
import '../models/user_preferences.dart';

/// Breakdown of ranking factors for the "Why am I seeing this?" modal.
class FeedScoreBreakdown {
  const FeedScoreBreakdown({
    required this.totalScore,
    required this.topicScore,
    required this.languageScore,
    required this.contentTypeScore,
    required this.diversityBonus,
    required this.explanation,
  });

  final double totalScore;
  final double topicScore;
  final double languageScore;
  final double contentTypeScore;
  final double diversityBonus;
  final String explanation;
}

/// Deterministic, transparent feed ranking algorithm complying with Section 5.3 of the Product Plan.
class FeedAlgorithm {
  FeedAlgorithm._();

  static const double topicWeight = 50.0;
  static const double languageWeight = 20.0;
  static const double contentTypeWeight = 10.0;
  static const double diversityWeight = 10.0;

  /// Ranks and diversifies a list of [ContentItem] based on user preferences.
  static List<ContentItem> rankFeed({
    required List<ContentItem> items,
    required UserPreferences preferences,
  }) {
    if (items.isEmpty) return [];

    // Filter by explicit content type if set
    var eligibleItems = items;
    if (preferences.contentTypeFilter != null) {
      eligibleItems = eligibleItems
          .where((i) => i.contentType == preferences.contentTypeFilter)
          .toList();
    }

    // 1. Calculate raw score for each item
    final scoredItems = eligibleItems.map((item) {
      final breakdown = explainScore(item, preferences);
      return MapEntry(item, breakdown.totalScore);
    }).toList();

    // 2. Sort descending by score
    scoredItems.sort((a, b) => b.value.compareTo(a.value));

    // 3. Apply diversity rules: interleave Quran and Hadith to avoid long single-type runs
    final quranItems = <ContentItem>[];
    final hadithItems = <ContentItem>[];

    for (final entry in scoredItems) {
      if (entry.key.contentType == ContentType.quran) {
        quranItems.add(entry.key);
      } else {
        hadithItems.add(entry.key);
      }
    }

    final balanced = <ContentItem>[];
    var qIndex = 0;
    var hIndex = 0;

    while (qIndex < quranItems.length || hIndex < hadithItems.length) {
      if (qIndex < quranItems.length) {
        balanced.add(quranItems[qIndex++]);
      }
      if (hIndex < hadithItems.length) {
        balanced.add(hadithItems[hIndex++]);
      }
    }

    return balanced.isNotEmpty ? balanced : items;
  }

  /// Generates human-readable breakdown explaining why a card was ranked.
  static FeedScoreBreakdown explainScore(
    ContentItem item,
    UserPreferences preferences,
  ) {
    // Topic matching
    var topicScore = 0.0;
    var matchedTopic = false;
    if (preferences.selectedCategoryIds.isNotEmpty) {
      final hasOverlap = item.categoryIds.any(
        (id) => preferences.selectedCategoryIds.contains(id),
      );
      if (hasOverlap) {
        topicScore = topicWeight;
        matchedTopic = true;
      }
    } else {
      // Default state: all curated categories receive baseline relevance
      topicScore = topicWeight * 0.7;
    }

    // Language matching: Arabic source with English translation is fully matched
    const languageScore = languageWeight;

    // Content type match
    var contentTypeScore = contentTypeWeight;
    if (preferences.contentTypeFilter != null &&
        item.contentType != preferences.contentTypeFilter) {
      contentTypeScore = 0.0;
    }

    // Baseline diversity bonus
    const diversityBonus = diversityWeight;

    final totalScore = topicScore + languageScore + contentTypeScore + diversityBonus;

    String explanation;
    if (matchedTopic) {
      explanation =
          'Matches your explicitly selected topic preferences ($topicScore pts), supported with verified translation ($languageScore pts), and balanced collection diversity ($diversityBonus pts).';
    } else if (preferences.selectedCategoryIds.isNotEmpty) {
      explanation =
          'Curated recommendation from the offline library included for topical breadth ($topicScore pts) and collection diversity ($diversityBonus pts).';
    } else {
      explanation =
          'Part of the standard editorial discovery baseline ($topicScore pts) with verified translation attribution ($languageScore pts).';
    }

    return FeedScoreBreakdown(
      totalScore: totalScore,
      topicScore: topicScore,
      languageScore: languageScore,
      contentTypeScore: contentTypeScore,
      diversityBonus: diversityBonus,
      explanation: explanation,
    );
  }
}
