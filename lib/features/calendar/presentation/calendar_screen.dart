import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../domain/day_visual.dart';
import 'calendar_widgets.dart';
import 'day_details_sheet.dart';

const _guide = GuideContent(
  id: 'calendar',
  title: 'How to read your calendar',
  steps: [
    'Swipe left or right to change month. Tap Today to come back.',
    'Tap any day to see or change what was logged. Press and hold to open its full log.',
    'Solid circles are days you logged. Dashed circles are only estimates.',
  ],
);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _centre = 1200;
  late final CalendarDate _base = ref.read(todayProvider).firstOfMonth;
  final _pages = PageController(initialPage: _centre);
  int _page = _centre;
  CalendarDate? _selected;

  CalendarDate _monthAt(int page) => _base.plusMonths(page - _centre);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _animateTo(int page) {
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

  void _openSettings() => showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _CalendarSettingsSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(currentSettingsProvider);
    final dates = ref.watch(lunaDatesProvider);
    final text = Theme.of(context).textTheme;
    final month = _monthAt(_page);
    final today = ref.watch(todayProvider);
    return LunaPage(
      title: 'Calendar',
      guide: _guide,
      actions: [
        IconButton(
          tooltip: 'Year overview',
          icon: const Icon(Icons.grid_view_rounded),
          onPressed: () => context.push('/year'),
        ),
        IconButton(
          tooltip: 'Calendar settings',
          icon: const Icon(Icons.tune_rounded),
          onPressed: _openSettings,
        ),
      ],
      children: [
        SketchCard(
          seed: 8,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _animateTo(_page - 1),
                  ),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        dates.monthTitle(month),
                        textAlign: TextAlign.center,
                        style: text.titleLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _animateTo(_page + 1),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: month.isSameMonth(today)
                          ? null
                          : () => _animateTo(_centre),
                      child: const FittedBox(child: Text('Today')),
                    ),
                  ),
                ],
              ),
              WeekdayHeader(firstDay: settings.firstDayOfWeek),
              const SizedBox(height: 4),
              SizedBox(
                height: 6 * 50,
                child: PageView.builder(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  itemBuilder: (context, page) {
                    final cells = monthGrid(
                      _monthAt(page),
                      settings.firstDayOfWeek,
                    );
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisExtent: 50,
                          ),
                      itemCount: cells.length,
                      itemBuilder: (context, i) {
                        final date = cells[i];
                        if (date == null) return const SizedBox.shrink();
                        return CalendarDayCell(
                          date: date,
                          selected: date == _selected,
                          onTap: () {
                            setState(() => _selected = date);
                            showDayDetails(context, date);
                          },
                          onLongPress: date.isAfter(today)
                              ? null
                              : () => context.push('/day/${date.toIso()}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SketchCard(
          seed: 17,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  'Key (tap one to learn more)',
                  style: text.titleSmall,
                ),
              ),
              const SizedBox(height: 2),
              CalendarLegend(fertility: settings.fertilityEstimatesEnabled),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarSettingsSheet extends ConsumerWidget {
  const _CalendarSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchTile(
              title: 'Fertility estimates',
              subtitle: 'Approximate only, off unless you want them',
              value: s.fertilityEstimatesEnabled,
              onChanged: (v) => repo.patch({'fertilityEstimatesEnabled': v}),
            ),
            SwitchTile(
              title: 'Ovulation estimates',
              value: s.ovulationMarkerEnabled,
              onChanged: s.fertilityEstimatesEnabled
                  ? (v) => repo.patch({'ovulationMarkerEnabled': v})
                  : null,
            ),
            SwitchTile(
              title: 'Symptom and note dots',
              value: s.showSymptomMarkers,
              onChanged: (v) => repo.patch({'showSymptomMarkers': v}),
            ),
            SwitchTile(
              title: 'Estimated period days',
              value: s.showPredictedPeriods,
              onChanged: (v) => repo.patch({'showPredictedPeriods': v}),
            ),
          ],
        ),
      ),
    );
  }
}
