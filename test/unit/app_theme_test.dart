import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/app/theme/app_theme.dart';
import 'package:quran_hadis/domain/models/user_preferences.dart';

void main() {
  group('AppTheme world-class multi-palette architecture', () {
    test('supports all 5 curated luxury palettes', () {
      expect(AppThemePalette.values, containsAll([
        AppThemePalette.medina,
        AppThemePalette.sapphire,
        AppThemePalette.sepia,
        AppThemePalette.amethyst,
        AppThemePalette.monochrome,
      ]));
    });

    test('generates valid light ThemeData for each palette', () {
      for (final palette in AppThemePalette.values) {
        final theme = AppTheme.light(palette: palette);
        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, equals(Brightness.light));
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(theme.chipTheme.shape, isA<RoundedRectangleBorder>());
      }
    });

    test('generates eye-comfort warm sepia light theme', () {
      final sepiaTheme = AppTheme.light(
        palette: AppThemePalette.sepia,
        eyeComfortSepia: true,
      );
      expect(sepiaTheme.scaffoldBackgroundColor, equals(const Color(0xFFF5EFE0)));
      expect(sepiaTheme.colorScheme.surface, equals(const Color(0xFFFAF6EC)));
    });

    test('generates valid dark ThemeData with OLED pure black option', () {
      for (final palette in AppThemePalette.values) {
        final darkTheme = AppTheme.dark(palette: palette);
        expect(darkTheme.brightness, equals(Brightness.dark));

        final pureBlackTheme = AppTheme.dark(palette: palette, pureBlack: true);
        expect(pureBlackTheme.scaffoldBackgroundColor, equals(Colors.black));
        expect(pureBlackTheme.cardTheme.color, equals(Colors.black));
      }
    });

    test('retains backward compatibility defaults', () {
      final defaultLight = AppTheme.light();
      final defaultDark = AppTheme.dark();
      expect(defaultLight.useMaterial3, isTrue);
      expect(defaultDark.useMaterial3, isTrue);
    });
  });
}
