import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/auto_scroll_bar.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/quran_models.dart';
import '../../../domain/models/reading_progress_model.dart';
import '../../../domain/models/user_preferences.dart';
import '../../reflections/views/reflection_note_sheet.dart';
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
  Set<String> _reflectedAyahIds = {};
  bool _isLoading = true;
  bool _initialized = false;
  int? _activeReadingAyah;
  double _readingProgress = 0.0;
  bool _isAutoScrollActive = false;
  bool _isAutoScrollPlaying = false;
  double _autoScrollSpeed = 1.0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.removeListener(_updateProgress);
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

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max > 0) {
      final progress = (_scrollController.offset / max).clamp(0.0, 1.0);
      if ((progress - _readingProgress).abs() > 0.01) {
        setState(() => _readingProgress = progress);
      }
    }
  }

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

    final initialAyah = widget.initialAyahNumber ??
        (scope.lastQuranProgress?.targetId == widget.surah.number.toString()
            ? scope.lastQuranProgress?.itemNumber
            : 1) ??
        1;

    setState(() {
      _ayahs = ayahs;
      _isLoading = false;
      _activeReadingAyah = initialAyah;
    });

    if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(widget.initialAyahNumber!);
      });
    }

    await _loadReflectionNotes();

    // Record reading progress
    await scope.recordProgress(
      ReadingProgress(
        contentType: ContentType.quran,
        targetId: widget.surah.number.toString(),
        itemNumber: initialAyah,
        title: 'Surah ${widget.surah.nameEnglish}',
        subtitle: 'Verse $initialAyah • ${widget.surah.nameArabic}',
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _loadReflectionNotes() async {
    final scope = AppScope.of(context);
    final notes = await scope.reflectionNotesRepository.getNotes();
    if (!mounted) return;
    setState(() {
      _reflectedAyahIds = notes
          .where((n) => n.contentType == ContentType.quran)
          .map((n) => n.contentId)
          .toSet();
    });
  }

  void _showSurahInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFC5A059), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Surah ${widget.surah.nameEnglish}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.surah.nameArabic,
                style: AppTypography.arabic(
                  fontSize: 26,
                  color: const Color(0xFFC5A059),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('• Translation: "${widget.surah.nameTranslation}"', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('• Revelation Place: ${widget.surah.revelationType}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('• Total Verses: ${widget.surah.ayahCount} Ayahs', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('• Chapter Number: ${widget.surah.number} of 114', style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _setReadingPosition(QuranAyah ayah) async {
    final scope = AppScope.of(context);
    if (scope.preferences.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _activeReadingAyah = ayah.ayahNumber;
    });
    await scope.recordProgress(
      ReadingProgress(
        contentType: ContentType.quran,
        targetId: widget.surah.number.toString(),
        itemNumber: ayah.ayahNumber,
        title: 'Surah ${widget.surah.nameEnglish}',
        subtitle: 'Verse ${ayah.ayahNumber} • ${widget.surah.nameArabic}',
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reading position saved: Verse ${ayah.ayahNumber}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToAyah(int ayahNumber) {
    final index = _ayahs.indexWhere((a) => a.ayahNumber == ayahNumber);
    if (index != -1 && _scrollController.hasClients) {
      final approximateOffset = 220.0 + (index * 200.0);
      _scrollController.animateTo(
        approximateOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showJumpToAyahDialog() {
    if (_ayahs.isEmpty) return;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Jump to Verse (1 - ${widget.surah.ayahCount})'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter verse number',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final target = int.tryParse(controller.text);
                if (target != null && target >= 1 && target <= widget.surah.ayahCount) {
                  Navigator.of(ctx).pop();
                  _scrollToAyah(target);
                }
              },
              child: const Text('Jump'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) return;
    final scope = AppScope.of(context);
    final surah = await scope.contentRepository.getSurah(surahNumber);
    if (surah != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuranReaderView(surah: surah),
        ),
      );
    }
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

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                    const SizedBox(height: 12),

                    // Reading Display Mode
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

                    // Arabic Size Slider
                    if (prefs.readingDisplayMode != ReadingDisplayMode.translationOnly) ...[
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
                    ],

                    // Translation Size Slider
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

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;

    final contentCount = _ayahs.isEmpty ? 1 : _ayahs.length;
    final totalItemCount = 1 + contentCount + 2; // header + (empty state or ayahs) + navigation + footer

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
            icon: const Icon(Icons.pin_outlined),
            tooltip: 'Jump to Verse',
            onPressed: _showJumpToAyahDialog,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Surah Overview',
            onPressed: () => _showSurahInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Typography Controls',
            onPressed: _showTypographySheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: LinearProgressIndicator(
            value: _readingProgress,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC5A059)),
            minHeight: 2.5,
          ),
        ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: totalItemCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeader(context);
                  }
                  if (index <= contentCount) {
                    if (_ayahs.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    final ayah = _ayahs[index - 1];
                    return _buildAyahCard(context, ayah, scope, prefs);
                  }
                  if (index == contentCount + 1) {
                    return _buildNavigationRow(context);
                  }
                  return _buildFooterAttribution(context);
                },
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            const Color(0xFFC5A059).withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const IslamicOrnamentalDivider(height: 16),
          const SizedBox(height: 6),
          Text(
            widget.surah.nameArabic,
            style: AppTypography.arabic(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC5A059),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              '${widget.surah.revelationType} • ${widget.surah.ayahCount} Verses',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (widget.surah.number != 1 && widget.surah.number != 9) ...[
            const SizedBox(height: 16),
            const BismillahBanner(),
          ] else ...[
            const SizedBox(height: 10),
            const IslamicOrnamentalDivider(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Text(
          'Verses for Surah ${widget.surah.nameEnglish} are indexed.\nOffline sync ready.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    BuildContext context,
    QuranAyah ayah,
    AppScope scope,
    UserPreferences prefs,
  ) {
    final isBookmarked = scope.isBookmarked('quran_${ayah.id}');
    final isHighlighted = widget.initialAyahNumber == ayah.ayahNumber;
    final isReadingPosition = _activeReadingAyah == ayah.ayahNumber;
    final hasReflection = scope.hasReflection('quran_${ayah.id}') ||
        _reflectedAyahIds.contains('quran_${ayah.id}');

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted || isReadingPosition
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFC5A059).withValues(alpha: 0.22),
          width: isHighlighted || isReadingPosition ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Number and Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RubElHizbBadge(
                    number: ayah.ayahNumber,
                    size: 36,
                    accentColor: isReadingPosition
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFC5A059),
                  ),
                  if (isReadingPosition) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LAST READ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy Verse',
                    onPressed: () {
                      if (prefs.hapticFeedbackEnabled) {
                        HapticFeedback.lightImpact();
                      }
                      Clipboard.setData(ClipboardData(
                        text: '${ayah.arabicText}\n\n${ayah.englishTranslation}\n— Surah ${widget.surah.nameEnglish} [${ayah.surahNumber}:${ayah.ayahNumber}]',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied verse ${ayah.ayahNumber} to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      isReadingPosition ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                      size: 19,
                      color: isReadingPosition ? Theme.of(context).colorScheme.primary : null,
                    ),
                    tooltip: isReadingPosition ? 'Active reading position' : 'Mark as reading position',
                    onPressed: () => _setReadingPosition(ayah),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 19,
                      color: isBookmarked ? const Color(0xFFC5A059) : null,
                    ),
                    tooltip: 'Bookmark Verse',
                    onPressed: () {
                      if (prefs.hapticFeedbackEnabled) {
                        HapticFeedback.mediumImpact();
                      }
                      scope.toggleBookmark(contentItem);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 19),
                    tooltip: 'Share Card',
                    onPressed: () {
                      if (prefs.hapticFeedbackEnabled) {
                        HapticFeedback.lightImpact();
                      }
                      ShareCardSheet.show(context, contentItem);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      hasReflection ? Icons.edit_note_rounded : Icons.edit_note_outlined,
                      size: 20,
                      color: hasReflection ? const Color(0xFFC5A059) : null,
                    ),
                    tooltip: hasReflection ? 'Edit Reflection' : 'Add Reflection (Tadabbur)',
                    onPressed: () async {
                      if (prefs.hapticFeedbackEnabled) {
                        HapticFeedback.lightImpact();
                      }
                      final changed = await ReflectionNoteSheet.show(
                        context,
                        contentId: 'quran_${ayah.id}',
                        contentType: ContentType.quran,
                        reference: 'Surah ${widget.surah.nameEnglish} [${ayah.surahNumber}:${ayah.ayahNumber}]',
                        arabicExcerpt: ayah.arabicText,
                        translationExcerpt: ayah.englishTranslation,
                      );
                      if (changed == true && mounted) {
                        await _loadReflectionNotes();
                      }
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabic Text
          if (prefs.readingDisplayMode != ReadingDisplayMode.translationOnly) ...[
            Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.arabic(
                fontSize: prefs.arabicFontSize,
                scriptStyle: prefs.arabicScriptStyle,
                height: prefs.lineSpacing,
              ),
            ),
          ],
          if (prefs.readingDisplayMode == ReadingDisplayMode.dual)
            const SizedBox(height: 12),

          // English Translation
          if (prefs.readingDisplayMode != ReadingDisplayMode.arabicOnly) ...[
            Text(
              ayah.englishTranslation,
              style: AppTypography.translation(
                fontSize: prefs.translationFontSize,
                height: (prefs.lineSpacing * 0.88).clamp(1.4, 2.2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          if (widget.surah.number > 1)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToSurah(widget.surah.number - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'Surah ${widget.surah.number - 1}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          if (widget.surah.number < 114)
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _navigateToSurah(widget.surah.number + 1),
                label: Text(
                  'Surah ${widget.surah.number + 1}',
                  overflow: TextOverflow.ellipsis,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFooterAttribution(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: Text(
          'Translation: Saheeh International\nMedina Mushaf (Hafs an Asim) Standard Edition',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
