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

  // Rituals
  Future<List<String>> getCompletedRitualIdsForDay(int day) async {
    final completions = await _db.getRitualCompletionsForDay(day);
    return completions.map((c) => c.ritualId).toList();
  }

  Future<void> markRitualComplete(int cycleDay, String ritualId) async {
    await _db.markRitualComplete(cycleDay, ritualId);
  }

  Future<int> getTotalRitualsCompleted() async {
    final completions = await _db.getAllRitualCompletions();
    return completions.length;
  }

  // Charms
  Future<int> getCharmCount() {
    return _db.getCharmCount();
  }

  Future<void> awardCharm(int cycleDay, String charmName) async {
    await _db.awardCharm(cycleDay, charmName);
  }

  Future<bool> hasCharmForDay(int cycleDay) {
    return _db.hasCharmForDay(cycleDay);
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
