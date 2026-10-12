import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/user_preferences.dart';
import '../../categories/category_explorer_sheet.dart';

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
            Text('Support This Project'),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Content Correction'),
        content: const Text(
          'Religious text integrity is paramount. If you observe any typographic inconsistency, diacritic discrepancy, or translation nuance, please reach out with the exact citation and edition comparison.',
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
          _sectionHeader(context, 'Appearance & Theme'),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Theme Mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SegmentedButton<ThemeMode>(
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 16)),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
                        ],
                        selected: {prefs.themeMode},
                        onSelectionChanged: (set) {
                          scope.updatePreferences(prefs.copyWith(themeMode: set.first));
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
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
          _sectionHeader(context, 'Procedural Visual Engine'),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Palette Preset',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<VisualPreset>(
                        value: prefs.visualPreset,
                        underline: const SizedBox(),
                        items: VisualPreset.values.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p.label));
                        }).toList(),
                        onChanged: (p) {
                          if (p != null) {
                            scope.updatePreferences(prefs.copyWith(visualPreset: p));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Visual Intensity',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<VisualIntensity>(
                        value: prefs.visualIntensity,
                        underline: const SizedBox(),
                        items: VisualIntensity.values.map((i) {
                          return DropdownMenuItem(value: i, child: Text(i.label));
                        }).toList(),
                        onChanged: (i) {
                          if (i != null) {
                            scope.updatePreferences(prefs.copyWith(visualIntensity: i));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Typography & Text Sizing
          _sectionHeader(context, 'Typography'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Arabic Font Size'),
                      Text('${prefs.arabicFontSize.toInt()} pt',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Translation Font Size'),
                      Text('${prefs.translationFontSize.toInt()} pt',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 12),
                  // Live Typography Preview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: AppTypography.arabic(fontSize: prefs.arabicFontSize),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                          textAlign: TextAlign.center,
                          style: AppTypography.translation(fontSize: prefs.translationFontSize),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Section: Content & Discovery
          _sectionHeader(context, 'Content & Taxonomy'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Manage Topic Preferences'),
                  subtitle: Text(
                    prefs.selectedCategoryIds.isEmpty
                        ? 'All 15 editorial categories active'
                        : '${prefs.selectedCategoryIds.length} categories selected',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    CategoryExplorerSheet.show(context, onSelectCategory: (_) {});
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: const Text('Content Rights & Editions'),
                  subtitle: const Text('View official editions, licenses, and attributions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRightsProvenanceDialog(context),
                ),
                const Divider(height: 1),
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
          _sectionHeader(context, 'Privacy & Funding'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.security_outlined),
                  title: Text('Offline-First Privacy Guarantee'),
                  subtitle: Text(
                    'No accounts. No user tracking. Reading history is stored strictly on your device.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism_outlined),
                  title: const Text('Support & Donations'),
                  subtitle: const Text('Optional donations. No locked features or ads.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDonationDialog(context),
                ),
                const Divider(height: 1),
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

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
