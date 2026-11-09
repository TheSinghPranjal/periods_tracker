import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/utils/health_enums.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../period_logging/presentation/period_flows.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/day_entry.dart';
import '../domain/symptom_catalog.dart';

enum DayFocus {
  all,
  symptoms,
  mood,
  note;

  static DayFocus fromName(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => DayFocus.all);
}

/// Every control saves on change, so nothing is lost if the app closes.
class DayEditor extends ConsumerStatefulWidget {
  const DayEditor({super.key, required this.date, required this.focus});
  final CalendarDate date;
  final DayFocus focus;

  @override
  ConsumerState<DayEditor> createState() => _DayEditorState();
}

class _DayEditorState extends ConsumerState<DayEditor> {
  bool _saved = false;
  Timer? _savedTimer;

  DailyLogRepository get _repo => ref.read(dailyLogRepositoryProvider);

  @override
  void dispose() {
    _savedTimer?.cancel();
    super.dispose();
  }

  Future<void> _save(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        showMessage(context, 'That couldn\'t be saved. Please try again.');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _saved = true);
    _savedTimer?.cancel();
    _savedTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _patch(DailyLogsCompanion changes) =>
      _save(() => _repo.patch(widget.date, changes));

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    if (date.isAfter(ref.watch(todayProvider))) {
      return const EmptyState(
        title: 'Not here yet',
        message: 'You can log this day when it arrives.',
      );
    }
    final focus = widget.focus;
    final s = ref.watch(currentSettingsProvider);
    return AsyncBody(
      value: ref.watch(dayEntryProvider(date)),
      builder: (entry) {
        final all = focus == DayFocus.all;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SavedTick(visible: _saved),
            ),
            if (all) ...[
              _PeriodStatus(date: date),
              _flowSection(entry),
              _painSection(entry),
            ],
            if (all || focus == DayFocus.mood) _moodSection(entry),
            if (all || focus == DayFocus.symptoms) _symptomSection(entry),
            if (all || focus == DayFocus.note) _noteSection(entry),
            if (all) ..._modules(entry, s),
          ],
        );
      },
    );
  }

  Widget _flowSection(DayEntry entry) {
    final flow = entry.flow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Flow'),
        SketchCard(
          seed: 31,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final level in FlowLevel.values)
                    SketchChip(
                      label: level.label,
                      selected: flow == level,
                      leading: FlowDrops(level: level.level, size: 15),
                      onTap: () => _patch(
                        DailyLogsCompanion(
                          flowLevel: Value(flow == level ? null : level.name),
                        ),
                      ),
                    ),
                ],
              ),
              if (flow == FlowLevel.spotting) ...[
                const SizedBox(height: 10),
                Text(
                  'Spotting is saved on its own. It won\'t start a new cycle unless you log a period.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (flow != null && flow != FlowLevel.spotting)
                _NotInPeriodPrompt(date: widget.date),
            ],
          ),
        ),
      ],
    );
  }

  Widget _painSection(DayEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Pain'),
        SketchCard(
          seed: 33,
          padding: const EdgeInsets.all(14),
          child: _IntensityRow(
            value: entry.pain,
            includeNone: true,
            onChanged: (v) => _patch(DailyLogsCompanion(painLevel: Value(v))),
          ),
        ),
      ],
    );
  }

  Widget _moodSection(DayEntry entry) {
    final t = LunaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Mood'),
        SketchCard(
          seed: 35,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.86,
                children: [
                  for (final mood in MoodKind.values)
                    Semantics(
                      button: true,
                      selected: entry.moods.contains(mood),
                      label: mood.label,
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          final next = {...entry.moods};
                          if (!next.remove(mood)) next.add(mood);
                          _save(() => _repo.setMoods(widget.date, next));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                child: MoodFace(
                                  mood: mood,
                                  size: 50,
                                  selected: entry.moods.contains(mood),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mood.label,
                              textScaler: MediaQuery.textScalerOf(
                                context,
                              ).clamp(maxScaleFactor: 1.2),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: t.ink,
                                    fontWeight: entry.moods.contains(mood)
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _AutosaveField(
                initial: entry.log?.moodNote ?? '',
                hint: 'Anything about your mood? (optional)',
                onSave: (v) => _patch(
                  DailyLogsCompanion(moodNote: Value(v.isEmpty ? null : v)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addCustom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add your own symptom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'For example, sore throat',
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
    if (name == null || name.isEmpty) return;
    await _save(() async {
      await _repo.addCustomSymptom(name);
      await _repo.setSymptom(widget.date, '$kCustomSymptomPrefix$name', 1);
    });
  }

  Widget _category(
    DayEntry entry,
    String title,
    List<SymptomDefinition> items,
  ) {
    final text = Theme.of(context).textTheme;
    final chosen = items
        .where((i) => entry.symptoms.containsKey(i.key))
        .toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SketchCard(
        seed: title.length + 40,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in items)
                  SketchChip(
                    label: item.label,
                    selected: entry.symptoms.containsKey(item.key),
                    onTap: () => _save(
                      () => _repo.setSymptom(
                        widget.date,
                        item.key,
                        entry.symptoms.containsKey(item.key) ? null : 1,
                      ),
                    ),
                  ),
              ],
            ),
            for (final item in chosen) ...[
              const SizedBox(height: 12),
              Text(
                'How strong was ${item.label.toLowerCase()}?',
                style: text.bodySmall,
              ),
              const SizedBox(height: 5),
              _IntensityRow(
                value: entry.symptoms[item.key],
                includeNone: true,
                onChanged: (v) => _save(
                  () => _repo.setSymptom(widget.date, item.key, v ?? 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _symptomSection(DayEntry entry) {
    final customNames =
        ref.watch(customSymptomsProvider).value ?? const <String>[];
    final custom = {
      ...customNames,
      ...entry.symptoms.keys
          .where((k) => k.startsWith(kCustomSymptomPrefix))
          .map((k) => k.substring(kCustomSymptomPrefix.length)),
    }.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Symptoms'),
        for (final c in kSymptomCatalog) _category(entry, c.title, c.items),
        if (custom.isNotEmpty)
          _category(entry, 'Your own', [
            for (final name in custom)
              SymptomDefinition('$kCustomSymptomPrefix$name', name),
          ]),
        SecondaryButton(
          icon: Icons.add_rounded,
          label: 'Add your own symptom',
          onPressed: _addCustom,
        ),
      ],
    );
  }

  Widget _noteSection(DayEntry entry) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle('Notes'),
      _AutosaveField(
        initial: entry.notes ?? '',
        hint: 'Write anything you\'d like to remember. Stays on this device.',
        lines: 4,
        onSave: (v) =>
            _patch(DailyLogsCompanion(notes: Value(v.isEmpty ? null : v))),
      ),
    ],
  );

  List<Widget> _modules(DayEntry entry, AppSettings s) {
    final log = entry.log;
    final usesF = s.temperatureUnit == TemperatureUnit.fahrenheit;
    final usesLb = s.weightUnit == WeightUnit.pounds;
    final tempC = entry.temperature?.temperatureCelsius;
    final text = Theme.of(context).textTheme;

    Widget card(int seed, Widget child) =>
        SketchCard(seed: seed, padding: const EdgeInsets.all(14), child: child);

    return [
      if (s.trackTemperature) ...[
        const SectionTitle('Basal body temperature'),
        card(
          51,
          _NumberField(
            initial: tempC == null
                ? null
                : (usesF ? tempC * 9 / 5 + 32 : tempC),
            unit: usesF ? '°F' : '°C',
            decimals: 2,
            min: usesF ? 93 : 34,
            max: usesF ? 108 : 42,
            onSave: (v) {
              final now = TimeOfDay.now();
              final minutes =
                  entry.temperature?.measurementMinutes ??
                  now.hour * 60 + now.minute;
              return _save(
                () => _repo.setTemperature(
                  widget.date,
                  v == null ? null : (usesF ? (v - 32) * 5 / 9 : v),
                  minutes: minutes,
                ),
              );
            },
          ),
        ),
      ],
      if (s.trackMucus) ...[
        const SectionTitle('Cervical mucus'),
        card(
          53,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in MucusType.values)
                SketchChip(
                  label: m.label,
                  selected: log?.cervicalMucus == m.name,
                  onTap: () => _patch(
                    DailyLogsCompanion(
                      cervicalMucus: Value(
                        log?.cervicalMucus == m.name ? null : m.name,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      if (s.trackOvulationTests) ...[
        const SectionTitle('Ovulation test'),
        card(
          55,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in OvulationTestResult.values)
                    SketchChip(
                      label: o.label,
                      selected: log?.ovulationTest == o.name,
                      onTap: () => _patch(
                        DailyLogsCompanion(
                          ovulationTest: Value(
                            log?.ovulationTest == o.name ? null : o.name,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'A test result is your own observation. It doesn\'t change the calendar estimates.',
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ],
      if (s.trackWeight) ...[
        const SectionTitle('Weight'),
        card(
          57,
          _NumberField(
            initial: log?.weightKg == null
                ? null
                : (usesLb ? log!.weightKg! * 2.20462 : log!.weightKg),
            unit: usesLb ? 'lb' : 'kg',
            decimals: 1,
            min: usesLb ? 44 : 20,
            max: usesLb ? 880 : 400,
            onSave: (v) => _patch(
              DailyLogsCompanion(
                weightKg: Value(v == null ? null : (usesLb ? v / 2.20462 : v)),
              ),
            ),
          ),
        ),
      ],
      if (s.trackSleep) ...[
        const SectionTitle('Sleep'),
        card(
          59,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberField(
                initial: log?.sleepHours,
                unit: 'hours',
                decimals: 1,
                min: 0,
                max: 24,
                onSave: (v) => _patch(DailyLogsCompanion(sleepHours: Value(v))),
              ),
              const SizedBox(height: 10),
              Text('Sleep quality', style: text.bodySmall),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (value, label) in const [
                    (0, 'Poor'),
                    (1, 'Fair'),
                    (2, 'Good'),
                    (3, 'Great'),
                  ])
                    SketchChip(
                      label: label,
                      selected: log?.sleepQuality == value,
                      onTap: () => _patch(
                        DailyLogsCompanion(
                          sleepQuality: Value(
                            log?.sleepQuality == value ? null : value,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
      if (s.trackSexualActivity) ...[
        const SectionTitle('Private log'),
        _PrivateActivity(log: log, onPatch: _patch),
      ],
    ];
  }
}

/// Collapsed by default so nothing shows if someone glances at the screen.
class _PrivateActivity extends StatefulWidget {
  const _PrivateActivity({required this.log, required this.onPatch});
  final DailyLog? log;
  final Future<void> Function(DailyLogsCompanion) onPatch;

  @override
  State<_PrivateActivity> createState() => _PrivateActivityState();
}

class _PrivateActivityState extends State<_PrivateActivity> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    return SketchCard(
      seed: 61,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTile(
            title: _open ? 'Hide' : 'Tap to show',
            trailing: Icon(
              _open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            onTap: () => setState(() => _open = !_open),
          ),
          if (_open) ...[
            SwitchTile(
              title: 'Sexual activity',
              value: log?.sexualActivity ?? false,
              onChanged: (v) => widget.onPatch(
                DailyLogsCompanion(
                  sexualActivity: Value(v ? true : null),
                  protection: v ? const Value.absent() : const Value(null),
                ),
              ),
            ),
            if (log?.sexualActivity ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in const [
                      'Protected',
                      'Unprotected',
                      'Prefer not to say',
                    ])
                      SketchChip(
                        label: option,
                        selected: log?.protection == option,
                        onTap: () => widget.onPatch(
                          DailyLogsCompanion(
                            protection: Value(
                              log?.protection == option ? null : option,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PeriodStatus extends ConsumerWidget {
  const _PeriodStatus({required this.date});
  final CalendarDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final periods = ref.watch(periodsProvider).value ?? const <PeriodRecord>[];
    final current = periods
        .where((p) => date.isWithin(p.startDate, p.endDate ?? today))
        .firstOrNull;
    final text = Theme.of(context).textTheme;
    final dates = ref.watch(lunaDatesProvider);
    return SketchCard(
      seed: 29,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            current == null
                ? 'This day isn\'t part of a period.'
                : 'Part of your period from ${dates.short(current.startDate)}.',
            style: text.titleSmall,
          ),
          const SizedBox(height: 10),
          if (current == null)
            PrimaryButton(
              label: 'Log a period on this day',
              onPressed: () => logPeriodOn(context, ref, date),
            )
          else
            Row(
              children: [
                if (current.endDate == null) ...[
                  Expanded(
                    child: PrimaryButton(
                      label: 'End Period',
                      onPressed: () => endPeriodFlow(context, ref, current),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: SecondaryButton(
                    label: 'Edit dates',
                    onPressed: () => showPeriodEditor(context, current),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NotInPeriodPrompt extends ConsumerWidget {
  const _NotInPeriodPrompt({required this.date});
  final CalendarDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final periods = ref.watch(periodsProvider).value ?? const <PeriodRecord>[];
    if (periods.any((p) => date.isWithin(p.startDate, p.endDate ?? today))) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Did your period start on this day? Flow alone doesn\'t change your cycle.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => logPeriodOn(context, ref, date),
            child: const Text('Yes, log it'),
          ),
        ],
      ),
    );
  }
}

class _IntensityRow extends StatelessWidget {
  const _IntensityRow({
    required this.value,
    required this.onChanged,
    this.includeNone = false,
  });
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool includeNone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = includeNone ? 0 : 1; i < kIntensityLabels.length; i++)
          SketchChip(
            label: kIntensityLabels[i],
            selected: value == i,
            onTap: () => onChanged(value == i ? null : i),
          ),
      ],
    );
  }
}

class _AutosaveField extends StatefulWidget {
  const _AutosaveField({
    required this.initial,
    required this.hint,
    required this.onSave,
    this.lines = 1,
  });
  final String initial;
  final String hint;
  final Future<void> Function(String) onSave;
  final int lines;

  @override
  State<_AutosaveField> createState() => _AutosaveFieldState();
}

class _AutosaveFieldState extends State<_AutosaveField> {
  late final _controller = TextEditingController(text: widget.initial);
  Timer? _timer;
  String _lastSaved = '';

  @override
  void initState() {
    super.initState();
    _lastSaved = widget.initial;
  }

  void _flush() {
    _timer?.cancel();
    final value = _controller.text.trim();
    if (value != _lastSaved) {
      _lastSaved = value;
      widget.onSave(value);
    }
  }

  @override
  void dispose() {
    _flush();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: widget.lines,
      maxLines: widget.lines + 4,
      maxLength: 2000,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: widget.hint),
      onChanged: (_) {
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 600), _flush);
      },
      onEditingComplete: _flush,
      onTapOutside: (_) {
        _flush();
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.initial,
    required this.unit,
    required this.decimals,
    required this.min,
    required this.max,
    required this.onSave,
  });
  final double? initial;
  final String unit;
  final int decimals;
  final double min;
  final double max;
  final Future<void> Function(double?) onSave;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final _controller = TextEditingController(
    text: widget.initial?.toStringAsFixed(widget.decimals) ?? '',
  );
  String? _error;

  void _commit() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      setState(() => _error = null);
      if (widget.initial != null) widget.onSave(null);
      return;
    }
    final value = double.tryParse(raw);
    if (value == null || value < widget.min || value > widget.max) {
      setState(
        () => _error =
            'Enter a value from ${widget.min.toStringAsFixed(0)} to ${widget.max.toStringAsFixed(0)}.',
      );
      return;
    }
    setState(() => _error = null);
    if (value != widget.initial) widget.onSave(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        suffixText: widget.unit,
        errorText: _error,
        hintText: 'Tap to enter',
      ),
      onEditingComplete: () {
        _commit();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onTapOutside: (_) {
        _commit();
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
