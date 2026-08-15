import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/chip_button.dart';
import '../widgets/number_scroll_picker.dart';
import '../utils/onboarding_completion.dart';

class OnboardingDaysPastOvulationScreen extends ConsumerWidget {
  const OnboardingDaysPastOvulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);

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
                      'How many days past\novulation are you?',
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
                      'We\'ll use this to place Wommi on the path accurately.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        height: 1.55,
                        color: WommiColors.inkDim,
                      ),
                    ),
                    const SizedBox(height: 26),
                    // IVF/IUI patients already answered this on the
                    // previous screen, so re-offering it here would just
                    // contradict what they picked.
                    if (!onboardingData.usesIvfOrIui) ...[
                      ChipButton(
                        text: 'Ovulation hasn\'t happened yet',
                        isSelected: onboardingData.ovulationNotYetHappened,
                        onTap: () => ref
                            .read(onboardingProvider.notifier)
                            .setOvulationNotYetHappened(),
                      ),
                    ],
                    if (!onboardingData.ovulationNotYetHappened) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            NumberScrollPicker(
                              minValue: 0,
                              maxValue: 16,
                              initialValue: onboardingData.daysPastOvulation ?? 0,
                              onChanged: (value) {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setDaysPastOvulation(value);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'DAYS PAST OVULATION',
                              style: TextStyle(
                                fontFamily: 'Space Mono',
                                fontSize: 11,
                                letterSpacing: 1.1,
                                color: WommiColors.inkDim,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: () =>
                      completeTtcOnboarding(context, ref, onboardingData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WommiColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 14,
                    shadowColor: WommiColors.cyan.withOpacity(0.38),
                  ),
                  child: Text(
                    'Begin my path',
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
