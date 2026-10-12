import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/hadith_models.dart';
import '../../../domain/models/reading_progress_model.dart';
import '../../share_cards/views/share_card_sheet.dart';

/// Hadith reader displaying Arabic, English translation, narrator, grading, and attribution.
/// Complies with Section 4.2 and 12 of the Product Plan.
class HadithReaderView extends StatefulWidget {
  const HadithReaderView({super.key, required this.hadith});

  final HadithItem hadith;

  @override
  State<HadithReaderView> createState() => _HadithReaderViewState();
}

class _HadithReaderViewState extends State<HadithReaderView> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _recordProgress();
      _initialized = true;
    }
  }

  Future<void> _recordProgress() async {
    final scope = AppScope.of(context);
    await scope.recordProgress(
      ReadingProgress(
        contentType: ContentType.hadith,
        targetId: widget.hadith.collectionId,
        itemNumber: widget.hadith.hadithNumber,
        title: widget.hadith.reference,
        subtitle: widget.hadith.bookNameEnglish,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;
    final isBookmarked = scope.isBookmarked('hadith_${widget.hadith.id}');

    final contentItem = ContentItem(
      id: 'hadith_${widget.hadith.id}',
      contentType: ContentType.hadith,
      reference: widget.hadith.reference,
      arabicText: widget.hadith.arabicText,
      englishTranslation: widget.hadith.englishTranslation,
      attribution: widget.hadith.attribution,
      narrator: widget.hadith.narrator,
      grading: widget.hadith.grading,
      collectionId: widget.hadith.collectionId,
      hadithNumber: widget.hadith.hadithNumber,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hadith.reference,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : null,
            ),
            tooltip: 'Bookmark Hadith',
            onPressed: () => scope.toggleBookmark(contentItem),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Card',
            onPressed: () => ShareCardSheet.show(context, contentItem),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Metadata card: Book and Chapter info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.hadith.bookNameEnglish,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.hadith.grading.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.hadith.chapterName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Chapter: ${widget.hadith.chapterName}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Narrated by ${widget.hadith.narrator}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Arabic Matn
          Text(
            widget.hadith.arabicText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTypography.arabic(
              fontSize: prefs.arabicFontSize,
            ),
          ),
          const SizedBox(height: 20),

          // English Translation
          Text(
            widget.hadith.englishTranslation,
            style: AppTypography.translation(
              fontSize: prefs.translationFontSize,
            ),
          ),
          const SizedBox(height: 28),

          // Attribution and source details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Source Attribution & Verification',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hadith.attribution,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
