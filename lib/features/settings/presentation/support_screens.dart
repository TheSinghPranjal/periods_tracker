import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../calendar/presentation/calendar_widgets.dart';
import '../../wellness/domain/content_library.dart';

const kAppVersion = '1.0.0 (1)';
const _supportEmail = String.fromEnvironment('LUNA_SUPPORT_EMAIL');

void showContactSupport(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Contact support'),
      content: Text(
        _supportEmail.isEmpty
            ? 'A support address has not been set up for this version yet.'
            : 'Email us at $_supportEmail.\n\nPlease don\'t include health details in your message.',
      ),
      actions: [
        if (_supportEmail.isNotEmpty)
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _supportEmail));
              Navigator.pop(context);
            },
            child: const Text('Copy address'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.steps, {this.extra});
  final String title;
  final List<String> steps;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SketchCard(
        seed: title.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(title, style: text.titleLarge)),
            const SizedBox(height: 8),
            for (final (i, step) in steps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}.', style: text.titleSmall),
                    ),
                    Expanded(child: Text(step, style: text.bodyMedium)),
                  ],
                ),
              ),
            ?extra,
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LunaPage(
      title: 'How to use LunaCycle',
      showBack: true,
      children: const [
        _Section('Log your period', [
          'On the first day of bleeding, go to Home and tap Start Period.',
          'Each day, tap the + button at the bottom and choose your flow.',
          'When it ends, tap End Period on Home and choose the last day.',
          'Forgot a day? Open Calendar, tap that day, then tap Log Period.',
        ]),
        _Section('Read the calendar', [
          'Solid circle: a day you logged as a period.',
          'Dashed circle: an estimated period day, which is only a guess.',
          'Small dot: you logged symptoms, mood, pain or a note.',
          'Tap any day to see it, change it or remove it.',
        ], extra: CalendarLegend(fertility: false)),
        _Section('Log how you feel', [
          'Tap the + button at the bottom of the screen.',
          'Tap your moods and symptoms. For each symptom, choose how strong it was.',
          'Everything saves by itself. Look for the green Saved tick.',
        ]),
        _Section('See your patterns', [
          'Open Insights once you have logged a couple of cycles.',
          'Pick a time range at the top.',
          'Open Cycle history to correct any past dates.',
        ]),
        _Section('Reminders', [
          'Open Profile, then Reminders.',
          'Switch on what you want and set the time.',
          'Discreet mode hides the details on your lock screen.',
        ]),
        _Section('Keep it private', [
          'Open Profile, then Privacy and security.',
          'Add a PIN so that only you can open the app.',
          'Make an encrypted backup before changing phones.',
          'You can delete everything from the same page.',
        ]),
      ],
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LunaPage(
      title: 'Health articles',
      subtitle: kContentReviewStatus,
      showBack: true,
      children: [
        for (final (i, a) in kArticles.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SketchCard(
              seed: i + 3,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(a.title, style: text.titleSmall),
                  subtitle: Text(a.summary, style: text.bodySmall),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in a.body)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Text(p, style: text.bodyMedium),
                      ),
                    Text(
                      'Further reading: ${a.sources.join('; ')}',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const _faq = [
  (
    'Why is my estimate a range?',
    'A range appears when there isn\'t much history yet, or when your cycles vary. It is more honest than one exact date.',
  ),
  (
    'Can I use this to avoid pregnancy?',
    'No. These estimates cannot reliably prevent pregnancy and are not a contraceptive method.',
  ),
  (
    'Where is my data stored?',
    'On this device, in an encrypted database. There is no account, and nothing is uploaded.',
  ),
  (
    'What happens if I change phones?',
    'Your data doesn\'t move automatically. Make an encrypted backup in Privacy and security, then import it on the new phone.',
  ),
  (
    'I forgot my PIN. What can I do?',
    'For your privacy there is no way to reset it. You would need to reinstall the app, which erases your data unless you have a backup.',
  ),
  (
    'Does spotting count as a period?',
    'Not unless you say so. Spotting is saved as its own entry and doesn\'t start a new cycle.',
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LunaPage(
      title: 'Questions',
      showBack: true,
      children: [
        for (final (i, (q, a)) in _faq.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SketchCard(
              seed: i + 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q, style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(a, style: text.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final String doc;

  static const _privacy = [
    (
      'What we collect',
      'LunaCycle has no account and no server. Everything you enter stays on your device.',
    ),
    (
      'Encryption',
      'Your records are stored in an encrypted database. The key is kept in your device\'s secure storage.',
    ),
    (
      'Advertising and analytics',
      'The app contains no advertising or analytics SDKs, and does not use advertising identifiers.',
    ),
    (
      'Notifications',
      'Reminders are scheduled on your device. By default their text reveals nothing about your cycle.',
    ),
    (
      'Backups and exports',
      'Files you export are yours to look after. Plain CSV and JSON files are not encrypted. Encrypted backups can only be opened with the password you choose, and it cannot be recovered if lost. The database is excluded from automatic device backups.',
    ),
    (
      'Deleting your data',
      'You can delete single entries, your cycle history, or everything, from within the app. Copies you exported are not affected, so please delete those yourself. There is no cloud copy to delete.',
    ),
    (
      'Purchases',
      'If you buy LunaCycle Plus, the purchase is handled by Apple or Google under their terms.',
    ),
  ];

  static const _terms = [
    (
      'Not medical advice',
      'LunaCycle is a personal tracking tool. It does not diagnose, treat or prevent any condition. Talk to a qualified healthcare professional about health concerns.',
    ),
    (
      'Estimates',
      'Predictions are approximate calendar calculations. These estimates cannot reliably prevent pregnancy and are not a contraceptive method.',
    ),
    (
      'Your responsibility',
      'You are responsible for keeping your device, PIN and backups safe.',
    ),
    (
      'Free features',
      'Period logging, calendar, estimates, symptom and mood tracking, reminders, export, deletion and app lock are always free.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isPrivacy = doc == 'privacy';
    final text = Theme.of(context).textTheme;
    return LunaPage(
      title: isPrivacy ? 'Privacy policy' : 'Terms',
      subtitle:
          'Draft: to be reviewed by a qualified lawyer before publication.',
      showBack: true,
      children: [
        for (final (i, (h, b)) in (isPrivacy ? _privacy : _terms).indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SketchCard(
              seed: i + 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h, style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(b, style: text.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
