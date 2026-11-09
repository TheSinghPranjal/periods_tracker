/// Offline educational content. Written as general information and marked as
/// awaiting clinical review: see the release checklist in the README.
const kContentReviewStatus =
    'General information only. Not yet reviewed by a clinician.';

const kDailyTips = [
  'Cycle length is counted from the first day of one period to the first day of the next.',
  'Cycles often vary a little from month to month. A few days of difference is common.',
  'Logging the first day of bleeding is the single most useful entry for your estimates.',
  'Light exercise and a warm compress help some people with period cramps.',
  'Spotting is different from a period. You can log it separately in LunaCycle.',
  'Sleep and stress can both affect how you feel across your cycle.',
  'If a symptom worries you, or changes suddenly, it\'s reasonable to talk to a healthcare professional.',
  'Notes can help you remember details to share at a medical appointment.',
];

class Article {
  const Article({
    required this.title,
    required this.summary,
    required this.body,
    required this.sources,
  });
  final String title;
  final String summary;
  final List<String> body;
  final List<String> sources;
}

const kArticles = [
  Article(
    title: 'Understanding the menstrual cycle',
    summary: 'What a cycle is and how it is counted.',
    body: [
      'A menstrual cycle runs from the first day of one period to the day before the next period starts. Many adults have cycles somewhere between about 21 and 35 days, and it is common for the length to change a little from month to month.',
      'Cycles are often described in phases: the period itself, the follicular phase, ovulation, and the luteal phase. LunaCycle can only estimate these from dates. It does not measure hormones or confirm ovulation.',
    ],
    sources: ['NHS: Periods', 'ACOG: The Menstrual Cycle FAQ'],
  ),
  Article(
    title: 'Common period symptoms',
    summary: 'Cramps, bloating, tiredness and mood changes.',
    body: [
      'Many people notice cramps, bloating, sore breasts, headaches, tiredness or changes in mood before or during a period. The mix and strength of symptoms differs between people and from one cycle to another.',
      'Logging symptoms over a few months can show what is usual for you, which can be useful to share with a healthcare professional.',
    ],
    sources: ['NHS: Period pain', 'NHS: PMS (premenstrual syndrome)'],
  ),
  Article(
    title: 'Managing everyday discomfort',
    summary: 'Simple things some people find helpful.',
    body: [
      'Some people find that heat on the lower tummy, gentle movement, rest or a warm bath eases period discomfort. A pharmacist can advise on over-the-counter pain relief that is suitable for you.',
      'LunaCycle does not recommend medication or doses.',
    ],
    sources: ['NHS: Period pain'],
  ),
  Article(
    title: 'Understanding irregular cycles',
    summary: 'Why cycle length can change.',
    body: [
      'Cycle length can be affected by things such as stress, illness, changes in weight, hormonal contraception, pregnancy, breastfeeding and the years around menopause. Cycles are also often less regular in the first years after periods begin.',
      'If your periods stop, become very irregular or change noticeably, a healthcare professional can help you find out why.',
    ],
    sources: ['NHS: Irregular periods', 'NHS: Stopped or missed periods'],
  ),
  Article(
    title: 'Menstrual hygiene',
    summary: 'Using products safely.',
    body: [
      'Change pads, tampons or cups as the product\'s instructions advise, and wash your hands before and after. Tampons should be changed regularly and the lowest absorbency that suits your flow is generally recommended.',
    ],
    sources: ['NHS: Periods'],
  ),
  Article(
    title: 'When to seek medical advice',
    summary: 'Signs that are worth getting checked.',
    body: [
      'Consider speaking to a healthcare professional if your periods are very heavy, for example if you are soaking through products every hour or two; if bleeding lasts more than about a week; if pain stops you doing everyday things; or if you bleed between periods or after sex.',
      'Also seek advice if your periods stop unexpectedly, or if you might be pregnant and have pain or bleeding.',
      'Seek urgent care for sudden severe pain, heavy bleeding with dizziness or fainting, or if you feel very unwell.',
    ],
    sources: ['NHS: Heavy periods', 'ACOG: Heavy Menstrual Bleeding FAQ'],
  ),
  Article(
    title: 'What estimates can and can\'t do',
    summary: 'The limits of calendar predictions.',
    body: [
      'LunaCycle calculates estimates from the dates you log, using the median of your recent cycles. This is a simple calendar method and not a clinically validated model.',
      'Estimates can be less reliable with irregular cycles, after pregnancy, while using hormonal contraception, and around perimenopause.',
      'Fertile-window and ovulation estimates are approximate. These estimates cannot reliably prevent pregnancy and are not a contraceptive method.',
    ],
    sources: ['ACOG: Fertility Awareness-Based Methods FAQ'],
  ),
];
