import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/accessibility/contrast_checker.dart';
import '../../domain/models/user_preferences.dart';
import '../palette/palette_registry.dart';

/// Parameters for a single organic procedural shape layer.
class OrganicShapeParam {
  const OrganicShapeParam({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    required this.color,
    required this.opacity,
    required this.blurSigma,
  });

  final double centerX; // Normalized 0.0 - 1.0
  final double centerY; // Normalized 0.0 - 1.0
  final double radiusX; // Normalized 0.0 - 1.0
  final double radiusY; // Normalized 0.0 - 1.0
  final Color color;
  final double opacity;
  final double blurSigma;
}

/// Compact cached background parameters derived deterministically by seed.
class BackgroundParams {
  const BackgroundParams({
    required this.seedKey,
    required this.preset,
    required this.isDarkMode,
    required this.baseGradientColors,
    required this.gradientStart,
    required this.gradientEnd,
    required this.shapes,
    required this.scrimColor,
    required this.scrimAlpha,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  final String seedKey;
  final VisualPreset preset;
  final bool isDarkMode;
  final List<Color> baseGradientColors;
  final Alignment gradientStart;
  final Alignment gradientEnd;
  final List<OrganicShapeParam> shapes;
  final Color scrimColor;
  final double scrimAlpha;
  final Color primaryTextColor;
  final Color secondaryTextColor;
}

/// Deterministic, seeded mathematical visual generator complying with Section 11 of the Product Plan.
class SeededVisualGenerator {
  SeededVisualGenerator._();

  static const int generatorVersion = 1;
  static final Map<String, BackgroundParams> _cache = {};

  /// Generates or retrieves cached background parameters for a given content item.
  static BackgroundParams generate({
    required String contentId,
    required VisualPreset preset,
    required bool isDarkMode,
    required VisualIntensity intensity,
    bool isPlainMode = false,
  }) {
    final cacheKey = '${contentId}_${preset.name}_${isDarkMode}_${intensity.name}_${isPlainMode}_v$generatorVersion';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final palette = PaletteRegistry.getPalette(preset);
    final seed = _deriveSeed(contentId, preset);
    final random = math.Random(seed);

    if (isPlainMode) {
      // Clean, distraction-free solid background with guaranteed maximum contrast
      final bgColor = isDarkMode ? palette.backgroundDark : palette.backgroundLight;
      final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
      final textSecondary = isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF555555);

      final params = BackgroundParams(
        seedKey: cacheKey,
        preset: preset,
        isDarkMode: isDarkMode,
        baseGradientColors: [bgColor, bgColor],
        gradientStart: Alignment.topCenter,
        gradientEnd: Alignment.bottomCenter,
        shapes: const [],
        scrimColor: bgColor,
        scrimAlpha: 0.0,
        primaryTextColor: textPrimary,
        secondaryTextColor: textSecondary,
      );
      _cache[cacheKey] = params;
      return params;
    }

    // 1. Select base gradient colors
    final rawColors = isDarkMode ? palette.getDarkGradient() : palette.getLightGradient();
    final baseGradientColors = [
      rawColors[0],
      rawColors[1],
      rawColors[2],
    ];

    // 2. Compute gentle gradient alignments based on seed
    final angle = random.nextDouble() * 2 * math.pi;
    final gradientStart = Alignment(math.cos(angle), math.sin(angle));
    final gradientEnd = Alignment(-math.cos(angle), -math.sin(angle));

    // 3. Generate 2 to 3 organic diffused shapes positioned away from center text
    final shapeCount = 2 + random.nextInt(2);
    final shapes = <OrganicShapeParam>[];

    for (var i = 0; i < shapeCount; i++) {
      // Keep organic shapes anchored around borders/corners to preserve central legibility
      final isTop = random.nextBool();
      final isLeft = random.nextBool();
      final cx = isLeft ? (0.05 + random.nextDouble() * 0.25) : (0.70 + random.nextDouble() * 0.25);
      final cy = isTop ? (0.05 + random.nextDouble() * 0.25) : (0.70 + random.nextDouble() * 0.25);

      final rx = (0.25 + random.nextDouble() * 0.40);
      final ry = (0.25 + random.nextDouble() * 0.40);

      final colorPick = rawColors[(i + 1) % rawColors.length];
      final opacity = (0.18 + random.nextDouble() * 0.22) * intensity.value;
      final blurSigma = 30.0 + random.nextDouble() * 25.0;

      shapes.add(
        OrganicShapeParam(
          centerX: cx,
          centerY: cy,
          radiusX: rx,
          radiusY: ry,
          color: colorPick,
          opacity: opacity,
          blurSigma: blurSigma,
        ),
      );
    }

    // 4. Compute contrast scrim to guarantee WCAG compliance
    final scrimColor = isDarkMode ? const Color(0xFF0A0E14) : const Color(0xFFFAFCFE);
    final scrimAlpha = ContrastChecker.recommendScrimAlpha(
      backgroundEstimate: baseGradientColors.first,
      isDarkMode: isDarkMode,
      visualIntensity: intensity.value,
    );

    // 5. Select contrast-verified text colors
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF14191E);
    final textSecondary = isDarkMode
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    final params = BackgroundParams(
      seedKey: cacheKey,
      preset: preset,
      isDarkMode: isDarkMode,
      baseGradientColors: baseGradientColors,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      shapes: shapes,
      scrimColor: scrimColor,
      scrimAlpha: scrimAlpha,
      primaryTextColor: textPrimary,
      secondaryTextColor: textSecondary,
    );

    _cache[cacheKey] = params;
    return params;
  }

  /// Derives stable 32-bit positive integer seed from content ID and preset.
  static int _deriveSeed(String contentId, VisualPreset preset) {
    var hash = 0x811c9dc5;
    final str = '$contentId:${preset.name}:v$generatorVersion';
    for (var i = 0; i < str.length; i++) {
      hash ^= str.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Clears in-memory parameter cache (e.g., upon settings reset).
  static void clearCache() {
    _cache.clear();
  }
}
