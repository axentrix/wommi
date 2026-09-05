import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';
import '../models/user_state.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../utils/journey_completion_flows.dart';

/// Shown when tapping a day on the journey map: a summary of what's
/// typically happening in the cycle on that day, and - for a day that
/// isn't fully completed yet - the option to do (or finish) its rituals
/// and collect more conception charms.
class CycleDayInfoDialog extends ConsumerWidget {
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

  /// The "period started / pregnancy detected" pair only makes sense once
  /// ovulation is known and enough of the two-week wait has passed -
  /// offering them any earlier would just be noise.
  bool _journeyEndToggleEligible(UserState userState) {
    final ovulationDay = userState.ovulationDay;
    return ovulationDay != null && day >= ovulationDay + 12;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final info = _getCycleDayInfo(day, conceptionStatus, userState.ovulationDay);
    // Always offered on any non-future day until marked - a journey can be
    // started on any cycle day, so there's no "too late to ask" cutoff;
    // this toggle is the only way to close off the ovary phase (see
    // JourneyMapWidget._ovaryDayCount), so it must never become unreachable.
    // None of this applies to a journey that isn't tracking a menstrual
    // cycle in the first place (see UserState.tracksMenstrualCycle).
    final showOvulationToggle = userState.tracksMenstrualCycle &&
        !isFuture &&
        (userState.ovulationDay == null || userState.ovulationDay == day);
    final ovulationMarkedHere = userState.ovulationDay == day;
    final showJourneyEndToggles = userState.tracksMenstrualCycle &&
        !isFuture &&
        _journeyEndToggleEligible(userState);

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
            if (showOvulationToggle) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: WommiColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WommiColors.gold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ovulation started',
                            style: GoogleFonts.unbounded(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: WommiColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ovulationMarkedHere
                                ? 'Marked on day $day. Tap to undo.'
                                : 'Got a positive test or other sign today? Let us know.',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: WommiColors.inkDim,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: ovulationMarkedHere,
                      activeThumbColor: WommiColors.gold,
                      onChanged: (value) {
                        final newDay = value ? day : null;
                        ref
                            .read(userStateProvider.notifier)
                            .markOvulationDay(newDay);
                        ref.read(repositoryProvider).setOvulationDay(newDay);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (showJourneyEndToggles) ...[
              _buildJourneyEndToggle(
                context,
                ref,
                label: 'Period started',
                activeColor: WommiColors.cyan,
                onToggledOn: () => showPeriodStartedFlow(context, ref),
              ),
              const SizedBox(height: 10),
              _buildJourneyEndToggle(
                context,
                ref,
                label: 'Pregnancy detected',
                activeColor: WommiColors.rose,
                onToggledOn: () => showPregnancyDetectedFlow(context, ref),
              ),
              const SizedBox(height: 16),
            ],
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
              _buildActionButtons(
                context,
                color: info.color,
                ritualsLabel: 'Revisit daily rituals',
                showRitualsReward: false,
                gameAlreadyPlayed: userState.dailyGamePlayedDays.contains(day),
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
              _buildActionButtons(
                context,
                color: info.color,
                ritualsLabel:
                    isInProgress ? 'Finish daily rituals' : 'Complete daily rituals',
                showRitualsReward: true,
                gameAlreadyPlayed: userState.dailyGamePlayedDays.contains(day),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The two things to do on a non-future day - the 3 rituals and the
  /// day's mini-game, each a real button since both are independent ways
  /// to earn a charm - with a plain "Not now" text link below for
  /// dismissing without doing either. Dismissing (including "Play daily
  /// game") just closes this dialog: the game is already running full-
  /// screen behind it (see DailyGameScreen), so there's nothing else to
  /// navigate to.
  Widget _buildActionButtons(
    BuildContext context, {
    required Color color,
    required String ritualsLabel,
    required bool showRitualsReward,
    required bool gameAlreadyPlayed,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onOpenMissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
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
                  ritualsLabel,
                  style: GoogleFonts.unbounded(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (showRitualsReward) ...[
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            // Still just dismisses either way - the game (or, once played,
            // its locked state) is already running behind this dialog, see
            // DailyGameScreen. Greyed out here just as a heads-up so
            // tapping it isn't a surprise.
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: gameAlreadyPlayed ? WommiColors.inkDim : color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: gameAlreadyPlayed ? WommiColors.line : color,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              gameAlreadyPlayed ? 'Game already played today' : 'Play daily game',
              style: GoogleFonts.unbounded(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: gameAlreadyPlayed ? WommiColors.inkDim : color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Not now',
            style: GoogleFonts.unbounded(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WommiColors.inkDim,
            ),
          ),
        ),
      ],
    );
  }

  /// One of the "period started" / "pregnancy detected" pills - same
  /// styling as the Profile screen's version of these, and wired to the
  /// same flows, just reachable from a day's popup instead. Always shows
  /// off: switching it on immediately leaves this journey via [onToggledOn],
  /// so there's nothing to reflect back as already-on.
  Widget _buildJourneyEndToggle(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required Color activeColor,
    required VoidCallback onToggledOn,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WommiColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.unbounded(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WommiColors.ink,
            ),
          ),
          Switch(
            value: false,
            activeThumbColor: activeColor,
            onChanged: (value) {
              if (value) onToggledOn();
            },
          ),
        ],
      ),
    );
  }

  _CycleDayInfo _getCycleDayInfo(int day, ConceptionStatus? status, int? ovulationDay) {
    final isTrying = status == ConceptionStatus.activelyTrying;

    if (day >= 1 && day <= 5) {
      return _CycleDayInfo(
        phase: 'Menstruation Phase',
        icon: '🌸',
        color: WommiColors.rose,
        description:
            'The first days of your cycle. Menstruation is happening as the uterine lining sheds. Energy may be lower, and self-care is key.',
      );
    }

    // Once ovulation is actually tracked, describe this day relative to
    // when it really happened, instead of the generic day-13-15 guess
    // below - otherwise a day already past real ovulation could still be
    // described as "preparing for ovulation".
    if (ovulationDay != null) {
      if (day < ovulationDay) {
        return _follicularPhase;
      }
      if (day == ovulationDay) {
        return _ovulationWindow(isTrying);
      }
      final daysSinceOvulation = day - ovulationDay;
      if (daysSinceOvulation <= 6) return _earlyLutealPhase(isTrying);
      if (daysSinceOvulation <= 13) return _lateLutealPhase(isTrying);
      return _extendedCycle;
    }

    if (day >= 6 && day <= 12) return _follicularPhase;
    if (day >= 13 && day <= 15) return _ovulationWindow(isTrying);
    if (day >= 16 && day <= 21) return _earlyLutealPhase(isTrying);
    if (day >= 22 && day <= 28) return _lateLutealPhase(isTrying);
    return _extendedCycle;
  }

  _CycleDayInfo get _follicularPhase => _CycleDayInfo(
        phase: 'Follicular Phase',
        icon: '🌱',
        color: WommiColors.lilac,
        description:
            'Your body is preparing for ovulation. Follicles in the ovaries are maturing, and estrogen levels are rising. Energy typically increases.',
      );

  _CycleDayInfo _ovulationWindow(bool isTrying) => _CycleDayInfo(
        phase: 'Ovulation Window',
        icon: '✨',
        color: WommiColors.gold,
        description: isTrying
            ? 'Peak fertility! This is the optimal time for conception. The egg is released and can be fertilized for 12-24 hours.'
            : 'Ovulation is occurring. Your body releases an egg, and you may feel more energetic and social during this time.',
      );

  _CycleDayInfo _earlyLutealPhase(bool isTrying) => _CycleDayInfo(
        phase: 'Early Luteal Phase',
        icon: '🌼',
        color: WommiColors.cyan,
        description: isTrying
            ? 'Post-ovulation phase. If conception occurred, the fertilized egg is traveling to the uterus and may implant around day 6-12 after ovulation.'
            : 'After ovulation, progesterone rises to prepare the uterine lining. Your body temperature may be slightly higher.',
      );

  _CycleDayInfo _lateLutealPhase(bool isTrying) => _CycleDayInfo(
        phase: 'Late Luteal Phase',
        icon: '🌙',
        color: WommiColors.lilac,
        description: isTrying
            ? 'Implantation may have occurred by now if conception was successful. Some experience early pregnancy symptoms, though it\'s too early to test.'
            : 'The final week before your next cycle begins. Progesterone drops if no pregnancy occurs, which may lead to PMS symptoms.',
      );

  _CycleDayInfo get _extendedCycle => _CycleDayInfo(
        phase: 'Extended Cycle',
        icon: '🔄',
        color: WommiColors.inkDim,
        description:
            'Cycles can vary in length. If your cycle extends beyond 28 days, it\'s still perfectly normal. You may be approaching menstruation.',
      );
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
