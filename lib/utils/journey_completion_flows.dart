import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/charm_rarity.dart';
import '../providers/user_state_provider.dart';
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
/// what was done, then lets the user pick the new journey's start day (see
/// _showStartNewJourneyDayDialog) without re-asking anything about who
/// they are, since that's unchanged from the journey that just ended.
void showPeriodStartedFlow(BuildContext context, WidgetRef ref) {
  final userState = ref.read(userStateProvider);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => JourneyCompletionDialog(
      gemsCollected: userState.gemBalance,
      onStartNewJourney: () {
        Navigator.pop(context);
        _showStartNewJourneyDayDialog(context, ref);
      },
    ),
  );
}

/// "Pregnancy detected": celebrates the win, then lets the user either keep
/// this journey going or wrap it up and pick the new journey's start day.
void showPregnancyDetectedFlow(BuildContext context, WidgetRef ref) {
  _awardPregnancyLegendaryCharm(ref);
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

/// Pregnancy is a legendary moment regardless of the day's ritual/streak
/// progress - awarded immediately on detection, once per journey (a long
/// streak might already have claimed the journey's one legendary charm).
Future<void> _awardPregnancyLegendaryCharm(WidgetRef ref) async {
  final repository = ref.read(repositoryProvider);
  if (await repository.hasLegendaryCharmThisJourney()) return;
  final userState = ref.read(userStateProvider);
  await repository.awardCharm(
    userState.currentDay,
    'pregnancy_charm',
    rarity: CharmRarity.legendary.name,
  );
  ref.read(userStateProvider.notifier).addGems(1);
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
        // Carries over gender identity and TTC status/method from the
        // journey that's ending - see saveCycleProfileForNewJourney.
        await ref.read(repositoryProvider).saveCycleProfileForNewJourney(
              startDate: DateTime.now().subtract(Duration(days: startDay - 1)),
              startingCycleDay: startDay,
            );
        ref
            .read(userStateProvider.notifier)
            .completeCurrentJourney(startDay: startDay);

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
