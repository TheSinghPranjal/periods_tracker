import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';
import '../../period_logging/presentation/period_flows.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';
import '../../prediction/presentation/prediction_copy.dart';

const _longBleedingDays = 10;

class CycleCard extends ConsumerWidget {
  const CycleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = LunaTokens.of(context);
    final privacy = ref.watch(currentSettingsProvider).privacyMode;
    return SketchCard(
      seed: 2,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.heroStart, t.heroEnd],
      ),
      child: privacy
          ? const _HiddenCard()
          : AsyncBody(
              value: ref.watch(predictionProvider),
              builder: (r) => _Content(result: r),
            ),
    );
  }
}

class _HiddenCard extends StatelessWidget {
  const _HiddenCard();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Center(
      child: Text(
        'Cycle details are hidden.\nTap the eye icon above to show them.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  );
}

class _Content extends ConsumerWidget {
  const _Content({required this.result});
  final CyclePredictionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final dates = ref.watch(lunaDatesProvider);
    final r = result;
    final periods = ref.watch(periodsProvider).value ?? const <PeriodRecord>[];
    final current = periods.isEmpty ? null : periods.last;

    if (!r.hasPeriodHistory) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CycleRing(
            progress: null,
            size: 150,
            child: BlossomIcon(size: 56),
          ),
          const SizedBox(height: 10),
          Text(
            'Let\'s learn your cycle.',
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Log your period when it starts, and estimates will begin from there.',
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Log a period',
            onPressed: () => startPeriodFlow(context, ref),
          ),
        ],
      );
    }

    final dayNumber = r.currentCycleDay!;
    final periodFraction =
        r.cycleLength != null && r.predictedPeriodLength != null
        ? r.predictedPeriodLength! / r.cycleLength!
        : null;
    final ring = CycleRing(
      progress: r.cycleProgress,
      periodFraction: periodFraction,
      child: Semantics(
        label: 'Cycle day $dayNumber',
        excludeSemantics: true,
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cycle Day', style: text.labelMedium),
              Text('$dayNumber', style: text.displayLarge),
            ],
          ),
        ),
      ),
    );

    final ongoingDays = r.isPeriodActive && current?.endDate == null
        ? dayNumber
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ring,
        const SizedBox(height: 10),
        if (r.isPeriodActive) ...[
          Text(
            'Period, day $dayNumber',
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Log today\'s flow, and mark the last day when it ends.',
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
        ] else if (r.hasPrediction) ...[
          Text(
            PredictionCopy.countdown(r),
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            PredictionCopy.dateLine(r, dates),
            textAlign: TextAlign.center,
            style: text.bodyLarge,
          ),
        ] else ...[
          Text(
            'Keep tracking to build your cycle estimate.',
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
        ],
        if (r.hasPrediction) ...[
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('About this estimate'),
                content: Text(PredictionCopy.explanation(r)),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${PredictionCopy.confidence(r.confidence)} · Why?',
                      style: text.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (ongoingDays >= _longBleedingDays) ...[
          const SizedBox(height: 8),
          const PrivacyNotice(
            'This period has been open for a while. If it has ended, please add the last day. '
            'If bleeding really has lasted this long, it may be worth speaking with a healthcare professional.',
            warning: true,
          ),
        ],
      ],
    );
  }
}
