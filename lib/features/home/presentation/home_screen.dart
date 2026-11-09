import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/common.dart';
import 'cycle_card.dart';
import 'home_sections.dart';

const _guide = GuideContent(
  id: 'home',
  title: 'Getting started',
  steps: [
    'On the first day of bleeding, tap Start Period below.',
    'Use the other buttons to log symptoms, mood or a note for today.',
    'The circle shows where you are in your cycle. Dates are estimates that improve as you log.',
  ],
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good morning'
        : (hour < 18 ? 'Good afternoon' : 'Good evening');
    return name == null ? part : '$part, $name';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final today = ref.watch(todayProvider);
    final dates = ref.watch(lunaDatesProvider);
    return LunaPage(
      title: _greeting(s.nickname),
      subtitle: dates.full(today),
      guide: _guide,
      actions: [
        IconButton(
          tooltip: s.privacyMode ? 'Show cycle details' : 'Hide cycle details',
          icon: Icon(
            s.privacyMode
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => ref.read(settingsRepositoryProvider).patch({
            'privacyMode': !s.privacyMode,
          }),
        ),
        IconButton(
          tooltip: 'Reminders',
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => context.push('/reminders'),
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go('/profile'),
        ),
      ],
      children: [
        const CycleCard(),
        const SizedBox(height: 14),
        const QuickActions(),
        const SectionTitle('This week'),
        const WeekStrip(),
        if (!s.privacyMode) ...[
          const PhaseCard(),
          const SectionTitle('Today'),
          const TodaySummary(),
          const SectionTitle('Coming up'),
          const UpcomingEvents(),
        ],
        const SectionTitle('A note for today'),
        const DailyTipCard(),
      ],
    );
  }
}
