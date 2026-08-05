enum ConceptionStatus {
  thinkingAboutIt('Just starting to think about it'),
  activelyTrying('Actively trying'),
  takingPause('Taking a pause right now');

  const ConceptionStatus(this.label);
  final String label;
}

enum TryingMethod {
  naturally('Naturally'),
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
  // Only asked when actively trying: whether they're tracking ovulation,
  // and - if so, and enough of the cycle has passed for it to be relevant -
  // how many days past it they are. ovulationNotYetHappened covers the case
  // where they're tracking but ovulation hasn't happened this cycle yet.
  final bool? isTrackingOvulation;
  final int? daysPastOvulation;
  final bool ovulationNotYetHappened;

  OnboardingData({
    this.cycleDay = 13,
    this.cycleDayDisclosure,
    this.conceptionStatus,
    this.tryingMethods = const [],
    this.isTrackingOvulation,
    this.daysPastOvulation,
    this.ovulationNotYetHappened = false,
  });

  /// The day actually used to seed the cycle: the picked day normally, or
  /// day 1 (a neutral default) when the user opted out of specifying one.
  int get effectiveCycleDay => cycleDayDisclosure != null ? 1 : cycleDay;

  OnboardingData copyWith({
    int? cycleDay,
    ConceptionStatus? conceptionStatus,
    List<TryingMethod>? tryingMethods,
    bool? isTrackingOvulation,
    int? daysPastOvulation,
    bool? ovulationNotYetHappened,
  }) {
    return OnboardingData(
      cycleDay: cycleDay ?? this.cycleDay,
      // Picking a specific day supersedes any earlier opt-out.
      cycleDayDisclosure: cycleDay != null ? null : cycleDayDisclosure,
      conceptionStatus: conceptionStatus ?? this.conceptionStatus,
      tryingMethods: tryingMethods ?? this.tryingMethods,
      isTrackingOvulation: isTrackingOvulation ?? this.isTrackingOvulation,
      daysPastOvulation: daysPastOvulation ?? this.daysPastOvulation,
      ovulationNotYetHappened:
          ovulationNotYetHappened ?? this.ovulationNotYetHappened,
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
      isTrackingOvulation: isTrackingOvulation,
      daysPastOvulation: daysPastOvulation,
      ovulationNotYetHappened: ovulationNotYetHappened,
    );
  }

  /// Sets the tracking-ovulation answer, resetting the follow-up question
  /// (copyWith can't null daysPastOvulation back out) since switching the
  /// answer makes any previous follow-up answer stale.
  OnboardingData withTrackingOvulation(bool value) {
    return OnboardingData(
      cycleDay: cycleDay,
      cycleDayDisclosure: cycleDayDisclosure,
      conceptionStatus: conceptionStatus,
      tryingMethods: tryingMethods,
      isTrackingOvulation: value,
      daysPastOvulation: null,
      ovulationNotYetHappened: false,
    );
  }

  /// Picks a specific days-past-ovulation count, clearing "hasn't happened
  /// yet" if that was previously picked instead.
  OnboardingData withDaysPastOvulation(int days) {
    return OnboardingData(
      cycleDay: cycleDay,
      cycleDayDisclosure: cycleDayDisclosure,
      conceptionStatus: conceptionStatus,
      tryingMethods: tryingMethods,
      isTrackingOvulation: isTrackingOvulation,
      daysPastOvulation: days,
      ovulationNotYetHappened: false,
    );
  }

  /// Picks "ovulation hasn't happened yet", clearing any day count picked
  /// instead.
  OnboardingData withOvulationNotYetHappened() {
    return OnboardingData(
      cycleDay: cycleDay,
      cycleDayDisclosure: cycleDayDisclosure,
      conceptionStatus: conceptionStatus,
      tryingMethods: tryingMethods,
      isTrackingOvulation: isTrackingOvulation,
      daysPastOvulation: null,
      ovulationNotYetHappened: true,
    );
  }

  bool get needsStep3 => conceptionStatus == ConceptionStatus.activelyTrying;

  /// Whether the "how many days past ovulation" follow-up is relevant -
  /// only once enough of the cycle has passed for it to matter.
  bool get needsDaysPastOvulationQuestion =>
      isTrackingOvulation == true && effectiveCycleDay > 9;
}
