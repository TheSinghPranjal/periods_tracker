// Drift's table DSL refers to a column inside its own definition.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';

import '../utils/calendar_date.dart';

/// Stores date-only values as `YYYY-MM-DD` text, which sorts correctly and
/// can never shift across a timezone change.
class CalendarDateConverter extends TypeConverter<CalendarDate, String> {
  const CalendarDateConverter();

  @override
  CalendarDate fromSql(String fromDb) => CalendarDate.parse(fromDb);

  @override
  String toSql(CalendarDate value) => value.toIso();
}

@DataClassName('UserPreferencesRow')
class UserPreferences extends Table {
  IntColumn get id => integer().check(id.equals(1))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get settingsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PeriodRecord')
@TableIndex(name: 'idx_period_start', columns: {#startDate}, unique: true)
class PeriodRecords extends Table {
  TextColumn get id => text()();
  TextColumn get startDate => text().map(const CalendarDateConverter())();
  TextColumn get endDate =>
      text().map(const CalendarDateConverter()).nullable()();
  TextColumn get status => text().withDefault(const Constant('confirmed'))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (end_date IS NULL OR end_date >= start_date)',
  ];
}

@DataClassName('DailyLog')
@TableIndex(name: 'idx_daily_date', columns: {#localDate}, unique: true)
class DailyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get localDate => text().map(const CalendarDateConverter())();
  TextColumn get flowLevel => text().nullable()();
  IntColumn get painLevel =>
      integer().nullable().check(painLevel.isBetweenValues(0, 3))();
  TextColumn get notes => text().nullable()();
  TextColumn get moodNote => text().nullable()();
  TextColumn get cervicalMucus => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get sleepHours => real().nullable()();
  IntColumn get sleepQuality =>
      integer().nullable().check(sleepQuality.isBetweenValues(0, 3))();
  TextColumn get ovulationTest => text().nullable()();
  BoolColumn get sexualActivity => boolean().nullable()();
  TextColumn get protection => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MoodRecord')
class DailyMoods extends Table {
  TextColumn get dailyLogId =>
      text().references(DailyLogs, #id, onDelete: KeyAction.cascade)();
  TextColumn get mood => text()();

  @override
  Set<Column> get primaryKey => {dailyLogId, mood};
}

@DataClassName('SymptomRecord')
@TableIndex(name: 'idx_symptom_log', columns: {#dailyLogId})
class SymptomRecords extends Table {
  TextColumn get id => text()();
  TextColumn get dailyLogId =>
      text().references(DailyLogs, #id, onDelete: KeyAction.cascade)();

  /// A catalog key such as `cramps`, or `custom:<name>`.
  TextColumn get symptomType => text()();
  IntColumn get intensity => integer().check(intensity.isBetweenValues(0, 3))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {dailyLogId, symptomType},
  ];
}

@DataClassName('CustomSymptom')
class CustomSymptoms extends Table {
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {name};
}

@DataClassName('TemperatureRecord')
@TableIndex(name: 'idx_temperature_date', columns: {#localDate}, unique: true)
class TemperatureRecords extends Table {
  TextColumn get id => text()();
  TextColumn get localDate => text().map(const CalendarDateConverter())();
  RealColumn get temperatureCelsius => real()();

  /// Minutes after local midnight.
  IntColumn get measurementMinutes => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReminderRecord')
class Reminders extends Table {
  TextColumn get id => text()();

  /// `period`, `daily`, `fertile` or `custom`.
  TextColumn get type => text()();
  TextColumn get label => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get minutes => integer().withDefault(const Constant(9 * 60))();
  IntColumn get leadDays => integer().withDefault(const Constant(2))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationRecord')
class Medications extends Table {
  TextColumn get id => text()();

  /// Optional by design: a schedule can exist without naming the medication.
  TextColumn get name => text().nullable()();

  /// `daily`, `weekly` or `interval`.
  TextColumn get scheduleType => text()();

  /// Comma-separated ISO weekdays for weekly schedules.
  TextColumn get weekdays => text().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get anchorDate => text().map(const CalendarDateConverter())();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get minutes => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationLog')
@TableIndex(name: 'idx_med_log_date', columns: {#localDate})
class MedicationLogs extends Table {
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  TextColumn get localDate => text().map(const CalendarDateConverter())();

  /// `taken` or `skipped`.
  TextColumn get status => text()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {medicationId, localDate};
}

/// Calculated output only. Kept apart from every observation table.
@DataClassName('CyclePredictionRow')
class CyclePredictions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get calculatedAt => dateTime()();
  TextColumn get algorithmVersion => text()();
  TextColumn get predictedStartDate =>
      text().map(const CalendarDateConverter()).nullable()();
  TextColumn get earliestEstimatedDate =>
      text().map(const CalendarDateConverter()).nullable()();
  TextColumn get latestEstimatedDate =>
      text().map(const CalendarDateConverter()).nullable()();
  TextColumn get confidenceCategory => text()();
  IntColumn get historyCount => integer()();
}
