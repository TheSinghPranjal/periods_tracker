import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../data/period_repository.dart';
import '../domain/period_rules.dart';

String describePeriodIssue(
  PeriodIssue issue,
  LunaDates dates,
) => switch (issue) {
  EndBeforeStart() => 'The last day can\'t be before the first day.',
  FutureDate() => 'Periods can only be logged for today or earlier.',
  OverlapsPeriod(:final other) =>
    'These dates overlap the period that started on ${dates.medium(other.start)}. Change the dates, or edit that period instead.',
  OngoingPeriodBefore(:final other) =>
    'The period from ${dates.medium(other.start)} has no end date yet. Please add its last day first.',
};

Future<CalendarDate?> pickDate(
  BuildContext context, {
  required CalendarDate initial,
  required CalendarDate first,
  required CalendarDate last,
  required String help,
}) async {
  final picked = await showDatePicker(
    context: context,
    helpText: help,
    initialDate: initial.toLocalDateTime(),
    firstDate: first.toLocalDateTime(),
    lastDate: last.toLocalDateTime(),
  );
  return picked == null ? null : CalendarDate.fromDateTime(picked);
}

Future<void> startPeriodFlow(BuildContext context, WidgetRef ref) async {
  final today = ref.read(todayProvider);
  final picked = await pickDate(
    context,
    initial: today,
    first: CalendarDate(today.year - 5, 1, 1),
    last: today,
    help: 'First day of bleeding',
  );
  if (picked != null && context.mounted) {
    await logPeriodOn(context, ref, picked);
  }
}

/// Works out what logging this day means and confirms anything that would
/// change an existing record.
Future<void> logPeriodOn(
  BuildContext context,
  WidgetRef ref,
  CalendarDate date,
) async {
  final repo = ref.read(periodRepositoryProvider);
  final dates = ref.read(lunaDatesProvider);
  final today = ref.read(todayProvider);
  final periods = (await repo.getAll()).map(spanOf).toList();
  if (!context.mounted) return;

  Future<void> guarded(Future<void> Function() action, String done) async {
    try {
      await action();
      if (context.mounted) showMessage(context, done);
    } on PeriodConflict catch (c) {
      if (context.mounted) {
        showMessage(context, describePeriodIssue(c.issues.first, dates));
      }
    }
  }

  switch (planLogDay(date: date, periods: periods, today: today)) {
    case CannotLogFuture():
      showMessage(context, 'You can log this day when it arrives.');
    case AlreadyInPeriod(:final period):
      showMessage(
        context,
        'This day is already part of the period from ${dates.short(period.start)}.',
      );
    case ExtendPeriodEnd(:final period, :final newEnd):
      final ok = await confirmAction(
        context,
        title: 'Extend this period?',
        message:
            'Your period from ${dates.short(period.start)} ended on ${dates.short(period.end!)}. '
            'Extend it to ${dates.short(newEnd)}?',
        confirmLabel: 'Extend',
      );
      if (ok) {
        await guarded(
          () => repo.updateDates(
            id: period.id,
            start: period.start,
            end: newEnd,
            today: today,
          ),
          'Period extended.',
        );
      }
    case MovePeriodStartEarlier(:final period, :final newStart):
      final ok = await confirmAction(
        context,
        title: 'Start this period earlier?',
        message:
            'Move the first day of your period from ${dates.short(period.start)} to ${dates.short(newStart)}?',
        confirmLabel: 'Move start',
      );
      if (ok) {
        await guarded(
          () => repo.updateDates(
            id: period.id,
            start: newStart,
            end: period.end,
            today: today,
          ),
          'First day updated.',
        );
      }
    case CloseOngoingAndStart(:final ongoing):
      final usual = ref.read(currentSettingsProvider).usualPeriodLength ?? 5;
      final closeOn = CalendarDate.fromEpochDay(
        math.min(
          ongoing.start.plusDays(usual - 1).epochDay,
          date.minusDays(1).epochDay,
        ),
      );
      final ok = await confirmAction(
        context,
        title: 'Start a new period?',
        message:
            'Your period from ${dates.short(ongoing.start)} has no end date. We\'ll record it as ending on '
            '${dates.short(closeOn)} and start a new one on ${dates.short(date)}. You can edit both later.',
        confirmLabel: 'Continue',
      );
      if (ok) {
        await guarded(() async {
          await repo.updateDates(
            id: ongoing.id,
            start: ongoing.start,
            end: closeOn,
            today: today,
          );
          await repo.add(start: date, today: today);
        }, 'New period started.');
      }
    case StartNewPeriod():
      try {
        final record = await repo.add(start: date, today: today);
        if (context.mounted) {
          showMessage(
            context,
            'Period started on ${dates.short(date)}.',
            onUndo: () => repo.delete(record.id),
          );
        }
      } on PeriodConflict catch (c) {
        if (context.mounted) {
          showMessage(context, describePeriodIssue(c.issues.first, dates));
        }
      }
  }
}

Future<void> endPeriodFlow(
  BuildContext context,
  WidgetRef ref,
  PeriodRecord record,
) async {
  final today = ref.read(todayProvider);
  final picked = await pickDate(
    context,
    initial: today,
    first: record.startDate,
    last: today,
    help: 'Last day of bleeding',
  );
  if (picked == null) return;
  try {
    await ref
        .read(periodRepositoryProvider)
        .updateDates(
          id: record.id,
          start: record.startDate,
          end: picked,
          today: today,
        );
    if (context.mounted) {
      showMessage(
        context,
        'Period ended on ${ref.read(lunaDatesProvider).short(picked)}.',
      );
    }
  } on PeriodConflict catch (c) {
    if (context.mounted) {
      showMessage(
        context,
        describePeriodIssue(c.issues.first, ref.read(lunaDatesProvider)),
      );
    }
  }
}

Future<void> deletePeriodFlow(
  BuildContext context,
  WidgetRef ref,
  PeriodRecord record,
) async {
  final dates = ref.read(lunaDatesProvider);
  final ok = await confirmAction(
    context,
    title: 'Delete this period?',
    message:
        'The period from ${dates.medium(record.startDate)} will be removed, and your estimates and insights '
        'will be recalculated. Daily logs for those days are kept.',
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!ok) return;
  final repo = ref.read(periodRepositoryProvider);
  final removed = await repo.delete(record.id);
  if (context.mounted && removed != null) {
    showMessage(
      context,
      'Period deleted.',
      onUndo: () => repo.restore(removed),
    );
  }
}

Future<void> showPeriodEditor(
  BuildContext context,
  PeriodRecord? record, {
  CalendarDate? initialStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        PeriodEditorSheet(record: record, initialStart: initialStart),
  );
}

/// Date-range editor for adding a past period or correcting an existing one.
class PeriodEditorSheet extends ConsumerStatefulWidget {
  const PeriodEditorSheet({super.key, this.record, this.initialStart});
  final PeriodRecord? record;
  final CalendarDate? initialStart;

  @override
  ConsumerState<PeriodEditorSheet> createState() => _PeriodEditorSheetState();
}

class _PeriodEditorSheetState extends ConsumerState<PeriodEditorSheet> {
  late CalendarDate? _start = widget.record?.startDate ?? widget.initialStart;
  late CalendarDate? _end = widget.record?.endDate;
  late bool _ongoing = widget.record != null && widget.record!.endDate == null;
  String? _error;

  Future<void> _save() async {
    final repo = ref.read(periodRepositoryProvider);
    final today = ref.read(todayProvider);
    final dates = ref.read(lunaDatesProvider);
    final end = _ongoing ? null : _end;
    try {
      if (widget.record == null) {
        await repo.add(start: _start!, end: end, today: today);
      } else {
        await repo.updateDates(
          id: widget.record!.id,
          start: _start!,
          end: end,
          today: today,
        );
      }
      if (mounted) Navigator.pop(context);
    } on PeriodConflict catch (c) {
      setState(() => _error = describePeriodIssue(c.issues.first, dates));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = ref.watch(lunaDatesProvider);
    final today = ref.watch(todayProvider);
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    final canSave = _start != null && (_ongoing || _end != null);
    final earliest = CalendarDate(today.year - 10, 1, 1);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.record == null ? 'Add a period' : 'Edit period',
              style: text.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Set the first and last day of bleeding. A period can span two months.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 14),
            SecondaryButton(
              icon: Icons.play_arrow_rounded,
              label: _start == null
                  ? 'Choose first day'
                  : 'First day: ${dates.medium(_start!)}',
              onPressed: () async {
                final d = await pickDate(
                  context,
                  initial: _start ?? today,
                  first: earliest,
                  last: today,
                  help: 'First day of bleeding',
                );
                if (d != null) setState(() => _start = d);
              },
            ),
            const SizedBox(height: 10),
            if (!_ongoing)
              SecondaryButton(
                icon: Icons.stop_rounded,
                label: _end == null
                    ? 'Choose last day'
                    : 'Last day: ${dates.medium(_end!)}',
                onPressed: _start == null
                    ? null
                    : () async {
                        final d = await pickDate(
                          context,
                          initial: _end ?? _start!,
                          first: _start!,
                          last: today,
                          help: 'Last day of bleeding',
                        );
                        if (d != null) setState(() => _end = d);
                      },
              ),
            SwitchTile(
              title: 'Still going',
              subtitle: 'Leave the last day open',
              value: _ongoing,
              onChanged: (v) => setState(() => _ongoing = v),
            ),
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: text.bodyMedium?.copyWith(color: t.error),
                ),
              ),
              const SizedBox(height: 10),
            ],
            PrimaryButton(label: 'Save', onPressed: canSave ? _save : null),
            if (widget.record != null) ...[
              const SizedBox(height: 6),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: t.error),
                onPressed: () async {
                  final record = widget.record!;
                  Navigator.pop(context);
                  await deletePeriodFlow(context, ref, record);
                },
                child: const Text('Delete this period'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
