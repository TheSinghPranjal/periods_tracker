import 'package:flutter/foundation.dart';

/// A date with no time-of-day or timezone.
///
/// Periods and daily logs belong to the calendar day the person experienced
/// them on, so they must never move when the device changes timezone. All
/// arithmetic goes through UTC internally, which has no daylight-saving gaps.
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  factory CalendarDate(int year, int month, int day) {
    final normal = DateTime.utc(year, month, day);
    return CalendarDate._(normal.year, normal.month, normal.day);
  }

  const CalendarDate._(this.year, this.month, this.day);

  factory CalendarDate.fromDateTime(DateTime value) =>
      CalendarDate(value.year, value.month, value.day);

  factory CalendarDate.fromEpochDay(int epochDay) {
    final d = DateTime.fromMillisecondsSinceEpoch(
      epochDay * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return CalendarDate._(d.year, d.month, d.day);
  }

  factory CalendarDate.today() => CalendarDate.fromDateTime(DateTime.now());

  /// Parses strict `YYYY-MM-DD`. Throws [FormatException] for anything else,
  /// including impossible dates such as 2025-02-30.
  factory CalendarDate.parse(String value) {
    final parsed = tryParse(value);
    if (parsed == null) {
      throw FormatException('Not a calendar date', value);
    }
    return parsed;
  }

  static final RegExp _iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static CalendarDate? tryParse(String value) {
    final match = _iso.firstMatch(value);
    if (match == null) return null;
    final y = int.parse(match[1]!);
    final m = int.parse(match[2]!);
    final d = int.parse(match[3]!);
    final date = CalendarDate(y, m, d);
    if (date.year != y || date.month != m || date.day != d) return null;
    return date;
  }

  final int year;
  final int month;
  final int day;

  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// 1 = Monday ... 7 = Sunday.
  int get weekday => DateTime.utc(year, month, day).weekday;

  CalendarDate plusDays(int days) => CalendarDate.fromEpochDay(epochDay + days);

  CalendarDate minusDays(int days) => plusDays(-days);

  /// Number of days from this date to [other]; negative if [other] is earlier.
  int daysUntil(CalendarDate other) => other.epochDay - epochDay;

  CalendarDate get firstOfMonth => CalendarDate(year, month, 1);

  CalendarDate get lastOfMonth => CalendarDate(year, month + 1, 0);

  CalendarDate plusMonths(int months) {
    final target = CalendarDate(year, month + months, 1);
    final last = target.lastOfMonth.day;
    return CalendarDate(target.year, target.month, day > last ? last : day);
  }

  bool isBefore(CalendarDate other) => epochDay < other.epochDay;
  bool isAfter(CalendarDate other) => epochDay > other.epochDay;
  bool isOnOrBefore(CalendarDate other) => epochDay <= other.epochDay;
  bool isOnOrAfter(CalendarDate other) => epochDay >= other.epochDay;

  bool isWithin(CalendarDate first, CalendarDate last) =>
      isOnOrAfter(first) && isOnOrBefore(last);

  bool isSameMonth(CalendarDate other) =>
      year == other.year && month == other.month;

  /// Local midnight on this date, for display and scheduling only.
  DateTime toLocalDateTime() => DateTime(year, month, day);

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CalendarDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
