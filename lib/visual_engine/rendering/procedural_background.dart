import 'package:flutter/material.dart';
import '../generator/seeded_generator.dart';

/// Renders the deterministic color-only procedural background.
/// Implements Section 11 of the Product Plan.
class ProceduralBackground extends StatelessWidget {
  const ProceduralBackground({
    super.key,
    required this.params,
    required this.child,
    this.borderRadius = 20.0,
    this.clipBehavior = Clip.antiAlias,
  });

  final BackgroundParams params;
  final Widget child;
  final double borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: CustomPaint(
        painter: _ProceduralBackgroundPainter(params),
        child: child,
      ),
    );
  }
}

class _ProceduralBackgroundPainter extends CustomPainter {
  _ProceduralBackgroundPainter(this.params);

  final BackgroundParams params;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

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

    // 3. Draw contrast scrim overlay to protect text legibility
    if (params.scrimAlpha > 0.0) {
      final scrimPaint = Paint()
        ..color = params.scrimColor.withValues(alpha: params.scrimAlpha);
      canvas.drawRect(rect, scrimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralBackgroundPainter oldDelegate) {
    return oldDelegate.params.seedKey != params.seedKey;
  }
}
