import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_hadis/data/repositories/preferences_repository.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesRepository world-class preferences persistence', () {
    test('loads defaults when empty', () async {
      final repo = PreferencesRepository();
      final prefs = await repo.loadPreferences();

      expect(prefs.themeMode, equals(ThemeMode.system));
      expect(prefs.themePalette, equals(AppThemePalette.medina));
      expect(prefs.eyeComfortSepia, isFalse);
      expect(prefs.hapticFeedbackEnabled, isTrue);
      expect(prefs.keepScreenAwake, isFalse);
      expect(prefs.showTransliteration, isFalse);
      expect(prefs.pureBlackDark, isFalse);
      expect(prefs.arabicFontSize, equals(24.0));
      expect(prefs.translationFontSize, equals(15.0));
    });

    test('persists and reloads updated world-class preferences', () async {
      final repo = PreferencesRepository();
      const updated = UserPreferences(
        themeMode: ThemeMode.dark,
        themePalette: AppThemePalette.sapphire,
        eyeComfortSepia: true,
        hapticFeedbackEnabled: false,
        keepScreenAwake: true,
        showTransliteration: true,
        pureBlackDark: true,
        arabicFontSize: 28.0,
        translationFontSize: 18.0,
        readingDisplayMode: ReadingDisplayMode.arabicOnly,
        arabicScriptStyle: ArabicScriptStyle.naskh,
        visualPreset: VisualPreset.deepNight,
        visualIntensity: VisualIntensity.vibrant,
      );

      await repo.savePreferences(updated);
      final loaded = await repo.loadPreferences();

      expect(loaded.themeMode, equals(ThemeMode.dark));
      expect(loaded.themePalette, equals(AppThemePalette.sapphire));
      expect(loaded.eyeComfortSepia, isTrue);
      expect(loaded.hapticFeedbackEnabled, isFalse);
      expect(loaded.keepScreenAwake, isTrue);
      expect(loaded.showTransliteration, isTrue);
      expect(loaded.pureBlackDark, isTrue);
      expect(loaded.arabicFontSize, equals(28.0));
      expect(loaded.translationFontSize, equals(18.0));
      expect(loaded.readingDisplayMode, equals(ReadingDisplayMode.arabicOnly));
      expect(loaded.arabicScriptStyle, equals(ArabicScriptStyle.naskh));
      expect(loaded.visualPreset, equals(VisualPreset.deepNight));
      expect(loaded.visualIntensity, equals(VisualIntensity.vibrant));
    });
  });
}
