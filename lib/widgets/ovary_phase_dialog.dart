import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';

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
                          'Days 1-$dayCount',
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(dayCount, (i) {
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
