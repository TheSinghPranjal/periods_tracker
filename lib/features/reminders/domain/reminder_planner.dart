import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';

enum ReminderRepeat { once, daily, weekly }

@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.at,
    required this.repeat,
    required this.title,
    required this.body,
  });
  final int id;

  /// Local wall-clock time.
  final DateTime at;
  final ReminderRepeat repeat;
  final String title;
  final String body;
}

@immutable
class ReminderSpec {
  const ReminderSpec({
    required this.type,
    required this.enabled,
    required this.minutes,
    this.leadDays = 2,
    this.label,
  });
  final String type;
  final bool enabled;
  final int minutes;
  final int leadDays;
  final String? label;
}

@immutable
class MedicationSpec {
  const MedicationSpec({
    required this.scheduleType,
    required this.minutes,
    required this.anchor,
    this.name,
    this.enabled = true,
    this.weekdays = const [],
    this.intervalDays,
  });
  final String scheduleType;
  final int minutes;
  final CalendarDate anchor;
  final String? name;
  final bool enabled;
  final List<int> weekdays;
  final int? intervalDays;
}

@immutable
class QuietHours {
  const QuietHours(this.startMinutes, this.endMinutes);
  final int startMinutes;
  final int endMinutes;

  bool contains(int minutes) => startMinutes <= endMinutes
      ? minutes >= startMinutes && minutes < endMinutes
      : minutes >= startMinutes || minutes < endMinutes;
}

const kDiscreetTitle = 'LunaCycle';
const kDiscreetBody = 'You have a reminder from LunaCycle.';
const _intervalOccurrences = 20;

/// Works out which notifications should exist. The caller replaces the whole
/// set each time, so duplicates cannot accumulate.
List<PlannedNotification> planNotifications({
  required List<ReminderSpec> reminders,
  required List<MedicationSpec> medications,
  required CyclePredictionResult? prediction,
  required bool fertilityEnabled,
  required bool discreet,
  required QuietHours? quiet,
  required DateTime now,
}) {
  final plan = <PlannedNotification>[];
  var nextCustomId = 2000;
  var nextMedicationId = 3000;

  DateTime at(CalendarDate date, int minutes) {
    final base = DateTime(date.year, date.month, date.day);
    var result = DateTime(
      base.year,
      base.month,
      base.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (quiet != null && quiet.contains(minutes)) {
      final end = quiet.endMinutes;
      // An overnight window reached before midnight ends on the next day.
      final addDay =
          quiet.startMinutes > quiet.endMinutes &&
          minutes >= quiet.startMinutes;
      result = DateTime(
        base.year,
        base.month,
        base.day + (addDay ? 1 : 0),
        end ~/ 60,
        end % 60,
      );
    }
    return result;
  }

  DateTime nextDaily(int minutes) {
    final today = CalendarDate.fromDateTime(now);
    final candidate = at(today, minutes);
    return candidate.isAfter(now) ? candidate : at(today.plusDays(1), minutes);
  }

  String body(String detail) => discreet ? kDiscreetBody : detail;

  for (final r in reminders.where((r) => r.enabled)) {
    switch (r.type) {
      case 'period':
        final start = prediction?.predictedStart;
        if (start == null) break;
        final when = at(start.minusDays(r.leadDays), r.minutes);
        if (when.isAfter(now)) {
          plan.add(
            PlannedNotification(
              id: 1000,
              at: when,
              repeat: ReminderRepeat.once,
              title: kDiscreetTitle,
              body: body('Your next period may start soon.'),
            ),
          );
        }
      case 'daily':
        plan.add(
          PlannedNotification(
            id: 1001,
            at: nextDaily(r.minutes),
            repeat: ReminderRepeat.daily,
            title: kDiscreetTitle,
            body: body('A moment to log how today went.'),
          ),
        );
      case 'fertile':
        if (!fertilityEnabled || prediction == null) break;
        for (final window in prediction.fertileWindows) {
          final when = at(window.first.minusDays(1), r.minutes);
          if (when.isAfter(now)) {
            plan.add(
              PlannedNotification(
                id: 1002,
                at: when,
                repeat: ReminderRepeat.once,
                title: kDiscreetTitle,
                body: body(
                  'Your estimated fertile window may begin soon. This is an estimate only.',
                ),
              ),
            );
            break;
          }
        }
      case 'custom':
        plan.add(
          PlannedNotification(
            id: nextCustomId++,
            at: nextDaily(r.minutes),
            repeat: ReminderRepeat.daily,
            title: kDiscreetTitle,
            body: body(r.label ?? 'Your reminder.'),
          ),
        );
    }
  }

  for (final m in medications.where((m) => m.enabled)) {
    final detail = m.name == null || m.name!.isEmpty
        ? 'Your medication reminder.'
        : 'Reminder: ${m.name}';
    switch (m.scheduleType) {
      case 'daily':
        plan.add(
          PlannedNotification(
            id: nextMedicationId++,
            at: nextDaily(m.minutes),
            repeat: ReminderRepeat.daily,
            title: kDiscreetTitle,
            body: body(detail),
          ),
        );
      case 'weekly':
        final today = CalendarDate.fromDateTime(now);
        for (final weekday in m.weekdays) {
          var date = today;
          while (date.weekday != weekday || !at(date, m.minutes).isAfter(now)) {
            date = date.plusDays(1);
          }
          plan.add(
            PlannedNotification(
              id: nextMedicationId++,
              at: at(date, m.minutes),
              repeat: ReminderRepeat.weekly,
              title: kDiscreetTitle,
              body: body(detail),
            ),
          );
        }
      case 'interval':
        final every = m.intervalDays ?? 1;
        if (every < 1) break;
        final today = CalendarDate.fromDateTime(now);
        var date = m.anchor;
        while (!at(date, m.minutes).isAfter(now)) {
          date = date.plusDays(every);
        }
        if (date.isBefore(today)) date = today;
        for (var i = 0; i < _intervalOccurrences; i++) {
          plan.add(
            PlannedNotification(
              id: nextMedicationId++,
              at: at(date, m.minutes),
              repeat: ReminderRepeat.once,
              title: kDiscreetTitle,
              body: body(detail),
            ),
          );
          date = date.plusDays(every);
        }
    }
  }
  return plan;
}
