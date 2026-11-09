import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../domain/day_visual.dart';
import 'calendar_widgets.dart';

/// Year at a glance. Solid dots are logged; hollow dots are estimated.
class YearScreen extends ConsumerStatefulWidget {
  const YearScreen({super.key});

  @override
  ConsumerState<YearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends ConsumerState<YearScreen> {
  late int _year = ref.read(todayProvider).year;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dates = ref.watch(lunaDatesProvider);
    final firstDay = ref.watch(currentSettingsProvider).firstDayOfWeek;
    return LunaPage(
      title: 'Year overview',
      subtitle: 'Solid dots are logged days. Hollow dots are estimates.',
      showBack: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous year',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => setState(() => _year--),
            ),
            Text('$_year', style: text.titleLarge),
            IconButton(
              tooltip: 'Next year',
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => setState(() => _year++),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SketchCard(
          seed: 5,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              for (var m = 1; m <= 12; m++)
                _MiniMonth(
                  month: CalendarDate(_year, m, 1),
                  firstDay: firstDay,
                  title: dates
                      .monthTitle(CalendarDate(_year, m, 1))
                      .split(' ')
                      .first,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMonth extends ConsumerWidget {
  const _MiniMonth({
    required this.month,
    required this.firstDay,
    required this.title,
  });
  final CalendarDate month;
  final int firstDay;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cells = monthGrid(month, firstDay);
    final t = LunaTokens.of(context);
    final visuals = [
      for (final c in cells)
        c == null ? null : ref.watch(calendarDataProvider(c)),
    ];
    final logged = visuals.where((v) => v?.confirmed ?? false).length;
    final predicted = visuals.where((v) => v?.predicted ?? false).length;
    return Semantics(
      label: '$title: $logged logged period days, $predicted estimated',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 5),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                for (final v in visuals)
                  Center(
                    child: v == null
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: v.confirmed
                                  ? t.periodFill
                                  : Colors.transparent,
                              border: v.predicted
                                  ? Border.all(color: t.predicted, width: 1.3)
                                  : v.confirmed
                                  ? null
                                  : Border.all(color: t.line, width: 0.8),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
