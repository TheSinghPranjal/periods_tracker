import 'package:drift/drift.dart';

import '../utils/calendar_date.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserPreferences,
    PeriodRecords,
    DailyLogs,
    DailyMoods,
    SymptomRecords,
    CustomSymptoms,
    TemperatureRecords,
    Reminders,
    Medications,
    MedicationLogs,
    CyclePredictions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedReminders();
    },
    onUpgrade: (m, from, to) async {
      // A database written by a newer app must never be guessed at.
      if (from > to) {
        throw StateError('Unsupported database downgrade $from -> $to');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA secure_delete = ON');
    },
  );

  Future<void> _seedReminders() async {
    await batch((b) {
      b.insertAll(reminders, const [
        RemindersCompanion(id: Value('period'), type: Value('period')),
        RemindersCompanion(
          id: Value('daily'),
          type: Value('daily'),
          minutes: Value(20 * 60),
        ),
        RemindersCompanion(id: Value('fertile'), type: Value('fertile')),
      ]);
    });
  }

  /// Restores the just-created state. Used by "delete all data".
  Future<void> wipeEverything() => transaction(() async {
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
    await _seedReminders();
  });
}
