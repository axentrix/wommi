import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

/// Placeholder for the "Lucky Wheel" Rive scene: tap to spin, the wheel
/// settles on a random wedge. Unlike the other placeholder games, this one
/// is luck-based - some wedges are a genuine miss, so [onWin] only fires
/// when the wheel actually lands on a winning one. Pure Flutter
/// (CustomPaint + an AnimationController) standing in until a real Rive
/// state machine replaces it.
class LuckyWheelGame extends StatefulWidget {
  final VoidCallback onWin;

  const LuckyWheelGame({super.key, required this.onWin});

  @override
  State<LuckyWheelGame> createState() => _LuckyWheelGameState();
}

class _WheelWedge {
  final Color color;
  final bool won;
  const _WheelWedge(this.color, this.won);
}

class _LuckyWheelGameState extends State<LuckyWheelGame>
    with SingleTickerProviderStateMixin {
  // 4 winning wedges, 2 miss (grey) - about a two-in-three chance per spin,
  // spread on opposite sides of the wheel rather than bunched together.
  static const _wedges = [
    _WheelWedge(WommiColors.rose, true),
    _WheelWedge(WommiColors.inkDim, false),
    _WheelWedge(WommiColors.cyan, true),
    _WheelWedge(WommiColors.gold, true),
    _WheelWedge(WommiColors.inkDim, false),
    _WheelWedge(WommiColors.lilac, true),
  ];

  late final AnimationController _controller;
  late Animation<double> _spin;
  bool _spinning = false;
  bool _done = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _spin = AlwaysStoppedAnimation(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_spinning) return;
    final random = math.Random();
    final wedgeIndex = random.nextInt(_wedges.length);
    final won = _wedges[wedgeIndex].won;

    // Rotate so the chosen wedge's center ends up under the fixed arrow at
    // the top (angle -pi/2) - plus a few extra full turns just for show,
    // which don't change where it actually lands.
    final sweep = 2 * math.pi / _wedges.length;
    final wedgeCenter = (wedgeIndex + 0.5) * sweep;
    final baseTheta = (-math.pi / 2 - wedgeCenter) % (2 * math.pi);
    final extraSpins = (4 + random.nextInt(3)) * 2 * math.pi;
    final target = extraSpins + baseTheta;

    _spin = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    setState(() => _spinning = true);
    _controller
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _spinning = false;
          _done = true;
          _won = won;
        });
        if (won) widget.onWin();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [WommiColors.lilac, WommiColors.bg],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎡',
              style: const TextStyle(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'Lucky Wheel',
              style: GoogleFonts.unbounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: WommiColors.ink,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _spin,
                    builder: (context, child) => Transform.rotate(
                      angle: _spin.value,
                      child: child,
                    ),
                    child: CustomPaint(
                      size: const Size(240, 240),
                      painter: _WheelPainter(
                          wedges: _wedges.map((w) => w.color).toList()),
                    ),
                  ),
                  const Positioned(
                    top: -6,
                    child: Icon(Icons.arrow_drop_down,
                        size: 40, color: WommiColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _spinning || _done ? null : _startSpin,
              style: ElevatedButton.styleFrom(
                backgroundColor: WommiColors.cyan,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                _done
                    ? (_won ? 'Charm collected!' : 'No luck this time')
                    : (_spinning ? 'Spinning…' : 'Spin'),
                style: GoogleFonts.unbounded(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Color> wedges;
  _WheelPainter({required this.wedges});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweep = 2 * math.pi / wedges.length;
    for (var i = 0; i < wedges.length; i++) {
      final paint = Paint()..color = wedges[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        true,
        paint,
      );
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(center, 14, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => false;
}
