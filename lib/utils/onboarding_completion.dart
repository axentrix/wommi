import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_state.dart';
import '../providers/repository_provider.dart';
import '../providers/user_state_provider.dart';

/// Saves the TTC questionnaire answers and continues to the profile step -
/// shared by whichever screen ends up being last in the "actively trying"
/// branch (the tracking-ovulation screen when no follow-up is needed, or
/// the days-past-ovulation screen when it is).
Future<void> completeTtcOnboarding(
  BuildContext context,
  WidgetRef ref,
  OnboardingData onboardingData,
) async {
  final repository = ref.read(repositoryProvider);
  try {
    await repository.saveCycleProfile(
      // Back-date so "today" lands on the cycle day the user actually
      // picked, not day 1 - this is what calculateCurrentCycleDay() uses
      // to restore the right day on a later login.
      startDate: DateTime.now()
          .subtract(Duration(days: onboardingData.effectiveCycleDay - 1)),
      cycleLength: 28,
      ttcStatus: onboardingData.conceptionStatus,
      ttcMethods: onboardingData.tryingMethods,
      startingCycleDay: onboardingData.effectiveCycleDay,
    );
  } catch (error) {
    print('Error saving cycle profile: $error');
    // Still continue even if save fails.
  }

  ref
      .read(userStateProvider.notifier)
      .initializeFromOnboarding(onboardingData.effectiveCycleDay);
  await _applyOvulationAnswer(ref, onboardingData);
  if (!context.mounted) return;

  Navigator.of(context).pushNamed('/onboarding-profile');
}

/// If they gave a specific days-past-ovulation answer, seed
/// UserState.ovulationDay from it directly - so the journey map already
/// reflects it instead of asking them to set the toggle again themselves.
/// A no-op if they're not tracking, said ovulation hasn't happened yet,
/// or didn't answer.
Future<void> _applyOvulationAnswer(
  WidgetRef ref,
  OnboardingData onboardingData,
) async {
  final daysPast = onboardingData.daysPastOvulation;
  if (onboardingData.isTrackingOvulation != true ||
      onboardingData.ovulationNotYetHappened ||
      daysPast == null) {
    return;
  }
  final ovulationDay =
      (onboardingData.effectiveCycleDay - daysPast).clamp(1, 33);
  ref.read(userStateProvider.notifier).markOvulationDay(ovulationDay);
  await ref.read(repositoryProvider).setOvulationDay(ovulationDay);
}
