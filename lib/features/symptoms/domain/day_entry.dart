import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';

/// Everything recorded for one calendar day.
@immutable
class DayEntry {
  const DayEntry({
    required this.date,
    this.log,
    this.moods = const {},
    this.symptoms = const {},
    this.temperature,
  });

  final CalendarDate date;
  final DailyLog? log;
  final Set<MoodKind> moods;

  /// Symptom key to intensity (0-3).
  final Map<String, int> symptoms;
  final TemperatureRecord? temperature;

  FlowLevel? get flow => FlowLevel.tryName(log?.flowLevel);
  String? get notes => log?.notes;
  int? get pain => log?.painLevel;
  bool get hasNote => (log?.notes ?? '').trim().isNotEmpty;
  bool get hasSymptoms => symptoms.isNotEmpty;

  bool get isEmpty =>
      log == null && moods.isEmpty && symptoms.isEmpty && temperature == null;

  /// Shown as the small calendar dot.
  bool get hasMarker =>
      hasSymptoms || hasNote || moods.isNotEmpty || pain != null;
}

abstract interface class DailyLogRepository {
  Stream<DayEntry> watchDay(CalendarDate date);

  /// Inclusive range; null bounds are open.
  Stream<List<DayEntry>> watchRange({CalendarDate? from, CalendarDate? to});
  Future<List<DayEntry>> getRange({CalendarDate? from, CalendarDate? to});
  Stream<List<String>> watchCustomSymptoms();
  Future<void> addCustomSymptom(String name);
  Future<void> patch(CalendarDate date, DailyLogsCompanion changes);
  Future<void> setMoods(CalendarDate date, Set<MoodKind> moods);
  Future<void> setSymptom(CalendarDate date, String key, int? intensity);
  Future<void> setTemperature(
    CalendarDate date,
    double? celsius, {
    int? minutes,
    String? notes,
  });

  /// Returns what was removed, so the action can be undone.
  Future<DayEntry> deleteDay(CalendarDate date);
  Future<void> restoreDay(DayEntry entry);
}

const clearValue = Value<String?>(null);
