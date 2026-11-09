import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../period_logging/presentation/period_flows.dart';
import '../domain/insights_calculator.dart';

const _pageSize = 24;

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _newestFirst = true;
  int _visible = _pageSize;

  @override
  Widget build(BuildContext context) {
    final periods = ref.watch(periodsProvider);
    final days = ref.watch(allDaysProvider).value ?? const [];
    final today = ref.watch(todayProvider);
    return LunaPage(
      title: 'Cycle history',
      subtitle: 'Tap a cycle to see details or make a correction.',
      showBack: true,
      actions: [
        IconButton(
          tooltip: _newestFirst ? 'Show oldest first' : 'Show newest first',
          icon: const Icon(Icons.swap_vert_rounded),
          onPressed: () => setState(() => _newestFirst = !_newestFirst),
        ),
        IconButton(
          tooltip: 'Add a past period',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => showPeriodEditor(context, null),
        ),
      ],
      children: [
        AsyncBody(
          value: periods,
          builder: (records) {
            if (records.isEmpty) {
              return EmptyState(
                title: 'No periods recorded yet',
                message: 'Add your first period to begin your history.',
                action: PrimaryButton(
                  label: 'Add a period',
                  onPressed: () => showPeriodEditor(context, null),
                ),
              );
            }
            final data = computeInsights(
              periods: ref.watch(periodSpansProvider),
              days: days,
              today: today,
            );
            final ordered = _newestFirst
                ? data.cycles.reversed.toList()
                : data.cycles;
            final byId = {for (final r in records) r.id: r};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in ordered.take(_visible))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CycleTile(cycle: c, record: byId[c.period.id]!),
                  ),
                if (ordered.length > _visible)
                  SecondaryButton(
                    label: 'Show more',
                    onPressed: () => setState(() => _visible += _pageSize),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CycleTile extends ConsumerWidget {
  const _CycleTile({required this.cycle, required this.record});
  final CycleSummary cycle;
  final PeriodRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = ref.watch(lunaDatesProvider);
    final text = Theme.of(context).textTheme;
    final c = cycle;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 108, child: Text(label, style: text.bodySmall)),
          Expanded(child: Text(value, style: text.bodyMedium)),
        ],
      ),
    );
    final title = c.period.end == null
        ? '${dates.medium(c.period.start)} – ongoing'
        : '${dates.short(c.period.start)} – ${dates.medium(c.period.end!)}';
    return SketchCard(
      seed: c.period.start.epochDay % 50,
      onTap: () => showPeriodEditor(context, record),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleSmall),
          const SizedBox(height: 6),
          row(
            'Period length',
            c.periodLength == null ? 'Not finished' : '${c.periodLength} days',
          ),
          row(
            'Cycle length',
            c.cycleLength != null
                ? '${c.cycleLength} days'
                : (c.nextStart == null
                      ? 'Current cycle'
                      : 'Not counted (unusual gap)'),
          ),
          if (c.topSymptoms.isNotEmpty)
            row('Symptoms', c.topSymptoms.join(', ')),
          if (c.notesCount > 0)
            row(
              'Notes',
              '${c.notesCount} ${c.notesCount == 1 ? 'day' : 'days'} with notes',
            ),
        ],
      ),
    );
  }
}
