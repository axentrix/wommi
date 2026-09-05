import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';

/// The "enlarged highlight" shown when tapping the combined ovary node on
/// the journey map: since ovulation timing varies and this phase's real
/// length isn't known in advance, its days are grouped into one node on
/// the map itself, but can still be picked individually from here.
class OvaryPhaseDialog extends ConsumerWidget {
  final int dayCount;
  final ValueChanged<int> onDayTap;

  const OvaryPhaseDialog({
    super.key,
    required this.dayCount,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final currentDay = userState.currentDay;
    // Reacts live to the toggle below instead of the count this dialog was
    // opened with, so marking ovulation immediately shrinks the grid to
    // match, no reopen needed. The marked day itself becomes day 1 of the
    // tube phase (shown on the map, not here), so the ovary only covers up
    // to the day before it - matches JourneyMapWidget._ovaryDayCount.
    final effectiveDayCount = (userState.ovulationDay != null
            ? userState.ovulationDay! - 1
            : dayCount)
        .clamp(1, 33);

    // Always offered until marked, regardless of when the journey started -
    // this toggle is the only way to close off the ovary phase, so it must
    // never become unreachable (see JourneyMapWidget._ovaryDayCount). Not
    // offered at all for a journey that isn't tracking a menstrual cycle
    // (see UserState.tracksMenstrualCycle) - it just keeps growing instead.
    final ovulationMarkedToday = userState.ovulationDay == currentDay;
    final showOvulationToggle = userState.tracksMenstrualCycle &&
        (userState.ovulationDay == null || ovulationMarkedToday);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🥚', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Days 1-$effectiveDayCount',
                          style: GoogleFonts.unbounded(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: WommiColors.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: WommiColors.inkDim),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ovulation timing varies cycle to cycle, so these early days are grouped together on the map. Tap any day below to see what\'s going on and do its rituals.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (showOvulationToggle)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: WommiColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: WommiColors.gold.withOpacity(0.4)),
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
                              ovulationMarkedToday
                                  ? 'Marked on day $currentDay. From here the journey continues into the fallopian tube. Tap to undo.'
                                  : 'Got a positive test or other sign today? From here the journey continues into the fallopian tube.',
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
                        value: ovulationMarkedToday,
                        activeThumbColor: WommiColors.gold,
                        onChanged: (value) {
                          final newDay = value ? currentDay : null;
                          ref
                              .read(userStateProvider.notifier)
                              .markOvulationDay(newDay);
                          ref
                              .read(repositoryProvider)
                              .setOvulationDay(newDay);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(effectiveDayCount, (i) {
                    final day = i + 1;
                    final isCompleted = userState.completedDays.contains(day);
                    final isInProgress = !isCompleted &&
                        userState.inProgressDays.contains(day);
                    final isCurrent = day == currentDay;
                    final isFuture = day > currentDay;

                    return _DayChip(
                      day: day,
                      isCompleted: isCompleted,
                      isInProgress: isInProgress,
                      isCurrent: isCurrent,
                      isFuture: isFuture,
                      onTap: () => onDayTap(day),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isInProgress;
  final bool isCurrent;
  final bool isFuture;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isCompleted,
    required this.isInProgress,
    required this.isCurrent,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCurrent
              ? WommiColors.cyan
              : isCompleted
                  ? WommiColors.gold.withOpacity(0.3)
                  : isInProgress
                      ? WommiColors.roseSoft
                      : WommiColors.bgSoft,
          border: Border.all(
            color: isCurrent
                ? WommiColors.cyan
                : isCompleted
                    ? WommiColors.gold
                    : isInProgress
                        ? WommiColors.rose
                        : WommiColors.line,
            width: isCurrent || isInProgress ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: isFuture
              ? Icon(Icons.lock, size: 16, color: WommiColors.inkDim.withOpacity(0.5))
              : Stack(
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
                          child: Icon(Icons.check, size: 9, color: Colors.white),
                        ),
                      )
                    else if (isInProgress)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: WommiColors.rose,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
