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

class _ShareCardSheetState extends State<ShareCardSheet> {
  final GlobalKey _cardKey = GlobalKey();
  late VisualPreset _selectedPreset;
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
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: ProceduralBackground(
                            params: params,
                            borderRadius: 24,
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
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
                                  const SizedBox(height: 20),

                                  // Arabic text
                                  if (widget.item.arabicText.isNotEmpty) ...[
                                    Text(
                                      widget.item.arabicText,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: AppTypography.arabic(
                                        fontSize: 22,
                                        color: params.primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Translation text
                                  Text(
                                    widget.item.englishTranslation,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.translation(
                                      fontSize: 15,
                                      color: params.primaryTextColor.withValues(alpha: 0.95),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Divider
                                  Container(
                                    height: 1,
                                    color: params.primaryTextColor.withValues(alpha: 0.15),
                                  ),
                                  const SizedBox(height: 12),

                                  // Reference and Attribution
                                  Text(
                                    widget.item.reference,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.reference(
                                      color: params.primaryTextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.item.attribution,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.5,
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
                    const SizedBox(height: 24),

                    // Palette Preset Selector
                    Text(
                      'Visual Palette',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
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
