import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../generator/seeded_generator.dart';

/// Renders the deterministic color-only procedural background with
/// illuminated sacred geometry watermark and subtle border highlight.
/// Implements Section 11 of the Product Plan.
class ProceduralBackground extends StatelessWidget {
  const ProceduralBackground({
    super.key,
    required this.params,
    required this.child,
    this.borderRadius = 22.0,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
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

    // 2. Draw organic diffused shapes (if any)
    for (final shape in params.shapes) {
      final center = Offset(shape.centerX * size.width, shape.centerY * size.height);
      final rx = shape.radiusX * size.width;
      final ry = shape.radiusY * size.height;
      final shapeRect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);

      final shapePaint = Paint()
        ..color = shape.color.withValues(alpha: shape.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shape.blurSigma);

      canvas.drawOval(shapeRect, shapePaint);
    }

    // 3. Draw subtle Islamic geometric watermark when not in plain reading mode
    if (params.shapes.isNotEmpty) {
      _drawGeometricLattice(canvas, size);
    }

    // 4. Draw contrast scrim overlay to protect text legibility
    if (params.scrimAlpha > 0.0) {
      final scrimPaint = Paint()
        ..color = params.scrimColor.withValues(alpha: params.scrimAlpha);
      canvas.drawRect(rect, scrimPaint);
    }

    // 5. Delicate border highlight (subtle gold/light perimeter stroke)
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          params.primaryTextColor.withValues(alpha: 0.28),
          params.primaryTextColor.withValues(alpha: 0.08),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawGeometricLattice(Canvas canvas, Size size) {
    final latticePaint = Paint()
      ..color = params.primaryTextColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
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
