import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/prediction/domain/cycle_prediction_engine.dart';
import 'package:periods_tracker/features/reminders/domain/reminder_planner.dart';

void main() {
  final now = DateTime(2025, 6, 10, 12);
  final prediction = const CyclePredictionEngine().predict(
    PredictionInput(
      periods: [
        PeriodObservation(
          start: CalendarDate(2025, 6, 1),
          end: CalendarDate(2025, 6, 5),
        ),
      ],
      today: CalendarDate(2025, 6, 10),
      usualCycleLength: 28,
      fertilityEnabled: true,
    ),
  );

  List<PlannedNotification> plan(
    List<ReminderSpec> reminders, {
    bool discreet = true,
    QuietHours? quiet,
    CyclePredictionResult? p,
    List<MedicationSpec> meds = const [],
    bool fertility = true,
  }) => planNotifications(
    reminders: reminders,
    medications: meds,
    prediction: p,
    fertilityEnabled: fertility,
    discreet: discreet,
    quiet: quiet,
    now: now,
  );

  test('period reminder fires lead days before the estimate', () {
    final r = plan([
      const ReminderSpec(
        type: 'period',
        enabled: true,
        minutes: 540,
        leadDays: 2,
      ),
    ], p: prediction).single;
    expect(r.at, DateTime(2025, 6, 27, 9));
    expect(r.repeat, ReminderRepeat.once);
  });

  test('default content never mentions a period', () {
    final r = plan([
      const ReminderSpec(type: 'period', enabled: true, minutes: 540),
    ], p: prediction).single;
    expect(r.body, 'You have a reminder from LunaCycle.');
    expect(r.title.toLowerCase(), isNot(contains('period')));
  });

  test('detailed content is used only when requested', () {
    final r = plan(
      [const ReminderSpec(type: 'period', enabled: true, minutes: 540)],
      p: prediction,
      discreet: false,
    ).single;
    expect(r.body, 'Your next period may start soon.');
  });

  test('no prediction means no period reminder', () {
    expect(
      plan([const ReminderSpec(type: 'period', enabled: true, minutes: 540)]),
      isEmpty,
    );
  });

  test('disabled reminders are not scheduled', () {
    expect(
      plan([const ReminderSpec(type: 'daily', enabled: false, minutes: 540)]),
      isEmpty,
    );
  });

  test('daily reminder already past today moves to tomorrow', () {
    final r = plan([
      const ReminderSpec(type: 'daily', enabled: true, minutes: 540),
    ]).single;
    expect(r.at, DateTime(2025, 6, 11, 9));
    expect(r.repeat, ReminderRepeat.daily);
  });

  test('quiet hours defer to the end of the window, overnight included', () {
    final r = plan([
      const ReminderSpec(type: 'daily', enabled: true, minutes: 23 * 60),
    ], quiet: const QuietHours(22 * 60, 7 * 60)).single;
    expect(r.at, DateTime(2025, 6, 11, 7));
  });

  test('fertile reminder needs fertility estimates on', () {
    const spec = ReminderSpec(type: 'fertile', enabled: true, minutes: 540);
    expect(plan([spec], p: prediction), hasLength(1));
    expect(plan([spec], p: prediction, fertility: false), isEmpty);
  });

  test('weekly medication creates one repeating entry per weekday', () {
    final r = plan(
      const [],
      meds: [
        MedicationSpec(
          scheduleType: 'weekly',
          minutes: 480,
          anchor: CalendarDate(2025, 6, 1),
          weekdays: const [1, 4],
        ),
      ],
    );
    expect(r.length, 2);
    expect(r.every((n) => n.repeat == ReminderRepeat.weekly), isTrue);
    expect(r.map((n) => n.at.weekday).toSet(), {1, 4});
  });

  test('medication name stays hidden in discreet mode', () {
    final r = plan(
      const [],
      meds: [
        MedicationSpec(
          scheduleType: 'daily',
          minutes: 480,
          anchor: CalendarDate(2025, 6, 1),
          name: 'Secret',
        ),
      ],
    ).single;
    expect(r.body, isNot(contains('Secret')));
  });

  test('interval schedule steps from its anchor', () {
    final r = plan(
      const [],
      meds: [
        MedicationSpec(
          scheduleType: 'interval',
          minutes: 480,
          anchor: CalendarDate(2025, 6, 1),
          intervalDays: 3,
        ),
      ],
    );
    expect(r.first.at, DateTime(2025, 6, 13, 8));
    expect(r[1].at, DateTime(2025, 6, 16, 8));
  });

  test('every notification id in a plan is unique', () {
    final r = plan(
      const [
        ReminderSpec(type: 'daily', enabled: true, minutes: 540),
        ReminderSpec(type: 'custom', enabled: true, minutes: 600, label: 'a'),
        ReminderSpec(type: 'custom', enabled: true, minutes: 660, label: 'b'),
      ],
      meds: [
        MedicationSpec(
          scheduleType: 'interval',
          minutes: 480,
          anchor: CalendarDate(2025, 6, 1),
          intervalDays: 2,
        ),
        MedicationSpec(
          scheduleType: 'daily',
          minutes: 480,
          anchor: CalendarDate(2025, 6, 1),
        ),
      ],
    );
    expect(r.map((n) => n.id).toSet().length, r.length);
  });
}
