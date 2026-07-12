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
}

class RitualCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleDay => integer()();
  TextColumn get ritualId => text()();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
}

class CharmsEarned extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleDay => integer()();
  TextColumn get charmName => text()();
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();
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
  int get schemaVersion => 3;

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
        },
      );

  // Cycle Profile queries
  Future<CycleProfile?> getCurrentCycleProfile() async {
    return await (select(cycleProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> createCycleProfile(CycleProfilesCompanion profile) async {
    return await into(cycleProfiles).insert(profile);
  }

  // Ritual Completions queries
  Future<List<RitualCompletion>> getRitualCompletionsForDay(int day) async {
    return await (select(ritualCompletions)
          ..where((t) => t.cycleDay.equals(day)))
        .get();
  }

  Future<int> markRitualComplete(int cycleDay, String ritualId) async {
    return await into(ritualCompletions).insert(
      RitualCompletionsCompanion.insert(
        cycleDay: cycleDay,
        ritualId: ritualId,
      ),
    );
  }

  Future<List<RitualCompletion>> getAllRitualCompletions() async {
    return await select(ritualCompletions).get();
  }

  Future<void> clearAllRitualCompletions() async {
    await delete(ritualCompletions).go();
  }

  // Charms Earned queries
  Future<List<CharmsEarnedData>> getCharmsForCycle() async {
    return await select(charmsEarned).get();
  }

  Future<int> awardCharm(int cycleDay, String charmName) async {
    return await into(charmsEarned).insert(
      CharmsEarnedCompanion.insert(
        cycleDay: cycleDay,
        charmName: charmName,
      ),
    );
  }

  Future<int> getCharmCount() async {
    final countQuery = charmsEarned.id.count();
    final query = selectOnly(charmsEarned)..addColumns([countQuery]);
    final result = await query.getSingle();
    return result.read(countQuery) ?? 0;
  }

  Future<bool> hasCharmForDay(int cycleDay) async {
    final existing = await (select(charmsEarned)
          ..where((t) => t.cycleDay.equals(cycleDay)))
        .getSingleOrNull();
    return existing != null;
  }

  Future<void> clearAllCharms() async {
    await delete(charmsEarned).go();
  }

  // User Profile queries
  Future<UserProfile?> getUserProfile() async {
    return await (select(userProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
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
}

QueryExecutor _openConnection() {
  return WebDatabase('wommi_db');
}
