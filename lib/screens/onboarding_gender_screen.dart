import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/choice_button.dart';
import '../utils/onboarding_completion.dart';

/// The very first onboarding question, asked before anything about cycles
/// or conception - it decides whether those even come up. A man or someone
/// who identifies otherwise skips straight to a day-1 journey with none of
/// that asked (see completeNonCycleOnboarding); a woman continues into the
/// existing cycle-day/conception flow unchanged.
class OnboardingGenderScreen extends ConsumerWidget {
  const OnboardingGenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(onboardingProvider);
    final selected = onboardingData.genderIdentity;

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
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Text(
                      'GETTING STARTED',
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
                      'How do you define\nyourself?',
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
                      'This decides which questions make sense to ask you next.',
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
                      children: GenderIdentity.values.map((identity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ChoiceButton(
                            text: identity.label,
                            isSelected: selected == identity,
                            onTap: () {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .setGenderIdentity(identity);
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
                  onPressed: selected == null
                      ? null
                      : () => _continue(context, ref, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selected == null ? WommiColors.line : WommiColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: selected == null ? 0 : 14,
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

  Future<void> _continue(
    BuildContext context,
    WidgetRef ref,
    GenderIdentity selected,
  ) async {
    if (selected == GenderIdentity.woman) {
      Navigator.of(context).pushNamed('/onboarding');
      return;
    }
    // Man or Other: no cycle/ovulation questions apply, so skip the whole
    // existing flow and start the journey from day 1 directly.
    await completeNonCycleOnboarding(context, ref, ref.read(onboardingProvider));
  }
}
