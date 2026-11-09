import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';
import '../../period_logging/domain/period_rules.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';
import '../../settings/domain/app_settings.dart';
import '../../symptoms/domain/day_entry.dart';

/// What one calendar cell must show. Confirmed and predicted are mutually
/// exclusive, so a guess can never look like something that was logged.
@immutable
class DayVisual {
  const DayVisual({
    required this.date,
    this.confirmed = false,
    this.predicted = false,
    this.fertile = false,
    this.ovulation = false,
    this.marker = false,
    this.isToday = false,
    this.isFuture = false,
  });

  final CalendarDate date;
  final bool confirmed;
  final bool predicted;
  final bool fertile;
  final bool ovulation;
  final bool marker;
  final bool isToday;
  final bool isFuture;

  /// Every visual state in words, for screen readers.
  String get statusWords => [
    if (isToday) 'today',
    if (confirmed) 'logged period',
    if (predicted) 'estimated period',
    if (ovulation) 'estimated ovulation',
    if (fertile && !ovulation) 'estimated fertile window',
    if (marker) 'has logged details',
  ].join(', ');
}

DayVisual buildDayVisual({
  required CalendarDate date,
  required CalendarDate today,
  required List<PeriodSpan> periods,
  required CyclePredictionResult? prediction,
  required AppSettings settings,
  required Map<CalendarDate, DayEntry> entries,
}) {
  final confirmed = periods.any((p) => p.contains(date, today));
  final canEstimate =
      date.isOnOrAfter(today) && !confirmed && prediction != null;
  final fertilityOn = settings.fertilityEstimatesEnabled;
  return DayVisual(
    date: date,
    confirmed: confirmed,
    predicted:
        canEstimate &&
        settings.showPredictedPeriods &&
        prediction.isPredictedPeriod(date),
    fertile: canEstimate && fertilityOn && prediction.isFertile(date),
    ovulation:
        canEstimate &&
        fertilityOn &&
        settings.ovulationMarkerEnabled &&
        prediction.isOvulationEstimate(date),
    marker: settings.showSymptomMarkers && (entries[date]?.hasMarker ?? false),
    isToday: date == today,
    isFuture: date.isAfter(today),
  );
}

/// Sunday- or Monday-first grid: leading blanks are null.
List<CalendarDate?> monthGrid(CalendarDate month, int firstDayOfWeek) {
  final first = month.firstOfMonth;
  final blanks = (first.weekday - firstDayOfWeek + 7) % 7;
  return [
    for (var i = 0; i < blanks; i++) null,
    for (var d = 1; d <= month.lastOfMonth.day; d++)
      CalendarDate(month.year, month.month, d),
  ];
}
