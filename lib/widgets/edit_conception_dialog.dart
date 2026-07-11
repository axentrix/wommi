import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/choice_button.dart';

class EditConceptionDialog extends ConsumerWidget {
  const EditConceptionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Conception Status',
                    style: GoogleFonts.unbounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you currently trying to conceive?',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: ConceptionStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChoiceButton(
                          text: status.label,
                          isSelected: onboardingData.conceptionStatus == status,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setConceptionStatus(status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WommiColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: WommiColors.line, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onboardingData.conceptionStatus != null
                          ? () => Navigator.pop(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onboardingData.conceptionStatus != null
                            ? WommiColors.cyan
                            : WommiColors.line,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: onboardingData.conceptionStatus != null ? 8 : 0,
                        shadowColor: WommiColors.cyan.withOpacity(0.38),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
}
