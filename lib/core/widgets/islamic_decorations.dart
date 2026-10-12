import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Islamic geometric decorations and traditional Mushaf ornaments.
class IslamicDecorations {
  IslamicDecorations._();

  /// Warm gold accent color characteristic of illuminated manuscripts.
  static const Color gold = Color(0xFFC5A059);
  static const Color brightGold = Color(0xFFE5C07B);
  static const Color deepGold = Color(0xFF9A7B38);
  static const Color emerald = Color(0xFF107C41);
}

/// Eight-pointed Islamic star badge (Rub el Hizb ۞) commonly used in
/// the Medina Mushaf for Surah and Ayah numbering.
class RubElHizbBadge extends StatelessWidget {
  const RubElHizbBadge({
    super.key,
    required this.number,
    this.size = 38.0,
    this.accentColor,
    this.textColor,
  });

  final int number;
  final double size;
  final Color? accentColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? IslamicDecorations.gold;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveText = textColor ??
        (isDark ? Colors.white : Theme.of(context).colorScheme.onSurface);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RubElHizbPainter(
              color: effectiveAccent,
              fillColor: isDark
                  ? effectiveAccent.withValues(alpha: 0.12)
                  : effectiveAccent.withValues(alpha: 0.08),
            ),
          ),
          Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.bold,
                color: effectiveText,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  const _RubElHizbPainter({required this.color, required this.fillColor});

  final Color color;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.90;

    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Build the 8-pointed star using two overlapping squares rotated 45 degrees
    Path buildSquarePath(double rotation) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = rotation + (i * math.pi / 2);
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    final square1 = buildSquarePath(math.pi / 4);
    final square2 = buildSquarePath(0.0);

    // Combine both squares into a single 8-pointed star outline
    final combined = Path.combine(PathOperation.union, square1, square2);
    canvas.drawPath(combined, paintFill);
    canvas.drawPath(combined, paintStroke);

    // Subtle inner circular accent ring
    final innerCirclePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.58, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _RubElHizbPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.fillColor != fillColor;
  }
}

/// Symmetrical Islamic ornamental divider with diamond/crest motif.
class IslamicOrnamentalDivider extends StatelessWidget {
  const IslamicOrnamentalDivider({
    super.key,
    this.color,
    this.height = 24.0,
  });

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IslamicDecorations.gold.withValues(alpha: 0.6);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveColor.withValues(alpha: 0.0),
                    effectiveColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: 6),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      border: Border.all(color: effectiveColor, width: 1.2),
                      color: effectiveColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveColor,
                    effectiveColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ornate traditional Mushaf Bismillah Banner.
class BismillahBanner extends StatelessWidget {
  const BismillahBanner({
    super.key,
    this.fontSize = 22.0,
    this.color,
  });

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ??
        (isDark ? const Color(0xFFF0E6D2) : const Color(0xFF2C2416));

    return Column(
      children: [
        const IslamicOrnamentalDivider(height: 18),
        const SizedBox(height: 8),
        Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.8,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamilyFallback: const [
              'Amiri',
              'Scheherazade New',
              'Noto Naskh Arabic',
              'Arabic Typesetting',
            ],
          ),
        ),
        const SizedBox(height: 8),
        const IslamicOrnamentalDivider(height: 18),
      ],
    );
  }
}

/// Custom painter for drawing a subtle Islamic geometric star lattice watermark.
class IslamicGeometricLatticePainter extends CustomPainter {
  const IslamicGeometricLatticePainter({
    required this.color,
    this.spacing = 40.0,
  });

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..isAntiAlias = true;

    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * spacing;
        final cy = r * spacing;

        // Draw miniature interlocking octagrams
        final r1 = spacing * 0.28;
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final rad = (i % 2 == 0) ? r1 : r1 * 0.55;
          final angle = (i * math.pi / 4);
          final x = cx + rad * math.cos(angle);
          final y = cy + rad * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicGeometricLatticePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}
