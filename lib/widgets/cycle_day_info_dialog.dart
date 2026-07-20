import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';

/// Shown when tapping a day on the journey map: a summary of what's
/// typically happening in the cycle on that day, and - for a day that
/// isn't fully completed yet - the option to do (or finish) its rituals
/// and collect more conception charms.
class CycleDayInfoDialog extends StatelessWidget {
  final int day;
  final ConceptionStatus? conceptionStatus;
  final bool isCompleted;
  final bool isInProgress;
  final bool isCurrent;
  final bool isFuture;
  final VoidCallback onOpenMissions;

  const CycleDayInfoDialog({
    super.key,
    required this.day,
    this.conceptionStatus,
    required this.isCompleted,
    required this.isInProgress,
    required this.isCurrent,
    required this.isFuture,
    required this.onOpenMissions,
  });

  @override
  Widget build(BuildContext context) {
    final info = _getCycleDayInfo(day, conceptionStatus);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: WommiColors.line,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: info.color,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day $day',
                    style: GoogleFonts.unbounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: WommiColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Phase title
            Text(
              info.phase,
              style: GoogleFonts.unbounded(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: info.color,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              info.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: WommiColors.ink,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: WommiColors.line,
            ),
            const SizedBox(height: 20),
            if (isFuture) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: WommiColors.inkDim, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'This day hasn\'t arrived yet',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: WommiColors.inkDim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Come back once you reach day $day to do its rituals and collect a conception charm.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: WommiColors.inkDim,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(color: WommiColors.line, width: 1.5),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.unbounded(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WommiColors.ink,
                    ),
                  ),
                ),
              ),
            ] else if (isCompleted) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: WommiColors.gold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Missions completed!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: WommiColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'You can revisit this day\'s rituals anytime, but its charm has already been collected.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: WommiColors.inkDim,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(color: WommiColors.line, width: 1.5),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.unbounded(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WommiColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onOpenMissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: info.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'View missions',
                        style: GoogleFonts.unbounded(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                isInProgress
                    ? 'You\'ve started this day\'s rituals - want to finish them and collect the charm?'
                    : isCurrent
                        ? 'Ready to complete today\'s rituals?'
                        : 'Would you like to complete this day\'s rituals and collect a conception charm?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: WommiColors.inkDim,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(color: WommiColors.line, width: 1.5),
                        ),
                      ),
                      child: Text(
                        'Not now',
                        style: GoogleFonts.unbounded(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WommiColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onOpenMissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: info.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isInProgress ? 'Finish' : 'Complete',
                            style: GoogleFonts.unbounded(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+1 💎',
                            style: GoogleFonts.unbounded(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  _CycleDayInfo _getCycleDayInfo(int day, ConceptionStatus? status) {
    final isTrying = status == ConceptionStatus.activelyTrying ||
        status == ConceptionStatus.twoWeekWait;

    if (day >= 1 && day <= 5) {
      return _CycleDayInfo(
        phase: 'Menstruation Phase',
        icon: '🌸',
        color: WommiColors.rose,
        description:
            'The first days of your cycle. Menstruation is happening as the uterine lining sheds. Energy may be lower, and self-care is key.',
      );
    } else if (day >= 6 && day <= 12) {
      return _CycleDayInfo(
        phase: 'Follicular Phase',
        icon: '🌱',
        color: WommiColors.lilac,
        description:
            'Your body is preparing for ovulation. Follicles in the ovaries are maturing, and estrogen levels are rising. Energy typically increases.',
      );
    } else if (day >= 13 && day <= 15) {
      return _CycleDayInfo(
        phase: 'Ovulation Window',
        icon: '✨',
        color: WommiColors.gold,
        description: isTrying
            ? 'Peak fertility! This is the optimal time for conception. The egg is released and can be fertilized for 12-24 hours.'
            : 'Ovulation is occurring. Your body releases an egg, and you may feel more energetic and social during this time.',
      );
    } else if (day >= 16 && day <= 21) {
      return _CycleDayInfo(
        phase: 'Early Luteal Phase',
        icon: '🌼',
        color: WommiColors.cyan,
        description: isTrying
            ? 'Post-ovulation phase. If conception occurred, the fertilized egg is traveling to the uterus and may implant around day 6-12 after ovulation.'
            : 'After ovulation, progesterone rises to prepare the uterine lining. Your body temperature may be slightly higher.',
      );
    } else if (day >= 22 && day <= 28) {
      return _CycleDayInfo(
        phase: 'Late Luteal Phase',
        icon: '🌙',
        color: WommiColors.lilac,
        description: isTrying
            ? 'Implantation may have occurred by now if conception was successful. Some experience early pregnancy symptoms, though it\'s too early to test.'
            : 'The final week before your next cycle begins. Progesterone drops if no pregnancy occurs, which may lead to PMS symptoms.',
      );
    } else {
      return _CycleDayInfo(
        phase: 'Extended Cycle',
        icon: '🔄',
        color: WommiColors.inkDim,
        description:
            'Cycles can vary in length. If your cycle extends beyond 28 days, it\'s still perfectly normal. You may be approaching menstruation.',
      );
    }
  }
}

class _CycleDayInfo {
  final String phase;
  final String icon;
  final Color color;
  final String description;

  _CycleDayInfo({
    required this.phase,
    required this.icon,
    required this.color,
    required this.description,
  });
}
