import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

/// Placeholder for the "Piñata Smash" Rive scene: tap the piñata a handful
/// of times, it shakes more with each hit, then bursts and [onWin] fires.
class PinataGame extends StatefulWidget {
  final VoidCallback onWin;

  const PinataGame({super.key, required this.onWin});

  @override
  State<PinataGame> createState() => _PinataGameState();
}

class _PinataGameState extends State<PinataGame>
    with SingleTickerProviderStateMixin {
  static const _hitsToBreak = 5;

  late final AnimationController _shakeController;
  int _hits = 0;
  bool _broken = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _hit() {
    if (_broken) return;
    _shakeController.forward(from: 0);
    setState(() => _hits++);
    if (_hits >= _hitsToBreak) {
      setState(() => _broken = true);
      widget.onWin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_hits / _hitsToBreak).clamp(0.0, 1.0);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [WommiColors.roseSoft, WommiColors.bg],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Piñata Smash',
              style: GoogleFonts.unbounded(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: WommiColors.ink,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _hit,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final dx =
                      _shakeController.status == AnimationStatus.forward ||
                              _shakeController.value > 0
                          ? (8 * (0.5 - (_shakeController.value - 0.5).abs()))
                          : 0.0;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: _broken
                    ? const Text('🎊', style: TextStyle(fontSize: 96))
                    : const Text('🪅', style: TextStyle(fontSize: 96)),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: WommiColors.line,
                  color: WommiColors.rose,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _broken
                  ? 'Charm collected!'
                  : 'Tap the piñata ($_hits/$_hitsToBreak)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WommiColors.inkDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
