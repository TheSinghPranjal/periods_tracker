import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';

void main() {
  group('CalendarDate', () {
    test('crosses month and year boundaries', () {
      expect(CalendarDate(2025, 1, 31).plusDays(1), CalendarDate(2025, 2, 1));
      expect(CalendarDate(2024, 12, 31).plusDays(1), CalendarDate(2025, 1, 1));
      expect(CalendarDate(2025, 1, 1).minusDays(1), CalendarDate(2024, 12, 31));
    });

    test('handles leap years', () {
      expect(CalendarDate(2024, 2, 28).plusDays(1), CalendarDate(2024, 2, 29));
      expect(CalendarDate(2025, 2, 28).plusDays(1), CalendarDate(2025, 3, 1));
      expect(CalendarDate(2024, 2, 1).daysUntil(CalendarDate(2024, 3, 1)), 29);
      expect(CalendarDate(2024, 2, 29).lastOfMonth.day, 29);
    });

    test('rejects impossible and malformed dates', () {
      expect(CalendarDate.tryParse('2025-02-30'), isNull);
      expect(CalendarDate.tryParse('2025-2-3'), isNull);
      expect(CalendarDate.tryParse('2025-02-03T00:00:00Z'), isNull);
      expect(CalendarDate.tryParse('2024-02-29'), CalendarDate(2024, 2, 29));
    });

    test('iso text round-trips and sorts chronologically', () {
      final dates = [CalendarDate(2025, 10, 2), CalendarDate(2025, 9, 30)];
      final iso = dates.map((d) => d.toIso()).toList()..sort();
      expect(iso, ['2025-09-30', '2025-10-02']);
      expect(CalendarDate.parse('2025-09-30'), dates[1]);
    });

    test('day differences ignore daylight-saving transitions', () {
      // US spring-forward (2025-03-09) and autumn-back (2025-11-02).
      expect(CalendarDate(2025, 3, 8).daysUntil(CalendarDate(2025, 3, 10)), 2);
      expect(CalendarDate(2025, 11, 1).daysUntil(CalendarDate(2025, 11, 3)), 2);
    });

    test('the same instant keeps its stored date regardless of zone', () {
      // A date is stored as text; re-reading it never consults a timezone.
      final stored = CalendarDate(2025, 6, 15).toIso();
      expect(CalendarDate.parse(stored).toIso(), '2025-06-15');
      expect(
        CalendarDate.fromDateTime(DateTime(2025, 6, 15, 23, 59)).toIso(),
        stored,
      );
      expect(
        CalendarDate.fromDateTime(DateTime(2025, 6, 15, 0, 1)).toIso(),
        stored,
      );
    });

    test('plusMonths clamps to the last valid day', () {
      expect(
        CalendarDate(2025, 1, 31).plusMonths(1),
        CalendarDate(2025, 2, 28),
      );
      expect(
        CalendarDate(2024, 12, 15).plusMonths(2),
        CalendarDate(2025, 2, 15),
      );
    });
  });
}
