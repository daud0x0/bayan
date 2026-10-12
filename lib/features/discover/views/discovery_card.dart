import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/use_cases/feed_algorithm.dart';
import '../../reflections/views/reflection_note_sheet.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBookmarked = scope.isBookmarked(item.id);
    final isQuran = item.contentType == ContentType.quran;
    final isPlain = scope.preferences.plainReadingMode;

    // Harmonious luxury styling reflecting global theme palette
    final primaryBadgeColor = isQuran ? colorScheme.primary : const Color(0xFFC5A059);
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurfaceVariant;
    final outlineColor = colorScheme.outlineVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPlain
            ? colorScheme.surface
            : isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPlain
              ? Colors.transparent
              : outlineColor.withValues(alpha: isDark ? 0.35 : 0.60),
          width: 1.0,
        ),
        boxShadow: isPlain
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
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
                    color: primaryBadgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryBadgeColor.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.contentType.displayName.toUpperCase(),
                    style: AppTypography.badge(color: primaryBadgeColor),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.categoryIds.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.categoryIds.first.replaceAll('_', ' ').toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: colorScheme.outline,
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
                  color: primaryBadgeColor.withValues(alpha: isDark ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: primaryBadgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(
                    fontSize: scope.preferences.arabicFontSize,
                    color: textColor,
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
                  color: textColor.withValues(alpha: 0.95),
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
                        color: primaryBadgeColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.reference,
                          style: AppTypography.reference(
                            color: primaryBadgeColor,
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
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: outlineColor.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 4),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Read in context button (sleek compact pill)
                TextButton.icon(
                  onPressed: onOpenContext,
                  icon: Icon(
                    Icons.auto_stories_outlined,
                    size: 15,
                    color: primaryBadgeColor,
                  ),
                  label: Text(
                    'Read in Context',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryBadgeColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

                // Actions: Copy, Bookmark & Share Card
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: secondaryTextColor,
                      ),
                      tooltip: 'Copy Text',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
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
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 19,
                        color: isBookmarked ? const Color(0xFFC5A059) : secondaryTextColor,
                      ),
                      tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Bookmark',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (scope.preferences.hapticFeedbackEnabled) {
                          HapticFeedback.mediumImpact();
                        }
                        scope.toggleBookmark(item);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: secondaryTextColor,
                      ),
                      tooltip: 'Share Card',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (scope.preferences.hapticFeedbackEnabled) {
                          HapticFeedback.lightImpact();
                        }
                        ShareCardSheet.show(context, item);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                      tooltip: 'Tadabbur Reflection',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (scope.preferences.hapticFeedbackEnabled) {
                          HapticFeedback.lightImpact();
                        }
                        ReflectionNoteSheet.show(
                          context,
                          contentId: item.id,
                          contentType: item.contentType,
                          reference: item.reference,
                          arabicExcerpt: item.arabicText,
                          translationExcerpt: item.englishTranslation,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
