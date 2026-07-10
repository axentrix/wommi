import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/number_scroll_picker.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCycleDayScreen extends ConsumerWidget {
  const OnboardingCycleDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);
    final selectedDay = onboardingData.cycleDay;

    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: WommiColors.cyan,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: WommiColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: WommiColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Text(
                      'STEP 1 OF 3',
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
                      'Where are you in\nyour cycle today?',
                      style: TextStyle(
                        fontFamily: 'Unbounded',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1.25,
                        color: WommiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle
                    Text(
                      'We\'ll use this to place Wommi on the path and time your rituals to your body.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        height: 1.55,
                        color: WommiColors.inkDim,
                      ),
                    ),
                    const SizedBox(height: 26),
                    // Number wheel
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NumberScrollPicker(
                              minValue: 1,
                              maxValue: 35,
                              initialValue: selectedDay,
                              onChanged: (value) {
                                ref.read(onboardingProvider.notifier).setCycleDay(value);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'DAY OF CYCLE',
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
                  onPressed: () {
                    // Navigate to next onboarding screen
                    Navigator.of(context).pushNamed('/onboarding-step2');
                  },
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
