import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/challenges_screen.dart';
import 'cycle_day_info_dialog.dart';

/// Journey map with 35 cycle day positions
/// This is a placeholder that will be replaced with Rive animation
class JourneyMapWidget extends ConsumerWidget {
  const JourneyMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final currentDay = userState.currentDay;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: CustomPaint(
            painter: _PathPainter(currentDay),
            child: SizedBox(
              height: 1400, // Height for 35 positions
              child: Stack(
                children: [
                  for (int day = 1; day <= 35; day++)
                    _buildMapPosition(context, ref, day, currentDay),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPosition(
      BuildContext context, WidgetRef ref, int day, int currentDay) {
    final position = _getPositionForDay(day);
    final userState = ref.watch(userStateProvider);

    final isCurrent = day == currentDay;
    final isPast = day < currentDay;
    final isFuture = day > currentDay;

    // Check if this day's missions are completed
    final isCompleted = userState.completedDays.contains(day);
    // Started (at least one challenge done) but not all three yet - shown
    // with a rose accent instead of the plain "untouched" styling.
    final isInProgress = !isCompleted && userState.inProgressDays.contains(day);

    // Day is clickable if it's current or past (for replaying missions)
    final isClickable = !isFuture;

    return Positioned(
      left: position.dx - 25,
      top: position.dy - 25,
      child: GestureDetector(
        onTap: isClickable
            ? () => _showDayInfo(
                  context,
                  ref,
                  day,
                  isCompleted: isCompleted,
                  isInProgress: isInProgress,
                  isCurrent: isCurrent,
                )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position marker
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? WommiColors.cyan
                    : isCompleted
                        ? WommiColors.gold.withOpacity(0.3)
                        : isInProgress
                            ? WommiColors.roseSoft
                            : isPast
                                ? WommiColors.lilac.withOpacity(0.3)
                                : WommiColors.bgSoft,
                border: Border.all(
                  color: isCurrent
                      ? WommiColors.cyan
                      : isCompleted
                          ? WommiColors.gold
                          : isInProgress
                              ? WommiColors.rose
                              : isClickable
                                  ? WommiColors.line
                                  : WommiColors.line.withOpacity(0.3),
                  width: isCurrent || isInProgress ? 3 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: WommiColors.cyan.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: isClickable
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: GoogleFonts.unbounded(
                              fontSize: 14,
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
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: WommiColors.gold,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (isInProgress)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: WommiColors.rose,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Icon(
                        Icons.lock,
                        size: 20,
                        color: WommiColors.inkDim.withOpacity(0.4),
                      ),
              ),
            ),
            // Day label
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: WommiColors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'YOU',
                  style: GoogleFonts.spaceMono(
                    fontSize: 8,
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
  /// cycle on that day, and - if it isn't fully completed yet - offers to
  /// open its rituals from there.
  void _showDayInfo(
    BuildContext context,
    WidgetRef ref,
    int day, {
    required bool isCompleted,
    required bool isInProgress,
    required bool isCurrent,
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

  /// Calculate position for each day in a winding path
  Offset _getPositionForDay(int day) {
    const double width = 350;
    const double startX = 175; // Center
    const double verticalSpacing = 40;

    // Create a winding S-curve path
    final row = (day - 1) ~/ 5; // 5 positions per row
    final col = (day - 1) % 5;

    double x;
    if (row % 2 == 0) {
      // Left to right
      x = startX - 120 + (col * 60);
    } else {
      // Right to left
      x = startX + 120 - (col * 60);
    }

    final y = 40 + (row * verticalSpacing);

    return Offset(x, y);
  }
}

/// Custom painter to draw the path between positions
class _PathPainter extends CustomPainter {
  final int currentDay;

  _PathPainter(this.currentDay);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WommiColors.line.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintActive = Paint()
      ..color = WommiColors.lilac.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw connecting lines between positions
    for (int day = 1; day < 35; day++) {
      final start = _getPositionForDay(day);
      final end = _getPositionForDay(day + 1);

      // Use active paint for completed path segments
      final activePaint = day < currentDay ? paintActive : paint;

      canvas.drawLine(start, end, activePaint);
    }
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) =>
      oldDelegate.currentDay != currentDay;

  Offset _getPositionForDay(int day) {
    const double width = 350;
    const double startX = 175;
    const double verticalSpacing = 40;

    final row = (day - 1) ~/ 5;
    final col = (day - 1) % 5;

    double x;
    if (row % 2 == 0) {
      x = startX - 120 + (col * 60);
    } else {
      x = startX + 120 - (col * 60);
    }

    final y = 40 + (row * verticalSpacing);

    return Offset(x, y);
  }
}
