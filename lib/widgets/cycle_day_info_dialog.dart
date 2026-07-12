import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';

/// Dialog showing info about a specific cycle day
class CycleDayInfoDialog extends StatelessWidget {
  final int day;
  final ConceptionStatus? conceptionStatus;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onCompleteMissions;

  const CycleDayInfoDialog({
    super.key,
    required this.day,
    this.conceptionStatus,
    required this.isCompleted,
    required this.isCurrent,
    required this.onCompleteMissions,
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
            // Divider
            Container(
              height: 1,
              color: WommiColors.line,
            ),
            const SizedBox(height: 20),
            // Mission status and actions
            if (isCompleted) ...[
              // Already completed - show option to replay for fun
              Row(
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
                'You can replay missions for fun, but gems have already been collected.',
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
                      side: BorderSide(
                        color: WommiColors.line,
                        width: 1.5,
                      ),
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
            ] else ...[
              // Not completed yet - show option to complete missions
              Text(
                isCurrent
                    ? 'Ready to complete today\'s missions?'
                    : 'Would you like to complete this day\'s missions and collect gems?',
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
                          side: BorderSide(
                            color: WommiColors.line,
                            width: 1.5,
                          ),
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
                      onPressed: onCompleteMissions,
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
                            'Complete',
                            style: GoogleFonts.unbounded(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '💎 +10',
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
    // Determine phase and provide relevant info
    // Based on typical menstrual cycle events

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
        description: status == ConceptionStatus.activelyTrying ||
            status == ConceptionStatus.twoWeekWait
            ? 'Peak fertility! This is the optimal time for conception. The egg is released and can be fertilized for 12-24 hours.'
            : 'Ovulation is occurring. Your body releases an egg, and you may feel more energetic and social during this time.',
      );
    } else if (day >= 16 && day <= 21) {
      return _CycleDayInfo(
        phase: 'Early Luteal Phase',
        icon: '🌼',
        color: WommiColors.cyan,
        description: status == ConceptionStatus.activelyTrying ||
            status == ConceptionStatus.twoWeekWait
            ? 'Post-ovulation phase. If conception occurred, the fertilized egg is traveling to the uterus and may implant around day 6-12 after ovulation.'
            : 'After ovulation, progesterone rises to prepare the uterine lining. Your body temperature may be slightly higher.',
      );
    } else if (day >= 22 && day <= 28) {
      return _CycleDayInfo(
        phase: 'Late Luteal Phase',
        icon: '🌙',
        color: WommiColors.lilac,
        description: status == ConceptionStatus.activelyTrying ||
            status == ConceptionStatus.twoWeekWait
            ? 'Implantation may have occurred by now if conception was successful. Some women experience early pregnancy symptoms, though it\'s too early to test.'
            : 'The final week before your next cycle begins. Progesterone drops if no pregnancy occurs, which may lead to PMS symptoms.',
      );
    } else {
      // Days 29-35 (extended cycles)
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
