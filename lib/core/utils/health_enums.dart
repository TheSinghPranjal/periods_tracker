enum MoodKind {
  happy('Happy'),
  calm('Calm'),
  neutral('Neutral'),
  sad('Sad'),
  anxious('Anxious'),
  irritable('Irritable'),
  energetic('Energetic'),
  tired('Tired');

  const MoodKind(this.label);
  final String label;
}

enum FlowLevel {
  spotting('Spotting', 0, 'A few drops or marks'),
  light('Light', 1, 'Small amount'),
  medium('Medium', 2, 'Steady flow'),
  heavy('Heavy', 3, 'Soaking through quickly'),
  veryHeavy('Very heavy', 4, 'Hard to manage');

  const FlowLevel(this.label, this.level, this.hint);
  final String label;
  final int level;
  final String hint;

  static FlowLevel? tryName(String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

enum MucusType {
  dry('Dry'),
  sticky('Sticky'),
  creamy('Creamy'),
  watery('Watery'),
  eggWhite('Egg-white');

  const MucusType(this.label);
  final String label;
}

enum OvulationTestResult {
  positive('Positive'),
  negative('Negative'),
  invalid('Invalid'),
  notTaken('Not taken');

  const OvulationTestResult(this.label);
  final String label;
}

const kIntensityLabels = ['None', 'Mild', 'Moderate', 'Severe'];
