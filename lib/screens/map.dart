import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'alpha_hit_test.dart';
import 'city_location.dart';

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({
    super.key,
    required this.onSelectLocation,
    required this.onUserInteraction,
  });

  final Future<void> Function(CityLocation location) onSelectLocation;
  final VoidCallback onUserInteraction;

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

Future<void> preloadCityMapAssets(BuildContext context) async {
  await Future.wait([
    ...cityLocations.map(
      (location) => precacheImage(AssetImage(location.mapAsset), context),
    ),
    _CityMapScreenState.loadMasks(),
  ]);
}

class _CityMapScreenState extends State<CityMapScreen> {
  static const int _minimumAlpha = 24;

  final Map<String, AlphaMask?> _masks = {};
  CityLocation? _hoveredLocation;
  Offset? _lastPointer;
  Offset? _pendingTap;
  Size? _lastViewport;
  bool _masksLoaded = false;
  static Future<List<AlphaMask?>>? _maskCache;

  static Future<List<AlphaMask?>> loadMasks() {
    return _maskCache ??= Future.wait(
      cityLocations.map((location) => AlphaMask.load(location.mapAsset)),
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadMasks());
  }

  Future<void> _loadMasks() async {
    final loaded = await loadMasks();
    if (!mounted) return;
    setState(() {
      for (var index = 0; index < cityLocations.length; index++) {
        _masks[cityLocations[index].mapAsset] = loaded[index];
      }
      _masksLoaded = true;
      final pointer = _lastPointer;
      final viewport = _lastViewport;
      if (pointer != null && viewport != null) {
        _hoveredLocation = _hitTest(pointer, viewport);
      }
    });
    final pendingTap = _pendingTap;
    final viewport = _lastViewport;
    _pendingTap = null;
    if (pendingTap != null && viewport != null) {
      final location = _hitTest(pendingTap, viewport);
      if (location != null) unawaited(widget.onSelectLocation(location));
    }
  }

  Offset? _toArtworkPoint(Offset pointer, Size viewport) {
    final scale = math.max(
      viewport.width / cityCanvasWidth,
      viewport.height / cityCanvasHeight,
    );
    if (!scale.isFinite || scale <= 0) return null;
    final renderedWidth = cityCanvasWidth * scale;
    final renderedHeight = cityCanvasHeight * scale;
    return Offset(
      (pointer.dx - (viewport.width - renderedWidth) / 2) / scale,
      (pointer.dy - (viewport.height - renderedHeight) / 2) / scale,
    );
  }

  CityLocation? _hitTest(Offset pointer, Size viewport) {
    final artworkPoint = _toArtworkPoint(pointer, viewport);
    if (artworkPoint == null) return null;
    // Later entries are above earlier entries in the stack.
    for (final location in cityLocations.reversed) {
      final mask = _masks[location.mapAsset];
      if (mask != null &&
          mask.contains(
            artworkPoint.dx,
            artworkPoint.dy,
            minimumAlpha: _minimumAlpha,
          )) {
        return location;
      }
    }
    return null;
  }

  void _updateHover(Offset pointer, Size viewport) {
    _lastPointer = pointer;
    _lastViewport = viewport;
    final hit = _hitTest(pointer, viewport);
    if (!_masksLoaded) return;
    if (hit == _hoveredLocation) return;
    setState(() => _hoveredLocation = hit);
  }

  void _handlePointerDown(PointerDownEvent event, Size viewport) {
    if (event.kind == PointerDeviceKind.mouse &&
        (event.buttons & kPrimaryButton) == 0) {
      return;
    }
    widget.onUserInteraction();
    _lastPointer = event.localPosition;
    _lastViewport = viewport;
    if (!_masksLoaded) {
      _pendingTap = event.localPosition;
      return;
    }
    final hit = _hitTest(event.localPosition, viewport);
    if (hit != null) unawaited(widget.onSelectLocation(hit));
  }

  Alignment _artworkCenter(CityLocation location) {
    final mask = _masks[location.mapAsset];
    if (mask == null || mask.visibleBounds.isEmpty) {
      return Alignment.center;
    }
    final bounds = mask.visibleBounds;
    return Alignment(
      2 * bounds.center.dx / mask.width - 1,
      2 * bounds.center.dy / mask.height - 1,
    );
  }

  Widget _artwork() {
    return SizedBox(
      width: cityCanvasWidth,
      height: cityCanvasHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final location in cityLocations)
            AnimatedScale(
              scale: _hoveredLocation == location ? 1.02 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: _artworkCenter(location),
              child: Image.asset(
                location.mapAsset,
                width: cityCanvasWidth,
                height: cityCanvasHeight,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _handlePointerDown(event, viewport),
                  child: MouseRegion(
                    cursor: _hoveredLocation == null
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    onHover: (event) =>
                        _updateHover(event.localPosition, viewport),
                    onExit: (_) {
                      _lastPointer = null;
                      _lastViewport = null;
                      if (_hoveredLocation != null) {
                        setState(() => _hoveredLocation = null);
                      }
                    },
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      clipBehavior: Clip.hardEdge,
                      child: _artwork(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
