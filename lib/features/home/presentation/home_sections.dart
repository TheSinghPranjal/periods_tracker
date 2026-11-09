import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../calendar/presentation/calendar_widgets.dart';
import '../../calendar/presentation/day_details_sheet.dart';
import '../../period_logging/presentation/period_flows.dart';
import '../../prediction/presentation/prediction_copy.dart';
import '../../symptoms/domain/symptom_catalog.dart';
import '../../onboarding/presentation/onboarding_screen.dart'
    show kFertilityWarning;
import '../../wellness/domain/content_library.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider).value;
    final periods = ref.watch(periodsProvider).value ?? const [];
    final today = ref.watch(todayProvider).toIso();
    final active = prediction?.isPeriodActive ?? false;
    final ongoing = periods.isNotEmpty && periods.last.endDate == null
        ? periods.last
        : null;
    return Row(
      children: [
        Expanded(
          child: _Quick(
            icon: active
                ? Icons.stop_circle_outlined
                : Icons.water_drop_outlined,
            label: active ? 'End Period' : 'Start Period',
            onTap: () {
              if (ongoing != null) {
                endPeriodFlow(context, ref, ongoing);
              } else if (active) {
                showPeriodEditor(context, periods.last);
              } else {
                startPeriodFlow(context, ref);
              }
            },
          ),
        ),
        Expanded(
          child: _Quick(
            icon: Icons.healing_outlined,
            label: 'Log Symptoms',
            onTap: () => context.push('/day/$today?focus=symptoms'),
          ),
        ),
        Expanded(
          child: _Quick(
            icon: Icons.sentiment_satisfied_alt_outlined,
            label: 'Log Mood',
            onTap: () => context.push('/day/$today?focus=mood'),
          ),
        ),
        Expanded(
          child: _Quick(
            icon: Icons.edit_note_rounded,
            label: 'Add Note',
            onTap: () => context.push('/day/$today?focus=note'),
          ),
        ),
      ],
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 56,
                child: CustomPaint(
                  painter: SketchBoxPainter(
                    fill: t.surface,
                    stroke: t.blossomEdge,
                    seed: label.length,
                    radius: 28,
                  ),
                  child: Icon(icon, color: t.periodFill, size: 25),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: t.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final text = Theme.of(context).textTheme;
    return SketchCard(
      seed: 15,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Row(
        children: [
          for (var i = -3; i <= 3; i++)
            Expanded(
              child: Builder(
                builder: (context) {
                  final date = today.plusDays(i);
                  return Column(
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          kWeekdayLetters[date.weekday - 1],
                          style: text.labelSmall,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: CalendarDayCell(
                          date: date,
                          selected: false,
                          compact: true,
                          onTap: () => showDayDetails(context, date),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PhaseCard extends ConsumerWidget {
  const PhaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(predictionProvider).value?.phase;
    if (phase == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Cycle phase'),
        SketchCard(
          seed: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(PredictionCopy.phaseName(phase), style: text.titleMedium),
              const SizedBox(height: 4),
              Text(PredictionCopy.phaseBlurb(phase), style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class TodaySummary extends ConsumerWidget {
  const TodaySummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final entry = ref.watch(dayEntryProvider(today)).value;
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 86, child: Text(label, style: text.bodySmall)),
          Expanded(child: Text(value, style: text.bodyMedium)),
        ],
      ),
    );
    return SketchCard(
      seed: 19,
      onTap: () => context.push('/day/${today.toIso()}'),
      child: entry == null || entry.isEmpty
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    'Nothing logged today.',
                    style: text.bodyLarge?.copyWith(color: t.inkSoft),
                  ),
                ),
                Icon(Icons.add_rounded, color: t.periodFill),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.flow != null) row('Flow', entry.flow!.label),
                if (entry.moods.isNotEmpty)
                  row('Mood', entry.moods.map((m) => m.label).join(', ')),
                if (entry.pain != null) row('Pain', intensityWord(entry.pain!)),
                if (entry.symptoms.isNotEmpty)
                  row(
                    'Symptoms',
                    entry.symptoms.keys.map(symptomLabel).join(', '),
                  ),
                if (entry.hasNote) row('Notes', entry.notes!),
              ],
            ),
    );
  }
}

class UpcomingEvents extends ConsumerWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(predictionProvider).value;
    final s = ref.watch(currentSettingsProvider);
    final dates = ref.watch(lunaDatesProvider);
    final reminders = ref.watch(remindersProvider).value ?? const [];
    final today = ref.watch(todayProvider);
    final text = Theme.of(context).textTheme;
    final windows =
        r?.fertileWindows.where((w) => w.last.isOnOrAfter(today)).toList() ??
        const [];
    final enabled = reminders.where((x) => x.enabled).length;

    Widget row(IconData icon, String title, String detail) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: LunaTokens.of(context).periodFill),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                Text(detail, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );

    return SketchCard(
      seed: 23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Icons.event_outlined,
            'Estimated next period',
            r?.hasPrediction ?? false
                ? PredictionCopy.dateLine(r!, dates)
                : 'Not enough information yet',
          ),
          row(
            Icons.notifications_none_rounded,
            'Reminders',
            enabled == 0 ? 'None switched on' : '$enabled switched on',
          ),
          if (s.fertilityEstimatesEnabled && windows.isNotEmpty) ...[
            row(
              Icons.local_florist_outlined,
              'Estimated fertile window',
              dates.range(windows.first.first, windows.first.last),
            ),
            const SizedBox(height: 4),
            const PrivacyNotice(kFertilityWarning, warning: true),
          ],
        ],
      ),
    );
  }
}

class DailyTipCard extends ConsumerWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final text = Theme.of(context).textTheme;
    final tip = kDailyTips[today.epochDay % kDailyTips.length];
    return SketchCard(
      seed: 27,
      onTap: () => context.push('/articles'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BlossomIcon(size: 26),
              const SizedBox(width: 11),
              Expanded(child: Text(tip, style: text.bodyMedium)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'General information, not medical advice. Tap to read more.',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
