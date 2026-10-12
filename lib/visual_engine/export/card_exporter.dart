import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../domain/models/content_item.dart';

/// Utilities for exporting shareable wallpaper cards and plain-text fallbacks.
/// Implements Section 13 of the Product Plan.
class CardExporter {
  CardExporter._();

  /// Captures PNG byte data from a widget wrapped in [RepaintBoundary].
  /// Uses 3.0 pixel ratio for high-density crisp wallpaper export.
  static Future<Uint8List?> capturePng(GlobalKey boundaryKey, {double pixelRatio = 3.0}) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Card export error: $e');
      return null;
    }
  }

  /// Formats exact plain-text representation for clipboard or message sharing.
  static String formatPlainText(ContentItem item) {
    final buffer = StringBuffer();

    if (item.arabicText.isNotEmpty) {
      buffer.writeln(item.arabicText);
      buffer.writeln();
    }

    buffer.writeln('"${item.englishTranslation}"');
    buffer.writeln();
    buffer.writeln('— ${item.reference}');

    if (item.narrator != null && item.narrator!.isNotEmpty) {
      buffer.writeln('Narrated by: ${item.narrator}');
    }

    if (item.grading != null && item.grading!.isNotEmpty) {
      buffer.writeln('Grading: ${item.grading}');
    }

    buffer.writeln('Attribution: ${item.attribution}');
    return buffer.toString().trim();
  }
}
