import 'package:flutter/material.dart';
import 'bookmark_model.dart';

/// Available procedural visual families defined in Section 11.1 of the Product Plan.
enum VisualPreset {
  aurora('Aurora', 'Cool emeralds, teals, and soft night tones'),
  warmDawn('Warm Dawn', 'Rose, amber, apricot, and soft golden light'),
  deepNight('Deep Night', 'Indigo, midnight slate, and quiet depths'),
  oceanic('Oceanic', 'Azure, cyan, and marine calm'),
  botanical('Botanical', 'Sage, olive, forest greens, and earth'),
  softPaper('Soft Paper', 'Minimal warm parchment and clean ivory'),
  monochrome('Monochrome', 'Subtle grays and balanced charcoal'),
  highContrast('High Contrast', 'Maximum contrast for accessibility');

  const VisualPreset(this.label, this.description);
  final String label;
  final String description;
}

/// Visual intensity levels.
enum VisualIntensity {
  subtle(0.35, 'Subtle & Restrained'),
  standard(0.60, 'Balanced & Harmonious'),
  vibrant(0.85, 'Vibrant & Expressive');

  const VisualIntensity(this.value, this.label);
  final double value;
  final String label;
}

/// User preferences model stored purely on device.
class UserPreferences {
  const UserPreferences({
    this.selectedCategoryIds = const {},
    this.themeMode = ThemeMode.system,
    this.plainReadingMode = false,
    this.visualPreset = VisualPreset.aurora,
    this.visualIntensity = VisualIntensity.standard,
    this.arabicFontSize = 24.0,
    this.translationFontSize = 15.0,
    this.contentTypeFilter,
  });

  final Set<String> selectedCategoryIds;
  final ThemeMode themeMode;
  final bool plainReadingMode;
  final VisualPreset visualPreset;
  final VisualIntensity visualIntensity;
  final double arabicFontSize;
  final double translationFontSize;
  final ContentType? contentTypeFilter;

  UserPreferences copyWith({
    Set<String>? selectedCategoryIds,
    ThemeMode? themeMode,
    bool? plainReadingMode,
    VisualPreset? visualPreset,
    VisualIntensity? visualIntensity,
    double? arabicFontSize,
    double? translationFontSize,
    ContentType? Function()? contentTypeFilter,
  }) {
    return UserPreferences(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      themeMode: themeMode ?? this.themeMode,
      plainReadingMode: plainReadingMode ?? this.plainReadingMode,
      visualPreset: visualPreset ?? this.visualPreset,
      visualIntensity: visualIntensity ?? this.visualIntensity,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      contentTypeFilter:
          contentTypeFilter != null ? contentTypeFilter() : this.contentTypeFilter,
    );
  }
}
