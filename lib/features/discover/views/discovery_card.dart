import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      border: Border.all(
                        color: params.primaryTextColor.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      item.contentType.displayName.toUpperCase(),
                      style: AppTypography.badge(color: params.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.categoryIds.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: params.secondaryTextColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
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
              const SizedBox(height: 18),

              // Arabic Text inside an illuminated sacred container
              if (item.arabicText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: params.primaryTextColor.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: params.primaryTextColor.withValues(alpha: 0.10),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabic(
                      fontSize: scope.preferences.arabicFontSize,
                      color: params.primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // English Translation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.englishTranslation,
                  textAlign: TextAlign.left,
                  style: AppTypography.translation(
                    fontSize: scope.preferences.translationFontSize,
                    color: params.primaryTextColor.withValues(alpha: 0.95),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Source Reference & Attribution
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 15,
                          color: params.primaryTextColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.reference,
                            style: AppTypography.reference(
                              color: params.primaryTextColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.attribution,
                      style: TextStyle(
                        fontSize: 11,
                        color: params.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: params.primaryTextColor.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Read in context button
                  FilledButton.tonalIcon(
                    onPressed: onOpenContext,
                    icon: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: params.primaryTextColor,
                    ),
                    label: Text(
                      'Read in Context',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: params.primaryTextColor,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  // Actions: Copy, Bookmark & Share Card
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 19,
                          color: params.primaryTextColor,
                        ),
                        tooltip: 'Copy Text',
                        onPressed: () {
                          if (scope.preferences.hapticFeedbackEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          Clipboard.setData(ClipboardData(
                            text: '${item.arabicText}\n\n${item.englishTranslation}\n— ${item.reference}',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied verse and citation to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 21,
                          color: isBookmarked ? const Color(0xFFC5A059) : params.primaryTextColor,
                        ),
                        tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Bookmark',
                        onPressed: () {
                          if (scope.preferences.hapticFeedbackEnabled) {
                            HapticFeedback.mediumImpact();
                          }
                          scope.toggleBookmark(item);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: params.primaryTextColor,
                        ),
                        tooltip: 'Share Card',
                        onPressed: () {
                          if (scope.preferences.hapticFeedbackEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          ShareCardSheet.show(context, item);
                        },
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
