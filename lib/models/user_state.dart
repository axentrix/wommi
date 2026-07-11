import 'journey.dart';

class UserState {
  final int currentDay;
  final int cycleLength;
  final int gemBalance;
  final int streakDays;
  final List<int> completedDays;
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
      lastOpenedDate: lastOpenedDate ?? this.lastOpenedDate,
      currentJourneyNumber: currentJourneyNumber ?? this.currentJourneyNumber,
      journeyHistory: journeyHistory ?? this.journeyHistory,
      name: name ?? this.name,
      email: email ?? this.email,
      profileId: profileId ?? this.profileId,
    );
  }
}
