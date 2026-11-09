import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sakura_art.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../onboarding/presentation/onboarding_screen.dart'
    show kFertilityWarning;
import '../../period_logging/presentation/period_flows.dart';
import '../../premium/presentation/premium_screen.dart' show premiumProvider;
import '../../prediction/domain/cycle_prediction_engine.dart';
import '../domain/app_settings.dart';

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.allowNone = false,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final int? value;
  final int min;
  final int max;
  final bool allowNone;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      trailing: DropdownButton<int?>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          if (allowNone)
            const DropdownMenuItem<int?>(value: null, child: Text('Not set')),
          for (var i = min; i <= max; i++)
            DropdownMenuItem<int?>(value: i, child: Text('$i')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class CycleSettingsScreen extends ConsumerWidget {
  const CycleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final prediction = ref.watch(predictionProvider).value;
    final dates = ref.watch(lunaDatesProvider);
    final today = ref.watch(todayProvider);
    return LunaPage(
      title: 'Cycle settings',
      subtitle: 'Changes update your estimates straight away.',
      showBack: true,
      children: [
        SketchCard(
          seed: 3,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              _NumberTile(
                title: 'Usual cycle length',
                subtitle: 'Days, first day to first day',
                value: s.usualCycleLength,
                min: 15,
                max: 60,
                allowNone: true,
                onChanged: (v) => repo.patch({'usualCycleLength': v}),
              ),
              _NumberTile(
                title: 'Usual period length',
                subtitle: 'Days of bleeding',
                value: s.usualPeriodLength,
                min: 1,
                max: 10,
                allowNone: true,
                onChanged: (v) => repo.patch({'usualPeriodLength': v}),
              ),
              SettingsTile(
                title: 'Regularity',
                trailing: DropdownButton<Regularity>(
                  value: s.regularity,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: Regularity.regular,
                      child: Text('Usually regular'),
                    ),
                    DropdownMenuItem(
                      value: Regularity.sometimesIrregular,
                      child: Text('Sometimes irregular'),
                    ),
                    DropdownMenuItem(
                      value: Regularity.veryIrregular,
                      child: Text('Very irregular'),
                    ),
                    DropdownMenuItem(
                      value: Regularity.notSure,
                      child: Text('Not sure'),
                    ),
                  ],
                  onChanged: (v) => repo.patch({'regularity': v!.name}),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Estimates'),
        SketchCard(
          seed: 5,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              _NumberTile(
                title: 'Cycles used for estimates',
                subtitle: 'Most recent cycles counted',
                value: s.historyWindow,
                min: 3,
                max: 12,
                onChanged: (v) => repo.patch({'historyWindow': v}),
              ),
              SettingsTile(
                title: 'Adjust next period date',
                subtitle: s.manualNextStart != null
                    ? 'Set by you: ${dates.medium(s.manualNextStart!)}'
                    : 'If you know better than the estimate',
                trailing: s.manualNextStart == null
                    ? null
                    : TextButton(
                        onPressed: () => repo.patch({
                          'manualNextStart': null,
                          'manualAnchor': null,
                        }),
                        child: const Text('Clear'),
                      ),
                onTap: prediction?.lastStart == null
                    ? null
                    : () async {
                        final d = await pickDate(
                          context,
                          initial:
                              prediction!.predictedStart ?? today.plusDays(1),
                          first: prediction.lastStart!.plusDays(1),
                          last: today.plusDays(120),
                          help: 'Expected first day',
                        );
                        if (d != null) {
                          repo.patch({
                            'manualNextStart': d.toIso(),
                            'manualAnchor': prediction.lastStart!.toIso(),
                          });
                        }
                      },
              ),
            ],
          ),
        ),
        const SectionTitle('Fertility estimates'),
        SketchCard(
          seed: 7,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SwitchTile(
                title: 'Show fertility estimates',
                subtitle: 'Off unless you want them',
                value: s.fertilityEstimatesEnabled,
                onChanged: (v) => repo.patch({'fertilityEstimatesEnabled': v}),
              ),
              if (s.fertilityEstimatesEnabled)
                _NumberTile(
                  title: 'Luteal phase assumption',
                  subtitle: '14 days is common but not universal',
                  value: s.lutealDays,
                  min: 9,
                  max: 18,
                  onChanged: (v) => repo.patch({'lutealDays': v}),
                ),
            ],
          ),
        ),
        if (s.fertilityEstimatesEnabled) ...[
          const SizedBox(height: 10),
          const PrivacyNotice(kFertilityWarning, warning: true),
        ],
      ],
    );
  }
}

class TrackingModulesScreen extends ConsumerWidget {
  const TrackingModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    SwitchTile tile(String title, String key, bool value, [String? sub]) =>
        SwitchTile(
          title: title,
          subtitle: sub,
          value: value,
          onChanged: (v) => repo.patch({key: v}),
        );
    return LunaPage(
      title: 'What to track',
      subtitle:
          'Everything here is optional and off by default. Turned-on sections appear on the Log page.',
      showBack: true,
      children: [
        const SectionTitle('Your goals'),
        SketchCard(
          seed: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              for (final (goal, label) in const [
                (TrackingGoal.understandCycle, 'Understand my cycle'),
                (TrackingGoal.symptomsAndMoods, 'Track symptoms and moods'),
                (TrackingGoal.planPregnancy, 'Plan for pregnancy'),
                (TrackingGoal.justPeriod, 'Just track my period'),
              ])
                SwitchTile(
                  title: label,
                  value: s.goals.contains(goal),
                  onChanged: (v) => repo.patch({
                    'goals': [
                      for (final g in {...s.goals, goal})
                        if (g != goal || v) g.name,
                    ],
                  }),
                ),
            ],
          ),
        ),
        const SectionTitle('Optional sections'),
        SketchCard(
          seed: 9,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              tile(
                'Basal body temperature',
                'trackTemperature',
                s.trackTemperature,
              ),
              tile('Cervical mucus', 'trackMucus', s.trackMucus),
              tile(
                'Ovulation tests',
                'trackOvulationTests',
                s.trackOvulationTests,
              ),
              tile('Weight', 'trackWeight', s.trackWeight),
              tile('Sleep', 'trackSleep', s.trackSleep),
              tile(
                'Sexual activity',
                'trackSexualActivity',
                s.trackSexualActivity,
                'A private section, hidden until you tap to show it',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const PrivacyNotice(
          'Turning a section off hides it. Anything you already logged is kept until you delete it.',
        ),
      ],
    );
  }
}

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final unlocked = ref.watch(premiumProvider).entitled;
    final dark = Theme.of(context).brightness;
    return LunaPage(
      title: 'Appearance',
      showBack: true,
      children: [
        const SectionTitle('Theme'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (mode, label) in const [
              (AppThemeMode.system, 'Follow system'),
              (AppThemeMode.light, 'Light'),
              (AppThemeMode.dark, 'Dark'),
            ])
              SketchChip(
                label: label,
                selected: s.themeMode == mode,
                onTap: () => repo.patch({'themeMode': mode.name}),
              ),
          ],
        ),
        const SectionTitle('Colours'),
        for (final p in AppPalette.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(
              builder: (context) {
                final preview = LunaTokens.resolve(p, dark);
                final locked = p.premium && !unlocked;
                return SketchCard(
                  seed: p.index + 11,
                  fill: s.palette == p ? preview.pale : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  semanticLabel:
                      '${p.label}${locked ? ', part of LunaCycle Plus' : ''}${s.palette == p ? ', selected' : ''}',
                  onTap: () {
                    if (locked) {
                      context.push('/premium');
                    } else {
                      repo.patch({'palette': p.name});
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 36,
                        child: CustomPaint(painter: _SwatchPainter(preview)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (locked)
                        const Icon(Icons.lock_outline_rounded, size: 19),
                      if (s.palette == p) const Icon(Icons.check_rounded),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.t);
  final LunaTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    drawBlossom(
      canvas,
      size.center(Offset.zero),
      size.width / 2,
      0.2,
      BlossomInk(fill: t.blossom, edge: t.blossomEdge, core: t.blossomCore),
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.t != t;
}

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    DropdownButton<T> pick<T>(
      T value,
      List<(T, String)> options,
      ValueChanged<T> onChanged,
    ) => DropdownButton<T>(
      value: value,
      underline: const SizedBox.shrink(),
      items: [
        for (final (v, label) in options)
          DropdownMenuItem(value: v, child: Text(label)),
      ],
      onChanged: (v) => onChanged(v as T),
    );
    return LunaPage(
      title: 'General',
      showBack: true,
      children: [
        SketchCard(
          seed: 13,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              const SettingsTile(
                title: 'Language',
                subtitle: 'English is the only language available so far',
              ),
              SettingsTile(
                title: 'Date format',
                trailing: pick(s.dateFormat, const [
                  (DateFormatStyle.dayFirst, '31 Dec'),
                  (DateFormatStyle.monthFirst, 'Dec 31'),
                  (DateFormatStyle.yearFirst, '2026-12-31'),
                ], (v) => repo.patch({'dateFormat': v.name})),
              ),
              SettingsTile(
                title: 'First day of week',
                trailing: pick(s.firstDayOfWeek, const [
                  (DateTime.monday, 'Monday'),
                  (DateTime.saturday, 'Saturday'),
                  (DateTime.sunday, 'Sunday'),
                ], (v) => repo.patch({'firstDayOfWeek': v})),
              ),
              SettingsTile(
                title: 'Temperature unit',
                trailing: pick(s.temperatureUnit, const [
                  (TemperatureUnit.celsius, '°C'),
                  (TemperatureUnit.fahrenheit, '°F'),
                ], (v) => repo.patch({'temperatureUnit': v.name})),
              ),
              SettingsTile(
                title: 'Weight unit',
                trailing: pick(s.weightUnit, const [
                  (WeightUnit.kilograms, 'kg'),
                  (WeightUnit.pounds, 'lb'),
                ], (v) => repo.patch({'weightUnit': v.name})),
              ),
            ],
          ),
        ),
        const SectionTitle('Accessibility'),
        SketchCard(
          seed: 15,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SwitchTile(
                title: 'Reduce motion',
                subtitle: 'Turns off animations in the app',
                value: s.reduceMotion,
                onChanged: (v) => repo.patch({'reduceMotion': v}),
              ),
              SettingsTile(
                title: 'Show instructions again',
                subtitle: 'Brings back the "how to" notes on each page',
                onTap: () {
                  ref.read(dismissedGuidesProvider.notifier).resetAll();
                  showMessage(context, 'Instructions are back on every page.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
