import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../providers/user_state_provider.dart';
import '../widgets/chip_button.dart';
import '../widgets/number_scroll_picker.dart';
import '../providers/repository_provider.dart';

class OnboardingStep3Screen extends ConsumerWidget {
  const OnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);
    final isActivelyTrying =
        onboardingData.conceptionStatus == ConceptionStatus.activelyTrying;
    final isTwoWeekWait =
        onboardingData.conceptionStatus == ConceptionStatus.twoWeekWait;

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
                        color: WommiColors.cyan,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
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
                    // Title - conditional based on status
                    if (isActivelyTrying) ...[
                      Text(
                        'How are you trying\nto conceive?',
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
                        'Select all that apply. This helps us personalize your journey.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          height: 1.55,
                          color: WommiColors.inkDim,
                        ),
                      ),
                      const SizedBox(height: 26),
                      // Chip row for trying methods
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TryingMethod.values.map((method) {
                          return ChipButton(
                            text: method.label,
                            isSelected:
                                onboardingData.tryingMethods.contains(method),
                            onTap: () {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .toggleTryingMethod(method);
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (isTwoWeekWait) ...[
                      Text(
                        'How many days into\nthe wait are you?',
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
                        'This helps us time your rituals and support during the two-week wait.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          height: 1.55,
                          color: WommiColors.inkDim,
                        ),
                      ),
                      const SizedBox(height: 26),
                      // Number wheel for days into wait
                      Center(
                        child: Column(
                          children: [
                            NumberScrollPicker(
                              minValue: 1,
                              maxValue: 14,
                              initialValue: onboardingData.daysIntoWait ?? 7,
                              onChanged: (value) {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setDaysIntoWait(value);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'DAYS INTO WAIT',
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
                  onPressed: () {
                    // Save to database asynchronously
                    final repository = ref.read(repositoryProvider);
                    repository.saveCycleProfile(
                      startDate: DateTime.now(),
                      cycleLength: 28,
                      ttcStatus: onboardingData.conceptionStatus,
                      ttcMethods: onboardingData.tryingMethods,
                    ).then((_) {
                      // Initialize user state with onboarding data
                      ref
                          .read(userStateProvider.notifier)
                          .initializeFromOnboarding(onboardingData.cycleDay);

                      // Navigate to home screen
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    }).catchError((error) {
                      print('Error saving cycle profile: $error');
                      // Still navigate even if save fails
                      ref
                          .read(userStateProvider.notifier)
                          .initializeFromOnboarding(onboardingData.cycleDay);

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    });
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
