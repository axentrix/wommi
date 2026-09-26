import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/database.dart';
import '../models/charm_rarity.dart';
import '../models/charm_image_catalog.dart';
import 'flying_gem_overlay.dart';

class WinStateDialog extends StatefulWidget {
  final int currentDay;
  final int gemBalance;
  final int streakDays;
  final bool tracksMenstrualCycle;
  final CharmRarity rarity;
  // This journey's ritual charms earned so far, current one included -
  // ascending by day. Used to fill the bangle below with the real recent
  // charms instead of a generic pattern; the last entry is the one this
  // popup is celebrating.
  final List<CharmsEarnedData> recentCharms;
  // Where AppHeaderBar's gem count icon currently sits (see
  // gemIconKeyProvider) - lets Continue animate the earned gem flying there.
  // Null (or not yet laid out, e.g. a hidden route underneath) just skips
  // that animation rather than failing.
  final GlobalKey? gemIconKey;
  final VoidCallback onContinue;

  const WinStateDialog({
    super.key,
    required this.currentDay,
    required this.gemBalance,
    required this.streakDays,
    required this.tracksMenstrualCycle,
    this.rarity = CharmRarity.normal,
    this.recentCharms = const [],
    this.gemIconKey,
    required this.onContinue,
  });

  @override
  State<WinStateDialog> createState() => _WinStateDialogState();
}

class _WinStateDialogState extends State<WinStateDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _raysController;
  final _orbKey = GlobalKey();

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

  String? get _earnedImagePath =>
      CharmImageCatalog.journeyCharmImage(widget.rarity, widget.currentDay);

  /// Flies a copy of the earned charm from the orb to the header's gem icon
  /// before handing off to [WinStateDialog.onContinue] - purely a visual
  /// overlay effect (see showFlyingGem), so it never blocks or delays
  /// Continue's own behavior (closing the dialog, prompting the daily game,
  /// etc.), it just layers on top of it.
  void _handleContinue() {
    final targetKey = widget.gemIconKey;
    final orbBox = _orbKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox = targetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (orbBox != null &&
        orbBox.attached &&
        targetBox != null &&
        targetBox.attached) {
      final rootOverlayBox =
          Overlay.of(context, rootOverlay: true).context.findRenderObject()
              as RenderBox;
      final start = orbBox.localToGlobal(
        orbBox.size.center(Offset.zero),
        ancestor: rootOverlayBox,
      );
      final end = targetBox.localToGlobal(
        targetBox.size.center(Offset.zero),
        ancestor: rootOverlayBox,
      );
      showFlyingGem(
        context: context,
        startGlobal: start,
        endGlobal: end,
        gem: _FlyingGemArt(imagePath: _earnedImagePath, glowColor: _glowColor),
      );
    }
    widget.onContinue();
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
                    style: GoogleFonts.mulish(
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
                                key: _orbKey,
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
                                  child: _earnedImagePath != null
                                      ? ClipOval(
                                          child: Image.asset(
                                            _earnedImagePath!,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Text(
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
                    style: GoogleFonts.mulish(
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
                      onPressed: _handleContinue,
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

  /// The bangle shows this journey's up to 6 most recently earned ritual
  /// charms (see widget.recentCharms, already ascending by day), right-
  /// aligned so the newest - the one this popup is celebrating - always
  /// lands in the rightmost slot; any remaining slots on the left stay
  /// empty rather than padded with charms that don't exist yet.
  Widget _buildBangle() {
    final recent = widget.recentCharms;
    final shown = recent.length > 6
        ? recent.sublist(recent.length - 6)
        : recent;
    final emptySlots = 6 - shown.length;

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
        children: [
          for (var i = 0; i < emptySlots; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: _EmptyGemSlot(),
            ),
          for (var i = 0; i < shown.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _GemSlot(
                imagePath: CharmImageCatalog.journeyCharmImage(
                  CharmRarity.fromName(shown[i].rarity),
                  shown[i].cycleDay,
                ),
                rarity: CharmRarity.fromName(shown[i].rarity),
                isNew: i == shown.length - 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.mulish(
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

/// One earned charm in the bangle - the real artwork (see
/// CharmImageCatalog), framed by a border/glow that matches its actual
/// rarity, same palette as the rest of the app's charm displays (see
/// CharmAlbumGrid's _CharmCircle). The just-earned one ([isNew]) pops in
/// with a little bounce and an extra glow, same as before this showed a
/// generic gem, so the "new addition" cue survives the switch to real art.
class _GemSlot extends StatelessWidget {
  final String? imagePath;
  final CharmRarity rarity;
  final bool isNew;

  const _GemSlot({
    required this.imagePath,
    required this.rarity,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (rarity) {
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
              color: Colors.white,
              border: Border.all(color: borderColor, width: 1.5),
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
            child: ClipOval(
              child: imagePath != null
                  ? Image.asset(imagePath!, fit: BoxFit.cover)
                  : const Center(child: Text('💎', style: TextStyle(fontSize: 14))),
            ),
          ),
        );
      },
    );
  }
}

/// A not-yet-earned slot in the bangle - see _GemSlot.
class _EmptyGemSlot extends StatelessWidget {
  const _EmptyGemSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: WommiColors.bgSoft,
        border: Border.all(color: const Color(0xFFD8D2E8), width: 1.5),
      ),
      child: Center(
        child: Text('·', style: TextStyle(fontSize: 16, color: WommiColors.inkDim)),
      ),
    );
  }
}

/// The small art shown flying from the win-dialog orb to the header's gem
/// icon (see showFlyingGem) - same real charm image + rarity glow as the
/// orb itself, just without the orb's own sunburst/pop-in animation, which
/// wouldn't read at this size or during a fast flight.
class _FlyingGemArt extends StatelessWidget {
  final String? imagePath;
  final Color glowColor;

  const _FlyingGemArt({required this.imagePath, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: glowColor.withValues(alpha: 0.6), blurRadius: 12),
        ],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(imagePath!, fit: BoxFit.cover)
            : const Center(child: Text('💎', style: TextStyle(fontSize: 14))),
      ),
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
