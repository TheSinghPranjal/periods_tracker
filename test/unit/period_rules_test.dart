import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/period_logging/domain/period_rules.dart';

void main() {
  final today = CalendarDate(2025, 6, 20);
  final may = PeriodSpan(
    id: 'a',
    start: CalendarDate(2025, 5, 10),
    end: CalendarDate(2025, 5, 14),
  );

  group('validatePeriodRange', () {
    test('accepts a clean range', () {
      expect(
        validatePeriodRange(
          start: CalendarDate(2025, 6, 1),
          end: CalendarDate(2025, 6, 5),
          others: [may],
          today: today,
        ),
        isEmpty,
      );
    });

    test('rejects an end before the start', () {
      final issues = validatePeriodRange(
        start: CalendarDate(2025, 6, 5),
        end: CalendarDate(2025, 6, 1),
        others: const [],
        today: today,
      );
      expect(issues.single, isA<EndBeforeStart>());
    });

    test('reports overlap without changing anything', () {
      final issues = validatePeriodRange(
        start: CalendarDate(2025, 5, 13),
        end: CalendarDate(2025, 5, 18),
        others: [may],
        today: today,
      );
      expect(issues.single, isA<OverlapsPeriod>());
    });

    test('rejects future dates', () {
      final issues = validatePeriodRange(
        start: CalendarDate(2025, 6, 25),
        end: null,
        others: const [],
        today: today,
      );
      expect(issues.whereType<FutureDate>(), isNotEmpty);
    });

    test('an earlier ongoing period must be closed first', () {
      final ongoing = PeriodSpan(id: 'o', start: CalendarDate(2025, 6, 1));
      final issues = validatePeriodRange(
        start: CalendarDate(2025, 6, 15),
        end: null,
        others: [ongoing],
        today: today,
      );
      expect(issues.single, isA<OngoingPeriodBefore>());
    });

    test('editing a record ignores itself', () {
      expect(
        validatePeriodRange(
          start: CalendarDate(2025, 5, 11),
          end: CalendarDate(2025, 5, 15),
          others: [may],
          today: today,
          ignoreId: 'a',
        ),
        isEmpty,
      );
    });

    test('a period can span two calendar months', () {
      expect(
        validatePeriodRange(
          start: CalendarDate(2025, 5, 29),
          end: CalendarDate(2025, 6, 2),
          others: [may],
          today: today,
        ),
        isEmpty,
      );
    });
  });

  group('planLogDay', () {
    LogDayPlan plan(CalendarDate d, List<PeriodSpan> p) =>
        planLogDay(date: d, periods: p, today: today);

    test('new period when nothing is nearby', () {
      expect(plan(CalendarDate(2025, 6, 10), [may]), isA<StartNewPeriod>());
    });

    test('day inside a period is already logged', () {
      expect(plan(CalendarDate(2025, 5, 12), [may]), isA<AlreadyInPeriod>());
    });

    test('day just after a period offers to extend it', () {
      final r = plan(CalendarDate(2025, 5, 15), [may]) as ExtendPeriodEnd;
      expect(r.newEnd, CalendarDate(2025, 5, 15));
    });

    test('day just before a period offers to move the start', () {
      final r = plan(CalendarDate(2025, 5, 9), [may]) as MovePeriodStartEarlier;
      expect(r.newStart, CalendarDate(2025, 5, 9));
    });

    test('future days cannot be logged', () {
      expect(plan(CalendarDate(2025, 7, 1), [may]), isA<CannotLogFuture>());
    });

    test('a new start long after an unended period offers to close it', () {
      final ongoing = PeriodSpan(id: 'o', start: CalendarDate(2025, 5, 20));
      final r =
          plan(CalendarDate(2025, 6, 18), [ongoing]) as CloseOngoingAndStart;
      expect(r.ongoing.id, 'o');
    });

    test('an ongoing period counts through today', () {
      final ongoing = PeriodSpan(id: 'o', start: CalendarDate(2025, 6, 18));
      expect(
        plan(CalendarDate(2025, 6, 20), [ongoing]),
        isA<AlreadyInPeriod>(),
      );
    });
  });
}
