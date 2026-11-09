import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../period_logging/presentation/period_flows.dart';
import 'day_editor.dart';

const _guide = GuideContent(
  id: 'log',
  title: 'How to log a day',
  steps: [
    'Tap anything that applies. It saves by itself, so there is no save button.',
    'Tap a symptom, then choose how strong it was.',
    'Use the arrows or the date to go back and fill in an earlier day.',
  ],
);

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  CalendarDate? _picked;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final dates = ref.watch(lunaDatesProvider);
    final date = _picked ?? today;
    final isToday = date == today;
    return LunaPage(
      title: isToday ? 'Log today' : 'Log a past day',
      guide: _guide,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous day',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => setState(() => _picked = date.minusDays(1)),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final d = await pickDate(
                    context,
                    initial: date,
                    first: CalendarDate(today.year - 10, 1, 1),
                    last: today,
                    help: 'Choose a day to log',
                  );
                  if (d != null) setState(() => _picked = d);
                },
                child: Text(dates.full(date), textAlign: TextAlign.center),
              ),
            ),
            IconButton(
              tooltip: 'Next day',
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: isToday
                  ? null
                  : () => setState(() => _picked = date.plusDays(1)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DayEditor(key: ValueKey(date), date: date, focus: DayFocus.all),
      ],
    );
  }
}
