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

@DriftDatabase(tables: [CycleProfiles, RitualCompletions, CharmsEarned])
class WommiDatabase extends _$WommiDatabase {
  WommiDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
}

QueryExecutor _openConnection() {
  return WebDatabase('wommi_db');
}
