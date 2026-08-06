/// How valuable a collected charm/bead is - drives its weight/appearance
/// on the necklace.
enum CharmRarity {
  normal('Normal'),
  rare('Rare'),
  legendary('Legendary');

  const CharmRarity(this.label);
  final String label;

  /// Parses a rarity stored as a plain string (the DB column), falling
  /// back to normal for anything unrecognized - e.g. pre-migration rows
  /// that never had a rarity at all.
  static CharmRarity fromName(String name) {
    return CharmRarity.values.firstWhere(
      (r) => r.name == name,
      orElse: () => CharmRarity.normal,
    );
  }
}

/// Streak milestones that upgrade that day's daily-ritual charm from
/// normal to rare.
const rareStreakMilestones = {3, 7, 12, 14, 28};

/// Decides the rarity of the charm awarded for finishing a day's rituals.
///
/// [newStreak] is the streak value *after* this day counts - the caller
/// passes current streak + 1, since the streak hasn't been incremented yet
/// at the point this runs. Legendary is a once-per-journey reward for
/// sustaining a streak past 28 days; once it's been awarded,
/// [legendaryAlreadyAwardedThisJourney] keeps every later day (including
/// day 28 itself, which is already a rare milestone) from re-triggering it.
CharmRarity computeDailyCharmRarity({
  required int newStreak,
  required bool legendaryAlreadyAwardedThisJourney,
  required bool ovulationMarkedToday,
}) {
  if (!legendaryAlreadyAwardedThisJourney && newStreak > 28) {
    return CharmRarity.legendary;
  }
  if (ovulationMarkedToday || rareStreakMilestones.contains(newStreak)) {
    return CharmRarity.rare;
  }
  return CharmRarity.normal;
}
