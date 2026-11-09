import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';

const _guide = GuideContent(
  id: 'reminders',
  title: 'Setting a reminder',
  steps: [
    'Switch on a reminder. Your phone may ask for permission the first time.',
    'Tap the time to change when it arrives.',
    'Keep discreet notifications on so nothing personal appears on your lock screen.',
  ],
);

Future<TimeOfDay?> pickMinutes(BuildContext context, int minutes) =>
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  String? _denied;

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _write(String id, RemindersCompanion changes) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(changes);

  Future<void> _toggle(ReminderRecord r, bool on) async {
    if (on) {
      final granted = await ref
          .read(notificationGatewayProvider)
          .requestPermission();
      if (!granted) {
        setState(
          () => _denied =
              'Notifications are off for LunaCycle. To use reminders, allow notifications in your device settings, then try again.',
        );
        return;
      }
    }
    setState(() => _denied = null);
    await _write(r.id, RemindersCompanion(enabled: Value(on)));
  }

  Future<void> _time(ReminderRecord r) async {
    final picked = await pickMinutes(context, r.minutes);
    if (picked != null) {
      await _write(
        r.id,
        RemindersCompanion(minutes: Value(picked.hour * 60 + picked.minute)),
      );
    }
  }

  Future<void> _addCustom() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New daily reminder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(
            hintText: 'What should it remind you of?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (label == null || label.isEmpty) return;
    await _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: const Uuid().v4(),
            type: 'custom',
            label: Value(label),
          ),
        );
  }

  Widget _card(
    ReminderRecord r,
    String title,
    String subtitle, {
    bool canDelete = false,
    bool lead = false,
    bool enabled = true,
  }) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SketchCard(
        seed: title.length + 3,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            SwitchTile(
              title: title,
              subtitle: subtitle,
              value: r.enabled && enabled,
              onChanged: enabled ? (v) => _toggle(r, v) : null,
            ),
            if (r.enabled && enabled) ...[
              SettingsTile(
                icon: Icons.schedule_rounded,
                title: 'Time',
                trailing: Text(
                  LunaDates.time(context, r.minutes),
                  style: text.titleSmall,
                ),
                onTap: () => _time(r),
              ),
              if (lead)
                SettingsTile(
                  icon: Icons.event_available_rounded,
                  title: 'Days before',
                  trailing: DropdownButton<int>(
                    value: r.leadDays,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (var i = 0; i <= 7; i++)
                        DropdownMenuItem(value: i, child: Text('$i')),
                    ],
                    onChanged: (v) => _write(
                      r.id,
                      RemindersCompanion(leadDays: Value(v ?? 2)),
                    ),
                  ),
                ),
            ],
            if (canDelete)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => (_db.delete(
                    _db.reminders,
                  )..where((t) => t.id.equals(r.id))).go(),
                  child: const Text('Delete'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    return LunaPage(
      title: 'Reminders',
      showBack: true,
      guide: _guide,
      children: [
        if (_denied != null) ...[
          PrivacyNotice(_denied!, warning: true),
          const SizedBox(height: 10),
        ],
        AsyncBody(
          value: ref.watch(remindersProvider),
          builder: (list) {
            ReminderRecord? of(String id) =>
                list.where((r) => r.id == id).firstOrNull;
            final period = of('period');
            final daily = of('daily');
            final fertile = of('fertile');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (period != null)
                  _card(
                    period,
                    'Upcoming period',
                    'Before the estimated start',
                    lead: true,
                  ),
                if (daily != null)
                  _card(daily, 'Daily logging', 'A daily nudge to log'),
                if (fertile != null && s.fertilityEstimatesEnabled)
                  _card(
                    fertile,
                    'Estimated fertile window',
                    'Before the estimated window',
                  ),
                for (final r in list.where((r) => r.type == 'custom'))
                  _card(r, r.label ?? 'Custom', 'Every day', canDelete: true),
                SecondaryButton(
                  icon: Icons.add_rounded,
                  label: 'Add a custom reminder',
                  onPressed: _addCustom,
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  icon: Icons.medication_outlined,
                  label: 'Medication reminders',
                  onPressed: () => context.push('/medications'),
                ),
              ],
            );
          },
        ),
        const SectionTitle('Privacy and timing'),
        SketchCard(
          seed: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SwitchTile(
                title: 'Discreet notifications',
                subtitle: s.discreetNotifications
                    ? 'Shows: "You have a reminder from LunaCycle."'
                    : 'Shows details such as "Your next period may start soon."',
                value: s.discreetNotifications,
                onChanged: (v) => repo.patch({'discreetNotifications': v}),
              ),
              SwitchTile(
                title: 'Quiet hours',
                subtitle: 'Reminders wait until quiet hours end',
                value: s.quietHoursEnabled,
                onChanged: (v) => repo.patch({'quietHoursEnabled': v}),
              ),
              if (s.quietHoursEnabled) ...[
                SettingsTile(
                  title: 'Starts',
                  trailing: Text(LunaDates.time(context, s.quietStartMinutes)),
                  onTap: () async {
                    final p = await pickMinutes(context, s.quietStartMinutes);
                    if (p != null) {
                      repo.patch({'quietStartMinutes': p.hour * 60 + p.minute});
                    }
                  },
                ),
                SettingsTile(
                  title: 'Ends',
                  trailing: Text(LunaDates.time(context, s.quietEndMinutes)),
                  onTap: () async {
                    final p = await pickMinutes(context, s.quietEndMinutes);
                    if (p != null) {
                      repo.patch({'quietEndMinutes': p.hour * 60 + p.minute});
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
