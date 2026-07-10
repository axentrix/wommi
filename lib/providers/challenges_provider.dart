import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier() : super([]);

  void generateChallengesForDay(int day) {
    final templates = ChallengeTemplates.getChallengesForDay(day);
    state = templates
        .asMap()
        .entries
        .map((entry) => Challenge(
              id: 'day_${day}_challenge_${entry.key}',
              icon: entry.value['icon']!,
              title: entry.value['title']!,
              description: entry.value['description']!,
              day: day,
            ))
        .toList();
  }

  void toggleChallenge(String challengeId) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        return challenge.copyWith(isCompleted: !challenge.isCompleted);
      }
      return challenge;
    }).toList();
  }

  bool get allCompleted {
    return state.isNotEmpty && state.every((c) => c.isCompleted);
  }

  int get completedCount {
    return state.where((c) => c.isCompleted).length;
  }

  int get totalCount {
    return state.length;
  }
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  return ChallengesNotifier();
});
