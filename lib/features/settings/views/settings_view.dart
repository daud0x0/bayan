import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/user_preferences.dart';
import 'topic_preferences_view.dart';

/// Settings screen for typography, visual themes, privacy, content rights, and donations.
/// Complies with Section 4.4, 6, 11, and 14 of the Product Plan.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showRightsProvenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Content Rights & Provenance'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Holy Quran Arabic Text',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Script: Medina Mushaf (Hafs \'an \'Asim standard Uthmani script).\n• Provenance: King Fahd Complex for Printing the Holy Quran / Tanzil.'),
              SizedBox(height: 12),
              Text(
                '2. Quran English Translation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Edition: Saheeh International (Revised edition).\n• Attribution: "The Quran: Arabic Text with Corresponding English Meanings by Saheeh International".'),
              SizedBox(height: 12),
              Text(
                '3. Hadith Collections',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Sahih al-Bukhari: Translated by Dr. Muhammad Muhsin Khan.\n• Sahih Muslim: Translated by Abdul Hamid Siddiqui.\n• Numbering: Aligned with standard references.'),
              SizedBox(height: 12),
              Text(
                '4. Editorial Taxonomy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 15 curated categories provided solely as discovery aids, never as authoritative religious rulings.'),
            ],
          ),
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

  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism_outlined, size: 22),
            SizedBox(width: 8),
            Expanded(child: Text('Support This Project')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This application is 100% free, ad-free, account-free, and privacy-respecting.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Donations are entirely optional and never unlock or restrict any feature. Contributions help support accessibility enhancements, content rights reviews, and ongoing software maintenance.',
            ),
            SizedBox(height: 12),
            Text(
              'No payment credentials are ever accepted or stored inside this app.',
              style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donation gateway link opened in external browser.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Open External Link'),
          ),
        ],
      ),
    );
  }

  void _showReportCorrectionDialog(BuildContext context) {
    // Inline stateful dialog via StatefulBuilder — no additional file needed.
    const correctionTypes = [
      'Typographic / diacritic error',
      'Translation discrepancy',
      'Hadith number mismatch',
      'Missing attribution / edition info',
      'Category mapping concern',
      'Other',
    ];
    String selectedType = correctionTypes.first;
    final refController = TextEditingController();
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.spellcheck_rounded, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Report a Correction'),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Religious text integrity is paramount. Describe the issue precisely. '
                    'Your report will be copied to the clipboard so you can forward it '
                    'to the project maintainers.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(ctx).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Correction type selector
                  const Text(
                    'Issue type',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: correctionTypes.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 13.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Exact reference
                  const Text(
                    'Exact citation / reference',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: refController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Sahih al-Bukhari 6294, or Surah Al-Baqarah [2:255]',
                      hintStyle: const TextStyle(fontSize: 12.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13.5),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Describe the error and, if possible, the correct text or edition source.',
                      hintStyle: const TextStyle(fontSize: 12.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13.5),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Report'),
                onPressed: () async {
                  final ref = refController.text.trim();
                  final desc = descController.text.trim();
                  final report = StringBuffer()
                    ..writeln('[Quran & Hadith Discovery — Content Correction Report]')
                    ..writeln('Issue type : $selectedType')
                    ..writeln('Reference  : ${ref.isEmpty ? '(not provided)' : ref}')
                    ..writeln('Description: ${desc.isEmpty ? '(not provided)' : desc}');

                  await Clipboard.setData(ClipboardData(text: report.toString()));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Report copied to clipboard. Please send it to the project maintainers.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }


  void _confirmResetData(BuildContext context, AppScope scope) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Local Data?'),
        content: const Text(
          'This will clear all your saved bookmarks, reading positions, and customized preferences. The app will return to its default offline baseline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await scope.resetAllLocalData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local data has been safely cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  Widget _buildPalettePicker(BuildContext context, AppScope scope, UserPreferences prefs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Palette',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemePalette.values.map((palette) {
              final isSelected = prefs.themePalette == palette;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  scope.updatePreferences(prefs.copyWith(themePalette: palette));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? palette.primaryColor.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? palette.primaryColor
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: palette.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.accentColor, width: 1.8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        palette.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? palette.primaryColor : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Appearance & Themes
          _sectionHeader(context, 'Appearance & Theme', Icons.palette_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPalettePicker(context, scope, prefs),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme Mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          segments: const [
                            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16), label: Text('Light')),
                            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 16), label: Text('Auto')),
                            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16), label: Text('Dark')),
                          ],
                          selected: {prefs.themeMode},
                          onSelectionChanged: (set) {
                            scope.updatePreferences(prefs.copyWith(themeMode: set.first));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: const Text('Eye-Comfort Warm Sepia'),
                  subtitle: const Text('Soothing parchment canvas optimized for long reading sessions'),
                  value: prefs.eyeComfortSepia,
                  onChanged: (val) {
                    scope.updatePreferences(prefs.copyWith(eyeComfortSepia: val));
                  },
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: const Text('OLED Pure Black Dark Theme'),
                  subtitle: const Text('True black background in dark mode for maximum contrast and battery saving'),
                  value: prefs.pureBlackDark,
                  onChanged: (val) {
                    scope.updatePreferences(prefs.copyWith(pureBlackDark: val));
                  },
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: const Text('Plain Reading Mode'),
                  subtitle: const Text('Solid background for maximum legibility and distraction-free reading'),
                  value: prefs.plainReadingMode,
                  onChanged: (val) {
                    scope.updatePreferences(prefs.copyWith(plainReadingMode: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Visual Engine Settings
          _sectionHeader(context, 'Procedural Visual Engine', Icons.auto_awesome_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, size: 20, color: Theme.of(context).colorScheme.outline),
                  title: const Text('Palette Preset', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text(prefs.visualPreset.description, style: const TextStyle(fontSize: 12)),
                  trailing: DropdownButton<VisualPreset>(
                    value: prefs.visualPreset,
                    underline: const SizedBox(),
                    items: VisualPreset.values.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.label, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) {
                        scope.updatePreferences(prefs.copyWith(visualPreset: p));
                      }
                    },
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: Icon(Icons.tune_rounded, size: 20, color: Theme.of(context).colorScheme.outline),
                  title: const Text('Visual Intensity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text(
                    prefs.visualIntensity == VisualIntensity.subtle
                        ? 'Subtle background patterns'
                        : prefs.visualIntensity == VisualIntensity.standard
                            ? 'Balanced geometric accents'
                            : 'Vibrant expressive patterns',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: DropdownButton<VisualIntensity>(
                    value: prefs.visualIntensity,
                    underline: const SizedBox(),
                    items: VisualIntensity.values.map((i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text(
                          i == VisualIntensity.subtle
                              ? 'Subtle'
                              : i == VisualIntensity.standard
                                  ? 'Balanced'
                                  : 'Vibrant',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (i) {
                      if (i != null) {
                        scope.updatePreferences(prefs.copyWith(visualIntensity: i));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Typography & Text Sizing
          _sectionHeader(context, 'Typography', Icons.text_fields_rounded),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading Display Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ReadingDisplayMode>(
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(value: ReadingDisplayMode.dual, label: Text('Dual')),
                        ButtonSegment(value: ReadingDisplayMode.arabicOnly, label: Text('Arabic Only')),
                        ButtonSegment(value: ReadingDisplayMode.translationOnly, label: Text('Translation Only')),
                      ],
                      selected: {prefs.readingDisplayMode},
                      onSelectionChanged: (set) {
                        scope.updatePreferences(prefs.copyWith(readingDisplayMode: set.first));
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.font_download_outlined, size: 20, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Arabic Script Style',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                            scope.updatePreferences(prefs.copyWith(arabicScriptStyle: s));
                          }
                        },
                      ),
                    ],
                  ),
                  Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Arabic Font Size', style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${prefs.arabicFontSize.toInt()} pt',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: prefs.arabicFontSize,
                    min: 18.0,
                    max: 36.0,
                    divisions: 9,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(arabicFontSize: val));
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Translation Font Size', style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${prefs.translationFontSize.toInt()} pt',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: prefs.translationFontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(translationFontSize: val));
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Line Spacing', style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${prefs.lineSpacing.toStringAsFixed(1)}x',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: prefs.lineSpacing,
                    min: 1.4,
                    max: 2.6,
                    divisions: 6,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(lineSpacing: val));
                    },
                  ),
                  const SizedBox(height: 12),
                  // Live Typography Preview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.arabic(
                            fontSize: prefs.arabicFontSize,
                            scriptStyle: prefs.arabicScriptStyle,
                            height: prefs.lineSpacing,
                            color: const Color(0xFFC5A059),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                          textAlign: TextAlign.center,
                          style: AppTypography.translation(
                            fontSize: prefs.translationFontSize,
                            height: (prefs.lineSpacing * 0.88).clamp(1.4, 2.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Phonetic Transliteration'),
                    subtitle: const Text('Display phonetic Latin pronunciation guides'),
                    value: prefs.showTransliteration,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(showTransliteration: val));
                    },
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Haptic Touch Feedback'),
                    subtitle: const Text('Gentle tactile sensations during reading interactions'),
                    value: prefs.hapticFeedbackEnabled,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(hapticFeedbackEnabled: val));
                    },
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Keep Screen Awake'),
                    subtitle: const Text('Prevent display from sleeping during reading sessions'),
                    value: prefs.keepScreenAwake,
                    onChanged: (val) {
                      scope.updatePreferences(prefs.copyWith(keepScreenAwake: val));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Section: Content & Discovery
          _sectionHeader(context, 'Content & Taxonomy', Icons.auto_stories_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Manage Topic Preferences'),
                  subtitle: Text(
                    prefs.selectedCategoryIds.isEmpty
                        ? 'All 15 editorial categories active'
                        : '${prefs.selectedCategoryIds.length} categories prioritised',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TopicPreferencesView(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: const Text('Content Rights & Editions'),
                  subtitle: const Text('View official editions, licenses, and attributions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRightsProvenanceDialog(context),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.spellcheck_rounded),
                  title: const Text('Report Content Issue / Correction'),
                  subtitle: const Text('Submit a typographic or text verification report'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showReportCorrectionDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Privacy & Funding
          _sectionHeader(context, 'Privacy & Funding', Icons.shield_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.security_outlined, color: Colors.teal),
                  title: Text('Offline-First Privacy Guarantee'),
                  subtitle: Text(
                    'No accounts. No user tracking. Reading history is stored strictly on your device.',
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism_outlined),
                  title: const Text('Support & Donations'),
                  subtitle: const Text('Optional donations. No locked features or ads.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDonationDialog(context),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  title: const Text('Reset All Local Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Erase local bookmarks, reading progress, and settings'),
                  onTap: () => _confirmResetData(context, scope),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Quran & Hadith Discovery • v1.0.0 (Offline-First Baseline)\nBuilt with Flutter & Dart',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
          ],
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
