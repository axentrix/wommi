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

class OnboardingData {
  final int cycleDay;
  final ConceptionStatus? conceptionStatus;
  final List<TryingMethod> tryingMethods;
  final int? daysIntoWait;

  OnboardingData({
    this.cycleDay = 13,
    this.conceptionStatus,
    this.tryingMethods = const [],
    this.daysIntoWait,
  });

  OnboardingData copyWith({
    int? cycleDay,
    ConceptionStatus? conceptionStatus,
    List<TryingMethod>? tryingMethods,
    int? daysIntoWait,
  }) {
    return OnboardingData(
      cycleDay: cycleDay ?? this.cycleDay,
      conceptionStatus: conceptionStatus ?? this.conceptionStatus,
      tryingMethods: tryingMethods ?? this.tryingMethods,
      daysIntoWait: daysIntoWait ?? this.daysIntoWait,
    );
  }

  bool get needsStep3 {
    return conceptionStatus == ConceptionStatus.activelyTrying ||
        conceptionStatus == ConceptionStatus.twoWeekWait;
  }
}
