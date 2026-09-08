import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/charm_rarity.dart';

/// Shown when a day's mini-game is won - deliberately built to the same
/// size and visual language as WinStateDialog (the rituals-completion
/// popup), so collecting a charm feels the same regardless of which of
/// the two ways it was earned. [gemEmoji] is a stand-in for the real
/// per-charm artwork/name that will replace it later - everything else
/// here (size, orb, rarity theming) is already set up to take that swap
/// without further layout changes.
class GameWinDialog extends StatefulWidget {
  final String gameName;
  final int gemBalance;
  final CharmRarity rarity;
  final String gemEmoji;
  final VoidCallback onBackToMap;
  // Null when the day's rituals are already done - there's nothing left
  // to offer, so only the plain "Back to map" button shows.
  final VoidCallback? onCompleteRituals;

  const GameWinDialog({
    super.key,
    required this.gameName,
    required this.gemBalance,
    this.rarity = CharmRarity.normal,
    this.gemEmoji = '💎',
    required this.onBackToMap,
    this.onCompleteRituals,
  });

  @override
  State<GameWinDialog> createState() => _GameWinDialogState();
}

class _GameWinDialogState extends State<GameWinDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _raysController;

  @override
  void initState() {
    super.initState();
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _raysController.dispose();
    super.dispose();
  }

  List<Color> get _orbColors {
    switch (widget.rarity) {
      case CharmRarity.legendary:
        return [
          Colors.white,
          WommiColors.goldSoft,
          WommiColors.gold,
          Color(0xFFB9822E),
        ];
      case CharmRarity.rare:
        return [
          Colors.white,
          WommiColors.lilac,
          WommiColors.cyan,
          WommiColors.cyanDark,
        ];
      case CharmRarity.normal:
        return [
          Colors.white,
          WommiColors.bgSoft,
          WommiColors.line,
          Color(0xFFB7AFC9),
        ];
    }
  }

  Color get _glowColor {
    switch (widget.rarity) {
      case CharmRarity.legendary:
        return WommiColors.gold;
      case CharmRarity.rare:
        return WommiColors.cyan;
      case CharmRarity.normal:
        return WommiColors.line;
    }
  }

  String get _title {
    switch (widget.rarity) {
      case CharmRarity.legendary:
        return 'You won a\nLEGENDARY charm!';
      case CharmRarity.rare:
        return 'You won a\nrare charm!';
      case CharmRarity.normal:
        return 'You won\na new charm!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: WommiColors.deepBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.5,
                  colors: [
                    WommiColors.deepBlueSoft,
                    WommiColors.deepBlue,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.gameName.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      fontSize: 10.5,
                      letterSpacing: 2.1,
                      color: WommiColors.rose,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Charm orb - same rotating/pulsing rays + pop-in
                  // animation as WinStateDialog, colored by rarity. The
                  // emoji here is a placeholder for the real per-charm
                  // picture, coming later.
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _raysController,
                          builder: (context, child) {
                            final t = _raysController.value;
                            final pulse = 1.0 + 0.08 * math.sin(t * 2 * math.pi * 3);
                            return Transform.rotate(
                              angle: t * 2 * math.pi,
                              child: Transform.scale(
                                scale: pulse,
                                child: CustomPaint(
                                  size: const Size(200, 200),
                                  painter: _RaysPainter(color: _glowColor),
                                ),
                              ),
                            );
                          },
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: _orbColors,
                                    stops: const [0.0, 0.45, 0.78, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _glowColor.withValues(alpha: 0.4),
                                      blurRadius: 40,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 6,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.gemEmoji,
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One more charm for your collection.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.68),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildStat('Gems', '${widget.gemBalance} total'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  if (widget.onCompleteRituals != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onCompleteRituals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WommiColors.cyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 14,
                          shadowColor: WommiColors.cyan.withValues(alpha: 0.38),
                        ),
                        child: Text(
                          'Complete daily rituals',
                          style: GoogleFonts.unbounded(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onBackToMap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'Back to map',
                          style: GoogleFonts.unbounded(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onBackToMap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WommiColors.cyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 14,
                          shadowColor: WommiColors.cyan.withValues(alpha: 0.38),
                        ),
                        child: Text(
                          'Back to map',
                          style: GoogleFonts.unbounded(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.unbounded(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: WommiColors.cyan,
          ),
        ),
      ],
    );
  }
}

/// Paints a sunburst of tapered rays radiating outward from the center,
/// fading from [color] near the middle to transparent at the tips. Kept as
/// its own private copy of WinStateDialog's identical painter, rather than
/// sharing one, since that one isn't exported.
class _RaysPainter extends CustomPainter {
  static const _rayCount = 16;

  final Color color;

  _RaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;
    final innerRadius = maxRadius * 0.3;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        center,
        maxRadius,
        [color.withValues(alpha: 0.55), color.withValues(alpha: 0.0)],
      );

    for (int i = 0; i < _rayCount; i++) {
      final angle = (i / _rayCount) * 2 * math.pi;
      final rayRadius = maxRadius * (i.isEven ? 1.0 : 0.78);
      final halfWidth = (math.pi / _rayCount) * 0.32;

      final p1 = center +
          Offset(math.cos(angle - halfWidth), math.sin(angle - halfWidth)) *
              innerRadius;
      final p2 = center +
          Offset(math.cos(angle + halfWidth), math.sin(angle + halfWidth)) *
              innerRadius;
      final tip = center + Offset(math.cos(angle), math.sin(angle)) * rayRadius;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) =>
      oldDelegate.color != color;
}
