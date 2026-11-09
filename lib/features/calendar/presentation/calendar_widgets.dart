import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sakura_art.dart';
import '../../../core/widgets/sketch/sketch_geometry.dart';
import '../../period_logging/data/period_repository.dart';
import '../../symptoms/domain/day_entry.dart';
import '../domain/day_visual.dart';

/// All the inputs a calendar needs, combined once per data change.
final calendarDataProvider = Provider.family<DayVisual, CalendarDate>((
  ref,
  date,
) {
  final entries = ref.watch(entriesByDateProvider);
  return buildDayVisual(
    date: date,
    today: ref.watch(todayProvider),
    periods: (ref.watch(periodsProvider).value ?? const [])
        .map(spanOf)
        .toList(),
    prediction: ref.watch(predictionProvider).value,
    settings: ref.watch(currentSettingsProvider),
    entries: entries,
  );
});

final entriesByDateProvider = Provider<Map<CalendarDate, DayEntry>>((ref) {
  final days = ref.watch(allDaysProvider).value ?? const <DayEntry>[];
  return {for (final d in days) d.date: d};
});

class CalendarDayCell extends ConsumerWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.compact = false,
  });

  final CalendarDate date;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(calendarDataProvider(date));
    final t = LunaTokens.of(context);
    final dates = ref.watch(lunaDatesProvider);
    final words = v.statusWords;
    return Semantics(
      button: true,
      selected: selected,
      label: '${dates.full(date)}${words.isEmpty ? '' : ', $words'}',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        onLongPress: onLongPress,
        radius: 26,
        child: CustomPaint(
          painter: _DayPainter(visual: v, selected: selected, t: t),
          child: Center(
            child: Text(
              '${date.day}',
              textScaler: MediaQuery.textScalerOf(
                context,
              ).clamp(maxScaleFactor: 1.3),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: compact ? 14 : 15.5,
                color: v.confirmed ? t.onPeriod : t.ink,
                fontWeight: v.isToday || v.confirmed
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPainter extends CustomPainter {
  _DayPainter({required this.visual, required this.selected, required this.t});
  final DayVisual visual;
  final bool selected;
  final LunaTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = (size.shortestSide / 2) - 4.5;
    final seed = visual.date.epochDay;

    if (visual.fertile) {
      final rect = Rect.fromCircle(center: c, radius: r + 2.5);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      canvas.drawRRect(rrect, Paint()..color = t.fertileTint);
      canvas.save();
      canvas.clipRRect(rrect);
      final hatch = Paint()
        ..color = t.fertileInk.withValues(alpha: 0.26)
        ..strokeWidth = 1;
      for (var x = rect.left - rect.height; x < rect.right; x += 7) {
        canvas.drawLine(
          Offset(x, rect.bottom),
          Offset(x + rect.height, rect.top),
          hatch,
        );
      }
      canvas.restore();
    }
    if (visual.confirmed) {
      canvas.drawPath(
        sketchCircle(c, r, seed, roughness: 0.5),
        Paint()..color = t.periodFill,
      );
    }
    if (visual.predicted) {
      canvas.drawPath(
        dashed(sketchCircle(c, r, seed, roughness: 0.4), dash: 4.5, gap: 3.5),
        Paint()
          ..color = t.predicted
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.8,
      );
    }
    if (visual.isToday) {
      final y = c.dy + 11;
      canvas.drawLine(
        Offset(c.dx - 7, y),
        Offset(c.dx + 7, y),
        Paint()
          ..color = visual.confirmed ? t.onPeriod : t.today
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
    if (selected) {
      final pen = Paint()
        ..color = t.selected
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(sketchCircle(c, r + 3, seed + 4, roughness: 0.6), pen);
    }
    if (visual.ovulation) {
      drawBlossom(
        canvas,
        Offset(size.width - 11, 11),
        7,
        0.3,
        BlossomInk(fill: t.ovulation, edge: t.ovulation, core: t.fertileTint),
        detailed: false,
      );
    }
    if (visual.marker) {
      final dotAt = Offset(c.dx + r - 1, c.dy + r - 1);
      canvas.drawCircle(dotAt, 4.2, Paint()..color = t.surface);
      canvas.drawCircle(dotAt, 3, Paint()..color = t.ink);
    }
  }

  @override
  bool shouldRepaint(_DayPainter old) =>
      old.selected != selected ||
      old.t != t ||
      old.visual.confirmed != visual.confirmed ||
      old.visual.predicted != visual.predicted ||
      old.visual.fertile != visual.fertile ||
      old.visual.ovulation != visual.ovulation ||
      old.visual.marker != visual.marker ||
      old.visual.isToday != visual.isToday ||
      old.visual.date != visual.date;
}

class LegendEntry {
  const LegendEntry(this.visual, this.label, this.explanation);
  final DayVisual visual;
  final String label;
  final String explanation;
}

final _d = CalendarDate(2000, 1, 2);
final kLegend = [
  LegendEntry(
    DayVisual(date: _d, confirmed: true),
    'Logged period',
    'A solid circle is a day you recorded as a period. It is a confirmed entry.',
  ),
  LegendEntry(
    DayVisual(date: _d, predicted: true),
    'Estimated period',
    'A dashed circle is an estimate. It only turns solid if you log it.',
  ),
  LegendEntry(
    DayVisual(date: _d, fertile: true),
    'Estimated fertile',
    'Striped lavender is an approximate fertile window, shown only if you switch it on. These estimates cannot reliably prevent pregnancy and are not a contraceptive method.',
  ),
  LegendEntry(
    DayVisual(date: _d, ovulation: true),
    'Estimated ovulation',
    'A small flower is a calendar-based estimate of ovulation. It is not confirmed.',
  ),
  LegendEntry(
    DayVisual(date: _d, marker: true),
    'Has details',
    'A dot means you logged symptoms, mood, pain or a note on that day.',
  ),
];

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key, required this.fertility});
  final bool fertility;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final entries = fertility ? kLegend : [kLegend[0], kLegend[1], kLegend[4]];
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final e in entries)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(e.label),
                content: Text(e.explanation),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: CustomPaint(
                        painter: _DayPainter(
                          visual: e.visual,
                          selected: false,
                          t: t,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        e.label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
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

const kWeekdayLetters = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key, required this.firstDay});
  final int firstDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                kWeekdayLetters[(firstDay - 1 + i) % 7],
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
      ],
    );
  }
}

/// Shared date formatting for the bottom sheet's headline.
String periodStatusWords(DayVisual v) => v.confirmed
    ? 'Logged period day'
    : v.predicted
    ? 'Estimated period day (not logged)'
    : v.ovulation
    ? 'Estimated ovulation (not confirmed)'
    : v.fertile
    ? 'Estimated fertile window'
    : 'No period logged';

extension DatesHelp on LunaDates {
  String monthTitle(CalendarDate d) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[d.month - 1]} ${d.year}';
  }
}
