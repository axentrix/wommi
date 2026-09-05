import 'package:drift/drift.dart';
import 'database.dart';
import '../models/onboarding_state.dart';

class WommiRepository {
  final WommiDatabase _db;

  WommiRepository(this._db);

  // Cycle Profile
  Future<CycleProfile?> getCurrentCycleProfile() {
    return _db.getCurrentCycleProfile();
  }

  Future<void> saveCycleProfile({
    required DateTime startDate,
    int cycleLength = 28,
    ConceptionStatus? ttcStatus,
    List<TryingMethod>? ttcMethods,
    int? startingCycleDay,
    GenderIdentity? genderIdentity,
  }) async {
    final companion = CycleProfilesCompanion.insert(
      cycleLength: Value(cycleLength),
      startDate: startDate,
      ttcStatus: Value(ttcStatus?.name),
      ttcMethod: Value(ttcMethods?.map((m) => m.name).join(',')),
      startingCycleDay: Value(startingCycleDay),
      genderIdentity: Value(genderIdentity?.name),
    );
    await _db.createCycleProfile(companion);
  }

  /// Corrects the current journey's cycle day - unlike saveCycleProfile
  /// (which always starts a fresh journey), this updates the existing
  /// journey in place so its ritual completions, charms, and streak
  /// history stay attached instead of being orphaned under a new journey
  /// row. currentDay still advances with real calendar time from here on,
  /// exactly as it does normally - only the anchor point moves.
  Future<void> updateCycleDay(int day) async {
    final cycleProfileId = await _currentCycleProfileId();
    if (cycleProfileId == null) return;
    await _db.updateCycleProfileDay(
      cycleProfileId,
      startDate: DateTime.now().subtract(Duration(days: day - 1)),
      startingCycleDay: day,
    );
  }

  /// Records the cycle day the user says ovulation started on. Pass null to
  /// undo a mistaken mark.
  Future<void> setOvulationDay(int? day) async {
    final cycleProfileId = await _currentCycleProfileId();
    if (cycleProfileId == null) return;
    if (day == null) {
      await _db.clearOvulationDay(cycleProfileId);
    } else {
      await _db.setOvulationDay(cycleProfileId, day);
    }
  }

  /// The active journey's cycle profile id, used to scope rituals/charms so
  /// stale rows from a previous journey (e.g. left behind by a cross-tab
  /// write racing clearJourneyProgress()) can never surface in this one.
  Future<int?> _currentCycleProfileId() async {
    return (await getCurrentCycleProfile())?.id;
  }

  // Rituals
  Future<List<String>> getCompletedRitualIdsForDay(int day) async {
    final cycleProfileId = await _currentCycleProfileId();
    final completions =
        await _db.getRitualCompletionsForDay(day, cycleProfileId);
    return completions.map((c) => c.ritualId).toList();
  }

  Future<void> markRitualComplete(int cycleDay, String ritualId) async {
    final cycleProfileId = await _currentCycleProfileId();
    await _db.markRitualComplete(cycleDay, ritualId, cycleProfileId);
  }

  Future<int> getTotalRitualsCompleted() async {
    final completions = await _db.getAllRitualCompletions();
    return completions.length;
  }

  Future<Set<int>> getDaysWithRitualProgress() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getDaysWithRitualProgress(cycleProfileId);
  }

  // Charms
  Future<int> getCharmCount() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getCharmCount(cycleProfileId);
  }

  Future<void> awardCharm(
    int cycleDay,
    String charmName, {
    String rarity = 'normal',
  }) async {
    final cycleProfileId = await _currentCycleProfileId();
    await _db.awardCharm(cycleDay, charmName, cycleProfileId, rarity: rarity);
  }

  Future<bool> hasCharmForDay(int cycleDay) async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.hasCharmForDay(cycleDay, cycleProfileId);
  }

  Future<Set<int>> getDaysWithCharms() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getDaysWithCharms(cycleProfileId);
  }

  Future<List<CharmsEarnedData>> getAllCharms() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getCharmsForCycle(cycleProfileId);
  }

  /// The streak - distinct real calendar days with at least one charm
  /// earned this journey, not the raw charm count. Catching up on several
  /// past days from the journey map in one sitting still only counts as
  /// one day toward the streak.
  Future<int> getStreakDays() async {
    final dates = await _distinctCharmEarnedDates();
    return dates.length;
  }

  /// Whether a charm has already been earned today (device local time) -
  /// callers use this to decide whether awarding another charm right now
  /// should advance the streak or not.
  Future<bool> hasCharmEarnedToday() async {
    final dates = await _distinctCharmEarnedDates();
    final now = DateTime.now();
    return dates.contains(DateTime(now.year, now.month, now.day));
  }

  Future<Set<DateTime>> _distinctCharmEarnedDates() async {
    final cycleProfileId = await _currentCycleProfileId();
    final earnedAt = await _db.getCharmEarnedDates(cycleProfileId);
    return earnedAt.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  }

  /// Legendary is a once-per-journey reward - callers check this before
  /// awarding one, so a long streak or a later pregnancy detection in the
  /// same journey doesn't hand out a second.
  Future<bool> hasLegendaryCharmThisJourney() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.hasLegendaryCharm(cycleProfileId);
  }

  // User Profile
  Future<UserProfile?> getUserProfile() {
    return _db.getUserProfile();
  }

  Future<bool> isEmailTaken(String email) {
    return _db.isEmailTaken(email);
  }

  Future<int> createUserProfile(String name, String email) {
    return _db.createUserProfile(name, email);
  }

  Future<UserProfile?> getUserProfileByEmail(String email) {
    return _db.getUserProfileByEmail(email);
  }

  Future<List<UserProfile>> getAllUserProfiles() {
    return _db.getAllUserProfiles();
  }

  Future<void> deleteAllUserData(int userProfileId) {
    return _db.deleteAllUserData(userProfileId);
  }

  // Journeys
  Future<void> saveJourneyRecord({
    required int userProfileId,
    required int journeyNumber,
    required int gemsCollected,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _db.saveJourneyRecord(
      userProfileId: userProfileId,
      journeyNumber: journeyNumber,
      gemsCollected: gemsCollected,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<JourneyRecord>> getJourneyRecordsForUser(int userProfileId) {
    return _db.getJourneyRecordsForUser(userProfileId);
  }

  /// Clear all ritual completions and charms when starting a new journey
  Future<void> clearJourneyProgress() async {
    await _db.clearAllRitualCompletions();
    await _db.clearAllCharms();
  }

  /// Wipes every table, regardless of profile. Testing only.
  Future<void> resetEverything() {
    return _db.deleteEverything();
  }

  // Utility
  Future<int> calculateCurrentCycleDay() async {
    final profile = await getCurrentCycleProfile();
    if (profile == null) return 1;

    // Compare calendar dates, not raw elapsed duration - Duration.inDays
    // truncates to full 24-hour periods, so a journey started yesterday
    // evening would still show 0 days elapsed this morning even though a
    // calendar day has already passed.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(
      profile.startDate.year,
      profile.startDate.month,
      profile.startDate.day,
    );
    final daysSinceStart = today.difference(startDay).inDays;
    final cycleDay = (daysSinceStart % profile.cycleLength) + 1;
    return cycleDay;
  }

  Future<void> close() {
    return _db.close();
  }
}
