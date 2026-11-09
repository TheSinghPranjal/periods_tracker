import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/utils/health_enums.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/insights_calculator.dart';
import 'chart_cards.dart';

const _guide = GuideContent(
  id: 'insights',
  title: 'Reading your insights',
  steps: [
    'Choose a time range. Everything below updates to match.',
    'Charts appear once you have logged enough. Two recorded cycles is a good start.',
    'Tap a point on a chart for details, or use Show as table.',
  ],
);

final insightsRangeProvider = NotifierProvider<_RangeNotifier, int?>(
  _RangeNotifier.new,
);

class _RangeNotifier extends Notifier<int?> {
  @override
  int? build() => 6;
  void pick(int? months) => state = months;
}

final insightsProvider = Provider<AsyncValue<InsightsData>>((ref) {
  final periods = ref.watch(periodsProvider);
  final days = ref.watch(allDaysProvider);
  if (periods.hasError || days.hasError) {
    return AsyncError(periods.error ?? days.error!, StackTrace.current);
  }
  if (!periods.hasValue || !days.hasValue) return const AsyncLoading();
  return AsyncData(
    computeInsights(
      periods: ref.watch(periodSpansProvider),
      days: days.requireValue,
      today: ref.watch(todayProvider),
      monthsBack: ref.watch(insightsRangeProvider),
    ),
  );
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(insightsRangeProvider);
    return LunaPage(
      title: 'Insights',
      subtitle: 'Patterns from what you have logged',
      guide: _guide,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (months, label) in const [
              (3, '3 mo'),
              (6, '6 mo'),
              (12, '12 mo'),
              (null, 'All'),
            ])
              SketchChip(
                label: label,
                selected: range == months,
                onTap: () =>
                    ref.read(insightsRangeProvider.notifier).pick(months),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AsyncBody(
          value: ref.watch(insightsProvider),
          builder: (d) => _Body(data: d),
        ),
        const SizedBox(height: 4),
        SecondaryButton(
          icon: Icons.history_rounded,
          label: 'See cycle history',
          onPressed: () => context.push('/history'),
        ),
        const SizedBox(height: 10),
        Text(
          'These are summaries of your own entries. They are not a diagnosis or medical advice.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.data});
  final InsightsData data;

  String _fmt(double? v) =>
      v == null ? '—' : v.toStringAsFixed(1).replaceAll('.0', '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = data;
    final dates = ref.watch(lunaDatesProvider);
    final s = ref.watch(currentSettingsProvider);
    final text = Theme.of(context).textTheme;
    final usesF = s.temperatureUnit == TemperatureUnit.fahrenheit;

    if (d.cycles.isEmpty && d.symptomCounts.isEmpty && d.moodCounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: EmptyState(
          title: 'Nothing to show yet',
          message:
              'Insights will appear here as you log periods, symptoms and moods.',
        ),
      );
    }

    final stats = [
      (
        'Average cycle',
        d.averageCycle == null ? '—' : '${_fmt(d.averageCycle)} days',
      ),
      (
        'Average period',
        d.averagePeriod == null ? '—' : '${_fmt(d.averagePeriod)} days',
      ),
      (
        'Shortest cycle',
        d.shortestCycle == null ? '—' : '${d.shortestCycle} days',
      ),
      (
        'Longest cycle',
        d.longestCycle == null ? '—' : '${d.longestCycle} days',
      ),
      ('Variability', d.variability == null ? '—' : '${d.variability} days'),
      ('Recorded cycles', '${d.recordedCycles}'),
    ];

    List<(String, String)> table(List<SeriesPoint> series, String unit) => [
      for (final p in series)
        (
          dates.medium(p.date),
          '${p.value.toStringAsFixed(p.value % 1 == 0 ? 0 : 2)} $unit',
        ),
    ];

    String summary(String what, List<SeriesPoint> series, String unit) {
      final values = series.map((p) => p.value).toList()..sort();
      return '$what: ${series.length} values, from ${values.first.toStringAsFixed(0)} to ${values.last.toStringAsFixed(0)} $unit.';
    }

    List<double> temps() => [
      for (final p in d.temperatureSeries)
        usesF ? p.value * 9 / 5 + 32 : p.value,
    ];

    final topSymptoms = d.symptomCounts.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.9,
          children: [
            for (final (i, (label, value)) in stats.indexed)
              SketchCard(
                seed: 80 + i,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(value, style: text.headlineSmall),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(label, style: text.bodySmall),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (d.statements.isNotEmpty) ...[
          SketchCard(
            seed: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in d.statements)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: BlossomIcon(size: 14),
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Text(line, style: text.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (d.cycleSeries.length >= 2)
          ChartCard(
            title: 'Cycle length',
            description: summary('Cycle length', d.cycleSeries, 'days'),
            rows: table(d.cycleSeries, 'days'),
            chart: TrendLine(
              values: d.cycleSeries.map((p) => p.value).toList(),
              labels: d.cycleSeries.map((p) => dates.short(p.date)).toList(),
              unit: 'days',
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: EmptyState(
              title: 'Cycle trend needs more history',
              message:
                  'This chart appears after two complete cycles are recorded.',
            ),
          ),
        if (d.periodSeries.length >= 2)
          ChartCard(
            title: 'Period duration',
            seed: 72,
            description: summary('Period duration', d.periodSeries, 'days'),
            rows: table(d.periodSeries, 'days'),
            chart: CountBars(
              values: d.periodSeries.map((p) => p.value).toList(),
              labels: d.periodSeries.map((p) => dates.short(p.date)).toList(),
            ),
          ),
        if (topSymptoms.isNotEmpty)
          ChartCard(
            title: 'Most logged symptoms',
            seed: 73,
            description:
                'Symptoms by number of days logged. ${topSymptoms.map((e) => '${e.label}: ${e.count}').join(', ')}.',
            rows: [
              for (final e in d.symptomCounts) (e.label, '${e.count} days'),
            ],
            chart: CountBars(
              values: topSymptoms.map((e) => e.count.toDouble()).toList(),
              labels: topSymptoms.map((e) => e.label).toList(),
            ),
          ),
        if (d.moodCounts.isNotEmpty)
          ChartCard(
            title: 'Mood distribution',
            seed: 74,
            description:
                'Moods by number of days logged. ${d.moodCounts.map((e) => '${e.label}: ${e.count}').join(', ')}.',
            rows: [for (final e in d.moodCounts) (e.label, '${e.count} days')],
            chart: CountBars(
              values: d.moodCounts.map((e) => e.count.toDouble()).toList(),
              labels: d.moodCounts.map((e) => e.label).toList(),
              iconFor: (i) => MoodFace(
                mood: MoodKind.values.byName(d.moodCounts[i].key),
                size: 30,
              ),
            ),
          ),
        if (d.painSeries.length >= 2)
          ChartCard(
            title: 'Pain over time',
            seed: 75,
            description: summary(
              'Pain, on a scale of 0 to 3',
              d.painSeries,
              '',
            ),
            rows: [
              for (final p in d.painSeries)
                (dates.medium(p.date), intensityWord(p.value.toInt())),
            ],
            chart: TrendLine(
              values: d.painSeries.map((p) => p.value).toList(),
              labels: d.painSeries.map((p) => dates.short(p.date)).toList(),
              unit: 'of 3',
              minY: 0,
              maxY: 3,
              leftLabel: (v) =>
                  v == v.roundToDouble() ? intensityWord(v.toInt()) : '',
            ),
          ),
        if (d.flowSeries.length >= 2)
          ChartCard(
            title: 'Flow over time',
            seed: 76,
            description: summary(
              'Flow, from spotting 0 to very heavy 4',
              d.flowSeries,
              '',
            ),
            rows: [
              for (final p in d.flowSeries)
                (dates.medium(p.date), FlowLevel.values[p.value.toInt()].label),
            ],
            chart: TrendLine(
              values: d.flowSeries.map((p) => p.value).toList(),
              labels: d.flowSeries.map((p) => dates.short(p.date)).toList(),
              unit: 'of 4',
              minY: 0,
              maxY: 4,
              leftLabel: (v) => v == v.roundToDouble()
                  ? FlowLevel.values[v.toInt()].label
                  : '',
            ),
          ),
        if (s.trackTemperature && d.temperatureSeries.length >= 2)
          ChartCard(
            title: 'Temperature',
            seed: 77,
            description: summary(
              'Basal temperature',
              d.temperatureSeries,
              usesF ? 'degrees Fahrenheit' : 'degrees Celsius',
            ),
            rows: [
              for (final (i, p) in d.temperatureSeries.indexed)
                (
                  dates.medium(p.date),
                  '${temps()[i].toStringAsFixed(2)} ${usesF ? '°F' : '°C'}',
                ),
            ],
            chart: TrendLine(
              values: temps(),
              labels: d.temperatureSeries
                  .map((p) => dates.short(p.date))
                  .toList(),
              unit: usesF ? '°F' : '°C',
            ),
          ),
        if (s.trackWeight && d.weightSeries.length >= 2)
          Builder(
            builder: (context) {
              final usesLb = s.weightUnit == WeightUnit.pounds;
              final unit = usesLb ? 'lb' : 'kg';
              final values = [
                for (final p in d.weightSeries)
                  usesLb ? p.value * 2.20462 : p.value,
              ];
              return ChartCard(
                title: 'Weight',
                seed: 78,
                description: summary('Weight', [
                  for (final (i, p) in d.weightSeries.indexed)
                    SeriesPoint(p.date, values[i]),
                ], usesLb ? 'pounds' : 'kilograms'),
                rows: [
                  for (final (i, p) in d.weightSeries.indexed)
                    (
                      dates.medium(p.date),
                      '${values[i].toStringAsFixed(1)} $unit',
                    ),
                ],
                chart: TrendLine(
                  values: values,
                  labels: d.weightSeries
                      .map((p) => dates.short(p.date))
                      .toList(),
                  unit: unit,
                ),
              );
            },
          ),
        if (s.trackSleep && d.sleepSeries.length >= 2)
          ChartCard(
            title: 'Sleep',
            seed: 79,
            description: summary('Sleep', d.sleepSeries, 'hours'),
            rows: table(d.sleepSeries, 'hours'),
            chart: TrendLine(
              values: d.sleepSeries.map((p) => p.value).toList(),
              labels: d.sleepSeries.map((p) => dates.short(p.date)).toList(),
              unit: 'hours',
            ),
          ),
        if (d.cycles.isEmpty)
          Text(
            'No cycles in this range.',
            style: text.bodyMedium?.copyWith(
              color: LunaTokens.of(context).inkSoft,
            ),
          ),
      ],
    );
  }
}
