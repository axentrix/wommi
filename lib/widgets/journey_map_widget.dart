import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/challenges_screen.dart';
import 'cycle_day_info_dialog.dart';

/// Journey map with 35 cycle day positions, laid out along a curvy path
/// over the isometric womb illustration.
/// This is a placeholder background - it will be replaced with a Rive
/// animation.
class JourneyMapWidget extends ConsumerWidget {
  const JourneyMapWidget({super.key});

  // Matches the cropped background image's own pixel dimensions, so the
  // day path lines up with it at any screen size.
  static const double _bgWidth = 762;
  static const double _bgHeight = 849;

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
                    for (int day = 1; day <= 35; day++)
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
  /// in the background illustration, from the flag near the top to the
  /// heart marker near the bottom.
  Offset _getPositionForDay(int day, Size size) {
    final t = (day - 1) / 34.0;

    final yFrac = 0.06 + t * 0.80;
    final xFrac = 0.5 + 0.175 * math.sin(t * 2.5 * math.pi);

    return Offset(xFrac * size.width, yFrac * size.height);
  }
}
