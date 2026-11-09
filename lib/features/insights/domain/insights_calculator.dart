import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';
import '../../period_logging/domain/period_rules.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';
import '../../symptoms/domain/day_entry.dart';
import '../../symptoms/domain/symptom_catalog.dart';

@immutable
class CycleSummary {
  const CycleSummary({
    required this.period,
    this.nextStart,
    this.cycleLength,
    this.periodLength,
    this.topSymptoms = const [],
    this.notesCount = 0,
  });
  final PeriodSpan period;
  final CalendarDate? nextStart;
  final int? cycleLength;
  final int? periodLength;
  final List<String> topSymptoms;
  final int notesCount;
}

@immutable
class SeriesPoint {
  const SeriesPoint(this.date, this.value);
  final CalendarDate date;
  final double value;
}

@immutable
class CountEntry {
  const CountEntry(this.key, this.label, this.count);
  final String key;
  final String label;
  final int count;
}

@immutable
class InsightsData {
  const InsightsData({
    required this.cycles,
    required this.recordedCycles,
    this.averageCycle,
    this.averagePeriod,
    this.shortestCycle,
    this.longestCycle,
    this.variability,
    this.cycleSeries = const [],
    this.periodSeries = const [],
    this.painSeries = const [],
    this.flowSeries = const [],
    this.temperatureSeries = const [],
    this.weightSeries = const [],
    this.sleepSeries = const [],
    this.symptomCounts = const [],
    this.moodCounts = const [],
    this.statements = const [],
  });

  final List<CycleSummary> cycles;
  final int recordedCycles;
  final double? averageCycle;
  final double? averagePeriod;
  final int? shortestCycle;
  final int? longestCycle;
  final int? variability;
  final List<SeriesPoint> cycleSeries;
  final List<SeriesPoint> periodSeries;
  final List<SeriesPoint> painSeries;
  final List<SeriesPoint> flowSeries;
  final List<SeriesPoint> temperatureSeries;
  final List<SeriesPoint> weightSeries;
  final List<SeriesPoint> sleepSeries;
  final List<CountEntry> symptomCounts;
  final List<CountEntry> moodCounts;
  final List<String> statements;
}

const _words = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
];
String _count(int n) => n <= 10 ? _words[n] : '$n';

double? _mean(List<int> values) =>
    values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;

/// Describes saved data only. It never interprets it clinically; a missing
/// statistic stays null rather than being filled with a default.
InsightsData computeInsights({
  required List<PeriodSpan> periods,
  required List<DayEntry> days,
  required CalendarDate today,
  int? monthsBack,
  PredictionConfig config = const PredictionConfig(),
}) {
  final from = monthsBack == null ? null : today.plusMonths(-monthsBack);
  final sorted = [...periods]..sort((a, b) => a.start.compareTo(b.start));

  final allCycles = <CycleSummary>[];
  for (var i = 0; i < sorted.length; i++) {
    final period = sorted[i];
    final next = i + 1 < sorted.length ? sorted[i + 1].start : null;
    final span = next == null ? null : period.start.daysUntil(next);
    final valid =
        span != null &&
        span >= config.minValidCycle &&
        span <= config.maxValidCycle;
    final last = next?.minusDays(1) ?? today;
    final inCycle = days.where((d) => d.date.isWithin(period.start, last));
    final tally = <String, int>{};
    for (final d in inCycle) {
      for (final s in d.symptoms.entries.where((e) => e.value > 0)) {
        tally[s.key] = (tally[s.key] ?? 0) + 1;
      }
    }
    final ranked = tally.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    allCycles.add(
      CycleSummary(
        period: period,
        nextStart: next,
        cycleLength: valid ? span : null,
        periodLength: period.end == null
            ? null
            : periodLengthOf(period.start, period.end!),
        topSymptoms: ranked.take(3).map((e) => symptomLabel(e.key)).toList(),
        notesCount: inCycle.where((d) => d.hasNote).length,
      ),
    );
  }

  final cycles = from == null
      ? allCycles
      : allCycles.where((c) => c.period.start.isOnOrAfter(from)).toList();
  final lengths = cycles.map((c) => c.cycleLength).whereType<int>().toList();
  final bleeding = cycles
      .map((c) => c.periodLength)
      .whereType<int>()
      .where((n) => n <= config.maxBleedingDaysForAverage)
      .toList();
  final recentDays = from == null
      ? days
      : days.where((d) => d.date.isOnOrAfter(from)).toList();

  final symptomTally = <String, int>{};
  final moodTally = <MoodKind, int>{};
  for (final d in recentDays) {
    for (final s in d.symptoms.entries.where((e) => e.value > 0)) {
      symptomTally[s.key] = (symptomTally[s.key] ?? 0) + 1;
    }
    for (final m in d.moods) {
      moodTally[m] = (moodTally[m] ?? 0) + 1;
    }
  }
  final symptomCounts =
      symptomTally.entries
          .map((e) => CountEntry(e.key, symptomLabel(e.key), e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
  final moodCounts = [
    for (final m in MoodKind.values)
      if (moodTally.containsKey(m)) CountEntry(m.name, m.label, moodTally[m]!),
  ];

  final statements = <String>[];
  final lastThree = lengths.length >= 3
      ? lengths.sublist(lengths.length - 3)
      : const <int>[];
  if (lastThree.isNotEmpty) {
    final low = lastThree.reduce(math.min);
    final high = lastThree.reduce(math.max);
    statements.add(
      low == high
          ? 'Your last three recorded cycles were each $low days long.'
          : 'Your last three recorded cycles ranged from $low to $high days.',
    );
  }
  if (bleeding.length >= 2) {
    final mean = _mean(bleeding)!.round();
    statements.add(
      'Your recorded periods have lasted about $mean days on average.',
    );
  }
  final thisMonth = days.where((d) => d.date.isSameMonth(today));
  final monthTally = <String, int>{};
  for (final d in thisMonth) {
    for (final s in d.symptoms.entries.where((e) => e.value > 0)) {
      monthTally[s.key] = (monthTally[s.key] ?? 0) + 1;
    }
  }
  if (monthTally.isNotEmpty) {
    final top = monthTally.entries.reduce((a, b) => b.value > a.value ? b : a);
    final n = top.value;
    statements.add(
      'You logged ${symptomLabel(top.key).toLowerCase()} on ${_count(n)} ${n == 1 ? 'day' : 'days'} this month.',
    );
  }

  return InsightsData(
    cycles: cycles,
    recordedCycles: lengths.length,
    averageCycle: _mean(lengths),
    averagePeriod: _mean(bleeding),
    shortestCycle: lengths.isEmpty ? null : lengths.reduce(math.min),
    longestCycle: lengths.isEmpty ? null : lengths.reduce(math.max),
    variability: lengths.length < 2
        ? null
        : lengths.reduce(math.max) - lengths.reduce(math.min),
    cycleSeries: [
      for (final c in cycles)
        if (c.cycleLength != null)
          SeriesPoint(c.period.start, c.cycleLength!.toDouble()),
    ],
    periodSeries: [
      for (final c in cycles)
        if (c.periodLength != null)
          SeriesPoint(c.period.start, c.periodLength!.toDouble()),
    ],
    painSeries: [
      for (final d in recentDays)
        if (d.pain != null) SeriesPoint(d.date, d.pain!.toDouble()),
    ],
    flowSeries: [
      for (final d in recentDays)
        if (d.flow != null) SeriesPoint(d.date, d.flow!.level.toDouble()),
    ],
    temperatureSeries: [
      for (final d in recentDays)
        if (d.temperature != null)
          SeriesPoint(d.date, d.temperature!.temperatureCelsius),
    ],
    weightSeries: [
      for (final d in recentDays)
        if (d.log?.weightKg != null) SeriesPoint(d.date, d.log!.weightKg!),
    ],
    sleepSeries: [
      for (final d in recentDays)
        if (d.log?.sleepHours != null) SeriesPoint(d.date, d.log!.sleepHours!),
    ],
    symptomCounts: symptomCounts,
    moodCounts: moodCounts,
    statements: statements,
  );
}
