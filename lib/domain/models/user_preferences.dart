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

/// Reader display modes.
enum ReadingDisplayMode {
  dual('Dual', 'Arabic and English translation'),
  arabicOnly('Arabic Only', 'Recitation and memorization without translation'),
  translationOnly('Translation Only', 'Translation only for focused study');

  const ReadingDisplayMode(this.label, this.description);
  final String label;
  final String description;
}

/// Elegant curated theme color palettes meeting world-class design standards.
enum AppThemePalette {
  medina(
    label: 'Medina Emerald',
    description: 'Sacred emerald green with illuminated manuscript gold',
    primaryColor: Color(0xFF0D6B3C),
    accentColor: Color(0xFFC5A059),
  ),
  sapphire(
    label: 'Celestial Sapphire',
    description: 'Royal twilight sapphire with luminous celestial accents',
    primaryColor: Color(0xFF133E87),
    accentColor: Color(0xFF5B86E5),
  ),
  sepia(
    label: 'Desert Amber',
    description: 'Warm manuscript parchment, rich amber and espresso tones',
    primaryColor: Color(0xFF8B4513),
    accentColor: Color(0xFFD4A373),
  ),
  amethyst(
    label: 'Twilight Amethyst',
    description: 'Deep noble violet, spiritual plum and rose gold',
    primaryColor: Color(0xFF532E63),
    accentColor: Color(0xFFD6A4E8),
  ),
  monochrome(
    label: 'Onyx & Slate',
    description: 'Minimalist architectural graphite and silver tones',
    primaryColor: Color(0xFF2C3E50),
    accentColor: Color(0xFF95A5A6),
  );

  const AppThemePalette({
    required this.label,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
  });

  final String label;
  final String description;
  final Color primaryColor;
  final Color accentColor;
}

/// Calligraphic Arabic script family.
enum ArabicScriptStyle {
  uthmani('Medina Uthmani', 'King Fahd Complex / Medina Mushaf canonical script'),
  indopak('Indo-Pak', 'Traditional South Asian / Nastaliq aesthetic font'),
  naskh('Clear Naskh', 'Clean, modern high-legibility Naskh typography');

  const ArabicScriptStyle(this.label, this.description);
  final String label;
  final String description;
}

/// User preferences model stored purely on device.
class UserPreferences {
  const UserPreferences({
    this.selectedCategoryIds = const {},
    this.themeMode = ThemeMode.system,
    this.themePalette = AppThemePalette.medina,
    this.eyeComfortSepia = false,
    this.hapticFeedbackEnabled = true,
    this.keepScreenAwake = false,
    this.showTransliteration = false,
    this.plainReadingMode = false,
    this.visualPreset = VisualPreset.aurora,
    this.visualIntensity = VisualIntensity.standard,
    this.arabicFontSize = 24.0,
    this.translationFontSize = 15.0,
    this.readingDisplayMode = ReadingDisplayMode.dual,
    this.arabicScriptStyle = ArabicScriptStyle.uthmani,
    this.pureBlackDark = false,
    this.lineSpacing = 1.8,
    this.contentTypeFilter,
  });

  final Set<String> selectedCategoryIds;
  final ThemeMode themeMode;
  final AppThemePalette themePalette;
  final bool eyeComfortSepia;
  final bool hapticFeedbackEnabled;
  final bool keepScreenAwake;
  final bool showTransliteration;
  final bool plainReadingMode;
  final VisualPreset visualPreset;
  final VisualIntensity visualIntensity;
  final double arabicFontSize;
  final double translationFontSize;
  final ReadingDisplayMode readingDisplayMode;
  final ArabicScriptStyle arabicScriptStyle;
  final bool pureBlackDark;
  final double lineSpacing;
  final ContentType? contentTypeFilter;

  UserPreferences copyWith({
    Set<String>? selectedCategoryIds,
    ThemeMode? themeMode,
    AppThemePalette? themePalette,
    bool? eyeComfortSepia,
    bool? hapticFeedbackEnabled,
    bool? keepScreenAwake,
    bool? showTransliteration,
    bool? plainReadingMode,
    VisualPreset? visualPreset,
    VisualIntensity? visualIntensity,
    double? arabicFontSize,
    double? translationFontSize,
    ReadingDisplayMode? readingDisplayMode,
    ArabicScriptStyle? arabicScriptStyle,
    bool? pureBlackDark,
    double? lineSpacing,
    ContentType? Function()? contentTypeFilter,
  }) {
    return UserPreferences(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      themeMode: themeMode ?? this.themeMode,
      themePalette: themePalette ?? this.themePalette,
      eyeComfortSepia: eyeComfortSepia ?? this.eyeComfortSepia,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      plainReadingMode: plainReadingMode ?? this.plainReadingMode,
      visualPreset: visualPreset ?? this.visualPreset,
      visualIntensity: visualIntensity ?? this.visualIntensity,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      readingDisplayMode: readingDisplayMode ?? this.readingDisplayMode,
      arabicScriptStyle: arabicScriptStyle ?? this.arabicScriptStyle,
      pureBlackDark: pureBlackDark ?? this.pureBlackDark,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      contentTypeFilter:
          contentTypeFilter != null ? contentTypeFilter() : this.contentTypeFilter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedCategoryIds': selectedCategoryIds.toList(),
      'themeMode': themeMode.name,
      'themePalette': themePalette.name,
      'eyeComfortSepia': eyeComfortSepia,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'keepScreenAwake': keepScreenAwake,
      'showTransliteration': showTransliteration,
      'plainReadingMode': plainReadingMode,
      'visualPreset': visualPreset.name,
      'visualIntensity': visualIntensity.name,
      'arabicFontSize': arabicFontSize,
      'translationFontSize': translationFontSize,
      'readingDisplayMode': readingDisplayMode.name,
      'arabicScriptStyle': arabicScriptStyle.name,
      'pureBlackDark': pureBlackDark,
      'lineSpacing': lineSpacing,
      'contentTypeFilter': contentTypeFilter?.name,
    };
  }
}
