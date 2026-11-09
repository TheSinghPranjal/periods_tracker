import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sakura_art.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';
import '../../privacy/presentation/lock_screen.dart';
import '../../settings/domain/app_settings.dart';

const kFertilityWarning =
    'These estimates cannot reliably prevent pregnancy and are not a contraceptive method.';

class _Draft {
  final goals = <TrackingGoal>{};
  CalendarDate? lastPeriod;
  bool dontRemember = false;
  int? periodLength = 5;
  int? cycleLength = 28;
  Regularity regularity = Regularity.notSure;
  bool remindPeriod = false;
  bool remindDaily = false;
  bool remindMedication = false;
  bool remindFertile = false;
  bool fertility = false;
  String nickname = '';
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _lastStep = 8;
  final _draft = _Draft();
  int _step = 0;
  bool _saving = false;
  String? _permissionNote;
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _go(int step) => setState(() {
    _step = step;
    _permissionNote = null;
  });

  Future<void> _setReminder(void Function(bool) apply, bool value) async {
    if (value) {
      final granted = await ref
          .read(notificationGatewayProvider)
          .requestPermission();
      if (!granted) {
        setState(
          () => _permissionNote =
              'Notifications are turned off for LunaCycle in your device settings, so this reminder '
              'can\'t be switched on yet. You can turn it on later.',
        );
        return;
      }
    }
    setState(() {
      apply(value);
      _permissionNote = null;
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final d = _draft;
    final today = ref.read(todayProvider);
    final settings = AppSettings(
      onboardingCompleted: true,
      nickname: d.nickname.trim().isEmpty ? null : d.nickname.trim(),
      goals: d.goals,
      usualCycleLength: d.cycleLength,
      usualPeriodLength: d.periodLength,
      regularity: d.regularity,
      fertilityEstimatesEnabled: d.fertility,
    );
    final last = d.lastPeriod;
    if (last != null) {
      // Older than the usual length: it has ended. Otherwise leave it open
      // so nothing is claimed about a period that may still be going.
      CalendarDate? end;
      final usual = d.periodLength;
      if (usual != null && last.plusDays(usual - 1).isBefore(today)) {
        end = last.plusDays(usual - 1);
      }
      await ref
          .read(periodRepositoryProvider)
          .add(start: last, end: end, source: 'onboarding', today: today);
    }
    final db = ref.read(databaseProvider);
    Future<void> enable(String id, bool on) =>
        (db.update(db.reminders)..where((t) => t.id.equals(id))).write(
          RemindersCompanion(enabled: Value(on)),
        );
    await enable('period', d.remindPeriod);
    await enable('daily', d.remindDaily);
    await enable('fertile', d.remindFertile && d.fertility);
    await ref.read(settingsRepositoryProvider).save(settings);
    if (!mounted) return;
    context.go('/home');
    if (d.remindMedication) context.push('/medications');
  }

  List<(String, String?, List<Widget>)> _pages(BuildContext context) {
    final d = _draft;
    return [
      (
        'Your cycle, your way.',
        'Track your period, symptoms and patterns privately. No account needed.',
        const <Widget>[],
      ),
      (
        'What would you like to track?',
        'Choose any that fit. You can change this later.',
        _goals(context),
      ),
      (
        'When did your last period start?',
        'Choose the first day of bleeding. An approximate date is fine, and you can edit it later.',
        _lastPeriod(context),
      ),
      (
        'How many days does your period usually last?',
        'Tap a number. Five is only a suggestion, so change it to suit you.',
        [
          _NumberWheel(
            min: 1,
            max: 10,
            value: d.periodLength,
            unit: 'days',
            onChanged: (v) => setState(() => d.periodLength = v),
          ),
          const SizedBox(height: 12),
          _NotSure(
            selected: d.periodLength == null,
            onTap: () => setState(
              () => d.periodLength = d.periodLength == null ? 5 : null,
            ),
          ),
        ],
      ),
      (
        'How long is your usual cycle?',
        'Count from the first day of one period to the first day of the next. 28 is only a starting suggestion; cycles vary.',
        [
          _NumberWheel(
            min: 15,
            max: 60,
            value: d.cycleLength,
            unit: 'days',
            onChanged: (v) => setState(() => d.cycleLength = v),
          ),
          const SizedBox(height: 12),
          _NotSure(
            selected: d.cycleLength == null,
            onTap: () => setState(
              () => d.cycleLength = d.cycleLength == null ? 28 : null,
            ),
          ),
        ],
      ),
      (
        'How regular are your cycles?',
        'This changes how sure the app sounds about its estimates. It doesn\'t change what you can do.',
        [
          for (final (value, label) in const [
            (Regularity.regular, 'Usually regular'),
            (Regularity.sometimesIrregular, 'Sometimes irregular'),
            (Regularity.veryIrregular, 'Very irregular'),
            (Regularity.notSure, 'Not sure'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionCard(
                label: label,
                selected: d.regularity == value,
                onTap: () => setState(() => d.regularity = value),
              ),
            ),
        ],
      ),
      (
        'Would you like reminders?',
        'All are optional. Your device will only ask for permission if you switch one on.',
        _reminders(context),
      ),
      (
        'Your privacy',
        'Please read these. They explain how LunaCycle treats your information.',
        _privacy(context),
      ),
      (
        d.nickname.trim().isEmpty
            ? 'You\'re all set.'
            : 'You\'re all set, ${d.nickname.trim()}.',
        'Here is what you told us. Tap Edit to change anything.',
        _ready(context),
      ),
    ];
  }

  List<Widget> _goals(BuildContext context) {
    final d = _draft;
    return [
      for (final (goal, label) in const [
        (TrackingGoal.understandCycle, 'Understand my cycle'),
        (TrackingGoal.symptomsAndMoods, 'Track symptoms and moods'),
        (TrackingGoal.planPregnancy, 'Plan for pregnancy'),
        (TrackingGoal.justPeriod, 'Just track my period'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OptionCard(
            label: label,
            selected: d.goals.contains(goal),
            onTap: () => setState(() {
              if (!d.goals.remove(goal)) d.goals.add(goal);
              d.fertility = d.goals.contains(TrackingGoal.planPregnancy);
              if (!d.fertility) d.remindFertile = false;
            }),
          ),
        ),
      if (d.goals.contains(TrackingGoal.planPregnancy)) ...[
        const SizedBox(height: 4),
        const PrivacyNotice(
          'Fertility estimates will be shown. They are calendar calculations only. $kFertilityWarning',
          warning: true,
        ),
      ],
    ];
  }

  List<Widget> _lastPeriod(BuildContext context) {
    final d = _draft;
    final dates = ref.watch(lunaDatesProvider);
    final today = ref.watch(todayProvider);
    return [
      SecondaryButton(
        icon: Icons.event_rounded,
        label: d.lastPeriod == null
            ? 'Choose a date'
            : dates.full(d.lastPeriod!),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            helpText: 'First day of your last period',
            initialDate: (d.lastPeriod ?? today).toLocalDateTime(),
            firstDate: DateTime(today.year - 2),
            lastDate: today.toLocalDateTime(),
          );
          if (picked != null) {
            setState(() {
              d.lastPeriod = CalendarDate.fromDateTime(picked);
              d.dontRemember = false;
            });
          }
        },
      ),
      const SizedBox(height: 12),
      _OptionCard(
        label: 'I don\'t remember',
        selected: d.dontRemember,
        onTap: () => setState(() {
          d.dontRemember = !d.dontRemember;
          if (d.dontRemember) d.lastPeriod = null;
        }),
      ),
      if (d.dontRemember) ...[
        const SizedBox(height: 10),
        const PrivacyNotice(
          'That\'s fine. No date will be guessed. Log your next period when it starts and estimates will begin from there.',
          icon: Icons.spa_outlined,
        ),
      ],
    ];
  }

  List<Widget> _reminders(BuildContext context) {
    final d = _draft;
    return [
      SketchCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            SwitchTile(
              title: 'Upcoming period',
              subtitle: 'A note a couple of days before the estimate',
              value: d.remindPeriod,
              onChanged: (v) => _setReminder((x) => d.remindPeriod = x, v),
            ),
            SwitchTile(
              title: 'Daily logging',
              subtitle: 'A gentle evening nudge',
              value: d.remindDaily,
              onChanged: (v) => _setReminder((x) => d.remindDaily = x, v),
            ),
            SwitchTile(
              title: 'Medication',
              subtitle: 'You will add the schedule next',
              value: d.remindMedication,
              onChanged: (v) => _setReminder((x) => d.remindMedication = x, v),
            ),
            if (d.fertility)
              SwitchTile(
                title: 'Fertility estimates',
                subtitle: 'Before the estimated window',
                value: d.remindFertile,
                onChanged: (v) => _setReminder((x) => d.remindFertile = x, v),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      PrivacyNotice(
        _permissionNote ??
            'Notifications are discreet by default. They only say "You have a reminder from LunaCycle", so nothing about your cycle appears on your lock screen.',
        warning: _permissionNote != null,
      ),
    ];
  }

  List<Widget> _privacy(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    final text = Theme.of(context).textTheme;
    Widget point(IconData icon, String words) => Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: LunaTokens.of(context).periodFill),
          const SizedBox(width: 11),
          Expanded(child: Text(words, style: text.bodyMedium)),
        ],
      ),
    );
    return [
      SketchCard(
        child: Column(
          children: [
            point(
              Icons.phone_iphone_rounded,
              'Your data is stored on this device, in an encrypted database.',
            ),
            point(Icons.person_off_outlined, 'No account is needed.'),
            point(
              Icons.campaign_outlined,
              'Your details are never sent to advertisers. There are no ad or analytics trackers in the app.',
            ),
            point(
              Icons.lock_outline_rounded,
              'App lock is optional, and you can turn it on below.',
            ),
            point(
              Icons.ios_share_rounded,
              'You can export or permanently delete your data at any time.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      lock.enabled
          ? const PrivacyNotice(
              'App lock is on. You will enter your PIN when you open LunaCycle.',
            )
          : SecondaryButton(
              icon: Icons.pin_outlined,
              label: 'Protect with a PIN (optional)',
              onPressed: () => showPinSetup(context, ref),
            ),
      if (lock.enabled)
        FutureBuilder<bool>(
          future: ref.read(biometricsProvider).isAvailable(),
          builder: (context, snap) => snap.data == true
              ? SwitchTile(
                  title: 'Also unlock with biometrics',
                  value: lock.biometric,
                  onChanged: (v) =>
                      ref.read(appLockProvider.notifier).setBiometric(v),
                )
              : const SizedBox.shrink(),
        ),
    ];
  }

  List<Widget> _ready(BuildContext context) {
    final d = _draft;
    final dates = ref.watch(lunaDatesProvider);
    final goalWords = <String>[
      if (d.goals.contains(TrackingGoal.understandCycle))
        'Understanding my cycle',
      if (d.goals.contains(TrackingGoal.symptomsAndMoods)) 'Symptoms and moods',
      if (d.goals.contains(TrackingGoal.planPregnancy))
        'Planning for pregnancy',
      if (d.goals.contains(TrackingGoal.justPeriod)) 'Just my period',
    ];
    Widget row(String label, String value, int step) => SettingsTile(
      title: label,
      subtitle: value,
      trailing: TextButton(
        onPressed: () => _go(step),
        child: const Text('Edit'),
      ),
    );
    return [
      TextField(
        decoration: const InputDecoration(
          labelText: 'What should we call you? (optional)',
          helperText: 'Stays on this device.',
        ),
        textCapitalization: TextCapitalization.words,
        maxLength: 30,
        controller: _name,
        onChanged: (v) => setState(() => d.nickname = v),
      ),
      const SizedBox(height: 6),
      SketchCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Column(
          children: [
            row(
              'Tracking',
              goalWords.isEmpty ? 'Not chosen yet' : goalWords.join(', '),
              1,
            ),
            row(
              'Last period',
              d.lastPeriod == null
                  ? 'Not provided'
                  : dates.medium(d.lastPeriod!),
              2,
            ),
            row(
              'Period length',
              d.periodLength == null
                  ? 'Not sure yet'
                  : '${d.periodLength} days',
              3,
            ),
            row(
              'Cycle length',
              d.cycleLength == null ? 'Not sure yet' : '${d.cycleLength} days',
              4,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final (title, helper, content) = pages[_step];
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final gutter = size.width > 680 ? (size.width - 600) / 2 : 22.0;
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(_step - 1);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SakuraBackdrop(
              style: _step == 0 ? BackdropStyle.full : BackdropStyle.header,
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 18, 0),
                    child: Row(
                      children: [
                        if (_step > 0)
                          IconButton(
                            tooltip: 'Back',
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => _go(_step - 1),
                          )
                        else
                          const SizedBox(width: 48, height: 48),
                        Expanded(
                          child: Semantics(
                            label: 'Step ${_step + 1} of ${_lastStep + 1}',
                            excludeSemantics: true,
                            child: Row(
                              children: [
                                for (var i = 0; i <= _lastStep; i++)
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration: LunaMotion.of(
                                        context,
                                        LunaMotion.medium,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: i <= _step
                                            ? t.blossomEdge
                                            : t.surface,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: t.line,
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        _step == 0 ? height * 0.27 : 30,
                        gutter,
                        16,
                      ),
                      children: [
                        if (_step == 0) ...[
                          const Center(child: LunaLogo(size: 104)),
                          const SizedBox(height: 16),
                        ],
                        Semantics(
                          header: true,
                          child: Text(title, style: text.headlineMedium),
                        ),
                        if (helper != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            helper,
                            style: text.bodyLarge?.copyWith(color: t.inkSoft),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ...content,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 6, gutter, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          label: _step == 0
                              ? 'Get Started'
                              : _step == _lastStep
                              ? 'Open My Calendar'
                              : 'Continue',
                          onPressed: _saving
                              ? null
                              : () => _step == _lastStep
                                    ? _finish()
                                    : _go(_step + 1),
                        ),
                        if (_step == 0) ...[
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const _PrivacySheet(),
                            ),
                            child: const Text('Explore Privacy'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How LunaCycle protects you', style: text.titleLarge),
            const SizedBox(height: 10),
            Text(
              'Everything you log stays on this device, in a database encrypted with a key held by your '
              'phone\'s secure storage. There is no account, and core tracking works with no internet.\n\n'
              'LunaCycle contains no advertising or analytics SDKs. You can add a PIN, export your '
              'information, or delete it permanently whenever you wish.',
              style: text.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      selected: selected,
      child: SketchCard(
        seed: label.length,
        fill: selected ? t.pastel : t.surface,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (selected) const BlossomIcon(size: 24),
          ],
        ),
      ),
    );
  }
}

class _NotSure extends StatelessWidget {
  const _NotSure({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _OptionCard(
    label: 'Not sure, skip this',
    selected: selected,
    onTap: onTap,
  );
}

/// Scrollable number row; large targets, and an explicit current value.
class _NumberWheel extends StatefulWidget {
  const _NumberWheel({
    required this.min,
    required this.max,
    required this.value,
    required this.unit,
    required this.onChanged,
  });
  final int min;
  final int max;
  final int? value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberWheel> createState() => _NumberWheelState();
}

class _NumberWheelState extends State<_NumberWheel> {
  static const _itemWidth = 62.0;
  late final _controller = ScrollController(
    initialScrollOffset:
        ((widget.value ?? widget.min) - widget.min - 2) * _itemWidth,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final value = widget.value;
    return Column(
      children: [
        Text(value == null ? '—' : '$value', style: text.displayLarge),
        Text(
          value == null ? 'not set' : '${widget.unit} · editable any time',
          style: text.bodySmall,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 60,
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.max - widget.min + 1,
            itemExtent: _itemWidth,
            itemBuilder: (context, i) {
              final number = widget.min + i;
              final selected = number == value;
              return Semantics(
                button: true,
                selected: selected,
                label: '$number ${widget.unit}',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => widget.onChanged(number),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? t.pastel : t.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? t.blossomEdge : t.line,
                        width: selected ? 2 : 1.2,
                      ),
                    ),
                    child: Text('$number', style: text.titleMedium),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
