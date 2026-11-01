import 'dart:ui' show Offset, Rect;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kannada_plaza/screens/alpha_hit_test.dart';

void main() {
  test('alpha mask only hits sufficiently opaque in-bounds pixels', () {
    final mask = AlphaMask(
      width: 3,
      height: 2,
      alpha: Uint8List.fromList([0, 23, 24, 255, 64, 0]),
      visibleBounds: const Rect.fromLTRB(2, 0, 3, 2),
    );

    expect(mask.contains(0, 0), isFalse);
    expect(mask.contains(1, 0), isFalse);
    expect(mask.contains(2, 0), isTrue);
    expect(mask.contains(0, 1), isTrue);
    expect(mask.contains(1, 1), isTrue);
    expect(mask.contains(2, 1), isFalse);
    expect(mask.contains(-1, 0), isFalse);
    expect(mask.contains(3, 0), isFalse);
    expect(mask.contains(0, 2), isFalse);
  });

  test('alpha mask retains its visible artwork bounds', () {
    final mask = AlphaMask(
      width: 4,
      height: 3,
      alpha: Uint8List.fromList([
        0,
        0,
        0,
        0,
        0,
        0,
        40,
        0,
        0,
        0,
        0,
        0,
      ]),
      visibleBounds: const Rect.fromLTRB(2, 1, 3, 2),
    );

    expect(mask.visibleBounds.center, const Offset(2.5, 1.5));
  });
}
