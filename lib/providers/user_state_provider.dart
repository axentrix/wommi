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
      );
    } else {
      state = UserState(currentDay: 1);
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

  void setProfile(String name, String email) {
    state = state.copyWith(name: name, email: email);
  }

  void updateCurrentDay(int day) {
    state = state.copyWith(currentDay: day);
  }
}

final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
