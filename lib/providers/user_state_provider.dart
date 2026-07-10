import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_state.dart';

class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState(currentDay: 1));

  void initializeFromOnboarding(int cycleDay) {
    state = state.copyWith(currentDay: cycleDay);
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
}

final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
