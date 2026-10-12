import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/bookmark_model.dart';
import '../../domain/models/user_preferences.dart';

/// Repository for persisting user settings locally via SharedPreferences.
/// Complies with Section 14 (Private, on-device only) of the Product Plan.
class PreferencesRepository {
  static const _kCategoriesKey = 'user_selected_categories';
  static const _kThemeModeKey = 'user_theme_mode';
  static const _kThemePaletteKey = 'user_theme_palette';
  static const _kEyeComfortSepiaKey = 'user_eye_comfort_sepia';
  static const _kHapticFeedbackKey = 'user_haptic_feedback';
  static const _kKeepScreenAwakeKey = 'user_keep_screen_awake';
  static const _kShowTransliterationKey = 'user_show_transliteration';
  static const _kPlainModeKey = 'user_plain_reading_mode';
  static const _kPresetKey = 'user_visual_preset';
  static const _kIntensityKey = 'user_visual_intensity';
  static const _kArabicFontSizeKey = 'user_arabic_font_size';
  static const _kTranslationFontSizeKey = 'user_translation_font_size';
  static const _kReadingDisplayModeKey = 'user_reading_display_mode';
  static const _kArabicScriptStyleKey = 'user_arabic_script_style';
  static const _kPureBlackDarkKey = 'user_pure_black_dark';
  static const _kLineSpacingKey = 'user_line_spacing';
  static const _kContentTypeFilterKey = 'user_content_type_filter';

  Future<UserPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final categoryList = prefs.getStringList(_kCategoriesKey) ?? [];
    final themeStr = prefs.getString(_kThemeModeKey) ?? 'system';
    final paletteStr = prefs.getString(_kThemePaletteKey) ?? 'medina';
    final eyeComfort = prefs.getBool(_kEyeComfortSepiaKey) ?? false;
    final haptics = prefs.getBool(_kHapticFeedbackKey) ?? true;
    final keepAwake = prefs.getBool(_kKeepScreenAwakeKey) ?? false;
    final transliteration = prefs.getBool(_kShowTransliterationKey) ?? false;
    final plainMode = prefs.getBool(_kPlainModeKey) ?? false;
    final presetStr = prefs.getString(_kPresetKey) ?? 'aurora';
    final intensityStr = prefs.getString(_kIntensityKey) ?? 'standard';
    final arSize = prefs.getDouble(_kArabicFontSizeKey) ?? 24.0;
    final trSize = prefs.getDouble(_kTranslationFontSizeKey) ?? 15.0;
    final displayModeStr = prefs.getString(_kReadingDisplayModeKey) ?? 'dual';
    final scriptStr = prefs.getString(_kArabicScriptStyleKey) ?? 'uthmani';
    final pureBlack = prefs.getBool(_kPureBlackDarkKey) ?? false;
    final lineSpacing = prefs.getDouble(_kLineSpacingKey) ?? 1.8;
    final filterStr = prefs.getString(_kContentTypeFilterKey);

    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    final themePalette = AppThemePalette.values.firstWhere(
      (p) => p.name == paletteStr,
      orElse: () => AppThemePalette.medina,
    );

    final visualPreset = VisualPreset.values.firstWhere(
      (p) => p.name == presetStr,
      orElse: () => VisualPreset.aurora,
    );

    final visualIntensity = VisualIntensity.values.firstWhere(
      (i) => i.name == intensityStr,
      orElse: () => VisualIntensity.standard,
    );

    final displayMode = ReadingDisplayMode.values.firstWhere(
      (d) => d.name == displayModeStr,
      orElse: () => ReadingDisplayMode.dual,
    );

    final scriptStyle = ArabicScriptStyle.values.firstWhere(
      (s) => s.name == scriptStr,
      orElse: () => ArabicScriptStyle.uthmani,
    );

    ContentType? contentTypeFilter;
    if (filterStr != null && filterStr.isNotEmpty) {
      try {
        contentTypeFilter = ContentType.values.byName(filterStr);
      } catch (_) {}
    }

    return UserPreferences(
      selectedCategoryIds: categoryList.toSet(),
      themeMode: themeMode,
      themePalette: themePalette,
      eyeComfortSepia: eyeComfort,
      hapticFeedbackEnabled: haptics,
      keepScreenAwake: keepAwake,
      showTransliteration: transliteration,
      plainReadingMode: plainMode,
      visualPreset: visualPreset,
      visualIntensity: visualIntensity,
      arabicFontSize: arSize,
      translationFontSize: trSize,
      readingDisplayMode: displayMode,
      arabicScriptStyle: scriptStyle,
      pureBlackDark: pureBlack,
      lineSpacing: lineSpacing,
      contentTypeFilter: contentTypeFilter,
    );
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_kCategoriesKey, preferences.selectedCategoryIds.toList());
    await prefs.setString(_kThemeModeKey, preferences.themeMode.name);
    await prefs.setString(_kThemePaletteKey, preferences.themePalette.name);
    await prefs.setBool(_kEyeComfortSepiaKey, preferences.eyeComfortSepia);
    await prefs.setBool(_kHapticFeedbackKey, preferences.hapticFeedbackEnabled);
    await prefs.setBool(_kKeepScreenAwakeKey, preferences.keepScreenAwake);
    await prefs.setBool(_kShowTransliterationKey, preferences.showTransliteration);
    await prefs.setBool(_kPlainModeKey, preferences.plainReadingMode);
    await prefs.setString(_kPresetKey, preferences.visualPreset.name);
    await prefs.setString(_kIntensityKey, preferences.visualIntensity.name);
    await prefs.setDouble(_kArabicFontSizeKey, preferences.arabicFontSize);
    await prefs.setDouble(_kTranslationFontSizeKey, preferences.translationFontSize);
    await prefs.setString(_kReadingDisplayModeKey, preferences.readingDisplayMode.name);
    await prefs.setString(_kArabicScriptStyleKey, preferences.arabicScriptStyle.name);
    await prefs.setBool(_kPureBlackDarkKey, preferences.pureBlackDark);
    await prefs.setDouble(_kLineSpacingKey, preferences.lineSpacing);

    if (preferences.contentTypeFilter != null) {
      await prefs.setString(_kContentTypeFilterKey, preferences.contentTypeFilter!.name);
    } else {
      await prefs.remove(_kContentTypeFilterKey);
    }
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
