import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/use_cases/feed_algorithm.dart';
import '../../../visual_engine/generator/seeded_generator.dart';
import '../../../visual_engine/rendering/procedural_background.dart';
import '../../share_cards/views/share_card_sheet.dart';

/// Single discovery card in the feed displaying Quran or Hadith teaching.
/// Complies with Section 4.1 and 11 of the Product Plan.
class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.item,
    required this.onOpenContext,
  });

  final ContentItem item;
  final VoidCallback onOpenContext;

  void _showWhyModal(BuildContext context, AppScope scope) {
    final breakdown = FeedAlgorithm.explainScore(item, scope.preferences);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Why am I seeing this?',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              breakdown.explanation,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Deterministic Local Score: ${breakdown.totalScore.toInt()} pts',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text('• Topic preference: ${breakdown.topicScore.toInt()} pts',
                style: const TextStyle(fontSize: 12)),
            Text('• Language match: ${breakdown.languageScore.toInt()} pts',
                style: const TextStyle(fontSize: 12)),
            Text('• Collection diversity: ${breakdown.diversityBonus.toInt()} pts',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              'No remote analytics or profiling are used. Ranking is calculated entirely on your device based only on your preferences.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(ctx).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          if (item.categoryIds.isNotEmpty)
            TextButton(
              onPressed: () {
                final catId = item.categoryIds.first;
                final current = Set<String>.from(scope.preferences.selectedCategoryIds);
                final willFollow = !current.contains(catId);
                if (willFollow) {
                  current.add(catId);
                } else {
                  current.remove(catId);
                }
                scope.updatePreferences(scope.preferences.copyWith(selectedCategoryIds: current));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      willFollow
                          ? 'Added "${catId.replaceAll('_', ' ')}" to preferred topics.'
                          : 'Removed "${catId.replaceAll('_', ' ')}" from preferred topics.',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                scope.preferences.selectedCategoryIds.contains(item.categoryIds.first)
                    ? 'Show Less of Topic'
                    : 'Prioritize Topic',
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = scope.isBookmarked(item.id);

    final params = SeededVisualGenerator.generate(
      contentId: item.id,
      preset: scope.preferences.visualPreset,
      isDarkMode: isDark,
      intensity: scope.preferences.visualIntensity,
      isPlainMode: scope.preferences.plainReadingMode,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ProceduralBackground(
        params: params,
        borderRadius: 22,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Content Type Badge + Topics + Why icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: params.primaryTextColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.contentType.displayName.toUpperCase(),
                      style: AppTypography.badge(color: params.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.categoryIds.isNotEmpty)
                    Expanded(
                      child: Text(
                        item.categoryIds.first.replaceAll('_', ' ').toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: params.secondaryTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: params.secondaryTextColor,
                    ),
                    tooltip: 'Why am I seeing this?',
                    onPressed: () => _showWhyModal(context, scope),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Arabic Text
              if (item.arabicText.isNotEmpty) ...[
                Text(
                  item.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(
                    fontSize: scope.preferences.arabicFontSize,
                    color: params.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // English Translation
              Text(
                item.englishTranslation,
                textAlign: TextAlign.left,
                style: AppTypography.translation(
                  fontSize: scope.preferences.translationFontSize,
                  color: params.primaryTextColor.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 18),

              // Source Reference & Attribution
              Text(
                item.reference,
                style: AppTypography.reference(
                  color: params.primaryTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.attribution,
                style: TextStyle(
                  fontSize: 11,
                  color: params.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 18),

              // Divider
              Container(
                height: 1,
                color: params.primaryTextColor.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 10),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Read in context button
                  TextButton.icon(
                    onPressed: onOpenContext,
                    icon: Icon(
                      Icons.menu_book_rounded,
                      size: 17,
                      color: params.primaryTextColor,
                    ),
                    label: Text(
                      'Read in Context',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: params.primaryTextColor,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // Actions: Bookmark & Share Card
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 21,
                          color: isBookmarked ? Colors.amber : params.primaryTextColor,
                        ),
                        tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Bookmark',
                        onPressed: () => scope.toggleBookmark(item),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: params.primaryTextColor,
                        ),
                        tooltip: 'Share Card',
                        onPressed: () => ShareCardSheet.show(context, item),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
