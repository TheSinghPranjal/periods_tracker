import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';

/// Calendar-arithmetic product heuristic. It is not a clinically validated
/// model, and nothing in this file is ever written back as an observation.
const String kPredictionAlgorithmVersion = 'median-v1';

enum Regularity { regular, sometimesIrregular, veryIrregular, notSure }

enum PredictionConfidence { none, low, medium, high }

enum PredictionBasis { none, statedBaseline, history, manualAdjustment }

enum CyclePhase { menstrual, follicular, estimatedOvulation, luteal }

enum IntervalExclusion { duplicate, tooShort, tooLong }

@immutable
class PeriodObservation {
  const PeriodObservation({required this.start, this.end});
  final CalendarDate start;

  /// Null while the period is ongoing.
  final CalendarDate? end;
}

@immutable
class PredictionConfig {
  const PredictionConfig({
    this.historyWindow = 6,
    this.minValidCycle = 15,
    this.maxValidCycle = 90,
    this.lutealDays = 14,
    this.tightSpread = 3,
    this.moderateSpread = 7,
    this.maxBleedingDaysForAverage = 14,
    this.projectedCycles = 3,
  });

  final int historyWindow;
  final int minValidCycle;
  final int maxValidCycle;

  /// An assumption, adjustable in settings; 14 days is not universal.
  final int lutealDays;
  final int tightSpread;
  final int moderateSpread;
  final int maxBleedingDaysForAverage;
  final int projectedCycles;
}

@immutable
class PredictionInput {
  const PredictionInput({
    required this.periods,
    required this.today,
    this.usualCycleLength,
    this.usualPeriodLength,
    this.regularity = Regularity.notSure,
    this.fertilityEnabled = false,
    this.manualNextStart,
    this.config = const PredictionConfig(),
  });

  final List<PeriodObservation> periods;
  final CalendarDate today;
  final int? usualCycleLength;
  final int? usualPeriodLength;
  final Regularity regularity;
  final bool fertilityEnabled;

  /// A date the person chose themselves; only honoured after the last start.
  final CalendarDate? manualNextStart;
  final PredictionConfig config;
}

@immutable
class CycleInterval {
  const CycleInterval({
    required this.start,
    required this.nextStart,
    this.exclusion,
  });
  final CalendarDate start;
  final CalendarDate nextStart;
  final IntervalExclusion? exclusion;

  int get length => start.daysUntil(nextStart);
  bool get isValid => exclusion == null;
}

@immutable
class DateSpan {
  const DateSpan(this.first, this.last);
  final CalendarDate first;
  final CalendarDate last;

  bool contains(CalendarDate date) => date.isWithin(first, last);
  int get days => first.daysUntil(last) + 1;

  @override
  bool operator ==(Object other) =>
      other is DateSpan && other.first == first && other.last == last;

  @override
  int get hashCode => Object.hash(first, last);

  @override
  String toString() => '$first..$last';
}

@immutable
class CyclePredictionResult {
  const CyclePredictionResult({
    required this.today,
    required this.confidence,
    required this.basis,
    required this.intervals,
    required this.historyCount,
    this.lastStart,
    this.currentCycleDay,
    this.isPeriodActive = false,
    this.cycleLength,
    this.predictedStart,
    this.earliestStart,
    this.latestStart,
    this.showAsRange = false,
    this.spread,
    this.predictedPeriodLength,
    this.overdueDays = 0,
    this.projectedPeriods = const [],
    this.ovulationEstimates = const [],
    this.fertileWindows = const [],
    this.phase,
    this.highVariability = false,
    this.algorithmVersion = kPredictionAlgorithmVersion,
  });

  final CalendarDate today;
  final PredictionConfidence confidence;
  final PredictionBasis basis;
  final List<CycleInterval> intervals;

  /// Number of valid cycles inside the rolling window.
  final int historyCount;
  final CalendarDate? lastStart;
  final int? currentCycleDay;
  final bool isPeriodActive;
  final int? cycleLength;
  final CalendarDate? predictedStart;
  final CalendarDate? earliestStart;
  final CalendarDate? latestStart;

  /// True when a range should be shown instead of one confident date.
  final bool showAsRange;
  final int? spread;
  final int? predictedPeriodLength;

  /// Days since the central estimate passed without a logged period.
  final int overdueDays;
  final List<DateSpan> projectedPeriods;
  final List<CalendarDate> ovulationEstimates;
  final List<DateSpan> fertileWindows;
  final CyclePhase? phase;
  final bool highVariability;
  final String algorithmVersion;

  bool get hasPrediction => predictedStart != null;
  bool get hasPeriodHistory => lastStart != null;

  int? get daysUntilNext =>
      predictedStart == null ? null : today.daysUntil(predictedStart!);

  double? get cycleProgress {
    if (currentCycleDay == null || cycleLength == null) return null;
    return (currentCycleDay! / cycleLength!).clamp(0.0, 1.0);
  }

  bool isPredictedPeriod(CalendarDate date) =>
      projectedPeriods.any((s) => s.contains(date));

  bool isFertile(CalendarDate date) =>
      fertileWindows.any((s) => s.contains(date));

  bool isOvulationEstimate(CalendarDate date) =>
      ovulationEstimates.contains(date);
}

/// Middle value; for an even count, the mean of the middle two, rounded up.
int medianOf(Iterable<int> values) {
  final sorted = values.toList()..sort();
  if (sorted.isEmpty) throw ArgumentError('medianOf needs at least one value');
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return ((sorted[mid - 1] + sorted[mid]) / 2).ceil();
}

/// Pairs consecutive starts. Implausible gaps are flagged, never removed.
List<CycleInterval> computeIntervals(
  List<PeriodObservation> periods,
  PredictionConfig config,
) {
  final starts = periods.map((p) => p.start).toList()..sort();
  return [
    for (var i = 0; i + 1 < starts.length; i++)
      CycleInterval(
        start: starts[i],
        nextStart: starts[i + 1],
        exclusion: switch (starts[i].daysUntil(starts[i + 1])) {
          0 => IntervalExclusion.duplicate,
          final n when n < config.minValidCycle => IntervalExclusion.tooShort,
          final n when n > config.maxValidCycle => IntervalExclusion.tooLong,
          _ => null,
        },
      ),
  ];
}

/// Bleeding days of a completed period, counting both first and last day.
int periodLengthOf(CalendarDate start, CalendarDate end) =>
    start.daysUntil(end) + 1;

/// Deterministic and free of UI, database and clock access, so the same input
/// always gives the same output.
class CyclePredictionEngine {
  const CyclePredictionEngine();

  CyclePredictionResult predict(PredictionInput input) {
    final config = input.config;
    final today = input.today;
    final observed =
        input.periods.where((p) => p.start.isOnOrBefore(today)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final intervals = computeIntervals(observed, config);

    if (observed.isEmpty) {
      return CyclePredictionResult(
        today: today,
        confidence: PredictionConfidence.none,
        basis: PredictionBasis.none,
        intervals: intervals,
        historyCount: 0,
      );
    }

    final valid = intervals.where((i) => i.isValid).map((i) => i.length);
    final recent = valid.length <= config.historyWindow
        ? valid.toList()
        : valid.toList().sublist(valid.length - config.historyWindow);

    final last = observed.last;
    final lastStart = last.start;
    final cycleDay = lastStart.daysUntil(today) + 1;
    final isActive = last.end == null || today.isOnOrBefore(last.end!);
    final periodLength = _periodLength(observed, input);

    final usesHistory =
        recent.length >= 2 ||
        (recent.length == 1 && input.usualCycleLength == null);
    final int? cycleLength = usesHistory
        ? medianOf(recent)
        : input.usualCycleLength;

    if (cycleLength == null && input.manualNextStart == null) {
      return CyclePredictionResult(
        today: today,
        confidence: PredictionConfidence.none,
        basis: PredictionBasis.none,
        intervals: intervals,
        historyCount: recent.length,
        lastStart: lastStart,
        currentCycleDay: cycleDay,
        isPeriodActive: isActive,
        phase: isActive ? CyclePhase.menstrual : null,
      );
    }

    final spread = usesHistory
        ? recent.reduce(math.max) - recent.reduce(math.min)
        : null;
    final confidence = _confidence(
      recent.length,
      spread,
      usesHistory,
      input.regularity,
      config,
    );
    final highVariability =
        (spread ?? 0) > config.moderateSpread ||
        input.regularity == Regularity.veryIrregular;

    final manual = input.manualNextStart;
    final useManual = manual != null && manual.isAfter(lastStart);
    final effectiveLength = useManual
        ? lastStart.daysUntil(manual)
        : cycleLength;
    if (effectiveLength == null) {
      return CyclePredictionResult(
        today: today,
        confidence: PredictionConfidence.none,
        basis: PredictionBasis.none,
        intervals: intervals,
        historyCount: recent.length,
        lastStart: lastStart,
        currentCycleDay: cycleDay,
        isPeriodActive: isActive,
        phase: isActive ? CyclePhase.menstrual : null,
      );
    }

    final predicted = lastStart.plusDays(effectiveLength);
    // A manual date moves only the next period; later ones keep the usual gap.
    final repeatLength = cycleLength ?? effectiveLength;
    late CalendarDate earliest;
    late CalendarDate latest;
    if (usesHistory && !useManual) {
      final minLen = recent.reduce(math.min);
      final maxLen = recent.reduce(math.max);
      earliest = lastStart.plusDays(math.min(minLen, effectiveLength - 1));
      latest = lastStart.plusDays(math.max(maxLen, effectiveLength + 1));
    } else {
      final half = switch (input.regularity) {
        Regularity.regular => 3,
        Regularity.sometimesIrregular => 5,
        Regularity.notSure => 5,
        Regularity.veryIrregular => 7,
      };
      earliest = predicted.minusDays(half);
      latest = predicted.plusDays(half);
    }

    final overdue = today.isAfter(predicted) && !isActive
        ? predicted.daysUntil(today)
        : 0;

    final projections = _project(
      predicted: predicted,
      today: today,
      cycleLength: repeatLength,
      periodLength: periodLength,
      count: config.projectedCycles,
    );

    final ovulations = <CalendarDate>[];
    final windows = <DateSpan>[];
    if (input.fertilityEnabled && overdue == 0) {
      for (var i = 0; i < projections.length; i++) {
        final start = predicted.plusDays(repeatLength * i);
        final previousStart = i == 0
            ? lastStart
            : predicted.plusDays(repeatLength * (i - 1));
        final widen = i == 0 ? earliest.daysUntil(predicted) : 0;
        final widenLate = i == 0 ? predicted.daysUntil(latest) : 0;
        final ovulation = start.minusDays(config.lutealDays);
        if (ovulation.isOnOrBefore(previousStart)) continue;
        var first = ovulation.minusDays(5 + widen);
        final lastDay = ovulation.plusDays(1 + widenLate);
        if (first.isOnOrBefore(previousStart)) {
          first = previousStart.plusDays(1);
        }
        ovulations.add(ovulation);
        windows.add(DateSpan(first, lastDay));
      }
    }

    return CyclePredictionResult(
      today: today,
      confidence: useManual ? PredictionConfidence.low : confidence,
      basis: useManual
          ? PredictionBasis.manualAdjustment
          : usesHistory
          ? PredictionBasis.history
          : PredictionBasis.statedBaseline,
      intervals: intervals,
      historyCount: recent.length,
      lastStart: lastStart,
      currentCycleDay: cycleDay,
      isPeriodActive: isActive,
      cycleLength: effectiveLength,
      predictedStart: predicted,
      earliestStart: earliest,
      latestStart: latest,
      showAsRange: confidence != PredictionConfidence.high || useManual,
      spread: spread,
      predictedPeriodLength: periodLength,
      overdueDays: overdue,
      projectedPeriods: projections,
      ovulationEstimates: ovulations,
      fertileWindows: windows,
      highVariability: highVariability,
      phase: _phase(
        today: today,
        isActive: isActive,
        predicted: predicted,
        latest: latest,
        lutealDays: config.lutealDays,
        fertilityEnabled: input.fertilityEnabled,
      ),
    );
  }

  int? _periodLength(List<PeriodObservation> observed, PredictionInput input) {
    final completed = observed
        .where((p) => p.end != null)
        .map((p) => periodLengthOf(p.start, p.end!))
        .where((n) => n >= 1 && n <= input.config.maxBleedingDaysForAverage)
        .toList();
    if (completed.length >= 2) {
      final start = math.max(0, completed.length - input.config.historyWindow);
      return medianOf(completed.sublist(start));
    }
    return input.usualPeriodLength ??
        (completed.isEmpty ? null : completed.first);
  }

  PredictionConfidence _confidence(
    int count,
    int? spread,
    bool usesHistory,
    Regularity regularity,
    PredictionConfig config,
  ) {
    if (!usesHistory || count < 3 || spread == null) {
      return PredictionConfidence.low;
    }
    var result = spread <= config.tightSpread
        ? PredictionConfidence.high
        : spread <= config.moderateSpread
        ? PredictionConfidence.medium
        : PredictionConfidence.low;
    if (regularity == Regularity.veryIrregular) {
      result = PredictionConfidence.low;
    } else if (regularity == Regularity.sometimesIrregular &&
        result == PredictionConfidence.high) {
      result = PredictionConfidence.medium;
    }
    return result;
  }

  List<DateSpan> _project({
    required CalendarDate predicted,
    required CalendarDate today,
    required int cycleLength,
    required int? periodLength,
    required int count,
  }) {
    // Without a known period length only the expected first day is marked,
    // rather than inventing a duration.
    final days = periodLength ?? 1;
    final spans = <DateSpan>[];
    for (var i = 0; i < count; i++) {
      final nominal = predicted.plusDays(cycleLength * i);
      final start = i == 0 && nominal.isBefore(today) ? today : nominal;
      spans.add(DateSpan(start, start.plusDays(days - 1)));
    }
    return spans;
  }

  CyclePhase? _phase({
    required CalendarDate today,
    required bool isActive,
    required CalendarDate predicted,
    required CalendarDate latest,
    required int lutealDays,
    required bool fertilityEnabled,
  }) {
    if (isActive) return CyclePhase.menstrual;
    // Once the whole estimated range has passed, any phase would be a guess.
    if (today.isAfter(latest)) return null;
    final ovulation = predicted.minusDays(lutealDays);
    final distance = ovulation.daysUntil(today);
    if (fertilityEnabled && distance.abs() <= 1) {
      return CyclePhase.estimatedOvulation;
    }
    return distance < 0 ? CyclePhase.follicular : CyclePhase.luteal;
  }
}
