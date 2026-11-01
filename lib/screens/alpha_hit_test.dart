import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AlphaMask {
  static final Map<String, Future<AlphaMask?>> _cache = {};

  const AlphaMask({
    required this.width,
    required this.height,
    required this.alpha,
    required this.visibleBounds,
  });

  final int width;
  final int height;
  final Uint8List alpha;
  final ui.Rect visibleBounds;

  bool contains(double x, double y, {int minimumAlpha = 24}) {
    final pixelX = x.floor();
    final pixelY = y.floor();
    if (pixelX < 0 || pixelY < 0 || pixelX >= width || pixelY >= height) {
      return false;
    }
    return alpha[pixelY * width + pixelX] >= minimumAlpha;
  }

  static Future<AlphaMask?> load(String assetPath) {
    return _cache.putIfAbsent(assetPath, () => _decode(assetPath));
  }

  static Future<AlphaMask?> _decode(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      try {
        final frame = await codec.getNextFrame();
        final image = frame.image;
        try {
          final rgba = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (rgba == null) {
            throw StateError('Could not decode pixel data for $assetPath');
          }
          final bytes = rgba.buffer.asUint8List(
            rgba.offsetInBytes,
            rgba.lengthInBytes,
          );
          final alpha = Uint8List(image.width * image.height);
          var left = image.width;
          var top = image.height;
          var right = -1;
          var bottom = -1;
          for (var pixel = 0; pixel < alpha.length; pixel++) {
            final opacity = bytes[pixel * 4 + 3];
            alpha[pixel] = opacity;
            if (opacity >= 24) {
              final x = pixel % image.width;
              final y = pixel ~/ image.width;
              if (x < left) left = x;
              if (x > right) right = x;
              if (y < top) top = y;
              if (y > bottom) bottom = y;
            }
          }
          return AlphaMask(
            width: image.width,
            height: image.height,
            alpha: alpha,
            visibleBounds: right < 0
                ? ui.Rect.zero
                : ui.Rect.fromLTRB(
                    left.toDouble(),
                    top.toDouble(),
                    (right + 1).toDouble(),
                    (bottom + 1).toDouble(),
                  ),
          );
        } finally {
          image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } on FlutterError catch (error, stackTrace) {
      debugPrint('Unable to load alpha mask "$assetPath": $error\n$stackTrace');
      return null;
    } on Object catch (error, stackTrace) {
      debugPrint(
          'Unable to decode alpha mask "$assetPath": $error\n$stackTrace');
      return null;
    }
  }
}
