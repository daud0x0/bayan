import 'package:flutter/material.dart';
import '../../../data/services/quran_audio_player_service.dart';
import 'reciter_selection_sheet.dart';

/// Floating ambient audio recitation control bar for the Quran Reader.
/// Displays active reciter, current Ayah counter, play/pause, seek, Hifz loop, and speed chips.
class QuranAudioBar extends StatelessWidget {
  const QuranAudioBar({
    super.key,
    required this.audioService,
    required this.onClose,
  });

  final QuranAudioPlayerService audioService;
  final VoidCallback onClose;

  static const List<double> availableSpeeds = [0.75, 1.0, 1.25, 1.5];
  static const List<int> repeatModes = [1, 3, 5, 999];

  void _cycleRepeatMode() {
    final current = audioService.repeatTarget;
    final nextIndex = (repeatModes.indexOf(current) + 1) % repeatModes.length;
    audioService.setRepeatTarget(repeatModes[nextIndex]);
  }

  String _getRepeatLabel(int target) {
    if (target == 1) return 'Play Once';
    if (target == 999) return 'Loop ∞';
    return '${target}x Loop';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const goldColor = Color(0xFFC5A059);

    return AnimatedBuilder(
      animation: audioService,
      builder: (context, _) {
        final reciter = audioService.currentReciter;
        final currentAyah = audioService.currentAyahNumber ?? 1;
        final totalAyahs = audioService.totalAyahsInCurrentSurah;
        final isPlaying = audioService.isPlaying;
        final isBuffering = audioService.isBuffering;
        final speed = audioService.speed;
        final repeatTarget = audioService.repeatTarget;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.50),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Info Bar: Reciter & Ayah progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reciter Switcher Pill
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        ReciterSelectionSheet.show(
                          context,
                          currentReciter: reciter,
                          onSelectReciter: (newReciter) {
                            audioService.setReciter(newReciter);
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: goldColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_rounded, size: 14, color: goldColor),
                            const SizedBox(width: 4),
                            Text(
                              reciter.name.split(' ').first,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: goldColor),
                          ],
                        ),
                      ),
                    ),

                    // Ayah Progress Counter
                    Text(
                      totalAyahs > 0 ? 'Ayah $currentAyah of $totalAyahs' : 'Ayah $currentAyah',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    // Hifz Repeat Mode Badge
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _cycleRepeatMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: repeatTarget > 1
                              ? goldColor.withValues(alpha: 0.20)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 13,
                              color: repeatTarget > 1
                                  ? goldColor
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _getRepeatLabel(repeatTarget),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: repeatTarget > 1
                                    ? goldColor
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Controls Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Ayah
                      IconButton(
                        iconSize: 22,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        icon: const Icon(Icons.skip_previous_rounded),
                        tooltip: 'Previous Ayah',
                        onPressed: (currentAyah > 1) ? () => audioService.previousAyah() : null,
                      ),
                      const SizedBox(width: 6),

                      // Play / Pause / Buffering
                      IconButton.filled(
                        iconSize: 22,
                        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                        style: IconButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: isBuffering
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              ),
                        tooltip: isPlaying ? 'Pause Recitation' : 'Play Recitation',
                        onPressed: () => audioService.togglePlayPause(),
                      ),
                      const SizedBox(width: 6),

                      // Next Ayah
                      IconButton(
                        iconSize: 22,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        icon: const Icon(Icons.skip_next_rounded),
                        tooltip: 'Next Ayah',
                        onPressed: (currentAyah < totalAyahs)
                            ? () => audioService.nextAyah()
                            : null,
                      ),
                      const SizedBox(width: 8),

                      // Speed Chips
                      for (final s in availableSpeeds) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: ChoiceChip(
                            label: Text(
                              '${s.toStringAsFixed(s == 1.0 ? 0 : (s == 1.5 ? 1 : 2))}x',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: (speed == s) ? FontWeight.bold : FontWeight.normal,
                                color: (speed == s) ? goldColor : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            selected: (speed == s),
                            showCheckmark: false,
                            onSelected: (selected) {
                              if (selected) audioService.setSpeed(s);
                            },
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
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

                      // Close / Dismiss
                      IconButton(
                        iconSize: 18,
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close Audio Player',
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
