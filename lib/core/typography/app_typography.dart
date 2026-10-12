import 'package:flutter/material.dart';
import '../../domain/models/user_preferences.dart';

/// App typography definitions ensuring comfortable Arabic rendering
/// and balanced bilingual layout. Implements Section 12 of the Product Plan.
class AppTypography {
  AppTypography._();

  /// Default font families for Arabic text rendering with graceful fallbacks.
  static const List<String> arabicFontFallbacks = [
    'Amiri',
    'Scheherazade New',
    'Noto Naskh Arabic',
    'Arabic Typesetting',
    'Traditional Arabic',
    'Geeza Pro',
  ];

  /// Specialized font fallbacks tailored to the chosen calligraphy style.
  static List<String> fontFallbacksFor(ArabicScriptStyle style) {
    switch (style) {
      case ArabicScriptStyle.uthmani:
        return const [
          'Amiri',
          'Scheherazade New',
          'Noto Naskh Arabic',
          'KFGQPC Uthman Taha Naskh',
          'Traditional Arabic',
          'Geeza Pro',
        ];
      case ArabicScriptStyle.indopak:
        return const [
          'Urdu Typesetting',
          'Noto Nastaliq Urdu',
          'Jameel Noori Nastaleeq',
          'Scheherazade New',
          'Amiri',
        ];
      case ArabicScriptStyle.naskh:
        return const [
          'Noto Naskh Arabic',
          'Arial',
          'Geeza Pro',
          'Scheherazade New',
          'Amiri',
        ];
    }
  }

  /// Arabic TextStyle builder with sufficient line-height to avoid
  /// clipping upper and lower diacritics / harakat.
  static TextStyle arabic({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    double height = 2.0,
    ArabicScriptStyle scriptStyle = ArabicScriptStyle.uthmani,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      fontFamilyFallback: fontFallbacksFor(scriptStyle),
    );
  }

  /// English translation style with high legibility.
  static TextStyle translation({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.6,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: 0.15,
    );
  }

  /// Reference / metadata style for exact citations.
  static TextStyle reference({
    Color? color,
    double fontSize = 12.5,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.3,
    );
  }

  /// Badge / tag style for content type (Quran / Hadith) and categories.
  static TextStyle badge({
    Color? color,
    double fontSize = 11.0,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Transliteration style for phonetic pronunciation guides.
  static TextStyle transliteration({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.4,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.italic,
      height: height,
      color: color,
      letterSpacing: 0.2,
    );
  }
}
