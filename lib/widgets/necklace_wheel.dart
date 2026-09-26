import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// One slot on the wheel - either a real earned charm (real artwork, or an
/// emoji fallback if none was resolved) or a not-yet-earned placeholder,
/// shown as a plain empty circle until the day it stands for is completed.
class NecklaceWheelCharm {
  final String? imagePath;
  final String fallbackEmoji;
  final bool earned;

  const NecklaceWheelCharm({
    this.imagePath,
    this.fallbackEmoji = '💎',
    this.earned = true,
  });
}

/// The Achievements screen's hero visual (see the Figma design): a circle
/// far larger than the visible window, almost entirely hidden above/behind
/// it, with charms hanging around its rim like a necklace. Only a bottom
/// slice is ever visible; dragging left/right spins the whole thing around
/// its (off-screen) center, bringing hidden charms into view and pushing
/// visible ones out - a real necklace being turned, not a page of icons.
///
/// Charms are placed in [charms] order starting at the bottom center (slot
/// 0) and alternating left/right from there (index 1 left, 2 right, 3
/// further left, 4 further right, ...) - this fixed layout, not the drag,
/// is what "we start from the bottom center then alternate left and right"
/// describes; the drag only changes which part of that fixed ring currently
/// faces the viewer. Slots sit close enough together that roughly 7 are in
/// view at once (see _buildCharms), and dragging settles into the nearest
/// slot with an ease-in-out animation once released, like turning an old
/// rotary phone dial back to rest - not free-spinning like a wheel.
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

class _NecklaceWheelState extends State<NecklaceWheel>
    with SingleTickerProviderStateMixin {
  // Radians of rotation applied on top of each charm's fixed slot angle -
  // the only thing dragging (and the settle animation below) changes.
  double _rotation = 0;

  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double radius) {
    // A drag interrupts any in-flight settle, same as grabbing a real dial
    // mid-spin-back.
    if (_settleController.isAnimating) _settleController.stop();
    setState(() {
      // Dividing by radius turns a horizontal drag into an angle so a full
      // swipe across the screen feels like turning the wheel by roughly
      // that same arc-length, rather than a fixed (and so radius-dependent-
      // feeling) number of degrees per pixel.
      _rotation += details.delta.dx / radius;
    });
  }

  /// Snaps to the nearest slot on release - a rotary dial doesn't come to
  /// rest wherever a finger happened to let go, it clicks into the nearest
  /// detent.
  void _onPanEnd(DragEndDetails details, double angleStep) {
    final target = (_rotation / angleStep).round() * angleStep;
    _settleAnimation = Tween<double>(begin: _rotation, end: target).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeInOut),
    )..addListener(() => setState(() => _rotation = _settleAnimation!.value));
    _settleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = math.max(widget.charms.length, 1);
        // Spaces slots by roughly a charm's width along the arc (see
        // _buildCharms) - close enough to touch. Charms are spread evenly
        // around the *whole* circle (see angleStep below), so the radius
        // that gives them this spacing is derived from the circle's
        // circumference (count * chordSpacing) instead of picked
        // independently - a bigger radius than that would leave gaps
        // between charms as they wrap all the way around; a smaller one
        // would crowd them.
        const chordSpacing = _charmSize + 4;
        final radius = math.max(count * chordSpacing / (2 * math.pi), chordSpacing);
        // Where the bottom-center (first) charm's attachment point sits
        // within the window at rest.
        final baseY = widget.height * 0.58;
        final center = Offset(width / 2, baseY - radius);
        // Evenly spread every charm around the full circle rather than a
        // narrow arc, so rotating all the way around cycles through all of
        // them with no big empty gap where charms run out.
        final angleStep = 2 * math.pi / count;

        return ClipRect(
          child: SizedBox(
            width: width,
            height: widget.height,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) => _onPanUpdate(details, radius),
              onPanEnd: (details) => _onPanEnd(details, angleStep),
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
                  ..._buildCharms(center, radius, angleStep),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const double _charmSize = 56.0;

  List<Widget> _buildCharms(Offset center, double radius, double angleStep) {
    const beadSize = 14.0;

    return List.generate(widget.charms.length, (i) {
      // 0 -> center, then alternating: 1 left, 2 right, 3 left, 4 right...
      final magnitude = (i + 1) ~/ 2;
      final slot = i == 0
          ? 0
          : (i.isOdd ? magnitude : -magnitude);
      final angle = math.pi / 2 + slot * angleStep + _rotation;
      final pos = center +
          Offset(radius * math.cos(angle), radius * math.sin(angle));

      final charm = widget.charms[i];
      return Positioned(
        left: pos.dx - _charmSize / 2,
        top: pos.dy - beadSize / 2,
        width: _charmSize,
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
            charm.earned ? _earnedArt(charm) : const _PlaceholderCircle(),
          ],
        ),
      );
    });
  }

  Widget _earnedArt(NecklaceWheelCharm charm) {
    return charm.imagePath != null
        ? Image.asset(
            charm.imagePath!,
            width: _charmSize,
            height: _charmSize,
            fit: BoxFit.contain,
          )
        : Text(
            charm.fallbackEmoji,
            style: const TextStyle(fontSize: _charmSize * 0.7),
          );
  }
}

/// A not-yet-earned slot - a plain empty circle standing in for whichever
/// charm will eventually take its place (see NecklaceWheelCharm.earned).
class _PlaceholderCircle extends StatelessWidget {
  const _PlaceholderCircle();

  static const double _size = _NecklaceWheelState._charmSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
    );
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
