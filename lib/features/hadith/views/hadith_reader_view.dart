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
  final ScrollController _scrollController = ScrollController();
  late HadithItem _currentHadith;
  List<HadithItem> _collectionHadiths = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _currentHadith = widget.hadith;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadCollectionHadiths();
      _recordProgress();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCollectionHadiths() async {
    final scope = AppScope.of(context);
    final list = await scope.contentRepository.getHadiths(
      collectionId: _currentHadith.collectionId,
    );
    if (!mounted) return;
    setState(() {
      _collectionHadiths = list;
    });
  }

  Future<void> _recordProgress() async {
    final scope = AppScope.of(context);
    await scope.recordProgress(
      ReadingProgress(
        contentType: ContentType.hadith,
        targetId: _currentHadith.collectionId,
        itemNumber: _currentHadith.hadithNumber,
        title: _currentHadith.reference,
        subtitle: _currentHadith.bookNameEnglish,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _navigateToHadith(HadithItem hadith) {
    setState(() {
      _currentHadith = hadith;
    });
    _recordProgress();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showTypographySheet(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reading & Typography Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Arabic Slider
                  Text('Arabic Font Size: ${prefs.arabicFontSize.toInt()} pt'),
                  Slider(
                    value: prefs.arabicFontSize,
                    min: 18.0,
                    max: 36.0,
                    divisions: 6,
                    onChanged: (val) {
                      setSheetState(() {});
                      scope.updatePreferences(prefs.copyWith(arabicFontSize: val));
                    },
                  ),
                  const SizedBox(height: 12),

                  // English Slider
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

  void _showJumpToHadithDialog(BuildContext context) {
    if (_collectionHadiths.isEmpty) return;
    final controller = TextEditingController();
    final minNum = _collectionHadiths.first.hadithNumber;
    final maxNum = _collectionHadiths.last.hadithNumber;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jump to Hadith'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Hadith number ($minNum - $maxNum):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. $minNum',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.tag),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final num = int.tryParse(controller.text.trim());
              if (num != null) {
                final match = _collectionHadiths.firstWhere(
                  (h) => h.hadithNumber == num,
                  orElse: () => _collectionHadiths.reduce(
                    (a, b) => (a.hadithNumber - num).abs() < (b.hadithNumber - num).abs() ? a : b,
                  ),
                );
                Navigator.of(ctx).pop();
                _navigateToHadith(match);
              }
            },
            child: const Text('Jump'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;
    final isBookmarked = scope.isBookmarked('hadith_${_currentHadith.id}');

    final contentItem = ContentItem(
      id: 'hadith_${_currentHadith.id}',
      contentType: ContentType.hadith,
      reference: _currentHadith.reference,
      arabicText: _currentHadith.arabicText,
      englishTranslation: _currentHadith.englishTranslation,
      attribution: _currentHadith.attribution,
      narrator: _currentHadith.narrator,
      grading: _currentHadith.grading,
      collectionId: _currentHadith.collectionId,
      hadithNumber: _currentHadith.hadithNumber,
    );

    final currentIndex = _collectionHadiths.indexWhere((h) => h.id == _currentHadith.id);
    final hasPrevious = currentIndex > 0;
    final previousHadith = hasPrevious ? _collectionHadiths[currentIndex - 1] : null;
    final hasNext = currentIndex != -1 && currentIndex < _collectionHadiths.length - 1;
    final nextHadith = hasNext ? _collectionHadiths[currentIndex + 1] : null;

    final isPlain = prefs.plainReadingMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _currentHadith.reference,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tag),
            tooltip: 'Jump to Hadith',
            onPressed: () => _showJumpToHadithDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Typography & Plain Mode',
            onPressed: () => _showTypographySheet(context),
          ),
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
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Metadata card: Book and Chapter info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPlain
                  ? Theme.of(context).cardColor
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlain
                    ? Theme.of(context).dividerColor
                    : Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _currentHadith.bookNameEnglish,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPlain
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: isPlain
                            ? Border.all(color: Theme.of(context).dividerColor)
                            : null,
                      ),
                      child: Text(
                        _currentHadith.grading.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isPlain
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_currentHadith.chapterName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Chapter: ${_currentHadith.chapterName}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Narrated by ${_currentHadith.narrator}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: isPlain
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Arabic Matn
          Text(
            _currentHadith.arabicText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTypography.arabic(
              fontSize: prefs.arabicFontSize,
            ),
          ),
          const SizedBox(height: 20),

          // English Translation
          Text(
            _currentHadith.englishTranslation,
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
                  _currentHadith.attribution,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chapter & Adjacent Hadith Navigation
          if (_collectionHadiths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (hasPrevious && previousHadith != null)
                    OutlinedButton.icon(
                      onPressed: () => _navigateToHadith(previousHadith),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text('Hadith ${previousHadith.hadithNumber}'),
                    ),
                  const Spacer(),
                  if (hasNext && nextHadith != null)
                    FilledButton.tonalIcon(
                      onPressed: () => _navigateToHadith(nextHadith),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text('Hadith ${nextHadith.hadithNumber}'),
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
