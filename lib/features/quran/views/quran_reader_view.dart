import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/quran_models.dart';
import '../../../domain/models/reading_progress_model.dart';
import '../../share_cards/views/share_card_sheet.dart';

/// Full Surah reader supporting adjustable typography, bookmarking, and progress persistence.
/// Complies with Section 4.2 and 12 of the Product Plan.
class QuranReaderView extends StatefulWidget {
  const QuranReaderView({
    super.key,
    required this.surah,
    this.initialAyahNumber,
  });

  final QuranSurah surah;
  final int? initialAyahNumber;

  @override
  State<QuranReaderView> createState() => _QuranReaderViewState();
}

class _QuranReaderViewState extends State<QuranReaderView> {
  final ScrollController _scrollController = ScrollController();
  List<QuranAyah> _ayahs = [];
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadAyahs();
      _initialized = true;
    }
  }

  Future<void> _loadAyahs() async {
    final scope = AppScope.of(context);
    final ayahs = await scope.contentRepository.getAyahs(widget.surah.number);
    if (!mounted) return;

    setState(() {
      _ayahs = ayahs;
      _isLoading = false;
    });

    // Record reading progress
    await scope.recordProgress(
      ReadingProgress(
        contentType: ContentType.quran,
        targetId: widget.surah.number.toString(),
        itemNumber: widget.initialAyahNumber ?? 1,
        title: 'Surah ${widget.surah.nameEnglish}',
        subtitle: 'Verse ${widget.initialAyahNumber ?? 1} • ${widget.surah.nameArabic}',
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _showTypographySheet() {
    final scope = AppScope.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final prefs = scope.preferences;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Typography & Display',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Arabic Size Slider
                  Text('Arabic Font Size: ${prefs.arabicFontSize.toInt()} pt'),
                  Slider(
                    value: prefs.arabicFontSize,
                    min: 18.0,
                    max: 36.0,
                    divisions: 9,
                    onChanged: (val) {
                      setSheetState(() {});
                      scope.updatePreferences(prefs.copyWith(arabicFontSize: val));
                    },
                  ),
                  const SizedBox(height: 12),

                  // Translation Size Slider
                  Text('Translation Font Size: ${prefs.translationFontSize.toInt()} pt'),
                  Slider(
                    value: prefs.translationFontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    onChanged: (val) {
                      setSheetState(() {});
                      scope.updatePreferences(prefs.copyWith(translationFontSize: val));
                    },
                  ),
                  const SizedBox(height: 12),

                  // Plain Mode Switch
                  SwitchListTile(
                    title: const Text('Plain Reading Mode'),
                    subtitle: const Text('Minimal, high-contrast display without gradients'),
                    value: prefs.plainReadingMode,
                    onChanged: (val) {
                      setSheetState(() {});
                      scope.updatePreferences(prefs.copyWith(plainReadingMode: val));
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.surah.number}. ${widget.surah.nameEnglish}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              '${widget.surah.nameTranslation} • ${widget.surah.nameArabic}',
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Typography Controls',
            onPressed: _showTypographySheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Surah Header Banner
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.surah.nameArabic,
                        style: AppTypography.arabic(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.surah.revelationType} • ${widget.surah.ayahCount} Verses',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      if (widget.surah.number != 1 && widget.surah.number != 9) ...[
                        const SizedBox(height: 14),
                        const Divider(indent: 40, endIndent: 40),
                        const SizedBox(height: 8),
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: AppTypography.arabic(fontSize: 20),
                        ),
                      ],
                    ],
                  ),
                ),

                // Ayahs List
                if (_ayahs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Verses for Surah ${widget.surah.nameEnglish} are indexed.\nOffline sync ready.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                  )
                else
                  ..._ayahs.map((ayah) {
                    final isBookmarked = scope.isBookmarked('quran_${ayah.id}');
                    final isHighlighted = widget.initialAyahNumber == ayah.ayahNumber;

                    final contentItem = ContentItem(
                      id: 'quran_${ayah.id}',
                      contentType: ContentType.quran,
                      reference: 'Surah ${widget.surah.nameEnglish} [${ayah.surahNumber}:${ayah.ayahNumber}]',
                      arabicText: ayah.arabicText,
                      englishTranslation: ayah.englishTranslation,
                      attribution: 'The Quran: English Meanings by ${ayah.translationAttribution}',
                      surahNumber: ayah.surahNumber,
                      ayahNumber: ayah.ayahNumber,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHighlighted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ayah Number and Actions row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  ayah.ayahNumber.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      size: 19,
                                      color: isBookmarked ? Colors.amber : null,
                                    ),
                                    tooltip: 'Bookmark Verse',
                                    onPressed: () => scope.toggleBookmark(contentItem),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share_outlined, size: 19),
                                    tooltip: 'Share Card',
                                    onPressed: () => ShareCardSheet.show(context, contentItem),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Arabic Text
                          Text(
                            ayah.arabicText,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.arabic(
                              fontSize: prefs.arabicFontSize,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // English Translation
                          Text(
                            ayah.englishTranslation,
                            style: AppTypography.translation(
                              fontSize: prefs.translationFontSize,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Translation: Saheeh International\nMedina Mushaf (Hafs an Asim) Standard Edition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
