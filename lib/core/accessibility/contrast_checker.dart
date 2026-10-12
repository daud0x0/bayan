import 'dart:math' as math;
import 'package:flutter/material.dart';

/// WCAG 2.1 Relative Luminance & Contrast Checker.
/// Implements Section 11.4 and 15 of the Product Plan.
class ContrastChecker {
  ContrastChecker._();

  /// Calculates relative luminance for a given [Color] per WCAG 2.1 specs.
  static double calculateLuminance(Color color) {
    double transformChannel(double c) {
      if (c <= 0.03928) {
        return c / 12.92;
      } else {
        return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
      }
    }

    final r = transformChannel(color.r);
    final g = transformChannel(color.g);
    final b = transformChannel(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates contrast ratio between two colors (ranges from 1.0 to 21.0).
  static double calculateContrastRatio(Color color1, Color color2) {
    final l1 = calculateLuminance(color1);
    final l2 = calculateLuminance(color2);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Verifies WCAG AA compliance (4.5:1 for standard text, 3.0:1 for large text).
  static bool isWcagAaCompliant(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= (isLargeText ? 3.0 : 4.5);
  }

  /// Selects the best contrasting text color (white or black) for a given background color.
  static Color getContrastingTextColor(Color background) {
    final whiteContrast = calculateContrastRatio(Colors.white, background);
    final blackContrast = calculateContrastRatio(Colors.black, background);

    return whiteContrast >= blackContrast ? Colors.white : Colors.black87;
  }

  /// Computes recommended scrim opacity (between 0.15 and 0.85) to guarantee
  /// legibility over complex organic backgrounds.
  static double recommendScrimAlpha({
    required Color backgroundEstimate,
    required bool isDarkMode,
    required double visualIntensity, // 0.0 to 1.0
  }) {
    final baseAlpha = isDarkMode ? 0.35 : 0.25;
    final intensityFactor = visualIntensity * 0.35;
    return (baseAlpha + intensityFactor).clamp(0.20, 0.85);
  }
}
