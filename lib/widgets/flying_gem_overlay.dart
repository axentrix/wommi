import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animates [gem] flying from [startGlobal] to [endGlobal] - e.g. from the
/// earned-charm orb in WinStateDialog to the gem count in AppHeaderBar (see
/// gemIconKeyProvider) - as a self-removing OverlayEntry rather than a
/// widget the caller has to keep around, since by the time it's mid-flight
/// whatever spawned it (a popup) is usually already gone. Inserted into the
/// *root* overlay, so it flies on top of everything, dialog included, and
/// keeps going even after that dialog closes.
void showFlyingGem({
  required BuildContext context,
  required Offset startGlobal,
  required Offset endGlobal,
  required Widget gem,
  double startSize = 64,
  double endSize = 22,
  Duration duration = const Duration(milliseconds: 650),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _FlyingGem(
      start: startGlobal,
      end: endGlobal,
      startSize: startSize,
      endSize: endSize,
      duration: duration,
      gem: gem,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _FlyingGem extends StatefulWidget {
  final Offset start;
  final Offset end;
  final double startSize;
  final double endSize;
  final Duration duration;
  final Widget gem;
  final VoidCallback onDone;

  const _FlyingGem({
    required this.start,
    required this.end,
    required this.startSize,
    required this.endSize,
    required this.duration,
    required this.gem,
    required this.onDone,
  });

  @override
  State<_FlyingGem> createState() => _FlyingGemState();
}

class _FlyingGemState extends State<_FlyingGem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInCubic.transform(_controller.value);
          final pos = Offset.lerp(widget.start, widget.end, t)!;
          // A little upward toss instead of a flat slide, peaking mid-flight
          // and settling back to the straight line by the time it arrives.
          final arc = -70 * math.sin(t * math.pi);
          final size = widget.startSize + (widget.endSize - widget.startSize) * t;
          // Holds full opacity for most of the flight, then fades right at
          // the very end as it "lands" into the counter.
          final opacity = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0);

          return Positioned(
            left: pos.dx - size / 2,
            top: pos.dy + arc - size / 2,
            width: size,
            height: size,
            child: Opacity(opacity: opacity, child: widget.gem),
          );
        },
      ),
    );
  }
}
