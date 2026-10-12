import 'package:flutter/material.dart';
import '../../domain/models/user_preferences.dart';

/// A curated color scheme definition for the procedural visual engine.
class VisualPalette {
  const VisualPalette({
    required this.name,
    required this.primaryLight,
    required this.secondaryLight,
    required this.tertiaryLight,
    required this.backgroundLight,
    required this.surfaceLight,
    required this.primaryDark,
    required this.secondaryDark,
    required this.tertiaryDark,
    required this.backgroundDark,
    required this.surfaceDark,
  });

  final String name;
  final Color primaryLight;
  final Color secondaryLight;
  final Color tertiaryLight;
  final Color backgroundLight;
  final Color surfaceLight;

  final Color primaryDark;
  final Color secondaryDark;
  final Color tertiaryDark;
  final Color backgroundDark;
  final Color surfaceDark;

  List<Color> getLightGradient() => [primaryLight, secondaryLight, tertiaryLight];
  List<Color> getDarkGradient() => [primaryDark, secondaryDark, tertiaryDark];
}

/// Registry of curated, contrast-tested visual families defined in Section 11.1.
class PaletteRegistry {
  PaletteRegistry._();

  static const Map<VisualPreset, VisualPalette> palettes = {
    VisualPreset.aurora: VisualPalette(
      name: 'Aurora',
      primaryLight: Color(0xFF107C41),
      secondaryLight: Color(0xFF028A7A),
      tertiaryLight: Color(0xFF81C784),
      backgroundLight: Color(0xFFF1F8F5),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF0F3E2C),
      secondaryDark: Color(0xFF0A2C29),
      tertiaryDark: Color(0xFF051B17),
      backgroundDark: Color(0xFF07120E),
      surfaceDark: Color(0xFF0C1F18),
    ),
    VisualPreset.warmDawn: VisualPalette(
      name: 'Warm Dawn',
      primaryLight: Color(0xFFD97736),
      secondaryLight: Color(0xFFD94F70),
      tertiaryLight: Color(0xFFF5B041),
      backgroundLight: Color(0xFFFDF7F2),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF4A1A12),
      secondaryDark: Color(0xFF441829),
      tertiaryDark: Color(0xFF261014),
      backgroundDark: Color(0xFF16090B),
      surfaceDark: Color(0xFF231114),
    ),
    VisualPreset.deepNight: VisualPalette(
      name: 'Deep Night',
      primaryLight: Color(0xFF2B3A67),
      secondaryLight: Color(0xFF496A81),
      tertiaryLight: Color(0xFF6B818C),
      backgroundLight: Color(0xFFF2F4F8),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF0D1B2A),
      secondaryDark: Color(0xFF1B263B),
      tertiaryDark: Color(0xFF101925),
      backgroundDark: Color(0xFF080D14),
      surfaceDark: Color(0xFF0F1722),
    ),
    VisualPreset.oceanic: VisualPalette(
      name: 'Oceanic',
      primaryLight: Color(0xFF028090),
      secondaryLight: Color(0xFF00A896),
      tertiaryLight: Color(0xFF02C39A),
      backgroundLight: Color(0xFFEEF8F8),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF032530),
      secondaryDark: Color(0xFF053C48),
      tertiaryDark: Color(0xFF02171E),
      backgroundDark: Color(0xFF020C10),
      surfaceDark: Color(0xFF061A22),
    ),
    VisualPreset.botanical: VisualPalette(
      name: 'Botanical',
      primaryLight: Color(0xFF556B2F),
      secondaryLight: Color(0xFF6B8E23),
      tertiaryLight: Color(0xFF8FBC8F),
      backgroundLight: Color(0xFFF4F7F2),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF1E2B15),
      secondaryDark: Color(0xFF2E3D22),
      tertiaryDark: Color(0xFF131D0E),
      backgroundDark: Color(0xFF0A0F07),
      surfaceDark: Color(0xFF141D10),
    ),
    VisualPreset.softPaper: VisualPalette(
      name: 'Soft Paper',
      primaryLight: Color(0xFF8D7B68),
      secondaryLight: Color(0xFFA4907C),
      tertiaryLight: Color(0xFFC8B6A6),
      backgroundLight: Color(0xFFF9F5F0),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF2C2723),
      secondaryDark: Color(0xFF38322D),
      tertiaryDark: Color(0xFF1E1A17),
      backgroundDark: Color(0xFF12100E),
      surfaceDark: Color(0xFF1D1917),
    ),
    VisualPreset.monochrome: VisualPalette(
      name: 'Monochrome',
      primaryLight: Color(0xFF4A4E51),
      secondaryLight: Color(0xFF6C757D),
      tertiaryLight: Color(0xFFADB5BD),
      backgroundLight: Color(0xFFF8F9FA),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFF212529),
      secondaryDark: Color(0xFF343A40),
      tertiaryDark: Color(0xFF1A1D20),
      backgroundDark: Color(0xFF0D0F11),
      surfaceDark: Color(0xFF16191D),
    ),
    VisualPreset.highContrast: VisualPalette(
      name: 'High Contrast',
      primaryLight: Color(0xFF000000),
      secondaryLight: Color(0xFF1A1A1A),
      tertiaryLight: Color(0xFF333333),
      backgroundLight: Color(0xFFFFFFFF),
      surfaceLight: Color(0xFFFFFFFF),
      primaryDark: Color(0xFFFFFFFF),
      secondaryDark: Color(0xFFE0E0E0),
      tertiaryDark: Color(0xFFCCCCCC),
      backgroundDark: Color(0xFF000000),
      surfaceDark: Color(0xFF121212),
    ),
  };

  static VisualPalette getPalette(VisualPreset preset) {
    return palettes[preset] ?? palettes[VisualPreset.aurora]!;
  }
}
