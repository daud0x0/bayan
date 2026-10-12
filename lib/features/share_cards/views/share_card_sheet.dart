import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/user_preferences.dart';
import '../../../visual_engine/export/card_exporter.dart';
import '../../../visual_engine/generator/seeded_generator.dart';
import '../../../visual_engine/rendering/procedural_background.dart';

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
  late VisualPreset _selectedPreset;
  CardAspectRatio _aspectRatio = CardAspectRatio.standard;
  ContentDisplayMode _displayMode = ContentDisplayMode.both;
  bool _isExporting = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final scope = AppScope.of(context);
      _selectedPreset = scope.preferences.visualPreset;
      _initialized = true;
    }
  }

  Future<void> _exportImage() async {
    setState(() => _isExporting = true);
    final bytes = await CardExporter.capturePng(_cardKey);
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (bytes != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card image generated (${bytes.lengthInBytes ~/ 1024} KB). Ready to share!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final params = SeededVisualGenerator.generate(
      contentId: widget.item.id,
      preset: _selectedPreset,
      isDarkMode: isDark,
      intensity: scope.preferences.visualIntensity,
      isPlainMode: scope.preferences.plainReadingMode,
    );

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
                            child: ProceduralBackground(
                              params: params,
                              borderRadius: 24,
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
                                                color: params.primaryTextColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                widget.item.contentType.displayName.toUpperCase(),
                                                style: AppTypography.badge(
                                                  color: params.primaryTextColor,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.auto_awesome_outlined,
                                              size: 18,
                                              color: Colors.white70,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        // Arabic text
                                        if (_displayMode != ContentDisplayMode.englishOnly &&
                                            widget.item.arabicText.isNotEmpty) ...[
                                          Text(
                                            widget.item.arabicText,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            style: AppTypography.arabic(
                                              fontSize: _aspectRatio == CardAspectRatio.wallpaper ? 22 : 20,
                                              color: params.primaryTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                        ],

                                        // Translation text
                                        if (_displayMode != ContentDisplayMode.arabicOnly) ...[
                                          Text(
                                            widget.item.englishTranslation,
                                            textAlign: TextAlign.center,
                                            style: AppTypography.translation(
                                              fontSize: _aspectRatio == CardAspectRatio.wallpaper ? 14.5 : 14,
                                              color: params.primaryTextColor.withValues(alpha: 0.95),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                        ],

                                        // Divider
                                        Container(
                                          height: 1,
                                          color: params.primaryTextColor.withValues(alpha: 0.15),
                                        ),
                                        const SizedBox(height: 10),

                                        // Reference and Attribution
                                        Text(
                                          widget.item.reference,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.reference(
                                            color: params.primaryTextColor,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.item.attribution,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: params.secondaryTextColor,
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
                      'Visual Palette',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: VisualPreset.values.map((preset) {
                          final isSelected = preset == _selectedPreset;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(preset.label),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) setState(() => _selectedPreset = preset);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyPlainText,
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Plain Text'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isExporting ? null : _exportImage,
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.share_rounded, size: 18),
                            label: Text(_isExporting ? 'Exporting...' : 'Export Card'),
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
                    const SizedBox(height: 16),
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
