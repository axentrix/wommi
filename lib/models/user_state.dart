import 'journey.dart';

class UserState {
  final int currentDay;
  final int cycleLength;
  final int gemBalance;
  final int streakDays;
  final List<int> completedDays;
  // Days with at least one challenge done but not all three yet - shown as
  // an "in progress" indicator on the journey map, distinct from a fully
  // completed day (in completedDays) or an untouched one.
  final List<int> inProgressDays;
  final DateTime? lastOpenedDate;
  final int currentJourneyNumber;
  final List<Journey> journeyHistory;
  final String? name;
  final String? email;
  final int? profileId;

  UserState({
    required this.currentDay,
    this.cycleLength = 28,
    this.gemBalance = 0,
    this.streakDays = 0,
    this.completedDays = const [],
    this.inProgressDays = const [],
    this.lastOpenedDate,
    this.currentJourneyNumber = 1,
    this.journeyHistory = const [],
    this.name,
    this.email,
    this.profileId,
  });

  bool get hasProfile => name != null && email != null;

  UserState copyWith({
    int? currentDay,
    int? cycleLength,
    int? gemBalance,
    int? streakDays,
    List<int>? completedDays,
    List<int>? inProgressDays,
    DateTime? lastOpenedDate,
    int? currentJourneyNumber,
    List<Journey>? journeyHistory,
    String? name,
    String? email,
    int? profileId,
  }) {
    return UserState(
      currentDay: currentDay ?? this.currentDay,
      cycleLength: cycleLength ?? this.cycleLength,
      gemBalance: gemBalance ?? this.gemBalance,
      streakDays: streakDays ?? this.streakDays,
      completedDays: completedDays ?? this.completedDays,
      inProgressDays: inProgressDays ?? this.inProgressDays,
      lastOpenedDate: lastOpenedDate ?? this.lastOpenedDate,
      currentJourneyNumber: currentJourneyNumber ?? this.currentJourneyNumber,
      journeyHistory: journeyHistory ?? this.journeyHistory,
      name: name ?? this.name,
      email: email ?? this.email,
      profileId: profileId ?? this.profileId,
    );
  }
}
