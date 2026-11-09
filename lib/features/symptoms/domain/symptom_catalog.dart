class SymptomDefinition {
  const SymptomDefinition(this.key, this.label);
  final String key;
  final String label;
}

class SymptomCategory {
  const SymptomCategory(this.title, this.items);
  final String title;
  final List<SymptomDefinition> items;
}

const kCustomSymptomPrefix = 'custom:';

const kSymptomCatalog = [
  SymptomCategory('Pain', [
    SymptomDefinition('cramps', 'Cramps'),
    SymptomDefinition('headache', 'Headache'),
    SymptomDefinition('back_pain', 'Back pain'),
    SymptomDefinition('breast_tenderness', 'Breast tenderness'),
    SymptomDefinition('pelvic_discomfort', 'Pelvic discomfort'),
  ]),
  SymptomCategory('Physical', [
    SymptomDefinition('bloating', 'Bloating'),
    SymptomDefinition('fatigue', 'Fatigue'),
    SymptomDefinition('acne', 'Acne'),
    SymptomDefinition('nausea', 'Nausea'),
    SymptomDefinition('dizziness', 'Dizziness'),
    SymptomDefinition('digestive', 'Digestive changes'),
  ]),
  SymptomCategory('Emotional', [
    SymptomDefinition('irritability', 'Irritability'),
    SymptomDefinition('anxiety', 'Anxiety'),
    SymptomDefinition('sadness', 'Sadness'),
    SymptomDefinition('stress', 'Stress'),
    SymptomDefinition('mood_swings', 'Mood swings'),
  ]),
  SymptomCategory('Body and lifestyle', [
    SymptomDefinition('poor_sleep', 'Poor sleep'),
    SymptomDefinition('appetite', 'Appetite changes'),
    SymptomDefinition('cravings', 'Cravings'),
    SymptomDefinition('exercise', 'Exercise'),
    SymptomDefinition('low_energy', 'Low energy'),
    SymptomDefinition('water', 'Low water intake'),
  ]),
];

String symptomLabel(String key) {
  if (key.startsWith(kCustomSymptomPrefix)) {
    return key.substring(kCustomSymptomPrefix.length);
  }
  for (final category in kSymptomCatalog) {
    for (final item in category.items) {
      if (item.key == key) return item.label;
    }
  }
  return key;
}
