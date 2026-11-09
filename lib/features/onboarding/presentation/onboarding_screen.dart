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
import 'goal_art.dart';

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

  /// Steps drawn with corner blossoms and a two-line underlined heading.
  static const _headings = {
    1: ('What would you like to', 'track?', 28.0),
    2: ('When did your last', 'period start?', 28.0),
    3: ('How many days does', 'your period usually last?', 26.0),
    4: ('How long is your', 'usual cycle?', 28.0),
    5: ('How regular are your', 'cycles?', 28.0),
    6: ('Would you like', 'reminders?', 28.0),
  };

  bool get _meadowStep => _step >= 1 && _step <= 7;
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
        'Your Cycle, Your Way',
        'Track your period, symptoms and patterns privately. No account needed.',
        const <Widget>[],
      ),
      (
        'What would you like to track?',
        'Choose any that fit. You can change this later in Settings.',
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
          const Center(child: HeroCalendarArt(width: 190)),
          const SizedBox(height: 10),
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
          const Center(child: HeroCalendarArt(width: 180, cycle: true)),
          const SizedBox(height: 8),
          _NumberWheel(
            pageStarts: const [15, 17, 29, 41, 49],
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
        'This helps us make better estimates for your next period. It doesn\'t change what you can do with the app.',
        _regularity(context),
      ),
      (
        'Would you like reminders?',
        'All are optional. Your device will only ask for permission if you switch one on.',
        _reminders(context),
      ),
      (
        'Your Privacy',
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
      for (final (goal, title, description, art) in const [
        (
          TrackingGoal.understandCycle,
          'Understand my cycle',
          'See your cycle patterns, ovulation and key dates.',
          GoalArtKind.calendar,
        ),
        (
          TrackingGoal.symptomsAndMoods,
          'Track symptoms and moods',
          'Log physical symptoms, moods and daily changes.',
          GoalArtKind.moods,
        ),
        (
          TrackingGoal.planPregnancy,
          'Plan for pregnancy',
          'Track your fertile window and ovulation (optional).',
          GoalArtKind.feet,
        ),
        (
          TrackingGoal.justPeriod,
          'Just track my period',
          'Keep it simple with period tracking only.',
          GoalArtKind.dropCalendar,
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GoalCard(
            title: title,
            description: description,
            art: art,
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
      const Center(child: HeroCalendarArt()),
      const SizedBox(height: 14),
      _ChoicePill(
        icon: Icons.event_rounded,
        label: d.lastPeriod == null
            ? 'Choose a date'
            : dates.full(d.lastPeriod!),
        highlight: true,
        chevron: true,
        selected: d.lastPeriod != null,
        onTap: () async {
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
      const SizedBox(height: 14),
      _ChoicePill(
        icon: Icons.schedule_rounded,
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

  List<Widget> _regularity(BuildContext context) {
    final d = _draft;
    return [
      for (final (value, title, description, art) in const [
        (
          Regularity.regular,
          'Usually regular',
          'My cycle length is fairly consistent (e.g., around 28 days).',
          GoalArtKind.regular,
        ),
        (
          Regularity.sometimesIrregular,
          'Sometimes irregular',
          'My cycle length can vary (e.g., 24–35 days).',
          GoalArtKind.sometimesIrregular,
        ),
        (
          Regularity.veryIrregular,
          'Very irregular',
          'My cycle length varies a lot (e.g., shorter than 24 or longer than 35 days).',
          GoalArtKind.veryIrregular,
        ),
        (
          Regularity.notSure,
          'Not sure',
          'I\'m not sure yet or I\'m still learning about my cycle.',
          GoalArtKind.unsure,
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _GoalCard(
            title: title,
            description: description,
            art: art,
            radio: true,
            selected: d.regularity == value,
            onTap: () => setState(() => d.regularity = value),
          ),
        ),
    ];
  }

  List<Widget> _reminders(BuildContext context) {
    final d = _draft;
    Widget card(
      ReminderArtKind art,
      String title,
      String description,
      bool value,
      void Function(bool) apply,
    ) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _ReminderCard(
        art: art,
        title: title,
        description: description,
        value: value,
        onChanged: (v) => _setReminder(apply, v),
      ),
    );
    return [
      card(
        ReminderArtKind.calendar,
        'Upcoming period',
        'A note a couple of days before the estimate',
        d.remindPeriod,
        (x) => d.remindPeriod = x,
      ),
      card(
        ReminderArtKind.bell,
        'Daily logging',
        'A gentle evening nudge',
        d.remindDaily,
        (x) => d.remindDaily = x,
      ),
      card(
        ReminderArtKind.pills,
        'Medication',
        'You will add the schedule next',
        d.remindMedication,
        (x) => d.remindMedication = x,
      ),
      if (d.fertility)
        card(
          ReminderArtKind.blossom,
          'Fertility estimates',
          'Before the estimated window',
          d.remindFertile,
          (x) => d.remindFertile = x,
        ),
      const SizedBox(height: 4),
      _ReminderNotice(
        message:
            _permissionNote ??
            'Notifications are discreet by default. They only say “You have a reminder from LunaCycle”, so nothing about your cycle appears on your lock screen.',
        warning: _permissionNote != null,
      ),
    ];
  }

  List<Widget> _privacy(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    return [
      const _PrivacyPoints(),
      const SizedBox(height: 14),
      lock.enabled
          ? const PrivacyNotice(
              'App lock is on. You will enter your PIN when you open LunaCycle.',
            )
          : _ChoicePill(
              icon: Icons.dialpad_rounded,
              label: 'Protect with a PIN (optional)',
              highlight: true,
              chevron: true,
              selected: false,
              onTap: () => showPinSetup(context, ref),
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
              style: switch (_step) {
                0 => BackdropStyle.full,
                1 || 2 || 3 || 4 || 5 || 6 || 7 => BackdropStyle.meadow,
                _ => BackdropStyle.header,
              },
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
                            padding: EdgeInsets.zero,
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: t.pastel.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: t.heading,
                                size: 23,
                              ),
                            ),
                            onPressed: () => _go(_step - 1),
                          )
                        else
                          const SizedBox(width: 48, height: 48),
                        Expanded(
                          child: Semantics(
                            label: 'Step ${_step + 1} of ${_lastStep + 1}',
                            excludeSemantics: true,
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                // Keeps the steps readable where they cross the branch.
                                decoration: BoxDecoration(
                                  color: _meadowStep
                                      ? Colors.transparent
                                      : t.paper.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: i <= _step
                                                ? Color.lerp(
                                                    t.buttonStart,
                                                    t.buttonEnd,
                                                    0.6,
                                                  )
                                                : t.surface,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: i <= _step
                                                  ? Color.lerp(
                                                      t.buttonStart,
                                                      t.buttonEnd,
                                                      0.6,
                                                    )!
                                                  : t.blossomEdge,
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        switch (_step) {
                          0 => height * 0.27,
                          1 || 2 || 3 || 4 || 5 || 6 => 14,
                          7 => 0,
                          _ => 30,
                        },
                        gutter,
                        16,
                      ),
                      children: [
                        if (_step == 0) ...[
                          const Center(child: LunaLogo(size: 104)),
                          const SizedBox(height: 16),
                        ],
                        _step == 7
                            ? const _PrivacyHeading()
                            : _meadowStep
                            ? _TwoLineHeading(lines: _headings[_step]!)
                            : Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  textAlign: _step == 0
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  style:
                                      (_step == 0
                                              ? text.headlineMedium?.copyWith(
                                                  fontSize: 32,
                                                )
                                              : text.headlineMedium)
                                          ?.copyWith(color: t.heading),
                                ),
                              ),
                        if (helper != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.only(
                              left: _meadowStep && _step != 7 ? 8 : 0,
                            ),
                            child: Text(
                              helper,
                              textAlign: _step == 0 || _step == 7
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: text.bodyLarge?.copyWith(
                                color: t.inkSoft,
                                fontSize: _step == 0 ? 17.5 : null,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: _meadowStep ? 14 : 20),
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
                          arrow: true,
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
                          TextButton.icon(
                            icon: const Icon(
                              Icons.verified_user_outlined,
                              size: 22,
                            ),
                            onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const _PrivacySheet(),
                            ),
                            label: const Text('Explore Privacy'),
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

class _PrivacyHeading extends StatelessWidget {
  const _PrivacyHeading();

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Column(
      children: [
        const ShieldArt(),
        const SizedBox(height: 4),
        Semantics(
          header: true,
          child: CustomPaint(
            painter: _BrushStroke(t.blossomEdge),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Your Privacy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: t.heading,
                  fontSize: 33,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyPoints extends StatelessWidget {
  const _PrivacyPoints();

  static const _points = [
    (
      Icons.phone_iphone_rounded,
      'Your data is stored on this device, in an encrypted database.',
      true,
    ),
    (Icons.person_off_outlined, 'No account is needed.', true),
    (
      Icons.campaign_outlined,
      'Your details are never sent to advertisers. There are no ad or analytics trackers in the app.',
      false,
    ),
    (
      Icons.lock_outline_rounded,
      'App lock is optional, and you can turn it on below.',
      false,
    ),
    (
      Icons.ios_share_rounded,
      'You can export or permanently delete your data at any time.',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final accent = _accentOf(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: t.blossomEdge.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final (i, (icon, words, strong)) in _points.indexed) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Divider(
                  height: 1,
                  color: t.blossomEdge.withValues(alpha: 0.28),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.pastel.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      words,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                        height: 1.3,
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

class _TwoLineHeading extends StatelessWidget {
  const _TwoLineHeading({required this.lines});
  final (String, String, double) lines;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final (first, second, size) = lines;
    final style = Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(color: t.heading, fontSize: size);
    return Semantics(
      header: true,
      label: '$first $second',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(first, style: style),
            CustomPaint(
              painter: _BrushStroke(t.blossomEdge),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(second, style: style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tapered highlighter stroke under the last word of the heading.
class _BrushStroke extends CustomPainter {
  _BrushStroke(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - 3;
    final path = Path()
      ..moveTo(-8, y + 3)
      ..quadraticBezierTo(size.width * 0.45, y - 4, size.width + 6, y - 3)
      ..quadraticBezierTo(size.width * 0.5, y + 3, -8, y + 3)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.75));
  }

  @override
  bool shouldRepaint(_BrushStroke old) => old.color != color;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.description,
    required this.art,
    required this.selected,
    required this.onTap,
    this.radio = false,
  });

  /// Single choice from a group: a radio dot instead of a checkbox.
  final bool radio;
  final String title;
  final String description;
  final GoalArtKind art;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(24);
    final tick = Color.lerp(t.buttonStart, t.buttonEnd, 0.6)!;
    return Semantics(
      button: true,
      checked: selected,
      inMutuallyExclusiveGroup: radio,
      child: AnimatedContainer(
        duration: LunaMotion.of(context, LunaMotion.fast),
        decoration: BoxDecoration(
          color: radio && selected
              ? Color.lerp(t.surface, t.pastel, 0.3)
              : t.surface.withValues(alpha: 0.96),
          borderRadius: radius,
          border: Border.all(
            color: selected ? t.blossomEdge : t.surface,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: t.blossomEdge.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
              child: Row(
                children: [
                  radio
                      ? AnimatedContainer(
                          duration: LunaMotion.of(context, LunaMotion.fast),
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: t.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? tick : t.blossomEdge,
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: selected
                              ? DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: tick,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        )
                      : AnimatedContainer(
                          duration: LunaMotion.of(context, LunaMotion.fast),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: selected ? tick : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected ? tick : t.blossomEdge,
                              width: 1.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 17,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.titleMedium?.copyWith(
                            color: t.heading,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: text.bodyMedium?.copyWith(
                            color: t.inkSoft,
                            fontSize: 14,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  GoalArt(
                    kind: art,
                    width: MediaQuery.sizeOf(context).width < 360 ? 76 : 94,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.art,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });
  final ReminderArtKind art;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(22);
    return Semantics(
      toggled: value,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface.withValues(alpha: 0.96),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: t.blossomEdge.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Row(
                children: [
                  ReminderArt(kind: art),
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 11),
                    color: t.line,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.titleMedium?.copyWith(
                            color: t.heading,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: text.bodyMedium?.copyWith(
                            color: t.inkSoft,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SoftSwitch(value: value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Display only: the whole card is the touch target.
class _SoftSwitch extends StatelessWidget {
  const _SoftSwitch({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final duration = LunaMotion.of(context, LunaMotion.fast);
    return AnimatedContainer(
      duration: duration,
      width: 50,
      height: 28,
      padding: const EdgeInsets.all(2.5),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: value ? t.buttonEnd : t.line, width: 1.2),
        ),
        color: value
            ? Color.lerp(t.buttonStart, t.buttonEnd, 0.6)
            : t.line.withValues(alpha: 0.55),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderNotice extends StatelessWidget {
  const _ReminderNotice({required this.message, required this.warning});
  final String message;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      liveRegion: warning,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: t.pastel.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.blossomEdge, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.pastel.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                warning
                    ? Icons.info_outline_rounded
                    : Icons.lock_outline_rounded,
                color: warning ? t.warning : _accentOf(context),
                size: 23,
              ),
            ),
            Container(
              width: 1,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 11),
              color: t.blossomEdge.withValues(alpha: 0.4),
            ),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14.5, height: 1.32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _accentOf(BuildContext context) {
  final t = LunaTokens.of(context);
  return Theme.of(context).brightness == Brightness.dark
      ? t.periodFill
      : Color.lerp(t.buttonStart, t.buttonEnd, 0.7)!;
}

/// A full-width rounded choice with an icon, used on the date and length steps.
class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlight = false,
    this.chevron = false,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final accent = _accentOf(context);
    final foreground = highlight ? accent : t.heading;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: LunaMotion.of(context, LunaMotion.fast),
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: highlight || selected
                ? BorderSide(color: t.blossomEdge, width: selected ? 1.8 : 1.4)
                : BorderSide(color: t.surface),
          ),
          gradient: highlight
              ? LinearGradient(
                  colors: [t.surface, t.pastel.withValues(alpha: 0.55)],
                )
              : null,
          color: highlight ? null : t.surface,
          shadows: [
            BoxShadow(
              color: t.blossomEdge.withValues(alpha: 0.16),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 25, color: highlight ? accent : t.heading),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontSize: highlight ? 17 : 16,
                        ),
                      ),
                    ),
                    if (selected && !chevron)
                      Icon(Icons.check_rounded, color: accent),
                    if (chevron)
                      Icon(Icons.chevron_right_rounded, color: foreground),
                  ],
                ),
              ),
            ),
          ),
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
  Widget build(BuildContext context) => _ChoicePill(
    icon: Icons.schedule_rounded,
    label: 'Not sure, skip this',
    selected: selected,
    onTap: onTap,
  );
}

/// Large current value above a scrollable row of numbered circles.
class _NumberWheel extends StatefulWidget {
  const _NumberWheel({
    required this.min,
    required this.max,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.pageStarts,
  });

  /// When set, numbers show as swipeable two-row pages starting at these
  /// values, for ranges too long for a single row.
  final List<int>? pageStarts;
  final int min;
  final int max;
  final int? value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberWheel> createState() => _NumberWheelState();
}

class _NumberWheelState extends State<_NumberWheel> {
  static const _itemWidth = 58.0;
  static const _visibleItems = 6;

  late final _controller = ScrollController(
    initialScrollOffset: () {
      final count = widget.max - widget.min + 1;
      final index = (widget.value ?? widget.min) - widget.min;
      return ((index - 2).clamp(0, (count - _visibleItems).clamp(0, count))) *
          _itemWidth;
    }(),
  );

  static const _perPage = 12;
  static const _perRow = 6;
  static const _rowHeight = 54.0;

  late int _page = _initialPage();
  late final _pages = PageController(initialPage: _page);

  int _initialPage() {
    final starts = widget.pageStarts;
    final value = widget.value;
    if (starts == null || value == null) return starts == null ? 0 : 1;
    // Later pages first, so a usual value lands on the page that leads with it.
    for (var i = 1; i < starts.length; i++) {
      if (value >= starts[i] && value < starts[i] + _perPage) return i;
    }
    return 0;
  }

  void _goTo(int page) {
    final duration = LunaMotion.of(context, LunaMotion.slow);
    if (duration == Duration.zero) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pages.dispose();
    super.dispose();
  }

  Widget _numberGrid(List<int> starts) {
    final t = LunaTokens.of(context);
    return Column(
      children: [
        SizedBox(
          height: _rowHeight * 2,
          child: PageView.builder(
            controller: _pages,
            itemCount: starts.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (context, p) {
              final first = starts[p];
              return Column(
                children: [
                  for (var row = 0; row < _perPage ~/ _perRow; row++)
                    SizedBox(
                      height: _rowHeight,
                      child: Row(
                        children: [
                          for (var col = 0; col < _perRow; col++)
                            Expanded(
                              child: first + row * _perRow + col <= widget.max
                                  ? _circle(first + row * _perRow + col)
                                  : const SizedBox.shrink(),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Smaller numbers',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
            ),
            ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < starts.length; i++)
                    Container(
                      width: i == _page ? 14 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _page ? t.blossomEdge : t.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Larger numbers',
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _page < starts.length - 1
                  ? () => _goTo(_page + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _circle(int number) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final selected = number == widget.value;
    return Semantics(
      button: true,
      selected: selected,
      label: '$number ${widget.unit}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(number),
        child: Center(
          child: AnimatedContainer(
            duration: LunaMotion.of(context, LunaMotion.fast),
            width: selected ? 50 : 46,
            height: selected ? 50 : 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? null : t.surface,
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [t.buttonStart, t.buttonEnd],
                    )
                  : null,
              border: Border.all(
                color: selected ? t.surface : t.line,
                width: selected ? 2.5 : 1.3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: t.buttonEnd.withValues(alpha: 0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$number',
              style: text.titleMedium?.copyWith(
                fontSize: 20,
                color: selected ? Colors.white : t.heading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    final accent = _accentOf(context);
    final value = widget.value;
    final unit = value == 1
        ? widget.unit.replaceFirst(RegExp(r's\$'), '')
        : widget.unit;
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          label: value == null ? 'Not set' : '$value $unit',
          excludeSemantics: true,
          child: Container(
            constraints: const BoxConstraints(minWidth: 186, minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
            decoration: ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(color: t.blossomEdge, width: 1.4),
              ),
              gradient: LinearGradient(
                colors: [t.surface, t.pastel.withValues(alpha: 0.5)],
              ),
              shadows: [
                BoxShadow(
                  color: t.blossomEdge.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: value == null
                  ? [
                      Text(
                        'Not set',
                        style: text.titleLarge?.copyWith(color: accent),
                      ),
                    ]
                  : [
                      Text(
                        '$value',
                        style: text.displayMedium?.copyWith(
                          fontFamily: kBodyFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 42,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        unit,
                        style: text.titleLarge?.copyWith(
                          fontFamily: kBodyFont,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: t.pastel.withValues(alpha: 0.38),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 15, color: t.heading),
              const SizedBox(width: 7),
              Text(
                'Editable any time',
                style: text.bodyMedium?.copyWith(
                  color: t.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (widget.pageStarts != null)
          _numberGrid(widget.pageStarts!)
        else
          SizedBox(
            height: 68,
            child: ListView.builder(
              controller: _controller,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: widget.max - widget.min + 1,
              itemExtent: _itemWidth,
              itemBuilder: (context, i) {
                return _circle(widget.min + i);
              },
            ),
          ),
      ],
    );
  }
}
