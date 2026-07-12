import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/choice_button.dart';

class OnboardingConceptionScreen extends ConsumerWidget {
  const OnboardingConceptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);
    final selectedStatus = onboardingData.conceptionStatus;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Text(
                      'STEP 2 OF 3',
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
                      'Are you currently\ntrying to conceive?',
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
                      'Nothing here is shared — it just shapes which rituals we bring you.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        height: 1.55,
                        color: WommiColors.inkDim,
                      ),
                    ),
                    const SizedBox(height: 26),
                    // Choice list
                    Column(
                      children: ConceptionStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ChoiceButton(
                            text: status.label,
                            isSelected: selectedStatus == status,
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
            ),
            // Footer with button
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 26),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedStatus == null
                      ? null
                      : () {
                          // Navigate based on selection
                          if (onboardingData.needsStep3) {
                            Navigator.of(context).pushNamed('/onboarding-step3');
                          } else {
                            // Save to database asynchronously
                            final repository = ref.read(repositoryProvider);
                            repository.saveCycleProfile(
                              // Back-date so "today" lands on the cycle day
                              // the user actually picked, not day 1 - this
                              // is what calculateCurrentCycleDay() uses to
                              // restore the right day on a later login.
                              startDate: DateTime.now()
                                  .subtract(Duration(days: onboardingData.cycleDay - 1)),
                              cycleLength: 28,
                              ttcStatus: onboardingData.conceptionStatus,
                            ).then((_) {
                              // Initialize user state and go to home
                              ref
                                  .read(userStateProvider.notifier)
                                  .initializeFromOnboarding(onboardingData.cycleDay);

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
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedStatus == null
                        ? WommiColors.line
                        : WommiColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: selectedStatus == null ? 0 : 14,
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
