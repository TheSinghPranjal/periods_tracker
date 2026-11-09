import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';

@immutable
class PeriodSpan {
  const PeriodSpan({required this.id, required this.start, this.end});
  final String id;
  final CalendarDate start;
  final CalendarDate? end;

  /// Ongoing periods are treated as running through [today].
  CalendarDate effectiveEnd(CalendarDate today) {
    final e = end ?? today;
    return e.isBefore(start) ? start : e;
  }

  bool contains(CalendarDate date, CalendarDate today) =>
      date.isWithin(start, effectiveEnd(today));
}

sealed class PeriodIssue {
  const PeriodIssue();
}

class EndBeforeStart extends PeriodIssue {
  const EndBeforeStart();
}

class FutureDate extends PeriodIssue {
  const FutureDate();
}

class OverlapsPeriod extends PeriodIssue {
  const OverlapsPeriod(this.other);
  final PeriodSpan other;
}

/// An earlier period has no end date, so a new start must close it first.
class OngoingPeriodBefore extends PeriodIssue {
  const OngoingPeriodBefore(this.other);
  final PeriodSpan other;
}

/// Returns everything wrong with a proposed date range, so that the UI can
/// ask the person what to do. Nothing is corrected automatically.
List<PeriodIssue> validatePeriodRange({
  required CalendarDate start,
  required CalendarDate? end,
  required List<PeriodSpan> others,
  required CalendarDate today,
  String? ignoreId,
}) {
  final issues = <PeriodIssue>[];
  if (start.isAfter(today) || (end != null && end.isAfter(today))) {
    issues.add(const FutureDate());
  }
  if (end != null && end.isBefore(start)) {
    issues.add(const EndBeforeStart());
    return issues;
  }
  final candidates = others.where((o) => o.id != ignoreId);
  final proposedEnd = end ?? today;
  for (final other in candidates) {
    if (other.end == null && other.start.isBefore(start)) {
      issues.add(OngoingPeriodBefore(other));
      continue;
    }
    final otherEnd = other.effectiveEnd(today);
    if (start.isOnOrBefore(otherEnd) && other.start.isOnOrBefore(proposedEnd)) {
      issues.add(OverlapsPeriod(other));
    }
  }
  return issues;
}

sealed class LogDayPlan {
  const LogDayPlan();
}

class StartNewPeriod extends LogDayPlan {
  const StartNewPeriod();
}

class AlreadyInPeriod extends LogDayPlan {
  const AlreadyInPeriod(this.period);
  final PeriodSpan period;
}

class ExtendPeriodEnd extends LogDayPlan {
  const ExtendPeriodEnd(this.period, this.newEnd);
  final PeriodSpan period;
  final CalendarDate newEnd;
}

class MovePeriodStartEarlier extends LogDayPlan {
  const MovePeriodStartEarlier(this.period, this.newStart);
  final PeriodSpan period;
  final CalendarDate newStart;
}

class CloseOngoingAndStart extends LogDayPlan {
  const CloseOngoingAndStart(this.ongoing);
  final PeriodSpan ongoing;
}

class CannotLogFuture extends LogDayPlan {
  const CannotLogFuture();
}

/// Decides what "log a period on this day" should mean, given existing
/// records. A gap of up to [bridgeDays] counts as the same bleeding episode.
LogDayPlan planLogDay({
  required CalendarDate date,
  required List<PeriodSpan> periods,
  required CalendarDate today,
  int bridgeDays = 2,
}) {
  if (date.isAfter(today)) return const CannotLogFuture();
  final sorted = [...periods]..sort((a, b) => a.start.compareTo(b.start));

  for (final period in sorted) {
    if (period.contains(date, today)) return AlreadyInPeriod(period);
  }
  for (final period in sorted) {
    if (period.end != null &&
        date.isAfter(period.end!) &&
        period.end!.daysUntil(date) <= bridgeDays) {
      return ExtendPeriodEnd(period, date);
    }
  }
  for (final period in sorted) {
    if (date.isBefore(period.start) &&
        date.daysUntil(period.start) <= bridgeDays) {
      return MovePeriodStartEarlier(period, date);
    }
  }
  for (final period in sorted.reversed) {
    if (period.end == null && period.start.isBefore(date)) {
      return CloseOngoingAndStart(period);
    }
  }
  return const StartNewPeriod();
}
