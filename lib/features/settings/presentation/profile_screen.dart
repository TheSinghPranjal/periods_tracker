import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import 'support_screens.dart' show kAppVersion, showContactSupport;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget group(String title, int seed, List<Widget> tiles) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title),
        SketchCard(
          seed: seed,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(children: tiles),
        ),
      ],
    );
    SettingsTile link(
      IconData icon,
      String title,
      String path, [
      String? subtitle,
    ]) => SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => context.push(path),
    );
    return LunaPage(
      title: 'Profile',
      subtitle: 'Your settings, privacy and help',
      children: [
        SketchCard(
          seed: 91,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: link(
            Icons.menu_book_rounded,
            'How to use LunaCycle',
            '/help',
            'A simple guide to every feature',
          ),
        ),
        group('Your cycle', 93, [
          link(
            Icons.tune_rounded,
            'Cycle settings',
            '/settings/cycle',
            'Lengths, regularity and estimates',
          ),
          link(
            Icons.checklist_rounded,
            'What to track',
            '/settings/modules',
            'Turn optional sections on or off',
          ),
          link(Icons.history_rounded, 'Cycle history', '/history'),
        ]),
        group('Reminders', 95, [
          link(Icons.notifications_none_rounded, 'Reminders', '/reminders'),
          link(Icons.medication_outlined, 'Medication', '/medications'),
        ]),
        group('Privacy and data', 97, [
          link(
            Icons.shield_outlined,
            'Privacy and security',
            '/privacy',
            'App lock, export, import and delete',
          ),
        ]),
        group('App', 99, [
          link(
            Icons.palette_outlined,
            'Appearance',
            '/settings/appearance',
            'Colours and dark mode',
          ),
          link(
            Icons.language_rounded,
            'General',
            '/settings/general',
            'Date format, units and accessibility',
          ),
          link(
            Icons.local_florist_outlined,
            'LunaCycle Plus',
            '/premium',
            'Optional extra themes',
          ),
        ]),
        group('Support', 101, [
          link(Icons.auto_stories_outlined, 'Health articles', '/articles'),
          link(Icons.quiz_outlined, 'Frequently asked questions', '/faq'),
          SettingsTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact support',
            onTap: () => showContactSupport(context),
          ),
          link(Icons.policy_outlined, 'Privacy policy', '/legal/privacy'),
          link(Icons.gavel_rounded, 'Terms', '/legal/terms'),
          const SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App version',
            subtitle: kAppVersion,
          ),
        ]),
      ],
    );
  }
}
