class UserState {
  final int currentDay;
  final int cycleLength;
  final int gemBalance;
  final int streakDays;
  final List<int> completedDays;

  UserState({
    required this.currentDay,
    this.cycleLength = 28,
    this.gemBalance = 0,
    this.streakDays = 0,
    this.completedDays = const [],
  });

  UserState copyWith({
    int? currentDay,
    int? cycleLength,
    int? gemBalance,
    int? streakDays,
    List<int>? completedDays,
  }) {
    return UserState(
      currentDay: currentDay ?? this.currentDay,
      cycleLength: cycleLength ?? this.cycleLength,
      gemBalance: gemBalance ?? this.gemBalance,
      streakDays: streakDays ?? this.streakDays,
      completedDays: completedDays ?? this.completedDays,
    );
  }
}
