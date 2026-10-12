import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';
import 'package:quran_hadis/visual_engine/generator/seeded_generator.dart';

void main() {
  group('SeededVisualGenerator', () {
    test('is strictly deterministic: identical contentId and preset produce identical params', () {
      const contentId = 'quran_94_5';
      const preset = VisualPreset.aurora;

      final params1 = SeededVisualGenerator.generate(
        contentId: contentId,
        preset: preset,
        isDarkMode: false,
        intensity: VisualIntensity.standard,
      );

      final params2 = SeededVisualGenerator.generate(
        contentId: contentId,
        preset: preset,
        isDarkMode: false,
        intensity: VisualIntensity.standard,
      );

      expect(params1.seedKey, equals(params2.seedKey));
      expect(params1.baseGradientColors, equals(params2.baseGradientColors));
      expect(params1.shapes.length, equals(params2.shapes.length));
      expect(params1.gradientStart, equals(params2.gradientStart));
    });

    test('different content IDs yield distinct organic shape layouts', () {
      final paramsA = SeededVisualGenerator.generate(
        contentId: 'quran_1_1',
        preset: VisualPreset.warmDawn,
        isDarkMode: true,
        intensity: VisualIntensity.standard,
      );

      final paramsB = SeededVisualGenerator.generate(
        contentId: 'hadith_bukhari_1',
        preset: VisualPreset.warmDawn,
        isDarkMode: true,
        intensity: VisualIntensity.standard,
      );

      expect(paramsA.seedKey, isNot(equals(paramsB.seedKey)));
    });

    test('plainReadingMode disables decorative shapes and yields flat high-contrast background', () {
      final plainParams = SeededVisualGenerator.generate(
        contentId: 'quran_2_255',
        preset: VisualPreset.monochrome,
        isDarkMode: true,
        intensity: VisualIntensity.standard,
        isPlainMode: true,
      );

      expect(plainParams.shapes, isEmpty);
      expect(plainParams.scrimAlpha, 0.0);
    });
  });
}
