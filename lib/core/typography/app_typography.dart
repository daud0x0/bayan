import 'package:flutter/material.dart';

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

  /// Arabic TextStyle builder with sufficient line-height to avoid
  /// clipping upper and lower diacritics / harakat.
  static TextStyle arabic({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    double height = 2.0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      fontFamilyFallback: arabicFontFallbacks,
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
}
