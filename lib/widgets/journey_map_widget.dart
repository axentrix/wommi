import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/user_state.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/challenges_screen.dart';
import 'cycle_day_info_dialog.dart';
import 'ovary_phase_dialog.dart';

/// Journey map laid out over the isometric womb illustration: a single
/// combined node for the ovary/follicular days (whose real-world length
/// varies and isn't known in advance) connected by the fallopian tube into
/// the uterus, then individual day markers for the rest of the cycle.
/// This is a placeholder background - it will be replaced with a Rive
/// animation.
class JourneyMapWidget extends ConsumerWidget {
  const JourneyMapWidget({super.key});

  // Matches the cropped background image's own pixel dimensions, so the
  // day path lines up with it at any screen size.
  static const double _bgWidth = 762;
  static const double _bgHeight = 849;

  // Days 1..ovaryDayCount are bundled into a single node near the ovary,
  // rather than plotted individually - ovulation timing varies, so we
  // don't know in advance exactly how many days that phase will last.
  static const int ovaryDayCount = 13;

  // Fallopian tube path (fractions of the background image's size),
  // starting at the ovary and ending where it opens into the uterus.
  static const List<Offset> _tubePoints = [
    Offset(0.1772, 0.3357),
    Offset(0.0984, 0.2650),
    Offset(0.0591, 0.1649),
    Offset(0.1247, 0.0884),
    Offset(0.2428, 0.0707),
    Offset(0.3281, 0.1060),
    Offset(0.3675, 0.1354),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final currentDay = userState.currentDay;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AspectRatio(
            aspectRatio: _bgWidth / _bgHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/womb_journey_bg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TubePathPainter(points: _tubePoints),
                      ),
                    ),
                    _buildOvaryNode(context, ref, userState, currentDay, size),
                    for (int day = ovaryDayCount + 1; day <= 35; day++)
                      _buildMapPosition(context, ref, day, currentDay, size),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The combined node standing in for days 1..ovaryDayCount.
  Widget _buildOvaryNode(
    BuildContext context,
    WidgetRef ref,
    UserState userState,
    int currentDay,
    Size size,
  ) {
    final completedCount = List.generate(ovaryDayCount, (i) => i + 1)
        .where((d) => userState.completedDays.contains(d))
        .length;
    final hasProgress = List.generate(ovaryDayCount, (i) => i + 1)
        .any((d) => userState.inProgressDays.contains(d) ||
            userState.completedDays.contains(d));
    final isCurrentPhase = currentDay <= ovaryDayCount;
    final allCompleted = completedCount == ovaryDayCount;

    const nodeSize = 46.0;
    final position = _tubePoints.first;

    return Positioned(
      left: position.dx * size.width - nodeSize / 2,
      top: position.dy * size.height - nodeSize / 2,
      child: GestureDetector(
        onTap: () => _showOvaryPhase(context, ref, currentDay),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentPhase
                    ? WommiColors.cyan
                    : allCompleted
                        ? WommiColors.gold.withOpacity(0.85)
                        : hasProgress
                            ? WommiColors.roseSoft
                            : Colors.white.withOpacity(0.85),
                border: Border.all(
                  color: isCurrentPhase
                      ? WommiColors.cyan
                      : allCompleted
                          ? WommiColors.gold
                          : hasProgress
                              ? WommiColors.rose
                              : WommiColors.line,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCurrentPhase ? WommiColors.cyan : Colors.black)
                        .withOpacity(isCurrentPhase ? 0.4 : 0.15),
                    blurRadius: isCurrentPhase ? 14 : 5,
                    spreadRadius: isCurrentPhase ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: allCompleted
                    ? Icon(Icons.check, size: 18, color: WommiColors.ink)
                    : Text(
                        '1-$ovaryDayCount',
                        style: GoogleFonts.unbounded(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCurrentPhase ? Colors.white : WommiColors.ink,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: WommiColors.bg.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ovary • tap to open',
                style: GoogleFonts.spaceMono(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  color: WommiColors.inkDim,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOvaryPhase(BuildContext context, WidgetRef ref, int currentDay) {
    showDialog(
      context: context,
      builder: (context) => OvaryPhaseDialog(
        dayCount: ovaryDayCount,
        onDayTap: (day) {
          Navigator.pop(context);
          final userState = ref.read(userStateProvider);
          _showDayInfo(
            context,
            ref,
            day,
            isCompleted: userState.completedDays.contains(day),
            isInProgress: !userState.completedDays.contains(day) &&
                userState.inProgressDays.contains(day),
            isCurrent: day == currentDay,
            isFuture: day > currentDay,
          );
        },
      ),
    );
  }

  Widget _buildMapPosition(
    BuildContext context,
    WidgetRef ref,
    int day,
    int currentDay,
    Size size,
  ) {
    final position = _getPositionForDay(day, size);
    final userState = ref.watch(userStateProvider);

    final isCurrent = day == currentDay;
    final isPast = day < currentDay;
    final isFuture = day > currentDay;

    // Check if this day's missions are completed
    final isCompleted = userState.completedDays.contains(day);
    // Started (at least one challenge done) but not all three yet - shown
    // with a rose accent instead of the plain "untouched" styling.
    final isInProgress = !isCompleted && userState.inProgressDays.contains(day);

    // A day's rituals can only be done once it's current or past - future
    // days stay locked - but every day is tappable to see its info popup,
    // future ones just can't offer to start missions from there.
    final isClickable = !isFuture;

    const markerSize = 19.0;

    return Positioned(
      left: position.dx - markerSize / 2,
      top: position.dy - markerSize / 2,
      child: GestureDetector(
        onTap: () => _showDayInfo(
          context,
          ref,
          day,
          isCompleted: isCompleted,
          isInProgress: isInProgress,
          isCurrent: isCurrent,
          isFuture: isFuture,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position marker
            Container(
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? WommiColors.cyan
                    : isCompleted
                        ? WommiColors.gold.withOpacity(0.85)
                        : isInProgress
                            ? WommiColors.roseSoft
                            : isPast
                                ? Colors.white.withOpacity(0.85)
                                : Colors.white.withOpacity(0.55),
                border: Border.all(
                  color: isCurrent
                      ? WommiColors.cyan
                      : isCompleted
                          ? WommiColors.gold
                          : isInProgress
                              ? WommiColors.rose
                              : isClickable
                                  ? WommiColors.line
                                  : WommiColors.line.withOpacity(0.5),
                  width: isCurrent || isInProgress ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCurrent ? WommiColors.cyan : Colors.black)
                        .withOpacity(isCurrent ? 0.4 : 0.15),
                    blurRadius: isCurrent ? 12 : 4,
                    spreadRadius: isCurrent ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isClickable
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: GoogleFonts.unbounded(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : isCompleted
                                      ? WommiColors.ink
                                      : WommiColors.inkDim,
                            ),
                          ),
                          if (isCompleted)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: WommiColors.gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (isInProgress)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: WommiColors.rose,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Icon(
                        Icons.lock,
                        size: 10,
                        color: WommiColors.inkDim.withOpacity(0.5),
                      ),
              ),
            ),
            // Day label
            if (isCurrent) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: WommiColors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'YOU',
                  style: GoogleFonts.spaceMono(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tapping a day shows a summary of what's typically happening in the
  /// cycle on that day, and - if it isn't fully completed yet and isn't in
  /// the future - offers to open its rituals from there.
  void _showDayInfo(
    BuildContext context,
    WidgetRef ref,
    int day, {
    required bool isCompleted,
    required bool isInProgress,
    required bool isCurrent,
    required bool isFuture,
  }) {
    final conceptionStatus = ref.read(onboardingProvider).conceptionStatus;
    showDialog(
      context: context,
      builder: (context) => CycleDayInfoDialog(
        day: day,
        conceptionStatus: conceptionStatus,
        isCompleted: isCompleted,
        isInProgress: isInProgress,
        isCurrent: isCurrent,
        isFuture: isFuture,
        onOpenMissions: () {
          Navigator.pop(context);
          _openDayChallenges(context, day);
        },
      ),
    );
  }

  void _openDayChallenges(BuildContext context, int day) {
    // Same 3 daily missions/rituals as the Challenges tab, just scoped to
    // this specific day and pushed as its own screen with a back button.
    // Awards exactly 1 gem, same as any other day, only once all 3 are
    // complete.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChallengesScreen(day: day)),
    );
  }

  /// Traces a winding S-curve down the river/stepping-stone path visible
  /// in the background illustration, starting where the fallopian tube
  /// opens into the uterus and ending near the bottom heart marker.
  Offset _getPositionForDay(int day, Size size) {
    final individualDayCount = 35 - ovaryDayCount;
    final t = (day - ovaryDayCount - 1) / (individualDayCount - 1);

    final baseY = 0.16 + t * 0.70;
    final baseX = 0.5 + 0.175 * math.sin(t * 2.2 * math.pi);

    // Day 14 (t = 0) should sit right where the fallopian tube opens into
    // the uterus, not wherever the winding uterus path's formula happens to
    // start - so pull the first few days toward the tube's actual end
    // point, decaying to 0 by the time the path settles into its regular
    // wind through the uterus.
    final tubeEnd = _tubePoints.last;
    final baseAtStart = Offset(0.5, 0.16);
    final pull = math.pow(1 - t, 3).toDouble().clamp(0.0, 1.0);
    final xFrac = baseX + (tubeEnd.dx - baseAtStart.dx) * pull;
    final yFrac = baseY + (tubeEnd.dy - baseAtStart.dy) * pull;

    return Offset(xFrac * size.width, yFrac * size.height);
  }
}

/// Draws a soft line tracing the fallopian tube from the ovary node into
/// the uterus, smoothed through the given fractional points.
class _TubePathPainter extends CustomPainter {
  final List<Offset> points;

  _TubePathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final scaled = points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = Path()..moveTo(scaled.first.dx, scaled.first.dy);
    for (int i = 0; i < scaled.length - 1; i++) {
      final current = scaled[i];
      final next = scaled[i + 1];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.lineTo(scaled.last.dx, scaled.last.dy);

    final paint = Paint()
      ..color = WommiColors.rose.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TubePathPainter oldDelegate) => false;
}
