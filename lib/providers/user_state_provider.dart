import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_state.dart';
import '../models/journey.dart';
import '../models/onboarding_state.dart';

class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState(currentDay: 0));

  void initializeFromOnboarding(int cycleDay, {GenderIdentity? genderIdentity}) {
    state = state.copyWith(
      currentDay: cycleDay,
      startingCycleDay: cycleDay,
      lastOpenedDate: DateTime.now(),
      genderIdentity: genderIdentity,
    );
  }

  /// Restores the personal identifier (name/email) collected during a
  /// previous session. Email is only ever collected once per device.
  void hydrateProfile(int profileId, String name, String email) {
    state = state.copyWith(profileId: profileId, name: name, email: email);
  }

  /// Restores past completed journeys (loaded from the database) that
  /// belong to the current profile.
  void hydrateJourneyHistory(List<Journey> journeyHistory) {
    if (journeyHistory.isEmpty) return;
    // Next journey number must continue from the highest one seen, not
    // from the count of records - if a journey was ever lost (e.g. an old
    // bug that dropped 0-gem journeys), the count would be lower than the
    // highest existing number, and the next journey would silently reuse
    // and collide with an already-completed journey's number.
    final highestJourneyNumber = journeyHistory
        .map((j) => j.journeyNumber)
        .reduce((a, b) => a > b ? a : b);
    state = state.copyWith(
      journeyHistory: journeyHistory,
      currentJourneyNumber: highestJourneyNumber + 1,
    );
  }

  /// Restores the currently *in-progress* journey's live progress (cycle
  /// day and gems earned so far). Completed journeys are recorded in
  /// JourneyRecords via hydrateJourneyHistory, but the active, not-yet-
  /// completed journey has no record of its own - without this, a
  /// returning user's day/gem progress would appear to reset to 0 even
  /// though they're recognized and their past journeys load correctly.
  void hydrateActiveJourney({
    required int currentDay,
    required int gemBalance,
    required int streakDays,
    int? startingCycleDay,
    int? ovulationDay,
    GenderIdentity? genderIdentity,
  }) {
    state = state
        .copyWith(
          currentDay: currentDay,
          gemBalance: gemBalance,
          streakDays: streakDays,
          startingCycleDay: startingCycleDay,
          genderIdentity: genderIdentity,
        )
        .withOvulationDay(ovulationDay);
  }

  /// Restores which cycle days already have their missions completed, so
  /// the journey map's checkmarks survive a reload instead of only living
  /// in memory for the current session.
  void hydrateCompletedDays(Set<int> days) {
    if (days.isEmpty) return;
    state = state.copyWith(completedDays: days.toList());
  }

  /// Restores which cycle days have partial (but not full) progress, so
  /// the journey map's "in progress" indicator survives a reload too.
  void hydrateInProgressDays(Set<int> days) {
    if (days.isEmpty) return;
    state = state.copyWith(inProgressDays: days.toList());
  }

  /// Marks that at least one challenge has been done for [day] without all
  /// three being complete yet. Harmless to call again once the day is
  /// fully completed - completedDays takes visual priority over this.
  void markDayInProgress(int day) {
    if (!state.inProgressDays.contains(day)) {
      state = state.copyWith(inProgressDays: [...state.inProgressDays, day]);
    }
  }

  /// Records (or, passing null, undoes) the cycle day the user says
  /// ovulation started on. Only the in-memory side - callers also persist
  /// via the repository so it survives a reload.
  void markOvulationDay(int? day) {
    state = state.withOvulationDay(day);
  }

  void addGems(int amount) {
    state = state.copyWith(gemBalance: state.gemBalance + amount);
  }

  /// Marks [day]'s node complete on the journey map. Doesn't touch the
  /// streak - a real calendar day can contain several of these (e.g.
  /// catching up on past days), see setStreakDays().
  void completeDay(int day) {
    if (!state.completedDays.contains(day)) {
      state = state.copyWith(completedDays: [...state.completedDays, day]);
    }
  }

  /// Sets the streak to a value the caller already computed from real
  /// calendar dates (repository.getStreakDays()) - the streak only ever
  /// advances once per astronomical day, regardless of how many day-nodes
  /// get completed within it.
  void setStreakDays(int days) {
    state = state.copyWith(streakDays: days);
  }

  /// Marks [day]'s mini-game as actually won - a second, independent charm
  /// from the day's 3 rituals. Idempotent, same as completeDay().
  void markDailyGameComplete(int day) {
    if (!state.dailyGameCompletedDays.contains(day)) {
      state = state.copyWith(
        dailyGameCompletedDays: [...state.dailyGameCompletedDays, day],
      );
    }
  }

  /// Marks [day]'s mini-game as played, win or lose - a day only gets one
  /// attempt, so this is what locks DailyGameScreen out of offering it
  /// again (see UserState.dailyGamePlayedDays).
  void markDailyGamePlayed(int day) {
    if (!state.dailyGamePlayedDays.contains(day)) {
      state = state.copyWith(
        dailyGamePlayedDays: [...state.dailyGamePlayedDays, day],
      );
    }
  }

  void advanceDay() {
    final nextDay = state.currentDay < state.cycleLength
        ? state.currentDay + 1
        : 1;
    state = state.copyWith(currentDay: nextDay);
  }

  void completeCurrentJourney({int startDay = 1}) {
    // Save current journey to history
    final completedJourney = Journey(
      journeyNumber: state.currentJourneyNumber,
      gemsCollected: state.gemBalance,
      startDate: state.lastOpenedDate ?? DateTime.now(),
      endDate: DateTime.now(),
      isActive: false,
    );

    final updatedHistory = [...state.journeyHistory, completedJourney];

    // Start new journey
    state = state
        .copyWith(
          currentDay: startDay,
          gemBalance: 0,
          streakDays: 0,
          completedDays: [],
          inProgressDays: [],
          journeyHistory: updatedHistory,
          currentJourneyNumber: state.currentJourneyNumber + 1,
          lastOpenedDate: DateTime.now(),
          startingCycleDay: startDay,
        )
        .withOvulationDay(null);
  }

  void setProfile(int profileId, String name, String email) {
    state = state.copyWith(profileId: profileId, name: name, email: email);
  }

  void updateCurrentDay(int day, {int? startingCycleDay}) {
    state = state.copyWith(currentDay: day, startingCycleDay: startingCycleDay);
  }

  /// Full reset for testing - wipes everything in memory, including
  /// profile/journey history. Unlike completeCurrentJourney(), which
  /// intentionally preserves those across a legitimate "start new journey".
  void hardReset() {
    state = UserState(currentDay: 0);
  }
}

final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
