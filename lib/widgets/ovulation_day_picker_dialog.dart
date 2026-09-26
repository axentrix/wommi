import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';

/// Opens the picker that lets the user say exactly which day ovulation
/// started - see OvulationDayPickerDialog. [asBottomSheet] matches whichever
/// entry point is opening it: map-context popups (CycleDayInfoDialog,
/// OvaryPhaseDialog) already show as bottom sheets over the map, so this
/// should too rather than stacking a centered dialog on top of one; Profile
/// isn't a sheet context, so it gets a centered dialog instead.
Future<void> showOvulationDayPicker(
  BuildContext context, {
  bool asBottomSheet = false,
}) {
  if (asBottomSheet) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const OvulationDayPickerDialog(asBottomSheet: true),
    );
  }
  return showDialog(
    context: context,
    builder: (_) => const OvulationDayPickerDialog(),
  );
}

/// Lets the user say exactly which day of the *current* journey ovulation
/// started on - not just "today", since a positive test or other sign is
/// often noticed a day or more after it actually happened, and by the time
/// someone's well into a journey (e.g. day 18) restricting this to "today"
/// would make it impossible to correctly mark a day that's already passed.
/// Every day from 1 up to today is offered, today itself labeled as such;
/// picking one (a fresh pick or a correction to an already-marked one) sets
/// [UserState.ovulationDay] to it, and a plain link clears it back to
/// unmarked. Shared by every "Ovulation started" entry point (Profile,
/// CycleDayInfoDialog, OvaryPhaseDialog) so marking/changing it behaves the
/// same everywhere instead of each screen inventing its own day range.
class OvulationDayPickerDialog extends ConsumerWidget {
  final bool asBottomSheet;

  const OvulationDayPickerDialog({super.key, this.asBottomSheet = false});

  void _select(BuildContext context, WidgetRef ref, int? day) {
    ref.read(userStateProvider.notifier).markOvulationDay(day);
    ref.read(repositoryProvider).setOvulationDay(day);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final currentDay = userState.currentDay;
    final markedDay = userState.ovulationDay;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🥚', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'When did ovulation start?',
                style: GoogleFonts.unbounded(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
        const SizedBox(height: 6),
        Text(
          'Pick the day you got a positive test or other sign - it doesn\'t have to be today.',
          style: GoogleFonts.mulish(
            fontSize: 12,
            color: WommiColors.inkDim,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(currentDay, (i) {
                final day = i + 1;
                return _DayOption(
                  day: day,
                  isToday: day == currentDay,
                  isSelected: day == markedDay,
                  onTap: () => _select(context, ref, day),
                );
              }),
            ),
          ),
        ),
        if (markedDay != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _select(context, ref, null),
              child: Text(
                'Not marked yet - clear it',
                style: GoogleFonts.unbounded(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: WommiColors.inkDim,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (asBottomSheet) {
      return SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: WommiColors.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 8),
              Flexible(child: content),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: WommiColors.line, width: 2),
        ),
        child: content,
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: WommiColors.line,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _DayOption extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayOption({
    required this.day,
    required this.isToday,
    required this.isSelected,
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
          color: isSelected ? WommiColors.gold : WommiColors.bgSoft,
          border: Border.all(
            color: isSelected ? WommiColors.gold : WommiColors.line,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: GoogleFonts.unbounded(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : WommiColors.ink,
                ),
              ),
              if (isToday)
                Text(
                  'TODAY',
                  style: GoogleFonts.mulish(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : WommiColors.inkDim,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
