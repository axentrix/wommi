import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_state.dart';
import '../models/journey.dart';

class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState(currentDay: 0));

  void initializeFromOnboarding(int cycleDay) {
    state = state.copyWith(
      currentDay: cycleDay,
      lastOpenedDate: DateTime.now(),
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
  void hydrateActiveJourney({required int currentDay, required int gemBalance}) {
    state = state.copyWith(currentDay: currentDay, gemBalance: gemBalance);
  }

  /// Restores which cycle days already have their missions completed, so
  /// the journey map's checkmarks survive a reload instead of only living
  /// in memory for the current session.
  void hydrateCompletedDays(Set<int> days) {
    if (days.isEmpty) return;
    state = state.copyWith(completedDays: days.toList());
  }

  void addGems(int amount) {
    state = state.copyWith(gemBalance: state.gemBalance + amount);
  }

  void completeDay(int day) {
    if (!state.completedDays.contains(day)) {
      final completed = [...state.completedDays, day];
      state = state.copyWith(
        completedDays: completed,
        streakDays: state.streakDays + 1,
      );
    }
  }

  void advanceDay() {
    final nextDay = state.currentDay < state.cycleLength
        ? state.currentDay + 1
        : 1;
    state = state.copyWith(currentDay: nextDay);
  }

  void updateDaysSinceLastOpen() {
    if (state.lastOpenedDate == null) {
      // If no last opened date, just update it to now
      state = state.copyWith(lastOpenedDate: DateTime.now());
      return;
    }

    final now = DateTime.now();
    final lastOpened = state.lastOpenedDate!;
    final daysPassed = now.difference(lastOpened).inDays;

    if (daysPassed > 0) {
      // Calculate new current day accounting for cycle wrapping
      int newDay = state.currentDay + daysPassed;

      // Handle cycle wrapping (28-day cycle)
      while (newDay > state.cycleLength) {
        newDay -= state.cycleLength;
      }

      state = state.copyWith(
        currentDay: newDay,
        lastOpenedDate: now,
      );
    } else {
      // Same day, just update the timestamp
      state = state.copyWith(lastOpenedDate: now);
    }
  }

  void resetState() {
    print('[UserState] Resetting state - preserving ${state.journeyHistory.length} past journeys');
    // Always preserve journey history and profile across resets
    // (the actual journey saving to database happens in the UI layer before calling this)
    state = UserState(
      currentDay: 1,
      journeyHistory: state.journeyHistory,
      currentJourneyNumber: state.currentJourneyNumber + 1,
      // The profile is the user's persistent identity across journeys,
      // not journey-specific state, so it survives a reset.
      name: state.name,
      email: state.email,
      profileId: state.profileId,
    );
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
    state = state.copyWith(
      currentDay: startDay,
      gemBalance: 0,
      completedDays: [],
      journeyHistory: updatedHistory,
      currentJourneyNumber: state.currentJourneyNumber + 1,
      lastOpenedDate: DateTime.now(),
    );
  }

  void setProfile(int profileId, String name, String email) {
    state = state.copyWith(profileId: profileId, name: name, email: email);
  }

  void updateCurrentDay(int day) {
    state = state.copyWith(currentDay: day);
  }

  /// Full reset for testing - wipes everything in memory, including
  /// profile/journey history. Unlike resetState(), which intentionally
  /// preserves those across a legitimate "start new journey".
  void hardReset() {
    state = UserState(currentDay: 0);
  }
}

final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
