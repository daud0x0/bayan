import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/domain/models/bookmark_model.dart';
import 'package:quran_hadis/domain/models/content_item.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/domain/use_cases/feed_algorithm.dart';

void main() {
  group('FeedAlgorithm', () {
    final sampleQuran1 = ContentItem(
      id: 'quran_1',
      contentType: ContentType.quran,
      reference: 'Surah Ash-Sharh [94:5]',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      englishTranslation: 'For indeed, with hardship will be ease.',
      attribution: 'Saheeh International',
      categoryIds: ['hardship_and_hope'],
    );

    final sampleQuran2 = ContentItem(
      id: 'quran_2',
      contentType: ContentType.quran,
      reference: 'Surah Al-Baqarah [2:153]',
      arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ',
      englishTranslation: 'Seek help through patience and prayer.',
      attribution: 'Saheeh International',
      categoryIds: ['patience'],
    );

    final sampleHadith1 = ContentItem(
      id: 'hadith_1',
      contentType: ContentType.hadith,
      reference: 'Sahih al-Bukhari 1',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      englishTranslation: 'Actions are but by intention.',
      attribution: 'Dr. M. Muhsin Khan',
      categoryIds: ['character_and_conduct'],
    );

    final sampleHadith2 = ContentItem(
      id: 'hadith_2',
      contentType: ContentType.hadith,
      reference: 'Sahih Muslim 2999',
      arabicText: 'عَجَبًا لأَمْرِ الْمُؤْمِنِ',
      englishTranslation: 'How wonderful is the affair of the believer.',
      attribution: 'Abdul Hamid Siddiqui',
      categoryIds: ['patience', 'gratitude'],
    );

    test('boosts items matching user explicitly selected topics', () {
      const prefs = UserPreferences(
        selectedCategoryIds: {'patience'},
      );

      final breakdownPatience = FeedAlgorithm.explainScore(sampleQuran2, prefs);
      final breakdownHardship = FeedAlgorithm.explainScore(sampleQuran1, prefs);

      expect(breakdownPatience.topicScore, greaterThan(breakdownHardship.topicScore));
      expect(breakdownPatience.totalScore, greaterThan(breakdownHardship.totalScore));
    });

    test('interleaves Quran and Hadith to preserve collection diversity', () {
      final items = [sampleQuran1, sampleQuran2, sampleHadith1, sampleHadith2];
      final ranked = FeedAlgorithm.rankFeed(
        items: items,
        preferences: const UserPreferences(),
      );

      expect(ranked.length, 4);
      // First is Quran, second is Hadith, third is Quran, fourth is Hadith
      expect(ranked[0].contentType, ContentType.quran);
      expect(ranked[1].contentType, ContentType.hadith);
      expect(ranked[2].contentType, ContentType.quran);
      expect(ranked[3].contentType, ContentType.hadith);
    });

    test('respects explicit contentTypeFilter when set', () {
      const prefs = UserPreferences(
        contentTypeFilter: ContentType.hadith,
      );

      final items = [sampleQuran1, sampleQuran2, sampleHadith1, sampleHadith2];
      final ranked = FeedAlgorithm.rankFeed(items: items, preferences: prefs);

      expect(ranked.every((i) => i.contentType == ContentType.hadith), isTrue);
      expect(ranked.length, 2);
    });
  });
}
