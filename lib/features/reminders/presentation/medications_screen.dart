import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../calendar/presentation/calendar_widgets.dart' show kWeekdayLetters;
import 'reminders_screen.dart' show pickMinutes;

const _guide = GuideContent(
  id: 'medications',
  title: 'Medication reminders',
  steps: [
    'Tap Add a schedule and choose when you want to be reminded.',
    'The name is optional. You can leave it blank for extra privacy.',
    'Each day, mark Taken or Skipped to keep your own record.',
  ],
);

String _scheduleWords(MedicationRecord m) => switch (m.scheduleType) {
  'daily' => 'Every day',
  'weekly' =>
    (m.weekdays ?? '')
        .split(',')
        .where((d) => d.isNotEmpty)
        .map((d) => kWeekdayLetters[int.parse(d) - 1])
        .join(', '),
  _ => 'Every ${m.intervalDays} days',
};

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  Future<void> _mark(
    WidgetRef ref,
    MedicationRecord m,
    CalendarDate day,
    String? status,
  ) async {
    final db = ref.read(databaseProvider);
    if (status == null) {
      await (db.delete(db.medicationLogs)..where(
            (t) => t.medicationId.equals(m.id) & t.localDate.equalsValue(day),
          ))
          .go();
    } else {
      await db
          .into(db.medicationLogs)
          .insertOnConflictUpdate(
            MedicationLogsCompanion.insert(
              medicationId: m.id,
              localDate: day,
              status: status,
              recordedAt: DateTime.now(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final logs =
        ref.watch(medicationLogsProvider).value ?? const <MedicationLog>[];
    final dates = ref.watch(lunaDatesProvider);
    final text = Theme.of(context).textTheme;
    final db = ref.read(databaseProvider);
    return LunaPage(
      title: 'Medication',
      showBack: true,
      guide: _guide,
      children: [
        const PrivacyNotice(
          'These are reminders to help you stay organised. LunaCycle does not give dosage or prescribing advice.',
          icon: Icons.medication_outlined,
        ),
        const SizedBox(height: 12),
        AsyncBody(
          value: ref.watch(medicationsProvider),
          builder: (meds) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (meds.isEmpty)
                const EmptyState(
                  title: 'No schedules yet',
                  message: 'Add a schedule to get your first reminder.',
                ),
              for (final m in meds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SketchCard(
                    seed: m.minutes % 40,
                    padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchTile(
                          title: (m.name ?? '').isEmpty
                              ? 'Medication'
                              : m.name!,
                          subtitle:
                              '${_scheduleWords(m)} at ${LunaDates.time(context, m.minutes)}',
                          value: m.enabled,
                          onChanged: (v) =>
                              (db.update(
                                db.medications,
                              )..where((t) => t.id.equals(m.id))).write(
                                MedicationsCompanion(enabled: Value(v)),
                              ),
                        ),
                        Builder(
                          builder: (context) {
                            final todayLog = logs
                                .where(
                                  (l) =>
                                      l.medicationId == m.id &&
                                      l.localDate == today,
                                )
                                .firstOrNull;
                            return Wrap(
                              spacing: 8,
                              children: [
                                SketchChip(
                                  label: 'Taken today',
                                  selected: todayLog?.status == 'taken',
                                  onTap: () => _mark(
                                    ref,
                                    m,
                                    today,
                                    todayLog?.status == 'taken'
                                        ? null
                                        : 'taken',
                                  ),
                                ),
                                SketchChip(
                                  label: 'Skipped today',
                                  selected: todayLog?.status == 'skipped',
                                  onTap: () => _mark(
                                    ref,
                                    m,
                                    today,
                                    todayLog?.status == 'skipped'
                                        ? null
                                        : 'skipped',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              final ok = await confirmAction(
                                context,
                                title: 'Delete this schedule?',
                                message:
                                    'The reminder and its taken/skipped history will be removed.',
                                confirmLabel: 'Delete',
                                destructive: true,
                              );
                              if (ok) {
                                await (db.delete(
                                  db.medications,
                                )..where((t) => t.id.equals(m.id))).go();
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              PrimaryButton(
                icon: Icons.add_rounded,
                label: 'Add a schedule',
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const _AddMedicationSheet(),
                ),
              ),
              if (logs.isNotEmpty) ...[
                const SectionTitle('Recent history'),
                SketchCard(
                  seed: 46,
                  child: Column(
                    children: [
                      for (final l
                          in ([...logs]..sort(
                                (a, b) => b.localDate.compareTo(a.localDate),
                              ))
                              .take(14))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${dates.short(l.localDate)} · ${meds.where((m) => m.id == l.medicationId).firstOrNull?.name ?? 'Medication'}',
                                  style: text.bodyMedium,
                                ),
                              ),
                              Text(
                                l.status == 'taken' ? 'Taken' : 'Skipped',
                                style: text.titleSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AddMedicationSheet extends ConsumerStatefulWidget {
  const _AddMedicationSheet();

  @override
  ConsumerState<_AddMedicationSheet> createState() =>
      _AddMedicationSheetState();
}

class _AddMedicationSheetState extends ConsumerState<_AddMedicationSheet> {
  final _name = TextEditingController();
  String _type = 'daily';
  final _weekdays = <int>{};
  int _interval = 2;
  int _minutes = 9 * 60;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final granted = await ref
        .read(notificationGatewayProvider)
        .requestPermission();
    final db = ref.read(databaseProvider);
    await db
        .into(db.medications)
        .insert(
          MedicationsCompanion.insert(
            id: const Uuid().v4(),
            name: Value(_name.text.trim().isEmpty ? null : _name.text.trim()),
            scheduleType: _type,
            weekdays: Value(
              _type == 'weekly' ? (_weekdays.toList()..sort()).join(',') : null,
            ),
            intervalDays: Value(_type == 'interval' ? _interval : null),
            anchorDate: ref.read(todayProvider),
            minutes: _minutes,
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    Navigator.pop(context);
    if (!granted) {
      showMessage(
        context,
        'Saved, but notifications are off for LunaCycle in your device settings.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final valid = _type != 'weekly' || _weekdays.isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a schedule', style: text.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final (v, label) in const [
                  ('daily', 'Daily'),
                  ('weekly', 'Weekly'),
                  ('interval', 'Every few days'),
                ])
                  SketchChip(
                    label: label,
                    selected: _type == v,
                    onTap: () => setState(() => _type = v),
                  ),
              ],
            ),
            if (_type == 'weekly') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var d = 1; d <= 7; d++)
                    SketchChip(
                      label: kWeekdayLetters[d - 1],
                      selected: _weekdays.contains(d),
                      onTap: () => setState(() {
                        if (!_weekdays.remove(d)) _weekdays.add(d);
                      }),
                    ),
                ],
              ),
            ],
            if (_type == 'interval')
              SettingsTile(
                title: 'Repeat every',
                trailing: DropdownButton<int>(
                  value: _interval,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (var i = 2; i <= 90; i++)
                      DropdownMenuItem(value: i, child: Text('$i days')),
                  ],
                  onChanged: (v) => setState(() => _interval = v ?? 2),
                ),
              ),
            SettingsTile(
              icon: Icons.schedule_rounded,
              title: 'Time',
              trailing: Text(
                LunaDates.time(context, _minutes),
                style: text.titleSmall,
              ),
              onTap: () async {
                final p = await pickMinutes(context, _minutes);
                if (p != null) {
                  setState(() => _minutes = p.hour * 60 + p.minute);
                }
              },
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Save', onPressed: valid ? _save : null),
          ],
        ),
      ),
    );
  }
}
