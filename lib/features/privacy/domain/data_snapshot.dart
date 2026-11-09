import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';
import '../../period_logging/domain/period_rules.dart';

const kSnapshotApp = 'lunacycle';
const kSnapshotSchema = 1;

enum ImportMode { merge, replace }

@immutable
class ImportReport {
  const ImportReport({
    required this.periodsAdded,
    required this.daysAdded,
    required this.periodsSkipped,
    required this.daysSkipped,
  });
  final int periodsAdded;
  final int daysAdded;
  final int periodsSkipped;
  final int daysSkipped;
}

/// A validated export file. Parsing either yields this or a clear failure,
/// so a bad file can never be partially written to the database.
@immutable
class DataSnapshot {
  const DataSnapshot(this.json);

  final Map<String, dynamic> json;

  List<Map<String, dynamic>> list(String key) =>
      (json[key] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  int get periodCount => list('periods').length;
  int get dayCount => list('dailyLogs').length;
  String? get exportedAt => json['exportedAt'] as String?;

  static Never _bad(String why) => throw AppFailure(
    FailureKind.invalidImport,
    'This file cannot be imported: $why.',
  );

  static DataSnapshot parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      _bad('it is not valid JSON');
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != kSnapshotApp) {
      _bad('it is not a LunaCycle export');
    }
    final schema = decoded['schema'];
    if (schema is! int) _bad('its version is missing');
    if (schema > kSnapshotSchema) {
      _bad('it was made by a newer version of LunaCycle');
    }

    List<dynamic> section(String key) {
      final value = decoded as Map<String, dynamic>;
      final found = value[key] ?? const <dynamic>[];
      if (found is! List || found.any((e) => e is! Map<String, dynamic>)) {
        _bad('the $key section is damaged');
      }
      return found;
    }

    CalendarDate date(Object? value, String what) {
      final parsed = value is String ? CalendarDate.tryParse(value) : null;
      if (parsed == null) _bad('$what has an invalid date');
      return parsed;
    }

    final spans = <PeriodSpan>[];
    for (final raw in section('periods').cast<Map<String, dynamic>>()) {
      if (raw['id'] is! String) _bad('a period has no identifier');
      final start = date(raw['startDate'], 'a period');
      final end = raw['endDate'] == null
          ? null
          : date(raw['endDate'], 'a period');
      if (end != null && end.isBefore(start)) {
        _bad('a period ends before it starts');
      }
      spans.add(PeriodSpan(id: raw['id'] as String, start: start, end: end));
    }
    spans.sort((a, b) => a.start.compareTo(b.start));
    for (var i = 0; i + 1 < spans.length; i++) {
      final end = spans[i].end;
      if (end == null || !end.isBefore(spans[i + 1].start)) {
        _bad('it contains overlapping periods');
      }
    }

    final seenDays = <CalendarDate>{};
    for (final raw in section('dailyLogs').cast<Map<String, dynamic>>()) {
      if (raw['id'] is! String) _bad('a daily log has no identifier');
      final day = date(raw['localDate'], 'a daily log');
      if (!seenDays.add(day)) _bad('a day appears twice');
      final flow = raw['flowLevel'];
      if (flow != null && FlowLevel.tryName(flow as String?) == null) {
        _bad('a daily log has an unknown flow level');
      }
      final pain = raw['painLevel'];
      if (pain != null && (pain is! int || pain < 0 || pain > 3)) {
        _bad('a daily log has an out-of-range pain level');
      }
      final symptoms = raw['symptoms'] ?? const <String, dynamic>{};
      if (symptoms is! Map<String, dynamic> ||
          symptoms.values.any((v) => v is! int || v < 0 || v > 3)) {
        _bad('a daily log has invalid symptoms');
      }
      final moods = raw['moods'] ?? const <dynamic>[];
      if (moods is! List) _bad('a daily log has invalid moods');
    }

    for (final raw in section('temperatures').cast<Map<String, dynamic>>()) {
      date(raw['localDate'], 'a temperature');
      if (raw['temperatureCelsius'] is! num) _bad('a temperature has no value');
    }
    section('medications');
    section('medicationLogs');
    section('reminders');
    section('customSymptoms');
    return DataSnapshot(decoded);
  }
}

/// Keeps spreadsheet software from running a cell as a formula.
String csvCell(Object? value) {
  var text = value?.toString() ?? '';
  if (text.isNotEmpty && '=+-@\t\r'.contains(text[0])) text = "'$text";
  if (text.contains(RegExp('[",\n\r]'))) {
    text = '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
