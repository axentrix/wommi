import 'package:drift/drift.dart';
import 'package:drift/web.dart';

part 'database.g.dart';

// Tables
class CycleProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleLength => integer().withDefault(const Constant(28))();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get ttcStatus => text().nullable()();
  TextColumn get ttcMethod => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // The cycle day this journey was anchored at (onboarding, an edit, or a
  // fresh "start new journey" pick) - used to decide whether the ovulation
  // toggle is still relevant (it isn't, once the journey is well past the
  // fertile window).
  IntColumn get startingCycleDay => integer().nullable()();
  // The cycle day the user told us ovulation started on, via the toggle on
  // a day's popup. Null until they mark it - the app has no other way to
  // learn this.
  IntColumn get ovulationDay => integer().nullable()();
  // How the user defines themselves ('woman', 'man', 'other') - see
  // GenderIdentity. Null for pre-migration rows, treated the same as
  // 'woman' (the only kind of journey that existed before this).
  TextColumn get genderIdentity => text().nullable()();
}

class RitualCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleDay => integer()();
  TextColumn get ritualId => text()();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
  // Ties this completion to the journey it happened in, so a row that
  // survives clearJourneyProgress() (e.g. via a stale-tab write racing the
  // delete) can never bleed into a later journey's map - queries always
  // scope to the currently active cycle profile.
  IntColumn get cycleProfileId => integer().nullable()();
}

class CharmsEarned extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleDay => integer()();
  TextColumn get charmName => text()();
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();
  // See RitualCompletions.cycleProfileId.
  IntColumn get cycleProfileId => integer().nullable()();
  // 'normal', 'rare', or 'legendary' - see CharmRarity. Defaults to
  // 'normal' so pre-migration rows mean what they already meant.
  TextColumn get rarity => text().withDefault(const Constant('normal'))();
}

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Email is the user's personal identifier: unique across all local
  // profiles and only ever collected once.
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// A completed journey, permanently attributed to the user profile that
// completed it (a "journey" ends when the user marks their period as
// started). Named JourneyRecords, not Journeys, to avoid colliding with
// the in-memory Journey model in lib/models/journey.dart.
class JourneyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userProfileId => integer().references(UserProfiles, #id)();
  IntColumn get journeyNumber => integer()();
  IntColumn get gemsCollected => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    CycleProfiles,
    RitualCompletions,
    CharmsEarned,
    UserProfiles,
    JourneyRecords,
  ],
)
class WommiDatabase extends _$WommiDatabase {
  WommiDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(userProfiles);
          }
          if (from < 3) {
            await m.createTable(journeyRecords);
          }
          if (from < 4) {
            await m.addColumn(ritualCompletions, ritualCompletions.cycleProfileId);
            await m.addColumn(charmsEarned, charmsEarned.cycleProfileId);
            // Backfill: pre-migration rows weren't scoped to a journey at
            // all, so attribute them to whatever is currently the active
            // cycle profile - that's what the app already treats as "the
            // current journey" today, so nothing visible changes.
            final currentProfile = await getCurrentCycleProfile();
            if (currentProfile != null) {
              await update(ritualCompletions).write(
                RitualCompletionsCompanion(
                  cycleProfileId: Value(currentProfile.id),
                ),
              );
              await update(charmsEarned).write(
                CharmsEarnedCompanion(cycleProfileId: Value(currentProfile.id)),
              );
            }
          }
          if (from < 5) {
            await m.addColumn(cycleProfiles, cycleProfiles.startingCycleDay);
            await m.addColumn(cycleProfiles, cycleProfiles.ovulationDay);
          }
          if (from < 6) {
            await m.addColumn(charmsEarned, charmsEarned.rarity);
          }
          if (from < 7) {
            await m.addColumn(cycleProfiles, cycleProfiles.genderIdentity);
          }
        },
      );

  // Cycle Profile queries
  Future<CycleProfile?> getCurrentCycleProfile() async {
    // Ordered by id, not createdAt: createdAt only has second resolution,
    // so two profiles created within the same second (e.g. completing one
    // journey and immediately starting the next) tie and can resolve to
    // the wrong "current" profile. id is monotonically increasing and
    // never ties.
    return await (select(cycleProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> createCycleProfile(CycleProfilesCompanion profile) async {
    return await into(cycleProfiles).insert(profile);
  }

  /// Corrects the current journey's cycle day in place, unlike
  /// createCycleProfile which always starts a fresh journey row - keeps
  /// prior ritual completions, charms, and streak history (all scoped to
  /// this row's id) attached to it instead of orphaning them under a new
  /// row every time the day is edited.
  Future<void> updateCycleProfileDay(
    int cycleProfileId, {
    required DateTime startDate,
    required int startingCycleDay,
  }) async {
    await (update(cycleProfiles)..where((t) => t.id.equals(cycleProfileId)))
        .write(
      CycleProfilesCompanion(
        startDate: Value(startDate),
        startingCycleDay: Value(startingCycleDay),
      ),
    );
  }

  Future<void> setOvulationDay(int cycleProfileId, int day) async {
    await (update(cycleProfiles)..where((t) => t.id.equals(cycleProfileId)))
        .write(CycleProfilesCompanion(ovulationDay: Value(day)));
  }

  Future<void> clearOvulationDay(int cycleProfileId) async {
    await (update(cycleProfiles)..where((t) => t.id.equals(cycleProfileId)))
        .write(const CycleProfilesCompanion(ovulationDay: Value(null)));
  }

  // Ritual Completions queries - all scoped to a cycle profile (journey) so
  // a row that outlives clearJourneyProgress() can't surface in a later
  // journey. Pass the id of whatever getCurrentCycleProfile() returns.
  Future<List<RitualCompletion>> getRitualCompletionsForDay(
    int day,
    int? cycleProfileId,
  ) async {
    return await (select(ritualCompletions)
          ..where((t) =>
              t.cycleDay.equals(day) &
              t.cycleProfileId.equalsNullable(cycleProfileId)))
        .get();
  }

  Future<int> markRitualComplete(
    int cycleDay,
    String ritualId,
    int? cycleProfileId,
  ) async {
    return await into(ritualCompletions).insert(
      RitualCompletionsCompanion.insert(
        cycleDay: cycleDay,
        ritualId: ritualId,
        cycleProfileId: Value(cycleProfileId),
      ),
    );
  }

  Future<List<RitualCompletion>> getAllRitualCompletions() async {
    return await select(ritualCompletions).get();
  }

  /// Days in the given journey with at least one ritual completed, whether
  /// or not all three (and thus the day's charm) are done yet - used to
  /// show an "in progress" indicator on the journey map.
  Future<Set<int>> getDaysWithRitualProgress(int? cycleProfileId) async {
    final rows = await (select(ritualCompletions)
          ..where((t) => t.cycleProfileId.equalsNullable(cycleProfileId)))
        .get();
    return rows.map((r) => r.cycleDay).toSet();
  }

  Future<void> clearAllRitualCompletions() async {
    await delete(ritualCompletions).go();
  }

  // Charms Earned queries
  Future<List<CharmsEarnedData>> getCharmsForCycle(int? cycleProfileId) async {
    return await (select(charmsEarned)
          ..where((t) => t.cycleProfileId.equalsNullable(cycleProfileId)))
        .get();
  }

  Future<int> awardCharm(
    int cycleDay,
    String charmName,
    int? cycleProfileId, {
    String rarity = 'normal',
  }) async {
    return await into(charmsEarned).insert(
      CharmsEarnedCompanion.insert(
        cycleDay: cycleDay,
        charmName: charmName,
        cycleProfileId: Value(cycleProfileId),
        rarity: Value(rarity),
      ),
    );
  }

  /// Whether a legendary charm has already been earned in the given
  /// journey - legendary is a once-per-journey reward, so callers use this
  /// to avoid awarding a second one.
  Future<bool> hasLegendaryCharm(int? cycleProfileId) async {
    final existing = await (select(charmsEarned)
          ..where((t) =>
              t.rarity.equals('legendary') &
              t.cycleProfileId.equalsNullable(cycleProfileId)))
        .getSingleOrNull();
    return existing != null;
  }

  Future<int> getCharmCount(int? cycleProfileId) async {
    final countQuery = charmsEarned.id.count();
    final query = selectOnly(charmsEarned)
      ..addColumns([countQuery])
      ..where(charmsEarned.cycleProfileId.equalsNullable(cycleProfileId));
    final result = await query.getSingle();
    return result.read(countQuery) ?? 0;
  }

  /// The earnedAt timestamp of every charm in the given journey - used to
  /// derive the streak from distinct calendar dates rather than raw charm
  /// count, since a user can earn multiple charms (e.g. catching up on a
  /// past day from the journey map) within the same real day.
  Future<List<DateTime>> getCharmEarnedDates(int? cycleProfileId) async {
    final rows = await (select(charmsEarned)
          ..where((t) => t.cycleProfileId.equalsNullable(cycleProfileId)))
        .get();
    return rows.map((r) => r.earnedAt).toList();
  }

  /// Scoped by [charmName] as well as the day, since a single day can carry
  /// two independent charms - one from its rituals ('daily_charm'), one
  /// from its mini-game ('game_charm') - and awarding one must never block
  /// the other.
  Future<bool> hasCharmForDay(
    int cycleDay,
    int? cycleProfileId, {
    required String charmName,
  }) async {
    final existing = await (select(charmsEarned)
          ..where((t) =>
              t.cycleDay.equals(cycleDay) &
              t.charmName.equals(charmName) &
              t.cycleProfileId.equalsNullable(cycleProfileId)))
        .getSingleOrNull();
    return existing != null;
  }

  Future<void> clearAllCharms() async {
    await delete(charmsEarned).go();
  }

  /// Which cycle days already have their *rituals* charm earned in the
  /// given journey - used to mark days as completed on the journey map, so
  /// that persists across reloads instead of only living in in-memory
  /// UserState.completedDays. Scoped to [charmName] (always 'daily_charm'
  /// in practice) so a day where only the mini-game was won, not the
  /// rituals, doesn't get counted as completed too.
  Future<Set<int>> getDaysWithCharms(
    int? cycleProfileId, {
    required String charmName,
  }) async {
    final rows = await (select(charmsEarned)
          ..where((t) =>
              t.charmName.equals(charmName) &
              t.cycleProfileId.equalsNullable(cycleProfileId)))
        .get();
    return rows.map((r) => r.cycleDay).toSet();
  }

  // User Profile queries
  Future<UserProfile?> getUserProfile() async {
    // See getCurrentCycleProfile() for why id, not createdAt.
    return await (select(userProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> isEmailTaken(String email) async {
    final existing = await (select(userProfiles)
          ..where((t) => t.email.equals(email)))
        .getSingleOrNull();
    return existing != null;
  }

  Future<int> createUserProfile(String name, String email) async {
    // Normalize email to lowercase for consistent lookups
    final normalizedEmail = email.toLowerCase().trim();
    return await into(userProfiles).insert(
      UserProfilesCompanion.insert(name: name, email: normalizedEmail),
    );
  }

  Future<UserProfile?> getUserProfileByEmail(String email) async {
    // Normalize email to lowercase for consistent lookups
    final normalizedEmail = email.toLowerCase().trim();
    return await (select(userProfiles)
          ..where((t) => t.email.equals(normalizedEmail)))
        .getSingleOrNull();
  }

  Future<List<UserProfile>> getAllUserProfiles() async {
    return await select(userProfiles).get();
  }

  Future<void> deleteUserProfile(int profileId) async {
    await (delete(userProfiles)..where((t) => t.id.equals(profileId))).go();
  }

  // Journey Record queries
  Future<int> saveJourneyRecord({
    required int userProfileId,
    required int journeyNumber,
    required int gemsCollected,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await into(journeyRecords).insert(
      JourneyRecordsCompanion.insert(
        userProfileId: userProfileId,
        journeyNumber: journeyNumber,
        gemsCollected: gemsCollected,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<List<JourneyRecord>> getJourneyRecordsForUser(
    int userProfileId,
  ) async {
    return await (select(journeyRecords)
          ..where((t) => t.userProfileId.equals(userProfileId))
          ..orderBy([(t) => OrderingTerm.desc(t.endDate)]))
        .get();
  }

  Future<void> deleteJourneyRecordsForUser(int userProfileId) async {
    await (delete(journeyRecords)
          ..where((t) => t.userProfileId.equals(userProfileId)))
        .go();
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(int userProfileId) async {
    await deleteJourneyRecordsForUser(userProfileId);
    await deleteUserProfile(userProfileId);
    await clearAllRitualCompletions();
    await clearAllCharms();
  }

  /// Wipes every table, regardless of profile. For testing only - lets a
  /// tester start over from a completely clean database without needing
  /// dev tools to clear browser storage by hand.
  Future<void> deleteEverything() async {
    await delete(journeyRecords).go();
    await delete(userProfiles).go();
    await delete(cycleProfiles).go();
    await clearAllRitualCompletions();
    await clearAllCharms();
  }
}

QueryExecutor _openConnection() {
  return WebDatabase('wommi_db');
}
