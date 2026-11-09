import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';
import '../../period_logging/domain/period_rules.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/data_snapshot.dart';

class DataTransferService {
  DataTransferService(this._db);
  final AppDatabase _db;

  Future<Map<String, Object?>> buildSnapshot() async {
    final periods = await _db.select(_db.periodRecords).get();
    final logs = await _db.select(_db.dailyLogs).get();
    final moods = await _db.select(_db.dailyMoods).get();
    final symptoms = await _db.select(_db.symptomRecords).get();
    final temps = await _db.select(_db.temperatureRecords).get();
    final custom = await _db.select(_db.customSymptoms).get();
    final meds = await _db.select(_db.medications).get();
    final medLogs = await _db.select(_db.medicationLogs).get();
    final reminders = await _db.select(_db.reminders).get();
    final prefs = await _db.select(_db.userPreferences).getSingleOrNull();

    return {
      'app': kSnapshotApp,
      'schema': kSnapshotSchema,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': prefs == null ? null : jsonDecode(prefs.settingsJson),
      'periods': [
        for (final p in periods)
          {
            'id': p.id,
            'startDate': p.startDate.toIso(),
            'endDate': p.endDate?.toIso(),
            'status': p.status,
            'source': p.source,
          },
      ],
      'dailyLogs': [
        for (final l in logs)
          {
            'id': l.id,
            'localDate': l.localDate.toIso(),
            'flowLevel': l.flowLevel,
            'painLevel': l.painLevel,
            'notes': l.notes,
            'moodNote': l.moodNote,
            'cervicalMucus': l.cervicalMucus,
            'weightKg': l.weightKg,
            'sleepHours': l.sleepHours,
            'sleepQuality': l.sleepQuality,
            'ovulationTest': l.ovulationTest,
            'sexualActivity': l.sexualActivity,
            'protection': l.protection,
            'moods': [
              for (final m in moods)
                if (m.dailyLogId == l.id) m.mood,
            ],
            'symptoms': {
              for (final s in symptoms)
                if (s.dailyLogId == l.id) s.symptomType: s.intensity,
            },
          },
      ],
      'temperatures': [
        for (final t in temps)
          {
            'id': t.id,
            'localDate': t.localDate.toIso(),
            'temperatureCelsius': t.temperatureCelsius,
            'measurementMinutes': t.measurementMinutes,
            'notes': t.notes,
          },
      ],
      'customSymptoms': [
        for (final c in custom) {'name': c.name},
      ],
      'medications': [
        for (final m in meds)
          {
            'id': m.id,
            'name': m.name,
            'scheduleType': m.scheduleType,
            'weekdays': m.weekdays,
            'intervalDays': m.intervalDays,
            'anchorDate': m.anchorDate.toIso(),
            'enabled': m.enabled,
            'minutes': m.minutes,
            'createdAt': m.createdAt.toUtc().toIso8601String(),
          },
      ],
      'medicationLogs': [
        for (final m in medLogs)
          {
            'medicationId': m.medicationId,
            'localDate': m.localDate.toIso(),
            'status': m.status,
            'recordedAt': m.recordedAt.toUtc().toIso8601String(),
          },
      ],
      'reminders': [
        for (final r in reminders)
          {
            'id': r.id,
            'type': r.type,
            'label': r.label,
            'enabled': r.enabled,
            'minutes': r.minutes,
            'leadDays': r.leadDays,
          },
      ],
    };
  }

  Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert(await buildSnapshot());

  /// One row per day that has any record, so it reads well in a spreadsheet.
  Future<String> exportCsv() async {
    final data = await buildSnapshot();
    final periods = (data['periods']! as List).cast<Map<String, Object?>>();
    final logs = (data['dailyLogs']! as List).cast<Map<String, Object?>>();
    final temps = (data['temperatures']! as List).cast<Map<String, Object?>>();
    final byDate = {for (final l in logs) l['localDate']! as String: l};
    final tempByDate = {for (final t in temps) t['localDate']! as String: t};
    final periodDay = <String, String>{};
    final today = CalendarDate.today();
    for (final p in periods) {
      final start = CalendarDate.parse(p['startDate']! as String);
      final endIso = p['endDate'] as String?;
      final end = endIso == null ? today : CalendarDate.parse(endIso);
      for (var d = start; d.isOnOrBefore(end); d = d.plusDays(1)) {
        periodDay[d.toIso()] = d == start ? 'period start' : 'period';
      }
    }
    final dates = {
      ...byDate.keys,
      ...tempByDate.keys,
      ...periodDay.keys,
    }.toList()..sort();
    final rows = <String>[
      'date,period,flow,pain,moods,symptoms,notes,temperature_c,weight_kg,sleep_hours',
    ];
    for (final date in dates) {
      final l = byDate[date];
      final symptoms = (l?['symptoms'] as Map<String, Object?>?) ?? const {};
      final moods = (l?['moods'] as List<Object?>?) ?? const [];
      rows.add(
        [
          date,
          periodDay[date],
          l?['flowLevel'],
          l?['painLevel'],
          moods.join('; '),
          symptoms.entries.map((e) => '${e.key}=${e.value}').join('; '),
          l?['notes'],
          tempByDate[date]?['temperatureCelsius'],
          l?['weightKg'],
          l?['sleepHours'],
        ].map(csvCell).join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }

  /// Applies a validated snapshot in one transaction: all of it or none of it.
  /// Merge keeps every existing record and reports what it left out.
  Future<ImportReport> apply(
    DataSnapshot snapshot,
    ImportMode mode,
  ) => _db.transaction(() async {
    if (mode == ImportMode.replace) {
      await _db.wipeEverything();
      final settings = snapshot.json['settings'];
      if (settings is Map<String, dynamic>) {
        final parsed = AppSettings.fromJson(
          settings.cast<String, Object?>(),
        ).patch({'onboardingCompleted': true});
        final now = DateTime.now();
        await _db
            .into(_db.userPreferences)
            .insertOnConflictUpdate(
              UserPreferencesCompanion.insert(
                id: const Value(1),
                onboardingCompleted: const Value(true),
                settingsJson: jsonEncode(parsed.toJson()),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    }

    var periodsAdded = 0, periodsSkipped = 0, daysAdded = 0, daysSkipped = 0;
    final today = CalendarDate.today();
    final existing = (await _db.select(_db.periodRecords).get())
        .map((r) => PeriodSpan(id: r.id, start: r.startDate, end: r.endDate))
        .toList();
    final now = DateTime.now();

    for (final raw in snapshot.list('periods')) {
      final start = CalendarDate.parse(raw['startDate'] as String);
      final endIso = raw['endDate'] as String?;
      final end = endIso == null ? null : CalendarDate.parse(endIso);
      final proposedEnd = end ?? today;
      final clash = existing.any(
        (o) =>
            o.id == raw['id'] ||
            (start.isOnOrBefore(o.effectiveEnd(today)) &&
                o.start.isOnOrBefore(proposedEnd)),
      );
      if (clash) {
        periodsSkipped++;
        continue;
      }
      await _db
          .into(_db.periodRecords)
          .insert(
            PeriodRecordsCompanion.insert(
              id: raw['id'] as String,
              startDate: start,
              endDate: Value(end),
              status: Value(raw['status'] as String? ?? 'confirmed'),
              source: const Value('import'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      existing.add(PeriodSpan(id: raw['id'] as String, start: start, end: end));
      periodsAdded++;
    }

    final takenDays = (await _db.select(_db.dailyLogs).get())
        .map((l) => l.localDate)
        .toSet();
    for (final raw in snapshot.list('dailyLogs')) {
      final date = CalendarDate.parse(raw['localDate'] as String);
      if (takenDays.contains(date)) {
        daysSkipped++;
        continue;
      }
      await _db
          .into(_db.dailyLogs)
          .insert(
            DailyLogsCompanion.insert(
              id: raw['id'] as String,
              localDate: date,
              flowLevel: Value(raw['flowLevel'] as String?),
              painLevel: Value(raw['painLevel'] as int?),
              notes: Value(raw['notes'] as String?),
              moodNote: Value(raw['moodNote'] as String?),
              cervicalMucus: Value(raw['cervicalMucus'] as String?),
              weightKg: Value((raw['weightKg'] as num?)?.toDouble()),
              sleepHours: Value((raw['sleepHours'] as num?)?.toDouble()),
              sleepQuality: Value(raw['sleepQuality'] as int?),
              ovulationTest: Value(raw['ovulationTest'] as String?),
              sexualActivity: Value(raw['sexualActivity'] as bool?),
              protection: Value(raw['protection'] as String?),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final mood in (raw['moods'] as List<dynamic>? ?? const [])) {
        if (MoodKind.values.any((m) => m.name == mood)) {
          await _db
              .into(_db.dailyMoods)
              .insert(
                DailyMoodsCompanion.insert(
                  dailyLogId: raw['id'] as String,
                  mood: mood as String,
                ),
              );
        }
      }
      final symptoms = raw['symptoms'] as Map<String, dynamic>? ?? const {};
      var index = 0;
      for (final s in symptoms.entries) {
        await _db
            .into(_db.symptomRecords)
            .insert(
              SymptomRecordsCompanion.insert(
                id: '${raw['id']}-${index++}',
                dailyLogId: raw['id'] as String,
                symptomType: s.key,
                intensity: s.value as int,
              ),
            );
      }
      daysAdded++;
    }

    final takenTemps = (await _db.select(_db.temperatureRecords).get())
        .map((t) => t.localDate)
        .toSet();
    for (final raw in snapshot.list('temperatures')) {
      final date = CalendarDate.parse(raw['localDate'] as String);
      if (!takenTemps.add(date)) continue;
      await _db
          .into(_db.temperatureRecords)
          .insert(
            TemperatureRecordsCompanion.insert(
              id: raw['id'] as String,
              localDate: date,
              temperatureCelsius: (raw['temperatureCelsius'] as num).toDouble(),
              measurementMinutes: Value(raw['measurementMinutes'] as int?),
              notes: Value(raw['notes'] as String?),
            ),
          );
    }

    for (final raw in snapshot.list('customSymptoms')) {
      await _db
          .into(_db.customSymptoms)
          .insertOnConflictUpdate(
            CustomSymptomsCompanion.insert(name: raw['name'] as String),
          );
    }

    for (final raw in snapshot.list('medications')) {
      await _db
          .into(_db.medications)
          .insertOnConflictUpdate(
            MedicationsCompanion.insert(
              id: raw['id'] as String,
              name: Value(raw['name'] as String?),
              scheduleType: raw['scheduleType'] as String,
              weekdays: Value(raw['weekdays'] as String?),
              intervalDays: Value(raw['intervalDays'] as int?),
              anchorDate: CalendarDate.parse(raw['anchorDate'] as String),
              enabled: Value(raw['enabled'] as bool? ?? false),
              minutes: raw['minutes'] as int,
              createdAt: DateTime.parse(raw['createdAt'] as String),
            ),
          );
    }
    for (final raw in snapshot.list('medicationLogs')) {
      await _db
          .into(_db.medicationLogs)
          .insertOnConflictUpdate(
            MedicationLogsCompanion.insert(
              medicationId: raw['medicationId'] as String,
              localDate: CalendarDate.parse(raw['localDate'] as String),
              status: raw['status'] as String,
              recordedAt: DateTime.parse(raw['recordedAt'] as String),
            ),
          );
    }
    if (mode == ImportMode.replace) {
      for (final raw in snapshot.list('reminders')) {
        await _db
            .into(_db.reminders)
            .insertOnConflictUpdate(
              RemindersCompanion.insert(
                id: raw['id'] as String,
                type: raw['type'] as String,
                label: Value(raw['label'] as String?),
                enabled: Value(raw['enabled'] as bool? ?? false),
                minutes: Value(raw['minutes'] as int? ?? 9 * 60),
                leadDays: Value(raw['leadDays'] as int? ?? 2),
              ),
            );
      }
    }
    return ImportReport(
      periodsAdded: periodsAdded,
      daysAdded: daysAdded,
      periodsSkipped: periodsSkipped,
      daysSkipped: daysSkipped,
    );
  });
}
