import 'dart:io' hide ContentType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/user_preferences.dart';
import '../../../visual_engine/export/card_exporter.dart';

/// Interactive modal sheet to customize and export shareable wallpaper cards.
/// Complies with Section 13 of the Product Plan.
class ShareCardSheet extends StatefulWidget {
  const ShareCardSheet({super.key, required this.item});

  final ContentItem item;

  static void show(BuildContext context, ContentItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareCardSheet(item: item),
    );
  }

  @override
  State<ShareCardSheet> createState() => _ShareCardSheetState();
}

enum CardAspectRatio {
  standard('Card'),
  square('Square 1:1'),
  wallpaper('Wallpaper 9:16');

  const CardAspectRatio(this.label);
  final String label;
}

enum ContentDisplayMode {
  both('Arabic & English'),
  arabicOnly('Arabic Only'),
  englishOnly('English Only');

  const ContentDisplayMode(this.label);
  final String label;
}

class _ShareCardSheetState extends State<ShareCardSheet> {
  final GlobalKey _cardKey = GlobalKey();
  late AppThemePalette _selectedPalette;
  CardAspectRatio _aspectRatio = CardAspectRatio.standard;
  ContentDisplayMode _displayMode = ContentDisplayMode.both;
  bool _isExporting = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final scope = AppScope.of(context);
      _selectedPalette = scope.preferences.themePalette;
      _initialized = true;
    }
  }

  Future<void> _exportImage() async {
    setState(() => _isExporting = true);
    final bytes = await CardExporter.capturePng(_cardKey);
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (bytes != null) {
      try {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${tempDir.path}/card_${widget.item.id}_${_aspectRatio.name}_$timestamp.png';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        final caption = '${widget.item.reference}\n${widget.item.englishTranslation}\n\n${widget.item.attribution}';
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: caption,
            subject: widget.item.reference,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card image generated (${bytes.lengthInBytes ~/ 1024} KB). Ready to share!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate image. Please try plain text sharing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyPlainText() {
    final text = CardExporter.formatPlainText(widget.item);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Source text and reference copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sharePlainText() async {
    final text = CardExporter.formatPlainText(widget.item);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: widget.item.reference,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isQuran = widget.item.contentType == ContentType.quran;
    final primaryColor = _selectedPalette.primaryColor;
    final accentColor = _selectedPalette.accentColor;
    final badgeColor = isQuran ? primaryColor : const Color(0xFFC5A059);
    final cardBg = isDark
        ? Color.lerp(primaryColor, const Color(0xFF101413), 0.85)!
        : Color.lerp(primaryColor, const Color(0xFFFCFAF7), 0.94)!;
    final textColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1E2822);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF5B6B63);

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Top drag indicator and title
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Card',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content scroll view
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Card Preview wrapped in RepaintBoundary for capture
                    Center(
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: _aspectRatio == CardAspectRatio.wallpaper ? 340 : 420,
                          ),
                          child: AspectRatio(
                            aspectRatio: _aspectRatio == CardAspectRatio.square
                                ? 1.0
                                : _aspectRatio == CardAspectRatio.wallpaper
                                    ? 9 / 16
                                    : 4 / 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          primaryColor.withValues(alpha: 0.28),
                                          cardBg,
                                          accentColor.withValues(alpha: 0.15),
                                        ]
                                      : [
                                          primaryColor.withValues(alpha: 0.08),
                                          cardBg,
                                          accentColor.withValues(alpha: 0.12),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: isDark ? 0.35 : 0.45),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Content Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: badgeColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: badgeColor.withValues(alpha: 0.35),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                widget.item.contentType.displayName.toUpperCase(),
                                                style: AppTypography.badge(
                                                  color: badgeColor,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 18,
                                              color: accentColor.withValues(alpha: 0.8),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        // Arabic text in sacred container
                                        if (_displayMode != ContentDisplayMode.englishOnly &&
                                            widget.item.arabicText.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(alpha: isDark ? 0.10 : 0.05),
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              widget.item.arabicText,
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.rtl,
                                              style: AppTypography.arabic(
                                                fontSize: _aspectRatio == CardAspectRatio.wallpaper ? 22 : 20,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                        ],

                                        // Translation text
                                        if (_displayMode != ContentDisplayMode.arabicOnly) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              widget.item.englishTranslation,
                                              textAlign: TextAlign.center,
                                              style: AppTypography.translation(
                                                fontSize: _aspectRatio == CardAspectRatio.wallpaper ? 14.5 : 14,
                                                color: textColor.withValues(alpha: 0.95),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                        ],

                                        // Divider
                                        Divider(
                                          height: 1,
                                          color: accentColor.withValues(alpha: 0.25),
                                        ),
                                        const SizedBox(height: 10),

                                        // Reference and Attribution
                                        Text(
                                          widget.item.reference,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.reference(
                                            color: badgeColor,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.item.attribution,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Format & Aspect Ratio Selector
                    Text(
                      'Format & Dimensions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: CardAspectRatio.values.map((ratio) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(ratio.label),
                              selected: ratio == _aspectRatio,
                              onSelected: (val) {
                                if (val) setState(() => _aspectRatio = ratio);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content Display Mode Selector
                    Text(
                      'Text Content',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ContentDisplayMode.values.map((mode) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(mode.label),
                              selected: mode == _displayMode,
                              onSelected: (val) {
                                if (val) setState(() => _displayMode = mode);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Palette Preset Selector
                    Text(
                      'Theme Palette',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppThemePalette.values.map((palette) {
                          final isSelected = palette == _selectedPalette;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              avatar: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: palette.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              label: Text(palette.label),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) setState(() => _selectedPalette = palette);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Pinned Bottom Action Bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                child: Row(
                  children: [
                    IconButton.outlined(
                      onPressed: _copyPlainText,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy Plain Text',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sharePlainText,
                        icon: const Icon(Icons.text_snippet_outlined, size: 17),
                        label: const Text('Share Text', overflow: TextOverflow.ellipsis),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isExporting ? null : _exportImage,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.image_outlined, size: 17),
                        label: Text(
                          _isExporting ? 'Exporting...' : 'Share Image',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
