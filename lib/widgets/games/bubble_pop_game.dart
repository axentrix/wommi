import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

/// Placeholder for the "Bubble Pop" Rive scene: pop every scattered bubble
/// to fire [onWin]. Positions are randomized once per game (not per
/// rebuild), so bubbles don't jump around as they're popped.
class BubblePopGame extends StatefulWidget {
  final VoidCallback onWin;

  const BubblePopGame({super.key, required this.onWin});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  static const _bubbleCount = 12;
  static const _colors = [
    WommiColors.cyan,
    WommiColors.rose,
    WommiColors.lilac,
    WommiColors.gold,
    WommiColors.sage,
  ];

  late final List<_BubbleSpec> _bubbles;
  final Set<int> _popped = {};
  bool _won = false;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _bubbles = List.generate(_bubbleCount, (i) {
      return _BubbleSpec(
        left: 0.08 + random.nextDouble() * 0.8,
        top: 0.12 + random.nextDouble() * 0.62,
        size: 44 + random.nextDouble() * 30,
        color: _colors[i % _colors.length],
      );
    });
  }

  void _pop(int index) {
    if (_popped.contains(index) || _won) return;
    setState(() => _popped.add(index));
    if (_popped.length == _bubbles.length) {
      setState(() => _won = true);
      widget.onWin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [WommiColors.cyan, WommiColors.bg],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Bubble Pop',
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _won
                        ? 'Charm collected!'
                        : 'Pop them all (${_popped.length}/${_bubbles.length})',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < _bubbles.length; i++)
              if (!_popped.contains(i))
                Positioned(
                  left: _bubbles[i].left * MediaQuery.of(context).size.width -
                      _bubbles[i].size / 2,
                  top: _bubbles[i].top * MediaQuery.of(context).size.height -
                      _bubbles[i].size / 2,
                  child: GestureDetector(
                    onTap: () => _pop(i),
                    child: AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: _bubbles[i].size,
                        height: _bubbles[i].size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bubbles[i].color.withOpacity(0.55),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BubbleSpec {
  final double left;
  final double top;
  final double size;
  final Color color;

  _BubbleSpec({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
  });
}
