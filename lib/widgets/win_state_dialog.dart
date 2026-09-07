import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/charm_rarity.dart';

class WinStateDialog extends StatefulWidget {
  final int currentDay;
  final int gemBalance;
  final int streakDays;
  final bool tracksMenstrualCycle;
  final CharmRarity rarity;
  final VoidCallback onContinue;

  const WinStateDialog({
    super.key,
    required this.currentDay,
    required this.gemBalance,
    required this.streakDays,
    required this.tracksMenstrualCycle,
    this.rarity = CharmRarity.normal,
    required this.onContinue,
  });

  @override
  State<WinStateDialog> createState() => _WinStateDialogState();
}

class _WinStateDialogState extends State<WinStateDialog>
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
        return 'You earned a\nLEGENDARY charm!';
      case CharmRarity.rare:
        return 'You earned a\nrare charm!';
      case CharmRarity.normal:
        return 'You earned\na new gem!';
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
            // Content area with gradient background
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
                  // Eyebrow
                  Text(
                    'DAY ${widget.currentDay} COMPLETE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10.5,
                      letterSpacing: 2.1,
                      color: WommiColors.rose,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Charm orb - rotating/pulsing sunburst rays behind it,
                  // colored by rarity, plus the orb's own pop-in animation.
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
                                    '💎',
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
                  // Title
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
                  // Flavor text
                  Text(
                    'Every small ritual adds up.\nYour consistency creates magic.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.68),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Bangle with gems
                  _buildBangle(),
                  const SizedBox(height: 22),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Streak', '${widget.streakDays} days'),
                      const SizedBox(width: 22),
                      _buildStat('Gems', '${widget.gemBalance} total'),
                      const SizedBox(width: 22),
                      _buildStat(
                        widget.tracksMenstrualCycle ? 'Cycle' : 'Journey',
                        'day ${widget.currentDay}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onContinue,
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
                        'Continue',
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

  Widget _buildBangle() {
    final filledGems = widget.gemBalance > 6 ? 6 : widget.gemBalance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: WommiColors.line,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: WommiColors.ink.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (index) {
          final isFilled = index < filledGems;
          final isNew = index == filledGems - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            // Only the just-earned slot reflects this charm's actual
            // rarity - earlier slots in the bangle don't have their own
            // rarity history threaded through here, so they stay gold.
            child: _buildGemSlot(isFilled, isNew, isNew ? widget.rarity : CharmRarity.legendary),
          );
        }),
      ),
    );
  }

  Widget _buildGemSlot(bool isFilled, bool isNew, CharmRarity slotRarity) {
    final gradientColors = switch (slotRarity) {
      CharmRarity.legendary => [WommiColors.goldSoft, WommiColors.gold],
      CharmRarity.rare => [WommiColors.lilac, WommiColors.cyan],
      CharmRarity.normal => [Colors.white, WommiColors.line],
    };
    final borderColor = switch (slotRarity) {
      CharmRarity.legendary => WommiColors.gold,
      CharmRarity.rare => WommiColors.cyan,
      CharmRarity.normal => WommiColors.inkDim,
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: isNew ? 0.0 : 1.0, end: 1.0),
      duration: Duration(milliseconds: isNew ? 600 : 0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isFilled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: isFilled ? null : WommiColors.bgSoft,
              border: Border.all(
                color: isFilled ? borderColor : Color(0xFFD8D2E8),
                width: 1.5,
                style: isFilled ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: isNew
                  ? [
                      BoxShadow(
                        color: WommiColors.cyan.withValues(alpha: 0.5),
                        blurRadius: 14,
                        spreadRadius: 2.5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isFilled ? '💎' : '·',
                style: TextStyle(
                  fontSize: isFilled ? 14 : 16,
                  color: isFilled ? Colors.white : WommiColors.inkDim,
                ),
              ),
            ),
          ),
        );
      },
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
/// fading from [color] near the middle to transparent at the tips. The
/// containing widget rotates and pulses this over time for the festive
/// glow effect behind the win-dialog orb.
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
      // Alternate slightly longer/shorter rays for a less mechanical look.
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
