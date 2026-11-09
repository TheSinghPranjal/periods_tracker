import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';
import '../domain/day_entry.dart';

class DriftDailyLogRepository implements DailyLogRepository {
  DriftDailyLogRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<void> get _anyChange => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _db.dailyLogs,
          _db.dailyMoods,
          _db.symptomRecords,
          _db.temperatureRecords,
        },
      )
      .watch()
      .map((_) {});

  @override
  Stream<DayEntry> watchDay(CalendarDate date) =>
      _anyChange.asyncMap((_) async {
        final found = await getRange(from: date, to: date);
        return found.isEmpty ? DayEntry(date: date) : found.first;
      });

  @override
  Stream<List<DayEntry>> watchRange({CalendarDate? from, CalendarDate? to}) =>
      _anyChange.asyncMap((_) => getRange(from: from, to: to));

  @override
  Future<List<DayEntry>> getRange({
    CalendarDate? from,
    CalendarDate? to,
  }) async {
    final fromIso = from?.toIso() ?? '0000-01-01';
    final toIso = to?.toIso() ?? '9999-12-31';
    final logQuery = _db.select(_db.dailyLogs)
      ..where(
        (t) => t.localDate.isBetween(
          Constant(fromIso).dartCast(),
          Constant(toIso).dartCast(),
        ),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.localDate)]);
    final logs = await logQuery.get();
    final temps =
        await (_db.select(_db.temperatureRecords)..where(
              (t) => t.localDate.isBetween(
                Constant(fromIso).dartCast(),
                Constant(toIso).dartCast(),
              ),
            ))
            .get();
    final ids = logs.map((l) => l.id).toList();
    final moods = ids.isEmpty
        ? const <MoodRecord>[]
        : await (_db.select(
            _db.dailyMoods,
          )..where((t) => t.dailyLogId.isIn(ids))).get();
    final symptoms = ids.isEmpty
        ? const <SymptomRecord>[]
        : await (_db.select(
            _db.symptomRecords,
          )..where((t) => t.dailyLogId.isIn(ids))).get();

    final moodMap = <String, Set<MoodKind>>{};
    for (final m in moods) {
      for (final kind in MoodKind.values) {
        if (kind.name == m.mood) (moodMap[m.dailyLogId] ??= {}).add(kind);
      }
    }
    final symptomMap = <String, Map<String, int>>{};
    for (final s in symptoms) {
      (symptomMap[s.dailyLogId] ??= {})[s.symptomType] = s.intensity;
    }
    final tempMap = {for (final t in temps) t.localDate: t};

    final dates = {...logs.map((l) => l.localDate), ...tempMap.keys}.toList()
      ..sort();
    final logMap = {for (final l in logs) l.localDate: l};
    return [
      for (final date in dates)
        DayEntry(
          date: date,
          log: logMap[date],
          moods: moodMap[logMap[date]?.id] ?? const {},
          symptoms: symptomMap[logMap[date]?.id] ?? const {},
          temperature: tempMap[date],
        ),
    ];
  }

  @override
  Stream<List<String>> watchCustomSymptoms() => _db
      .select(_db.customSymptoms)
      .watch()
      .map((r) => r.map((e) => e.name).toList()..sort());

  @override
  Future<void> addCustomSymptom(String name) => _db
      .into(_db.customSymptoms)
      .insertOnConflictUpdate(
        CustomSymptomsCompanion.insert(name: name.trim()),
      );

  Future<String> _ensureLog(CalendarDate date) async {
    final existing = await (_db.select(
      _db.dailyLogs,
    )..where((t) => t.localDate.equalsValue(date))).getSingleOrNull();
    if (existing != null) return existing.id;
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.dailyLogs)
        .insert(
          DailyLogsCompanion.insert(
            id: id,
            localDate: date,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  /// A row with nothing left in it would otherwise read as "logged".
  Future<void> _pruneIfEmpty(String id) async {
    final log = await (_db.select(
      _db.dailyLogs,
    )..where((t) => t.id.equals(id))).getSingle();
    final hasContent =
        log.flowLevel != null ||
        log.painLevel != null ||
        (log.notes ?? '').isNotEmpty ||
        (log.moodNote ?? '').isNotEmpty ||
        log.cervicalMucus != null ||
        log.weightKg != null ||
        log.sleepHours != null ||
        log.sleepQuality != null ||
        log.ovulationTest != null ||
        log.sexualActivity != null ||
        log.protection != null;
    if (hasContent) return;
    final moods = await (_db.select(
      _db.dailyMoods,
    )..where((t) => t.dailyLogId.equals(id))).get();
    final symptoms = await (_db.select(
      _db.symptomRecords,
    )..where((t) => t.dailyLogId.equals(id))).get();
    if (moods.isEmpty && symptoms.isEmpty) {
      await (_db.delete(_db.dailyLogs)..where((t) => t.id.equals(id))).go();
    }
  }

  @override
  Future<void> patch(CalendarDate date, DailyLogsCompanion changes) =>
      _db.transaction(() async {
        final id = await _ensureLog(date);
        await (_db.update(_db.dailyLogs)..where((t) => t.id.equals(id))).write(
          changes.copyWith(updatedAt: Value(DateTime.now())),
        );
        await _pruneIfEmpty(id);
      });

  @override
  Future<void> setMoods(CalendarDate date, Set<MoodKind> moods) =>
      _db.transaction(() async {
        final id = await _ensureLog(date);
        await (_db.delete(
          _db.dailyMoods,
        )..where((t) => t.dailyLogId.equals(id))).go();
        for (final mood in moods) {
          await _db
              .into(_db.dailyMoods)
              .insert(
                DailyMoodsCompanion.insert(dailyLogId: id, mood: mood.name),
              );
        }
        await _pruneIfEmpty(id);
      });

  @override
  Future<void> setSymptom(CalendarDate date, String key, int? intensity) =>
      _db.transaction(() async {
        final id = await _ensureLog(date);
        await (_db.delete(_db.symptomRecords)..where(
              (t) => t.dailyLogId.equals(id) & t.symptomType.equals(key),
            ))
            .go();
        if (intensity != null) {
          await _db
              .into(_db.symptomRecords)
              .insert(
                SymptomRecordsCompanion.insert(
                  id: _uuid.v4(),
                  dailyLogId: id,
                  symptomType: key,
                  intensity: intensity,
                ),
              );
        }
        await _pruneIfEmpty(id);
      });

  @override
  Future<void> setTemperature(
    CalendarDate date,
    double? celsius, {
    int? minutes,
    String? notes,
  }) => _db.transaction(() async {
    await (_db.delete(
      _db.temperatureRecords,
    )..where((t) => t.localDate.equalsValue(date))).go();
    if (celsius != null) {
      await _db
          .into(_db.temperatureRecords)
          .insert(
            TemperatureRecordsCompanion.insert(
              id: _uuid.v4(),
              localDate: date,
              temperatureCelsius: celsius,
              measurementMinutes: Value(minutes),
              notes: Value(notes),
            ),
          );
    }
  });

  @override
  Future<DayEntry> deleteDay(CalendarDate date) => _db.transaction(() async {
    final found = await getRange(from: date, to: date);
    await (_db.delete(
      _db.dailyLogs,
    )..where((t) => t.localDate.equalsValue(date))).go();
    await (_db.delete(
      _db.temperatureRecords,
    )..where((t) => t.localDate.equalsValue(date))).go();
    return found.isEmpty ? DayEntry(date: date) : found.first;
  });

  @override
  Future<void> restoreDay(DayEntry entry) => _db.transaction(() async {
    final log = entry.log;
    if (log != null) {
      await _db.into(_db.dailyLogs).insertOnConflictUpdate(log);
      for (final mood in entry.moods) {
        await _db
            .into(_db.dailyMoods)
            .insertOnConflictUpdate(
              DailyMoodsCompanion.insert(dailyLogId: log.id, mood: mood.name),
            );
      }
      for (final s in entry.symptoms.entries) {
        await _db
            .into(_db.symptomRecords)
            .insert(
              SymptomRecordsCompanion.insert(
                id: _uuid.v4(),
                dailyLogId: log.id,
                symptomType: s.key,
                intensity: s.value,
              ),
            );
      }
    }
    final temperature = entry.temperature;
    if (temperature != null) {
      await _db
          .into(_db.temperatureRecords)
          .insertOnConflictUpdate(temperature);
    }
  });
}
