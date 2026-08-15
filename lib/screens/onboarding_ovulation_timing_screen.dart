import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/chip_button.dart';
import '../utils/onboarding_completion.dart';

/// Shown instead of the tracking-ovulation yes/no screen for IVF/IUI
/// patients, who are already closely monitored - so we skip straight to
/// where they are relative to ovulation rather than asking if they track
/// it at all.
class OnboardingOvulationTimingScreen extends ConsumerWidget {
  const OnboardingOvulationTimingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);
    final isPostOvulation =
        onboardingData.isTrackingOvulation == true &&
        !onboardingData.ovulationNotYetHappened;
    final isBeforeOvulation =
        onboardingData.isTrackingOvulation == true &&
        onboardingData.ovulationNotYetHappened;

    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: WommiColors.ink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: WommiColors.cyan,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Text(
                      'STEP 3 OF 3',
                      style: TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 10.5,
                        letterSpacing: 1.89,
                        color: WommiColors.rose,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      'Where are you\nright now?',
                      style: TextStyle(
                        fontFamily: 'Unbounded',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1.25,
                        color: WommiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This helps us show you the right day on your journey map.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        height: 1.55,
                        color: WommiColors.inkDim,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChipButton(
                          text: 'I am post ovulation',
                          isSelected: isPostOvulation,
                          onTap: () => ref
                              .read(onboardingProvider.notifier)
                              .setTrackingOvulation(true),
                        ),
                        ChipButton(
                          text: 'I am before ovulation',
                          isSelected: isBeforeOvulation,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setTrackingOvulation(true);
                            ref
                                .read(onboardingProvider.notifier)
                                .setOvulationNotYetHappened();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Footer with button
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 26),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onboardingData.isTrackingOvulation != true
                      ? null
                      : () {
                          if (onboardingData.ovulationNotYetHappened) {
                            completeTtcOnboarding(context, ref, onboardingData);
                          } else {
                            Navigator.of(context)
                                .pushNamed('/onboarding-days-past-ovulation');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onboardingData.isTrackingOvulation != true
                        ? WommiColors.line
                        : WommiColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: onboardingData.isTrackingOvulation != true ? 0 : 14,
                    shadowColor: WommiColors.cyan.withOpacity(0.38),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Unbounded',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
