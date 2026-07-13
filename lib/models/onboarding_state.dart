enum ConceptionStatus {
  thinkingAboutIt('Just starting to think about it'),
  activelyTrying('Actively trying'),
  twoWeekWait('In the two-week wait'),
  takingPause('Taking a pause right now');

  const ConceptionStatus(this.label);
  final String label;
}

enum TryingMethod {
  naturally('Naturally'),
  trackingOvulation('Tracking ovulation'),
  iui('IUI'),
  ivf('IVF'),
  anotherPath('Another path');

  const TryingMethod(this.label);
  final String label;
}

/// Lets a user opt out of picking a specific cycle day on the first
/// onboarding screen, instead of being forced to scroll to some number
/// that isn't true for them.
enum CycleDayDisclosure {
  preferNotToSay('Prefer not to say'),
  irrelevant('Irrelevant');

  const CycleDayDisclosure(this.label);
  final String label;
}

class OnboardingData {
  final int cycleDay;
  final CycleDayDisclosure? cycleDayDisclosure;
  final ConceptionStatus? conceptionStatus;
  final List<TryingMethod> tryingMethods;
  final int? daysIntoWait;

  OnboardingData({
    this.cycleDay = 13,
    this.cycleDayDisclosure,
    this.conceptionStatus,
    this.tryingMethods = const [],
    this.daysIntoWait,
  });

  /// The day actually used to seed the cycle: the picked day normally, or
  /// day 1 (a neutral default) when the user opted out of specifying one.
  int get effectiveCycleDay => cycleDayDisclosure != null ? 1 : cycleDay;

  OnboardingData copyWith({
    int? cycleDay,
    ConceptionStatus? conceptionStatus,
    List<TryingMethod>? tryingMethods,
    int? daysIntoWait,
  }) {
    return OnboardingData(
      cycleDay: cycleDay ?? this.cycleDay,
      // Picking a specific day supersedes any earlier opt-out.
      cycleDayDisclosure: cycleDay != null ? null : cycleDayDisclosure,
      conceptionStatus: conceptionStatus ?? this.conceptionStatus,
      tryingMethods: tryingMethods ?? this.tryingMethods,
      daysIntoWait: daysIntoWait ?? this.daysIntoWait,
    );
  }

  /// Sets or clears (pass null) the opt-out choice directly - copyWith
  /// can't null out cycleDayDisclosure since it treats null as "keep the
  /// current value".
  OnboardingData withCycleDayDisclosure(CycleDayDisclosure? disclosure) {
    return OnboardingData(
      cycleDay: cycleDay,
      cycleDayDisclosure: disclosure,
      conceptionStatus: conceptionStatus,
      tryingMethods: tryingMethods,
      daysIntoWait: daysIntoWait,
    );
  }

  bool get needsStep3 {
    return conceptionStatus == ConceptionStatus.activelyTrying ||
        conceptionStatus == ConceptionStatus.twoWeekWait;
  }
}
