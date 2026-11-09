import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/prediction/domain/cycle_prediction_engine.dart';

const engine = CyclePredictionEngine();

List<PeriodObservation> startsEvery(
  CalendarDate first,
  List<int> gaps, {
  int days = 5,
}) {
  final out = <PeriodObservation>[];
  var start = first;
  out.add(PeriodObservation(start: start, end: start.plusDays(days - 1)));
  for (final gap in gaps) {
    start = start.plusDays(gap);
    out.add(PeriodObservation(start: start, end: start.plusDays(days - 1)));
  }
  return out;
}

void main() {
  final today = CalendarDate(2025, 6, 20);

  test('median handles odd and even counts', () {
    expect(medianOf([30, 26, 28]), 28);
    expect(medianOf([26, 28, 30, 32]), 29);
    expect(medianOf([27, 28]), 28);
  });

  test('no data gives no prediction and no invented dates', () {
    final r = engine.predict(
      PredictionInput(periods: const [], today: today, usualCycleLength: 28),
    );
    expect(r.hasPrediction, isFalse);
    expect(r.confidence, PredictionConfidence.none);
    expect(r.currentCycleDay, isNull);
  });

  test('first-ever period without a baseline never fabricates a date', () {
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2025, 6, 10),
            end: CalendarDate(2025, 6, 14),
          ),
        ],
        today: today,
      ),
    );
    expect(r.hasPrediction, isFalse);
    expect(r.currentCycleDay, 11);
  });

  test('first period with stated baseline is low confidence and a range', () {
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2025, 6, 10),
            end: CalendarDate(2025, 6, 14),
          ),
        ],
        today: today,
        usualCycleLength: 30,
        regularity: Regularity.regular,
      ),
    );
    expect(r.predictedStart, CalendarDate(2025, 7, 10));
    expect(r.confidence, PredictionConfidence.low);
    expect(r.basis, PredictionBasis.statedBaseline);
    expect(r.showAsRange, isTrue);
    expect(r.earliestStart, CalendarDate(2025, 7, 7));
    expect(r.latestStart, CalendarDate(2025, 7, 13));
  });

  test('two confirmed starts without a baseline use the single interval', () {
    final r = engine.predict(
      PredictionInput(
        periods: startsEvery(CalendarDate(2025, 5, 10), [31]),
        today: today,
      ),
    );
    expect(r.cycleLength, 31);
    expect(r.confidence, PredictionConfidence.low);
    expect(r.basis, PredictionBasis.history);
  });

  test('regular cycles use the median, high confidence, single date', () {
    final r = engine.predict(
      PredictionInput(
        periods: startsEvery(CalendarDate(2025, 1, 1), [28, 29, 28, 27, 28]),
        today: CalendarDate(2025, 5, 30),
      ),
    );
    expect(r.cycleLength, 28);
    expect(r.spread, 2);
    expect(r.confidence, PredictionConfidence.high);
    expect(r.showAsRange, isFalse);
    expect(r.predictedStart, CalendarDate(2025, 1, 1).plusDays(140 + 28));
    expect(r.historyCount, 5);
  });

  test('irregular cycles lower confidence and give a range', () {
    final first = CalendarDate(2025, 1, 1);
    final r = engine.predict(
      PredictionInput(
        periods: startsEvery(first, [24, 38, 27, 41]),
        today: first.plusDays(135),
      ),
    );
    expect(r.spread, 17);
    expect(r.confidence, PredictionConfidence.low);
    expect(r.highVariability, isTrue);
    expect(r.showAsRange, isTrue);
    final lastStart = first.plusDays(130);
    expect(r.earliestStart, lastStart.plusDays(24));
    expect(r.latestStart, lastStart.plusDays(41));
  });

  test(
    'stated "very irregular" caps confidence even when history is tight',
    () {
      final r = engine.predict(
        PredictionInput(
          periods: startsEvery(CalendarDate(2025, 1, 1), [28, 28, 28, 28]),
          today: CalendarDate(2025, 5, 10),
          regularity: Regularity.veryIrregular,
        ),
      );
      expect(r.confidence, PredictionConfidence.low);
    },
  );

  test('rolling window uses only the most recent cycles', () {
    final r = engine.predict(
      PredictionInput(
        periods: startsEvery(CalendarDate(2024, 1, 1), [
          40,
          40,
          40,
          40,
          28,
          28,
          28,
        ]),
        today: CalendarDate(2024, 9, 1),
        config: const PredictionConfig(historyWindow: 3),
      ),
    );
    expect(r.cycleLength, 28);
    expect(r.historyCount, 3);
  });

  test('implausible gaps are flagged and ignored, never removed', () {
    final first = CalendarDate(2024, 1, 1);
    final periods = startsEvery(first, [28, 200, 8, 28, 28]);
    final r = engine.predict(
      PredictionInput(periods: periods, today: first.plusDays(300)),
    );
    expect(r.intervals.length, 5);
    expect(r.intervals[1].exclusion, IntervalExclusion.tooLong);
    expect(r.intervals[2].exclusion, IntervalExclusion.tooShort);
    expect(r.historyCount, 3);
    expect(r.cycleLength, 28);
  });

  test('duplicate start dates are excluded', () {
    final d = CalendarDate(2025, 1, 1);
    final intervals = computeIntervals([
      PeriodObservation(start: d),
      PeriodObservation(start: d),
    ], const PredictionConfig());
    expect(intervals.single.exclusion, IntervalExclusion.duplicate);
  });

  test('editing a start date changes the prediction', () {
    final first = CalendarDate(2025, 1, 1);
    final before = engine.predict(
      PredictionInput(
        periods: startsEvery(first, [28, 28, 28]),
        today: first.plusDays(90),
      ),
    );
    final edited = startsEvery(first, [28, 28, 32]);
    final after = engine.predict(
      PredictionInput(periods: edited, today: first.plusDays(95)),
    );
    expect(after.predictedStart, isNot(before.predictedStart));
  });

  test('deleting the latest period recalculates from the previous one', () {
    final first = CalendarDate(2025, 1, 1);
    final all = startsEvery(first, [28, 28, 28]);
    final fewer = all.sublist(0, 3);
    final r = engine.predict(
      PredictionInput(periods: fewer, today: first.plusDays(60)),
    );
    expect(r.lastStart, first.plusDays(56));
  });

  test('prediction crosses a leap day correctly', () {
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2024, 2, 10),
            end: CalendarDate(2024, 2, 14),
          ),
        ],
        today: CalendarDate(2024, 2, 20),
        usualCycleLength: 28,
      ),
    );
    expect(r.predictedStart, CalendarDate(2024, 3, 9));
  });

  test('overdue period is reported and never marks past days as predicted', () {
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2025, 5, 1),
            end: CalendarDate(2025, 5, 5),
          ),
        ],
        today: CalendarDate(2025, 6, 5),
        usualCycleLength: 28,
      ),
    );
    expect(r.overdueDays, 7);
    expect(r.projectedPeriods.first.first, CalendarDate(2025, 6, 5));
    expect(r.isPredictedPeriod(CalendarDate(2025, 5, 29)), isFalse);
  });

  test('ongoing period counts as active and shows menstrual phase', () {
    final r = engine.predict(
      PredictionInput(
        periods: [PeriodObservation(start: CalendarDate(2025, 6, 18))],
        today: today,
        usualCycleLength: 28,
      ),
    );
    expect(r.isPeriodActive, isTrue);
    expect(r.phase, CyclePhase.menstrual);
    expect(r.currentCycleDay, 3);
    expect(r.overdueDays, 0);
  });

  test('fertility estimates are absent unless enabled', () {
    final input = PredictionInput(
      periods: startsEvery(CalendarDate(2025, 1, 1), [28, 28, 28, 28]),
      today: CalendarDate(2025, 5, 3),
    );
    final r = engine.predict(input);
    expect(r.fertileWindows, isEmpty);
    expect(r.ovulationEstimates, isEmpty);
  });

  test('ovulation uses the configurable luteal assumption', () {
    final periods = startsEvery(CalendarDate(2025, 1, 1), [28, 28, 28, 28]);
    final a = engine.predict(
      PredictionInput(
        periods: periods,
        today: CalendarDate(2025, 5, 3),
        fertilityEnabled: true,
      ),
    );
    final b = engine.predict(
      PredictionInput(
        periods: periods,
        today: CalendarDate(2025, 5, 3),
        fertilityEnabled: true,
        config: const PredictionConfig(lutealDays: 12),
      ),
    );
    final predicted = a.predictedStart!;
    expect(a.ovulationEstimates.first, predicted.minusDays(14));
    expect(b.ovulationEstimates.first, predicted.minusDays(12));
    expect(a.fertileWindows.first.last, a.ovulationEstimates.first.plusDays(2));
  });

  test('fertile window never reaches back into the previous period start', () {
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2025, 6, 1),
            end: CalendarDate(2025, 6, 3),
          ),
        ],
        today: CalendarDate(2025, 6, 4),
        usualCycleLength: 21,
        fertilityEnabled: true,
      ),
    );
    expect(
      r.fertileWindows.first.first.isAfter(CalendarDate(2025, 6, 1)),
      isTrue,
    );
  });

  test('manual adjustment replaces the central estimate and is labelled', () {
    final r = engine.predict(
      PredictionInput(
        periods: startsEvery(CalendarDate(2025, 1, 1), [28, 28, 28, 28]),
        today: CalendarDate(2025, 5, 3),
        manualNextStart: CalendarDate(2025, 6, 2),
      ),
    );
    expect(r.predictedStart, CalendarDate(2025, 6, 2));
    expect(r.basis, PredictionBasis.manualAdjustment);
    expect(r.confidence, PredictionConfidence.low);
  });

  test('period length excludes long bleeding episodes from the average', () {
    final first = CalendarDate(2025, 1, 1);
    final r = engine.predict(
      PredictionInput(
        periods: [
          PeriodObservation(start: first, end: first.plusDays(4)),
          PeriodObservation(
            start: first.plusDays(28),
            end: first.plusDays(28 + 24),
          ),
          PeriodObservation(start: first.plusDays(56), end: first.plusDays(60)),
        ],
        today: first.plusDays(70),
      ),
    );
    expect(r.predictedPeriodLength, 5);
  });

  test('is deterministic', () {
    PredictionInput input() => PredictionInput(
      periods: startsEvery(CalendarDate(2025, 1, 1), [27, 31, 29]),
      today: CalendarDate(2025, 4, 10),
      usualCycleLength: 28,
      fertilityEnabled: true,
    );
    final a = engine.predict(input());
    final b = engine.predict(input());
    expect(a.predictedStart, b.predictedStart);
    expect(a.fertileWindows, b.fertileWindows);
  });
}
