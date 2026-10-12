import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/bookmark_model.dart';
import '../../domain/models/user_preferences.dart';

/// Repository for persisting user settings locally via SharedPreferences.
/// Complies with Section 14 (Private, on-device only) of the Product Plan.
class PreferencesRepository {
  static const _kCategoriesKey = 'user_selected_categories';
  static const _kThemeModeKey = 'user_theme_mode';
  static const _kPlainModeKey = 'user_plain_reading_mode';
  static const _kPresetKey = 'user_visual_preset';
  static const _kIntensityKey = 'user_visual_intensity';
  static const _kArabicFontSizeKey = 'user_arabic_font_size';
  static const _kTranslationFontSizeKey = 'user_translation_font_size';
  static const _kContentTypeFilterKey = 'user_content_type_filter';

  Future<UserPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final categoryList = prefs.getStringList(_kCategoriesKey) ?? [];
    final themeStr = prefs.getString(_kThemeModeKey) ?? 'system';
    final plainMode = prefs.getBool(_kPlainModeKey) ?? false;
    final presetStr = prefs.getString(_kPresetKey) ?? 'aurora';
    final intensityStr = prefs.getString(_kIntensityKey) ?? 'standard';
    final arSize = prefs.getDouble(_kArabicFontSizeKey) ?? 24.0;
    final trSize = prefs.getDouble(_kTranslationFontSizeKey) ?? 15.0;
    final filterStr = prefs.getString(_kContentTypeFilterKey);

    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    final visualPreset = VisualPreset.values.firstWhere(
      (p) => p.name == presetStr,
      orElse: () => VisualPreset.aurora,
    );

    final visualIntensity = VisualIntensity.values.firstWhere(
      (i) => i.name == intensityStr,
      orElse: () => VisualIntensity.standard,
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
      plainReadingMode: plainMode,
      visualPreset: visualPreset,
      visualIntensity: visualIntensity,
      arabicFontSize: arSize,
      translationFontSize: trSize,
      contentTypeFilter: contentTypeFilter,
    );
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_kCategoriesKey, preferences.selectedCategoryIds.toList());
    await prefs.setString(_kThemeModeKey, preferences.themeMode.name);
    await prefs.setBool(_kPlainModeKey, preferences.plainReadingMode);
    await prefs.setString(_kPresetKey, preferences.visualPreset.name);
    await prefs.setString(_kIntensityKey, preferences.visualIntensity.name);
    await prefs.setDouble(_kArabicFontSizeKey, preferences.arabicFontSize);
    await prefs.setDouble(_kTranslationFontSizeKey, preferences.translationFontSize);

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
