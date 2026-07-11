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
    state = state.copyWith(
      journeyHistory: journeyHistory,
      currentJourneyNumber: journeyHistory.length + 1,
    );
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
    // Save current journey to history if it has gems
    if (state.gemBalance > 0) {
      final completedJourney = Journey(
        journeyNumber: state.currentJourneyNumber,
        gemsCollected: state.gemBalance,
        startDate: state.lastOpenedDate ?? DateTime.now(),
        endDate: DateTime.now(),
        isActive: false,
      );

      final updatedHistory = [...state.journeyHistory, completedJourney];

      state = UserState(
        currentDay: 1,
        journeyHistory: updatedHistory,
        currentJourneyNumber: state.currentJourneyNumber + 1,
        // The profile is the user's persistent identity across journeys,
        // not journey-specific state, so it survives a reset.
        name: state.name,
        email: state.email,
        profileId: state.profileId,
      );
    } else {
      state = UserState(
        currentDay: 1,
        name: state.name,
        email: state.email,
        profileId: state.profileId,
      );
    }
  }

  void completeCurrentJourney() {
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
      currentDay: 1,
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
}

final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
