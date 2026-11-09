import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../onboarding/presentation/onboarding_screen.dart'
    show kFertilityWarning;
import '../../period_logging/presentation/period_flows.dart';
import '../../symptoms/domain/symptom_catalog.dart';
import 'calendar_widgets.dart';

Future<void> showDayDetails(BuildContext context, CalendarDate date) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DayDetailsSheet(date: date),
    );

class DayDetailsSheet extends ConsumerWidget {
  const DayDetailsSheet({super.key, required this.date});
  final CalendarDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    final dates = ref.watch(lunaDatesProvider);
    final today = ref.watch(todayProvider);
    final visual = ref.watch(calendarDataProvider(date));
    final entry = ref.watch(dayEntryProvider(date)).value;
    final periods = ref.watch(periodsProvider).value ?? const [];
    final isFuture = date.isAfter(today);
    final inPeriod = periods
        .where((p) => date.isWithin(p.startDate, p.endDate ?? today))
        .firstOrNull;

    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label, style: text.bodySmall)),
          Expanded(child: value),
        ],
      ),
    );
    Widget plain(String s) => Text(s, style: text.bodyMedium);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(dates.full(date), style: text.titleLarge),
              ),
              const SizedBox(height: 10),
              row('Status', plain(periodStatusWords(visual))),
              if (entry?.flow != null)
                row(
                  'Flow',
                  Row(
                    children: [
                      FlowDrops(level: entry!.flow!.level, size: 18),
                      const SizedBox(width: 6),
                      plain(entry.flow!.label),
                    ],
                  ),
                ),
              if (entry?.symptoms.isNotEmpty ?? false)
                row(
                  'Symptoms',
                  plain(
                    entry!.symptoms.entries
                        .map(
                          (e) =>
                              '${symptomLabel(e.key)} (${intensityWord(e.value)})',
                        )
                        .join(', '),
                  ),
                ),
              if (entry?.moods.isNotEmpty ?? false)
                row('Mood', plain(entry!.moods.map((m) => m.label).join(', '))),
              if (entry?.pain != null)
                row('Pain', plain(intensityWord(entry!.pain!))),
              if (entry?.hasNote ?? false) row('Notes', plain(entry!.notes!)),
              if (entry?.isEmpty ?? true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Nothing logged on this day.',
                    style: text.bodyMedium?.copyWith(color: t.inkSoft),
                  ),
                ),
              if (visual.fertile || visual.ovulation) ...[
                const SizedBox(height: 6),
                const PrivacyNotice(kFertilityWarning, warning: true),
              ],
              const SizedBox(height: 14),
              if (isFuture)
                Text(
                  'You can log this day when it arrives.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium,
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: inPeriod == null
                          ? PrimaryButton(
                              label: 'Log Period',
                              onPressed: () {
                                Navigator.pop(context);
                                logPeriodOn(context, ref, date);
                              },
                            )
                          : PrimaryButton(
                              label: 'Edit Period',
                              onPressed: () {
                                Navigator.pop(context);
                                showPeriodEditor(context, inPeriod);
                              },
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Add Symptoms',
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/day/${date.toIso()}?focus=symptoms');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Edit Entry',
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/day/${date.toIso()}');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Remove Entry',
                        destructive: true,
                        onPressed: entry == null || entry.isEmpty
                            ? null
                            : () async {
                                final ok = await confirmAction(
                                  context,
                                  title: 'Remove this day\'s entry?',
                                  message:
                                      'Flow, symptoms, mood and notes for this day will be removed. '
                                      'Period dates are not changed.',
                                  confirmLabel: 'Remove',
                                  destructive: true,
                                );
                                if (!ok || !context.mounted) return;
                                final messenger = ScaffoldMessenger.of(context);
                                final repo = ref.read(
                                  dailyLogRepositoryProvider,
                                );
                                final removed = await repo.deleteDay(date);
                                if (context.mounted) Navigator.pop(context);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text('Entry removed.'),
                                    persist: false,
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () => repo.restoreDay(removed),
                                    ),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
