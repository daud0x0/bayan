import 'package:flutter/material.dart';

/// Ambient auto-scroll floating control bar for hands-free recitation and reading.
/// Provides play/pause, selectable recitation speeds (0.5x, 1.0x, 1.5x, 2.0x), and dismissal.
/// Guaranteed to fit without RenderFlex overflow on compact mobile screens.
class AutoScrollBar extends StatelessWidget {
  const AutoScrollBar({
    super.key,
    required this.isPlaying,
    required this.speed,
    required this.onPlayPauseToggle,
    required this.onSpeedSelected,
    required this.onClose,
  });

  final bool isPlaying;
  final double speed;
  final VoidCallback onPlayPauseToggle;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onClose;

  static const List<double> availableSpeeds = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const goldColor = Color(0xFFC5A059);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play / Pause button
              IconButton.filled(
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                style: IconButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(6),
                ),
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                tooltip: isPlaying ? 'Pause Auto-Scroll' : 'Resume Auto-Scroll',
                onPressed: onPlayPauseToggle,
              ),
              const SizedBox(width: 6),

              // Speed selector chips
              for (final s in availableSpeeds) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: ChoiceChip(
                    label: Text(
                      '${s.toStringAsFixed(s.truncateToDouble() == s ? 0 : 1)}x',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            (speed == s) ? FontWeight.bold : FontWeight.normal,
                        color: (speed == s)
                            ? goldColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: (speed == s),
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) onSpeedSelected(s);
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    selectedColor: goldColor.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: (speed == s)
                          ? goldColor
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 4),
              // Close / Dismiss button
              IconButton(
                iconSize: 18,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: const EdgeInsets.all(4),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Stop & Exit Auto-Scroll',
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
