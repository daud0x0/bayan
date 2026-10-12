import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/auto_scroll_bar.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/hadith_models.dart';
import '../../../domain/models/reading_progress_model.dart';
import '../../../domain/models/user_preferences.dart';
import '../../reflections/views/reflection_note_sheet.dart';
import '../../share_cards/views/share_card_sheet.dart';

/// Hadith reader displaying Arabic, English translation, narrator, grading, and attribution.
/// Complies with Section 4.2 and 12 of the Product Plan with illuminated manuscript styling.
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
  bool _isAutoScrollActive = false;
  bool _isAutoScrollPlaying = false;
  double _autoScrollSpeed = 1.0;
  Timer? _autoScrollTimer;

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
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrollActive = !_isAutoScrollActive;
      if (_isAutoScrollActive) {
        _isAutoScrollPlaying = true;
        _startAutoScrollTimer();
      } else {
        _isAutoScrollPlaying = false;
        _autoScrollTimer?.cancel();
      }
    });
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!mounted || !_isAutoScrollPlaying || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= max) {
        setState(() => _isAutoScrollPlaying = false);
        _autoScrollTimer?.cancel();
        return;
      }
      final step = _autoScrollSpeed * 1.2;
      final next = (current + step).clamp(0.0, max);
      _scrollController.jumpTo(next);
    });
  }

  void _onAutoScrollPlayPauseToggle() {
    setState(() {
      _isAutoScrollPlaying = !_isAutoScrollPlaying;
      if (_isAutoScrollPlaying) {
        _startAutoScrollTimer();
      } else {
        _autoScrollTimer?.cancel();
      }
    });
  }

  void _onAutoScrollSpeedSelected(double speed) {
    setState(() {
      _autoScrollSpeed = speed;
    });
  }

  void _closeAutoScroll() {
    setState(() {
      _isAutoScrollActive = false;
      _isAutoScrollPlaying = false;
      _autoScrollTimer?.cancel();
    });
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
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reading & Typography Settings',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Display Mode SegmentedButton
                    const Text('Display Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ReadingDisplayMode>(
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        segments: const [
                          ButtonSegment(value: ReadingDisplayMode.dual, label: Text('Dual')),
                          ButtonSegment(value: ReadingDisplayMode.arabicOnly, label: Text('Arabic')),
                          ButtonSegment(value: ReadingDisplayMode.translationOnly, label: Text('English')),
                        ],
                        selected: {prefs.readingDisplayMode},
                        onSelectionChanged: (set) {
                          setSheetState(() {});
                          scope.updatePreferences(prefs.copyWith(readingDisplayMode: set.first));
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Script Style Selector
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Script Style', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButton<ArabicScriptStyle>(
                          value: prefs.arabicScriptStyle,
                          underline: const SizedBox(),
                          isDense: true,
                          items: ArabicScriptStyle.values.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s.label));
                          }).toList(),
                          onChanged: (s) {
                            if (s != null) {
                              setSheetState(() {});
                              scope.updatePreferences(prefs.copyWith(arabicScriptStyle: s));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Arabic Slider
                    if (prefs.readingDisplayMode != ReadingDisplayMode.translationOnly) ...[
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
                    ],

                    // English Slider
                    if (prefs.readingDisplayMode != ReadingDisplayMode.arabicOnly) ...[
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
                    ],

                    // Line Spacing Slider
                    Text('Line Spacing: ${prefs.lineSpacing.toStringAsFixed(1)}x'),
                    Slider(
                      value: prefs.lineSpacing,
                      min: 1.4,
                      max: 2.6,
                      divisions: 6,
                      onChanged: (val) {
                        setSheetState(() {});
                        scope.updatePreferences(prefs.copyWith(lineSpacing: val));
                      },
                    ),
                    const SizedBox(height: 6),

                    // Plain Mode Switch
                    SwitchListTile(
                      title: const Text('Plain Reading Mode'),
                      subtitle: const Text('Minimal, high-contrast display without gradients'),
                      value: prefs.plainReadingMode,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setSheetState(() {});
                        scope.updatePreferences(prefs.copyWith(plainReadingMode: val));
                      },
                    ),

                    // Eye Comfort Sepia Switch
                    SwitchListTile(
                      title: const Text('Eye-Comfort Warm Sepia'),
                      subtitle: const Text('Soothing parchment tint for long reading sessions'),
                      value: prefs.eyeComfortSepia,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setSheetState(() {});
                        scope.updatePreferences(prefs.copyWith(eyeComfortSepia: val));
                      },
                    ),
                  ],
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final hasReflection = scope.hasReflection('hadith_${_currentHadith.id}');

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _currentHadith.reference,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isAutoScrollActive
                  ? Icons.motion_photos_paused_rounded
                  : Icons.slow_motion_video_rounded,
              color: _isAutoScrollActive ? const Color(0xFFC5A059) : null,
            ),
            tooltip: _isAutoScrollActive ? 'Auto-Scroll Active' : 'Start Auto-Scroll',
            onPressed: _toggleAutoScroll,
          ),
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
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? const Color(0xFFC5A059) : null,
            ),
            tooltip: 'Bookmark Hadith',
            onPressed: () {
              if (prefs.hapticFeedbackEnabled) {
                HapticFeedback.mediumImpact();
              }
              scope.toggleBookmark(contentItem);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy Hadith',
            onPressed: () {
              if (prefs.hapticFeedbackEnabled) {
                HapticFeedback.lightImpact();
              }
              Clipboard.setData(ClipboardData(
                text: '${_currentHadith.arabicText}\n\n${_currentHadith.englishTranslation}\n— ${_currentHadith.reference}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied Hadith to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Card',
            onPressed: () {
              if (prefs.hapticFeedbackEnabled) {
                HapticFeedback.lightImpact();
              }
              ShareCardSheet.show(context, contentItem);
            },
          ),
          IconButton(
            icon: Icon(
              hasReflection ? Icons.note_alt_rounded : Icons.edit_note_rounded,
              color: hasReflection ? const Color(0xFFC5A059) : null,
            ),
            tooltip: hasReflection ? 'Edit Reflection' : 'Tadabbur Reflection',
            onPressed: () async {
              if (prefs.hapticFeedbackEnabled) {
                HapticFeedback.lightImpact();
              }
              await ReflectionNoteSheet.show(
                context,
                contentId: 'hadith_${_currentHadith.id}',
                contentType: ContentType.hadith,
                reference: _currentHadith.reference,
                arabicExcerpt: _currentHadith.arabicText,
                translationExcerpt: _currentHadith.englishTranslation,
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isAutoScrollActive
          ? AutoScrollBar(
              isPlaying: _isAutoScrollPlaying,
              speed: _autoScrollSpeed,
              onPlayPauseToggle: _onAutoScrollPlayPauseToggle,
              onSpeedSelected: _onAutoScrollSpeedSelected,
              onClose: _closeAutoScroll,
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            if (_isAutoScrollPlaying) {
              setState(() {
                _isAutoScrollPlaying = false;
                _autoScrollTimer?.cancel();
              });
            }
          }
          return false;
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
          // Illuminated Metadata Frame: Book, Chapter, Narrator & Grading
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isPlain
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [Color(0xFF0F261E), Color(0xFF0A1913)]
                          : const [Color(0xFFF9F5ED), Color(0xFFEFE8DB)],
                    ),
              color: isPlain ? Theme.of(context).cardColor : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPlain
                    ? Theme.of(context).dividerColor
                    : const Color(0xFFC5A059).withValues(alpha: isDark ? 0.35 : 0.30),
                width: 1.2,
              ),
              boxShadow: isPlain
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RubElHizbBadge(
                      number: _currentHadith.hadithNumber,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentHadith.bookNameEnglish,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          if (_currentHadith.bookNameArabic.isNotEmpty)
                            Text(
                              _currentHadith.bookNameArabic,
                              style: AppTypography.arabic(
                                fontSize: 13,
                                color: const Color(0xFFC5A059),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isPlain
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPlain
                              ? Theme.of(context).dividerColor
                              : Colors.green.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isPlain) ...[
                            const Icon(Icons.verified_rounded, size: 12, color: Colors.green),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            _currentHadith.grading.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isPlain
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_currentHadith.chapterName.isNotEmpty) ...[
                  const SizedBox(height: 10),
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
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isPlain
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Illuminated Sacred Arabic Matn Container
          if (prefs.readingDisplayMode != ReadingDisplayMode.translationOnly) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                color: isPlain
                    ? null
                    : (isDark
                        ? const Color(0xFF0F1E19)
                        : const Color(0xFFFBF8F2)),
                borderRadius: BorderRadius.circular(20),
                border: isPlain
                    ? null
                    : Border.all(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                        width: 1.0,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isPlain) ...[
                    const IslamicOrnamentalDivider(height: 16),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    _currentHadith.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabic(
                      fontSize: prefs.arabicFontSize,
                      scriptStyle: prefs.arabicScriptStyle,
                      height: prefs.lineSpacing,
                    ),
                  ),
                  if (!isPlain) ...[
                    const SizedBox(height: 14),
                    const IslamicOrnamentalDivider(height: 16),
                  ],
                ],
              ),
            ),
          ],
          if (prefs.readingDisplayMode == ReadingDisplayMode.dual)
            const SizedBox(height: 20),

          // English Translation
          if (prefs.readingDisplayMode != ReadingDisplayMode.arabicOnly) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                _currentHadith.englishTranslation,
                style: AppTypography.translation(
                  fontSize: prefs.translationFontSize,
                  height: (prefs.lineSpacing * 0.88).clamp(1.4, 2.2),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Attribution and source verification card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: Color(0xFFC5A059),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Source Attribution & Verification',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currentHadith.attribution,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (hasNext && nextHadith != null)
                    FilledButton.tonalIcon(
                      onPressed: () => _navigateToHadith(nextHadith),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text('Hadith ${nextHadith.hadithNumber}'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
}
