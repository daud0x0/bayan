import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/core/accessibility/contrast_checker.dart';

void main() {
  group('ContrastChecker', () {
    test('calculates correct relative luminance for black and white', () {
      final lumWhite = ContrastChecker.calculateLuminance(Colors.white);
      final lumBlack = ContrastChecker.calculateLuminance(Colors.black);

      expect(lumWhite, closeTo(1.0, 0.01));
      expect(lumBlack, closeTo(0.0, 0.01));
    });

    test('calculates standard 21:1 contrast ratio between pure black and white', () {
      final ratio = ContrastChecker.calculateContrastRatio(Colors.black, Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('correctly validates WCAG AA compliance (4.5:1 minimum)', () {
      // Black on White complies
      expect(ContrastChecker.isWcagAaCompliant(Colors.black, Colors.white), isTrue);

      // Light gray on White does NOT comply
      expect(ContrastChecker.isWcagAaCompliant(const Color(0xFFE0E0E0), Colors.white), isFalse);
    });

    test('recommends contrasting text color', () {
      expect(ContrastChecker.getContrastingTextColor(Colors.white), Colors.black87);
      expect(ContrastChecker.getContrastingTextColor(Colors.black), Colors.white);
    });

    test('computes bounded safe scrim alpha', () {
      final scrimAlpha = ContrastChecker.recommendScrimAlpha(
        backgroundEstimate: const Color(0xFF107C41),
        isDarkMode: true,
        visualIntensity: 0.6,
      );

      expect(scrimAlpha, greaterThanOrEqualTo(0.20));
      expect(scrimAlpha, lessThanOrEqualTo(0.85));
    });
  });
}
