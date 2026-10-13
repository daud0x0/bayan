import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../generator/seeded_generator.dart';

/// Renders the deterministic color-only procedural background with
/// illuminated sacred geometry watermark, subtle border highlight,
/// blurred mesh gradient anchors, and tactile film grain / noise texture.
/// Implements Section 11 of the Product Plan.
class ProceduralBackground extends StatelessWidget {
  const ProceduralBackground({
    super.key,
    required this.params,
    required this.child,
    this.borderRadius = 24.0,
    this.clipBehavior = Clip.antiAlias,
  });

  final BackgroundParams params;
  final Widget child;
  final double borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: params.isPlainMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: params.isDarkMode ? 0.22 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: CustomPaint(
          painter: _ProceduralBackgroundPainter(params, borderRadius),
          child: child,
        ),
      ),
    );
  }
}

class _ProceduralBackgroundPainter extends CustomPainter {
  _ProceduralBackgroundPainter(this.params, this.borderRadius);

  final BackgroundParams params;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Draw base smooth linear gradient
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: params.gradientStart,
        end: params.gradientEnd,
        colors: params.baseGradientColors,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Draw organic diffused mesh shapes using smooth radial shaders
    for (final shape in params.shapes) {
      final center = Offset(shape.centerX * size.width, shape.centerY * size.height);
      final rx = shape.radiusX * size.width;
      final ry = shape.radiusY * size.height;
      final shapeRect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);

      // RadialGradient creates soft, GPU-rasterized diffused illumination without blur raster cost
      final shapeShader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          shape.color.withValues(alpha: shape.opacity),
          shape.color.withValues(alpha: shape.opacity * 0.45),
          shape.color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(shapeRect);

      final shapePaint = Paint()..shader = shapeShader;
      canvas.drawOval(shapeRect, shapePaint);
    }

    // 3. Draw subtle Islamic geometric watermark when not in plain reading mode
    if (params.shapes.isNotEmpty) {
      _drawGeometricLattice(canvas, size);
    }

    // 4. Draw contrast scrim overlay to guarantee text legibility in reading center
    if (params.scrimAlpha > 0.0) {
      final scrimPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            params.scrimColor.withValues(alpha: params.scrimAlpha),
            params.scrimColor.withValues(alpha: params.scrimAlpha * 0.70),
          ],
        ).createShader(rect);
      canvas.drawRect(rect, scrimPaint);
    }

    // 5. Delicate border perimeter highlight (subtle luminous stroke)
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          params.primaryTextColor.withValues(alpha: params.isDarkMode ? 0.16 : 0.10),
          params.primaryTextColor.withValues(alpha: params.isDarkMode ? 0.04 : 0.02),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawGeometricLattice(Canvas canvas, Size size) {
    final latticePaint = Paint()
      ..color = params.primaryTextColor.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..isAntiAlias = true;

    const spacing = 48.0;
    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * spacing;
        final cy = r * spacing;
        final r1 = spacing * 0.28;

        final path = Path();
        for (int i = 0; i < 8; i++) {
          final rad = (i % 2 == 0) ? r1 : r1 * 0.52;
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
        canvas.drawPath(path, latticePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralBackgroundPainter oldDelegate) {
    return oldDelegate.params.seedKey != params.seedKey ||
        oldDelegate.borderRadius != borderRadius;
  }
}
