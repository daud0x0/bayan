import 'package:flutter/material.dart';
import '../../../domain/models/reciter_model.dart';

/// Modal bottom sheet allowing users to switch between world-renowned Quran reciters.
class ReciterSelectionSheet extends StatelessWidget {
  const ReciterSelectionSheet({
    super.key,
    required this.selectedReciter,
    required this.onSelectReciter,
  });

  final Reciter selectedReciter;
  final ValueChanged<Reciter> onSelectReciter;

  static void show(
    BuildContext context, {
    required Reciter currentReciter,
    required ValueChanged<Reciter> onSelectReciter,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReciterSelectionSheet(
        selectedReciter: currentReciter,
        onSelectReciter: onSelectReciter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const goldColor = Color(0xFFC5A059);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: goldColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: goldColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Select Reciter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'القُرَّاء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: goldColor.withValues(alpha: 0.85),
                    fontFamily: 'Amiri',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'High-fidelity verse-by-verse recitation with live syncing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Reciters List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: Reciter.availableReciters.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final reciter = Reciter.availableReciters[index];
                  final isSelected = reciter.id == selectedReciter.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? goldColor.withValues(alpha: 0.20)
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        isSelected ? Icons.check_rounded : Icons.person_rounded,
                        color: isSelected ? goldColor : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reciter.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? goldColor : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          reciter.arabicName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? goldColor : theme.colorScheme.outline,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      reciter.style,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      onSelectReciter(reciter);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
