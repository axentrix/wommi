import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// One pendant on the wheel - the real charm artwork if one was resolved
/// (see CharmImageCatalog), otherwise a plain emoji fallback.
class NecklaceWheelCharm {
  final String? imagePath;
  final String fallbackEmoji;

  const NecklaceWheelCharm({this.imagePath, this.fallbackEmoji = '💎'});
}

/// The Achievements screen's hero visual (see the Figma design): a circle
/// far larger than the visible window, almost entirely hidden above/behind
/// it, with charms hanging around its rim like a necklace. Only a bottom
/// slice is ever visible; dragging left/right spins the whole thing around
/// its (off-screen) center, bringing hidden charms into view and pushing
/// visible ones out - a real necklace being turned, not a page of icons.
///
/// Charms are placed in collection order starting at the bottom center (the
/// most recently... well, first, position) and alternating left/right from
/// there (index 1 left, 2 right, 3 further left, 4 further right, ...) -
/// this fixed layout, not the drag, is what "we start from the bottom
/// center then alternate left and right" describes; the drag only changes
/// which part of that fixed ring is currently facing the viewer.
class NecklaceWheel extends StatefulWidget {
  final List<NecklaceWheelCharm> charms;
  final double height;

  const NecklaceWheel({
    super.key,
    required this.charms,
    this.height = 220,
  });

  @override
  State<NecklaceWheel> createState() => _NecklaceWheelState();
}

class _NecklaceWheelState extends State<NecklaceWheel> {
  // Radians of rotation applied on top of each charm's fixed slot angle -
  // the only thing dragging changes.
  double _rotation = 0;

  // Angle between adjacent charm slots - small enough that a full journey's
  // worth of charms (see CharmCatalog) can wrap around the ring without
  // piling up on top of each other.
  static const double _angleStep = 18 * math.pi / 180;

  void _onPanUpdate(DragUpdateDetails details, double radius) {
    setState(() {
      // Dividing by radius turns a horizontal drag into an angle so a full
      // swipe across the screen feels like turning the wheel by roughly
      // that same arc-length, rather than a fixed (and so radius-dependent-
      // feeling) number of degrees per pixel.
      _rotation += details.delta.dx / radius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Large relative to the visible window so the ring reads as mostly
        // off-screen, with only a gently-curved slice of its rim showing -
        // see the class doc.
        final radius = width * 1.7;
        // Where the bottom-center (first) charm's attachment point sits
        // within the window at rest.
        final baseY = widget.height * 0.58;
        final center = Offset(width / 2, baseY - radius);

        return ClipRect(
          child: SizedBox(
            width: width,
            height: widget.height,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) => _onPanUpdate(details, radius),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(width, widget.height),
                    painter: _NecklaceStringPainter(
                      center: center,
                      radius: radius,
                    ),
                  ),
                  ..._buildCharms(center, radius),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCharms(Offset center, double radius) {
    const beadSize = 14.0;
    const charmSize = 56.0;

    return List.generate(widget.charms.length, (i) {
      // 0 -> center, then alternating: 1 left, 2 right, 3 left, 4 right...
      final magnitude = (i + 1) ~/ 2;
      final slot = i == 0
          ? 0
          : (i.isOdd ? magnitude : -magnitude);
      final angle = math.pi / 2 + slot * _angleStep + _rotation;
      final pos = center +
          Offset(radius * math.cos(angle), radius * math.sin(angle));

      final charm = widget.charms[i];
      return Positioned(
        left: pos.dx - charmSize / 2,
        top: pos.dy - beadSize / 2,
        width: charmSize,
        child: Column(
          children: [
            Container(
              width: beadSize,
              height: beadSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [WommiColors.gold, Color(0xFFFFE8B0)],
                ),
              ),
            ),
            const SizedBox(height: 2),
            charm.imagePath != null
                ? Image.asset(
                    charm.imagePath!,
                    width: charmSize,
                    height: charmSize,
                    fit: BoxFit.contain,
                  )
                : Text(
                    charm.fallbackEmoji,
                    style: TextStyle(fontSize: charmSize * 0.7),
                  ),
          ],
        ),
      );
    });
  }
}

/// The necklace's own circular wire - a plain circle is rotationally
/// symmetric, so unlike the charms it never needs to redraw for rotation.
class _NecklaceStringPainter extends CustomPainter {
  final Offset center;
  final double radius;

  const _NecklaceStringPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _NecklaceStringPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}
