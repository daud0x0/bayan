import 'package:flutter/material.dart';
import '../../domain/models/user_preferences.dart';

/// App theme configurations providing tranquil, spiritual, and high-legibility aesthetics
/// adhering to world-class design standards (Material 3 Expressive, WCAG AAA contrast).
class AppTheme {
  AppTheme._();

  // Legacy aliases for backward compatibility
  static const Color primarySeed = Color(0xFF0D6B3C); // Sacred Medina Emerald
  static const Color goldAccent = Color(0xFFC5A059);  // Illuminated Manuscript Gold
  static const Color lightParchment = Color(0xFFFAF8F5); // Warm Quranic Parchment
  static const Color darkObsidian = Color(0xFF08120F);   // Midnight Obsidian Emerald
  static const Color darkSurface = Color(0xFF0F1E19);

  // Palette color definitions
  static const Color medinaPrimary = Color(0xFF0D6B3C);
  static const Color medinaGold = Color(0xFFC5A059);
  static const Color medinaParchment = Color(0xFFFAF8F5);
  static const Color medinaDark = Color(0xFF08120F);
  static const Color medinaDarkSurface = Color(0xFF0F1E19);

  static const Color sapphirePrimary = Color(0xFF133E87);
  static const Color sapphireAccent = Color(0xFF5B86E5);
  static const Color sapphireParchment = Color(0xFFF5F8FC);
  static const Color sapphireDark = Color(0xFF08101E);
  static const Color sapphireDarkSurface = Color(0xFF0E1A2F);

  static const Color sepiaPrimary = Color(0xFF8B4513);
  static const Color sepiaAccent = Color(0xFFD4A373);
  static const Color sepiaParchment = Color(0xFFFAF5EB);
  static const Color sepiaDark = Color(0xFF140D0A);
  static const Color sepiaDarkSurface = Color(0xFF221611);

  static const Color amethystPrimary = Color(0xFF532E63);
  static const Color amethystAccent = Color(0xFFD6A4E8);
  static const Color amethystParchment = Color(0xFFFAF5FC);
  static const Color amethystDark = Color(0xFF140819);
  static const Color amethystDarkSurface = Color(0xFF220F29);

  static const Color slatePrimary = Color(0xFF2C3E50);
  static const Color slateAccent = Color(0xFF95A5A6);
  static const Color slateParchment = Color(0xFFF8FAFC);
  static const Color slateDark = Color(0xFF0B0F14);
  static const Color slateDarkSurface = Color(0xFF141B24);

  static (Color primary, Color accent, Color parchment, Color darkBg, Color darkSurf) _colorsFor(
      AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.medina:
        return (medinaPrimary, medinaGold, medinaParchment, medinaDark, medinaDarkSurface);
      case AppThemePalette.sapphire:
        return (sapphirePrimary, sapphireAccent, sapphireParchment, sapphireDark, sapphireDarkSurface);
      case AppThemePalette.sepia:
        return (sepiaPrimary, sepiaAccent, sepiaParchment, sepiaDark, sepiaDarkSurface);
      case AppThemePalette.amethyst:
        return (amethystPrimary, amethystAccent, amethystParchment, amethystDark, amethystDarkSurface);
      case AppThemePalette.monochrome:
        return (slatePrimary, slateAccent, slateParchment, slateDark, slateDarkSurface);
    }
  }

  static ThemeData light({
    AppThemePalette palette = AppThemePalette.medina,
    bool eyeComfortSepia = false,
  }) {
    final (primary, accent, parchment, _, _) = _colorsFor(palette);
    final bgColor = eyeComfortSepia ? const Color(0xFFF5EFE0) : parchment;
    final surfaceColor = eyeComfortSepia ? const Color(0xFFFAF6EC) : Colors.white;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: eyeComfortSepia ? const Color(0xFF281C10) : const Color(0xFF1E2822),
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accent.withValues(alpha: 0.18),
            width: 1.0,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(
          color: accent.withValues(alpha: 0.20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 62,
        elevation: 4,
        backgroundColor: surfaceColor,
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
    );
  }

  static ThemeData dark({
    AppThemePalette palette = AppThemePalette.medina,
    bool pureBlack = false,
  }) {
    final (primary, accent, _, darkBg, darkSurf) = _colorsFor(palette);
    final surfaceColor = pureBlack ? const Color(0xFF0C0C0C) : darkSurf;
    final backgroundColor = pureBlack ? Colors.black : darkBg;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFF3F4F6),
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accent.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(
          color: accent.withValues(alpha: 0.30),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 62,
        elevation: 4,
        backgroundColor: pureBlack ? const Color(0xFF050505) : darkSurf,
        indicatorColor: accent.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accent,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
    );
  }
}
