import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/calendar/domain/day_visual.dart';
import 'package:periods_tracker/features/insights/domain/insights_calculator.dart';
import 'package:periods_tracker/features/period_logging/domain/period_rules.dart';
import 'package:periods_tracker/features/prediction/domain/cycle_prediction_engine.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';
import 'package:periods_tracker/features/symptoms/domain/day_entry.dart';

void main() {
  final today = CalendarDate(2025, 6, 20);

  List<PeriodSpan> periods(List<int> gaps, {CalendarDate? first}) {
    var start = first ?? CalendarDate(2025, 1, 1);
    final out = <PeriodSpan>[];
    for (var i = 0; i <= gaps.length; i++) {
      out.add(PeriodSpan(id: '$i', start: start, end: start.plusDays(4)));
      if (i < gaps.length) start = start.plusDays(gaps[i]);
    }
    return out;
  }

  group('insights', () {
    test('no data yields no invented statistics', () {
      final d = computeInsights(
        periods: const [],
        days: const [],
        today: today,
      );
      expect(d.averageCycle, isNull);
      expect(d.shortestCycle, isNull);
      expect(d.variability, isNull);
      expect(d.statements, isEmpty);
      expect(d.recordedCycles, 0);
    });

    test('computes descriptive statistics from recorded cycles', () {
      final d = computeInsights(
        periods: periods([27, 31, 29]),
        days: const [],
        today: today,
      );
      expect(d.recordedCycles, 3);
      expect(d.averageCycle, 29);
      expect(d.shortestCycle, 27);
      expect(d.longestCycle, 31);
      expect(d.variability, 4);
      expect(
        d.statements.first,
        'Your last three recorded cycles ranged from 27 to 31 days.',
      );
    });

    test('counts logged symptom days in plain words', () {
      final days = [
        for (var i = 0; i < 4; i++)
          DayEntry(
            date: CalendarDate(2025, 6, 3 + i),
            symptoms: const {'cramps': 2},
          ),
      ];
      final d = computeInsights(periods: const [], days: days, today: today);
      expect(
        d.statements,
        contains('You logged cramps on four days this month.'),
      );
    });

    test('statements never diagnose or quote risk percentages', () {
      final d = computeInsights(
        periods: periods([24, 41, 22]),
        days: [
          DayEntry(date: today, symptoms: const {'cramps': 3}),
        ],
        today: today,
      );
      final all = d.statements.join(' ').toLowerCase();
      for (final banned in [
        'pcos',
        'abnormal',
        '%',
        'chance',
        'diagnos',
        'risk',
      ]) {
        expect(all, isNot(contains(banned)));
      }
    });

    test('an unusual gap is left out of averages', () {
      final d = computeInsights(
        periods: periods([28, 200, 30]),
        days: const [],
        today: today,
      );
      expect(d.longestCycle, 30);
      expect(d.recordedCycles, 2);
    });

    test('the range filter limits cycles', () {
      final d = computeInsights(
        periods: periods([28, 28, 28, 28, 28, 28]),
        days: const [],
        today: today,
        monthsBack: 3,
      );
      expect(
        d.cycles.every(
          (c) => c.period.start.isOnOrAfter(CalendarDate(2025, 3, 20)),
        ),
        isTrue,
      );
    });
  });

  group('calendar day visuals', () {
    final logged = [
      PeriodSpan(
        id: 'a',
        start: CalendarDate(2025, 6, 1),
        end: CalendarDate(2025, 6, 5),
      ),
    ];
    final prediction = const CyclePredictionEngine().predict(
      PredictionInput(
        periods: [
          PeriodObservation(
            start: CalendarDate(2025, 6, 1),
            end: CalendarDate(2025, 6, 5),
          ),
        ],
        today: today,
        usualCycleLength: 28,
        usualPeriodLength: 5,
        fertilityEnabled: true,
      ),
    );

    DayVisual visual(CalendarDate d, AppSettings s) => buildDayVisual(
      date: d,
      today: today,
      periods: logged,
      prediction: prediction,
      settings: s,
      entries: const {},
    );

    const on = AppSettings(fertilityEstimatesEnabled: true);

    test('logged days are confirmed and never predicted', () {
      final v = visual(CalendarDate(2025, 6, 3), on);
      expect(v.confirmed, isTrue);
      expect(v.predicted, isFalse);
    });

    test('estimates are never confirmed', () {
      final v = visual(CalendarDate(2025, 6, 29), on);
      expect(v.predicted, isTrue);
      expect(v.confirmed, isFalse);
      expect(v.statusWords, contains('estimated period'));
    });

    test('fertility marks vanish when the setting is off', () {
      final window = prediction.fertileWindows.last.first;
      expect(visual(window, on).fertile, isTrue);
      expect(visual(window, const AppSettings()).fertile, isFalse);
    });

    test('predicted highlight can be turned off', () {
      final v = visual(
        CalendarDate(2025, 6, 29),
        const AppSettings(showPredictedPeriods: false),
      );
      expect(v.predicted, isFalse);
    });

    test('estimates never appear on past days', () {
      final v = visual(CalendarDate(2025, 6, 10), on);
      expect(v.predicted || v.fertile || v.ovulation, isFalse);
    });

    test('month grid honours first day of week', () {
      // 1 June 2025 is a Sunday.
      expect(
        monthGrid(
          CalendarDate(2025, 6, 1),
          DateTime.monday,
        ).takeWhile((d) => d == null).length,
        6,
      );
      expect(
        monthGrid(CalendarDate(2025, 6, 1), DateTime.sunday).first,
        CalendarDate(2025, 6, 1),
      );
      expect(
        monthGrid(
          CalendarDate(2024, 2, 1),
          DateTime.monday,
        ).whereType<CalendarDate>().length,
        29,
      );
    });
  });
}
