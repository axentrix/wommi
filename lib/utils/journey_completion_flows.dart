import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import '../services/local_backup_storage.dart';
import '../widgets/journey_completion_dialog.dart';
import '../widgets/pregnancy_win_dialog.dart';
import '../widgets/continue_journey_question_dialog.dart';
import '../widgets/start_new_journey_day_dialog.dart';

/// The two ways a journey can end, reachable from both the Profile screen's
/// settings and the "period started / pregnancy detected" toggle on a day's
/// popup once far enough past ovulation - kept in one place so both call
/// sites stay in sync.

/// Backs up the profile and full journey history to localStorage.
Future<void> backupJourneyData(WidgetRef ref, int profileId) async {
  final userState = ref.read(userStateProvider);
  final repository = ref.read(repositoryProvider);

  if (userState.name != null && userState.email != null) {
    await LocalBackupStorage.saveUserProfile(
      profileId: profileId,
      name: userState.name!,
      email: userState.email!,
    );
  }

  final records = await repository.getJourneyRecordsForUser(profileId);
  await LocalBackupStorage.saveJourneyHistory(
    records
        .map((r) => {
              'journeyNumber': r.journeyNumber,
              'gemsCollected': r.gemsCollected,
              'startDate': r.startDate.toIso8601String(),
              'endDate': r.endDate.toIso8601String(),
            })
        .toList(),
  );
}

/// "Period started": the journey is over with no pregnancy - celebrates
/// what was done, then resets straight back to onboarding for the next one.
void showPeriodStartedFlow(BuildContext context, WidgetRef ref) {
  final userState = ref.read(userStateProvider);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => JourneyCompletionDialog(
      gemsCollected: userState.gemBalance,
      onStartNewJourney: () async {
        final profileId = userState.profileId;
        if (profileId != null) {
          await ref.read(repositoryProvider).saveJourneyRecord(
                userProfileId: profileId,
                journeyNumber: userState.currentJourneyNumber,
                gemsCollected: userState.gemBalance,
                startDate: userState.lastOpenedDate ?? DateTime.now(),
                endDate: DateTime.now(),
              );
          await backupJourneyData(ref, profileId);
        }
        await ref.read(repositoryProvider).clearJourneyProgress();
        ref.read(userStateProvider.notifier).completeCurrentJourney();
        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/landing',
          (route) => false,
        );
      },
    ),
  );
}

/// "Pregnancy detected": celebrates the win, then lets the user either keep
/// this journey going or wrap it up and pick the new journey's start day.
void showPregnancyDetectedFlow(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PregnancyWinDialog(
      onShare: () {
        Navigator.pop(context);
        _showContinueJourneyDialog(context, ref);
      },
      onNoThanks: () {
        Navigator.pop(context);
        _showContinueJourneyDialog(context, ref);
      },
    ),
  );
}

void _showContinueJourneyDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ContinueJourneyQuestionDialog(
      onContinue: () => Navigator.pop(context),
      onComplete: () {
        Navigator.pop(context);
        _showStartNewJourneyDayDialog(context, ref);
      },
    ),
  );
}

void _showStartNewJourneyDayDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StartNewJourneyDayDialog(
      onConfirm: (startDay) async {
        final userState = ref.read(userStateProvider);
        final profileId = userState.profileId;

        if (profileId != null) {
          await ref.read(repositoryProvider).saveJourneyRecord(
                userProfileId: profileId,
                journeyNumber: userState.currentJourneyNumber,
                gemsCollected: userState.gemBalance,
                startDate: userState.lastOpenedDate ?? DateTime.now(),
                endDate: DateTime.now(),
              );
          await backupJourneyData(ref, profileId);
        }

        await ref.read(repositoryProvider).clearJourneyProgress();
        ref
            .read(userStateProvider.notifier)
            .completeCurrentJourney(startDay: startDay);
        await ref.read(repositoryProvider).saveCycleProfile(
              startDate: DateTime.now().subtract(Duration(days: startDay - 1)),
              cycleLength: 28,
              ttcStatus: ref.read(onboardingProvider).conceptionStatus,
              ttcMethods: ref.read(onboardingProvider).tryingMethods,
              startingCycleDay: startDay,
            );

        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      },
    ),
  );
}
