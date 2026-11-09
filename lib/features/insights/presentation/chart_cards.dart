import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/widgets/sketch/sketch_card.dart';

/// Frames a chart with a title, a spoken description and a table alternative.
class ChartCard extends StatefulWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.description,
    required this.chart,
    required this.rows,
    this.seed = 71,
  });
  final String title;
  final String description;
  final Widget chart;
  final List<(String, String)> rows;
  final int seed;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  bool _table = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SketchCard(
        seed: widget.seed,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(widget.title, style: text.titleMedium),
            ),
            const SizedBox(height: 12),
            if (_table)
              for (final (label, value) in widget.rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(label, style: text.bodyMedium)),
                      Text(value, style: text.titleSmall),
                    ],
                  ),
                )
            else
              Semantics(
                image: true,
                label: widget.description,
                excludeSemantics: true,
                child: SizedBox(height: 170, child: widget.chart),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _table = !_table),
                child: Text(_table ? 'Show chart' : 'Show as table'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

FlGridData _grid(LunaTokens t) => FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) =>
      FlLine(color: t.line.withValues(alpha: 0.55), strokeWidth: 1),
);

Widget _axisText(BuildContext context, String words) => Padding(
  padding: const EdgeInsets.only(top: 5),
  child: Text(
    words,
    textAlign: TextAlign.center,
    maxLines: 2,
    style: Theme.of(context).textTheme.labelSmall,
  ),
);

/// One line over indexed points; only the end labels are drawn to avoid
/// crowding the axis.
class TrendLine extends StatelessWidget {
  const TrendLine({
    super.key,
    required this.values,
    required this.labels,
    required this.unit,
    this.minY,
    this.maxY,
    this.leftLabel,
    this.stepped = false,
  });
  final List<double> values;
  final List<String> labels;
  final String unit;
  final double? minY;
  final double? maxY;
  final String Function(double)? leftLabel;
  final bool stepped;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final pad = math.max((high - low) * 0.2, 1.0);
    final last = values.length - 1;
    final duration = LunaMotion.of(context, LunaMotion.slow);
    return LineChart(
      duration: duration,
      LineChartData(
        minX: 0,
        maxX: math.max(1, last).toDouble(),
        minY: minY ?? (low - pad).floorToDouble(),
        maxY: maxY ?? (high + pad).ceilToDouble(),
        gridData: _grid(t),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: leftLabel == null ? 30 : 62,
              getTitlesWidget: (v, meta) =>
                  (v == meta.max || v == meta.min) && leftLabel == null
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(
                        leftLabel?.call(v) ?? v.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 26,
              getTitlesWidget: (v, meta) {
                final show = v == 0 || v == last;
                if (!show || v.toInt() >= labels.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: _axisText(context, labels[v.toInt()]),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => t.ink,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${labels[s.x.toInt()]}\n${s.y.toStringAsFixed(s.y == s.y.roundToDouble() ? 0 : 2)} $unit',
                  TextStyle(
                    color: t.paper,
                    fontFamily: kBodyFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isStepLineChart: stepped,
            color: t.periodFill,
            barWidth: 2,
            dotData: FlDotData(
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: t.periodFill,
                strokeColor: t.surface,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CountBars extends StatelessWidget {
  const CountBars({
    super.key,
    required this.values,
    required this.labels,
    this.unit = 'days',
    this.iconFor,
  });
  final List<double> values;
  final List<String> labels;
  final String unit;
  final Widget Function(int)? iconFor;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final top = values.reduce(math.max);
    return BarChart(
      duration: LunaMotion.of(context, LunaMotion.slow),
      BarChartData(
        maxY: (top * 1.2).ceilToDouble(),
        minY: 0,
        gridData: _grid(t),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: math.max(1, (top / 4).ceilToDouble()),
              getTitlesWidget: (v, meta) => v == meta.max
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(
                        v.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: iconFor != null ? 38 : 44,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                return SideTitleWidget(
                  meta: meta,
                  child:
                      iconFor?.call(i) ??
                      SizedBox(width: 52, child: _axisText(context, labels[i])),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => t.ink,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${labels[group.x]}\n${rod.toY.toStringAsFixed(0)} $unit',
              TextStyle(
                color: t.paper,
                fontFamily: kBodyFont,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 16,
                  color: t.blossomEdge,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
