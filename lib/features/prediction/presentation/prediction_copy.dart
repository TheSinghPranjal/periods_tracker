import '../../../core/widgets/common.dart';
import '../domain/cycle_prediction_engine.dart';

/// All wording about estimates lives here so that it stays consistently
/// cautious: "may", "estimated", and never a claim of certainty.
abstract final class PredictionCopy {
  static String confidence(PredictionConfidence c) => switch (c) {
    PredictionConfidence.none => 'Not enough information yet',
    PredictionConfidence.low => 'Low confidence',
    PredictionConfidence.medium => 'Medium confidence',
    PredictionConfidence.high => 'Higher confidence',
  };

  static String countdown(CyclePredictionResult r) {
    final days = r.daysUntilNext!;
    if (r.overdueDays > 0) {
      return 'Next period is ${r.overdueDays} ${r.overdueDays == 1 ? 'day' : 'days'} past the estimate';
    }
    if (days == 0) return 'Next period may start today';
    return 'Next period estimated in $days ${days == 1 ? 'day' : 'days'}';
  }

  static String dateLine(CyclePredictionResult r, LunaDates dates) {
    if (r.overdueDays > 0) {
      return 'It was estimated for ${dates.longDay(r.predictedStart!)}. Cycles can vary.';
    }
    if (r.showAsRange) {
      return 'May start between ${dates.range(r.earliestStart!, r.latestStart!)}';
    }
    return 'May start around ${dates.longDay(r.predictedStart!)}';
  }

  static String explanation(CyclePredictionResult r) {
    final base = switch (r.basis) {
      PredictionBasis.none => 'Log your period to begin building an estimate.',
      PredictionBasis.statedBaseline =>
        'Based on the usual cycle length you entered, because there isn\'t enough logged history yet.',
      PredictionBasis.history =>
        'Based on the median of your last ${r.historyCount} recorded ${r.historyCount == 1 ? 'cycle' : 'cycles'}.',
      PredictionBasis.manualAdjustment => 'You set this date yourself.',
    };
    final variability = r.highVariability
        ? ' Your cycles vary quite a bit, so a range is shown instead of one date.'
        : '';
    return '$base$variability This is a calendar estimate, not a medical prediction. It can be less '
        'reliable with irregular cycles, after pregnancy, with hormonal contraception, or during perimenopause.';
  }

  static String phaseName(CyclePhase p) => switch (p) {
    CyclePhase.menstrual => 'Menstrual',
    CyclePhase.follicular => 'Follicular (estimated)',
    CyclePhase.estimatedOvulation => 'Estimated ovulation',
    CyclePhase.luteal => 'Luteal (estimated)',
  };

  static String phaseBlurb(CyclePhase p) => switch (p) {
    CyclePhase.menstrual =>
      'Bleeding marks the start of a new cycle. Some people feel more tired or crampy around now.',
    CyclePhase.follicular =>
      'The days after a period, when the body typically prepares an egg. This phase is estimated from dates, not measured.',
    CyclePhase.estimatedOvulation =>
      'A calendar-based estimate of when ovulation might happen. It is not confirmed and can differ from what your body is doing.',
    CyclePhase.luteal =>
      'The days before the next period, estimated from dates. Some people notice mood or body changes around this time.',
  };
}
