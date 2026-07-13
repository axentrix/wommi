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
  }) async {
    final companion = CycleProfilesCompanion.insert(
      cycleLength: Value(cycleLength),
      startDate: startDate,
      ttcStatus: Value(ttcStatus?.name),
      ttcMethod: Value(ttcMethods?.map((m) => m.name).join(',')),
    );
    await _db.createCycleProfile(companion);
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

  // Charms
  Future<int> getCharmCount() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getCharmCount(cycleProfileId);
  }

  Future<void> awardCharm(int cycleDay, String charmName) async {
    final cycleProfileId = await _currentCycleProfileId();
    await _db.awardCharm(cycleDay, charmName, cycleProfileId);
  }

  Future<bool> hasCharmForDay(int cycleDay) async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.hasCharmForDay(cycleDay, cycleProfileId);
  }

  Future<Set<int>> getDaysWithCharms() async {
    final cycleProfileId = await _currentCycleProfileId();
    return _db.getDaysWithCharms(cycleProfileId);
  }

  Future<List<CharmsEarnedData>> getAllCharms() {
    return _db.getCharmsForCycle();
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

    final daysSinceStart = DateTime.now().difference(profile.startDate).inDays;
    final cycleDay = (daysSinceStart % profile.cycleLength) + 1;
    return cycleDay;
  }

  Future<void> close() {
    return _db.close();
  }
}
