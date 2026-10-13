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
    final hasReflection = scope.hasReflection(item.id);

    final isPureBlack = isDark && (scope.preferences.pureBlackDark || theme.scaffoldBackgroundColor == Colors.black);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? (isPureBlack ? Colors.black : colorScheme.surfaceContainer)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPlain
              ? Colors.transparent
              : (isPureBlack
                  ? Colors.white.withValues(alpha: 0.16)
                  : outlineColor.withValues(alpha: isDark ? 0.30 : 0.55)),
          width: 1.0,
        ),
        boxShadow: (isPlain || isPureBlack)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // Header Row: Content Type & Category in one clean, unboxed line
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.contentType.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: primaryBadgeColor,
                    ),
                  ),
                  if (item.categoryIds.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.categoryIds.first.replaceAll('_', ' ').toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],
                  IconButton(
                    icon: Icon(
                      Icons.help_outline_rounded,
                      size: 17,
                      color: secondaryTextColor.withValues(alpha: 0.6),
                    ),
                    tooltip: 'Why am I seeing this?',
                    onPressed: () => _showWhyModal(context, scope),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Arabic Text - Unboxed with generous line-height and breathing room
              if (item.arabicText.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                  child: Text(
                    item.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabic(
                      fontSize: scope.preferences.arabicFontSize,
                      color: textColor,
                      height: 1.85,
                      scriptStyle: scope.preferences.arabicScriptStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // English Translation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  item.englishTranslation,
                  textAlign: TextAlign.left,
                  style: AppTypography.translation(
                    fontSize: scope.preferences.translationFontSize,
                    color: textColor.withValues(alpha: 0.92),
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Source Reference & Attribution
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 14,
                          color: primaryBadgeColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.reference,
                            style: AppTypography.reference(
                              color: primaryBadgeColor,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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
              const SizedBox(height: 14),

              // Action Buttons Row (Airy and streamlined, no harsh divider line)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Read in context button (sleek translucent pill)
                  Flexible(
                    child: TextButton.icon(
                      onPressed: onOpenContext,
                      icon: Icon(
                        Icons.auto_stories_outlined,
                        size: 14,
                        color: primaryBadgeColor,
                      ),
                      label: Text(
                        'Read in Context',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBadgeColor,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: primaryBadgeColor.withValues(alpha: isDark ? 0.14 : 0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Actions: Copy, Bookmark, Share & Tadabbur Reflection
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 17,
                          color: secondaryTextColor,
                        ),
                        tooltip: 'Copy Text',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                          size: 18,
                          color: isBookmarked ? const Color(0xFFC5A059) : secondaryTextColor,
                        ),
                        tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Bookmark',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                          size: 17,
                          color: secondaryTextColor,
                        ),
                        tooltip: 'Share Card',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                          hasReflection ? Icons.note_alt_rounded : Icons.edit_note_rounded,
                          size: 19,
                          color: hasReflection ? const Color(0xFFC5A059) : secondaryTextColor,
                        ),
                        tooltip: hasReflection ? 'Edit Tadabbur Reflection' : 'Tadabbur Reflection',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
