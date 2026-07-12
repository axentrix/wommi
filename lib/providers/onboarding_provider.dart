import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_state.dart';

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(OnboardingData());

  void setCycleDay(int day) {
    state = state.copyWith(cycleDay: day);
  }

  void setConceptionStatus(ConceptionStatus status) {
    state = state.copyWith(conceptionStatus: status);
  }

  void toggleTryingMethod(TryingMethod method) {
    final methods = List<TryingMethod>.from(state.tryingMethods);
    if (methods.contains(method)) {
      methods.remove(method);
    } else {
      methods.add(method);
    }
    state = state.copyWith(tryingMethods: methods);
  }

  void setDaysIntoWait(int days) {
    state = state.copyWith(daysIntoWait: days);
  }

  void reset() {
    state = OnboardingData();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  return OnboardingNotifier();
});
