import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:periods_tracker/app/app.dart';
import 'package:periods_tracker/app/theme/app_theme.dart';
import 'package:periods_tracker/core/database/app_database.dart';
import 'package:periods_tracker/core/encryption/secure_store.dart';
import 'package:periods_tracker/core/security/app_lock_service.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/calendar/presentation/calendar_screen.dart';
import 'package:periods_tracker/features/home/presentation/home_screen.dart';
import 'package:periods_tracker/features/insights/presentation/history_screen.dart';
import 'package:periods_tracker/features/insights/presentation/insights_screen.dart';
import 'package:periods_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:periods_tracker/features/period_logging/data/period_repository.dart';
import 'package:periods_tracker/features/privacy/presentation/lock_screen.dart';
import 'package:periods_tracker/features/settings/data/settings_repository.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';
import 'package:periods_tracker/features/settings/presentation/settings_screens.dart';
import 'package:periods_tracker/features/symptoms/data/drift_daily_log_repository.dart';
import 'package:periods_tracker/features/symptoms/presentation/day_editor_screen.dart';
import 'package:periods_tracker/features/symptoms/presentation/log_screen.dart';

import '../support/harness.dart';

/// Drift works on real futures, so give them real time between frames.
Future<void> settle(WidgetTester tester, [int rounds = 8]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
  await tester.pump(const Duration(milliseconds: 400));
}

Future<AppDatabase> open(
  WidgetTester tester,
  Widget screen, {
  bool seed = false,
  double height = 2600,
}) async {
  useTallScreen(tester, height: height);
  final db = memoryDatabase();
  await tester.runAsync(() async {
    if (seed) {
      await seedHistory(db);
    } else {
      await DriftSettingsRepository(db).save(
        const AppSettings(
          onboardingCompleted: true,
          usualCycleLength: 28,
          usualPeriodLength: 5,
        ),
      );
    }
  });
  await tester.pumpWidget(
    testScope(overrides: testOverrides(db), child: themed(screen)),
  );
  await settle(tester);
  return db;
}

void main() {
  group('empty states', () {
    testWidgets('home invites the first log and invents nothing', (
      tester,
    ) async {
      final db = await open(tester, const HomeScreen());
      expect(find.text('Let\'s learn your cycle.'), findsOneWidget);
      expect(find.text('Nothing logged today.'), findsOneWidget);
      expect(find.textContaining('Cycle Day'), findsNothing);
      await disposeApp(tester, db);
    });

    testWidgets('insights explains there is no data', (tester) async {
      final db = await open(tester, const InsightsScreen());
      expect(find.text('Nothing to show yet'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('history offers to add a first period', (tester) async {
      final db = await open(tester, const HistoryScreen());
      expect(find.text('No periods recorded yet'), findsOneWidget);
      await disposeApp(tester, db);
    });
  });

  group('home', () {
    testWidgets('shows cycle information after history exists', (tester) async {
      final db = await open(tester, const HomeScreen(), seed: true);
      expect(find.text('Cycle Day'), findsOneWidget);
      expect(find.textContaining('confidence'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('the eye button hides cycle details', (tester) async {
      final db = await open(tester, const HomeScreen(), seed: true);
      await tester.tap(find.byTooltip('Hide cycle details'));
      await settle(tester);
      expect(find.text('Cycle Day'), findsNothing);
      expect(find.textContaining('Cycle details are hidden'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('the guide can be dismissed and reopened', (tester) async {
      final db = await open(tester, const HomeScreen());
      expect(find.text('Getting started'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pump();
      expect(find.text('Getting started'), findsNothing);
      await tester.tap(find.byTooltip('Show instructions'));
      await tester.pump();
      expect(find.text('Getting started'), findsOneWidget);
      await disposeApp(tester, db);
    });
  });

  group('calendar', () {
    testWidgets('tapping a logged day opens its details', (tester) async {
      final db = await open(tester, const CalendarScreen(), seed: true);
      await tester.tap(find.bySemanticsLabel(RegExp(r'^Friday, 20 June 2025')));
      await settle(tester);
      expect(find.text('Friday, 20 June 2025'), findsOneWidget);
      expect(find.text('Log Period'), findsOneWidget);
      expect(find.text('Add Symptoms'), findsOneWidget);
      expect(find.text('Edit Entry'), findsOneWidget);
      expect(find.text('Remove Entry'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('spoken labels separate logged days from estimates', (
      tester,
    ) async {
      final db = await open(tester, const CalendarScreen(), seed: true);
      expect(
        find.bySemanticsLabel(RegExp('June 2025.*logged period')),
        findsWidgets,
      );
      await tester.tap(find.byTooltip('Next month'));
      await settle(tester);
      expect(
        find.bySemanticsLabel(RegExp('July 2025.*estimated period')),
        findsWidgets,
      );
      await disposeApp(tester, db);
    });

    testWidgets('legend entries explain themselves', (tester) async {
      final db = await open(tester, const CalendarScreen(), seed: true);
      await tester.tap(find.text('Estimated period'));
      await settle(tester, 2);
      expect(
        find.textContaining('only turns solid if you log it'),
        findsOneWidget,
      );
      await disposeApp(tester, db);
    });

    testWidgets('fertility warning appears for an estimated fertile day', (
      tester,
    ) async {
      final db = await open(tester, const CalendarScreen(), seed: true);
      await tester.tap(find.byTooltip('Next month'));
      await settle(tester);
      final fertile = find.bySemanticsLabel(
        RegExp('estimated fertile window|estimated ovulation'),
      );
      expect(fertile, findsWidgets);
      await tester.tap(fertile.first);
      await settle(tester);
      expect(find.text(kFertilityWarning), findsOneWidget);
      await disposeApp(tester, db);
    });
  });

  group('logging', () {
    final day = CalendarDate(2025, 6, 18);

    testWidgets('logging a period updates records and the estimate', (
      tester,
    ) async {
      final db = await open(
        tester,
        DayEditorScreen(date: day, focus: DayFocus.all),
      );
      await tester.tap(find.text('Log a period on this day'));
      await settle(tester);
      final saved = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(saved!.single.startDate, day);
      expect(find.textContaining('Part of your period'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('spotting never creates a period', (tester) async {
      final db = await open(
        tester,
        DayEditorScreen(date: day, focus: DayFocus.all),
      );
      await tester.tap(find.text('Spotting'));
      await settle(tester);
      expect(
        find.textContaining('Spotting is saved on its own'),
        findsOneWidget,
      );
      final saved = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(saved, isEmpty);
      await disposeApp(tester, db);
    });

    testWidgets('heavier flow asks before starting a period', (tester) async {
      final db = await open(
        tester,
        DayEditorScreen(date: day, focus: DayFocus.all),
      );
      await tester.tap(find.text('Heavy'));
      await settle(tester);
      expect(find.text('Yes, log it'), findsOneWidget);
      final saved = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(saved, isEmpty);
      await disposeApp(tester, db);
    });

    testWidgets('a symptom can be selected and given an intensity', (
      tester,
    ) async {
      final db = await open(
        tester,
        DayEditorScreen(date: day, focus: DayFocus.symptoms),
      );
      await tester.tap(find.text('Cramps'));
      await settle(tester);
      expect(find.text('How strong was cramps?'), findsOneWidget);
      await tester.tap(find.text('Severe'));
      await settle(tester);
      final e = await tester.runAsync(
        () => DriftDailyLogRepository(db).getRange(from: day, to: day),
      );
      expect(e!.single.symptoms, {'cramps': 3});
      await disposeApp(tester, db);
    });

    testWidgets('multiple moods save together', (tester) async {
      final db = await open(
        tester,
        DayEditorScreen(date: day, focus: DayFocus.mood),
      );
      await tester.tap(find.bySemanticsLabel('Calm'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Tired'));
      await settle(tester);
      final e = await tester.runAsync(
        () => DriftDailyLogRepository(db).getRange(from: day, to: day),
      );
      expect(e!.single.moods.map((m) => m.name).toSet(), {'calm', 'tired'});
      await disposeApp(tester, db);
    });

    testWidgets('future days cannot be logged', (tester) async {
      final db = await open(
        tester,
        DayEditorScreen(date: CalendarDate(2025, 7, 1), focus: DayFocus.all),
      );
      expect(
        find.text('You can log this day when it arrives.'),
        findsOneWidget,
      );
      await disposeApp(tester, db);
    });

    testWidgets('sensitive modules stay hidden until enabled', (tester) async {
      final db = await open(tester, const LogScreen());
      expect(find.text('Private log'), findsNothing);
      expect(find.text('Basal body temperature'), findsNothing);
      expect(find.text('Cervical mucus'), findsNothing);
      await disposeApp(tester, db);
    });
  });

  group('onboarding', () {
    testWidgets('a person can finish without inventing data', (tester) async {
      useTallScreen(tester, height: 1000);
      final db = memoryDatabase();
      await tester.pumpWidget(
        testScope(overrides: testOverrides(db), child: _Router()),
      );
      await settle(tester);

      expect(find.text('Your cycle, your way.'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await settle(tester, 2);
      await tester.tap(find.text('Just track my period'));
      await settle(tester, 1);
      await tester.tap(find.text('Continue'));
      await settle(tester, 2);

      expect(find.text('I don\'t remember'), findsOneWidget);
      await tester.tap(find.text('I don\'t remember'));
      await settle(tester, 1);
      expect(find.textContaining('No date will be guessed'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('Continue'));
        await settle(tester, 2);
      }
      expect(find.textContaining('all set'), findsOneWidget);
      await tester.tap(find.text('Open My Calendar'));
      await settle(tester);

      final s = await tester.runAsync(() => DriftSettingsRepository(db).get());
      expect(s!.onboardingCompleted, isTrue);
      expect(s.goals, {TrackingGoal.justPeriod});
      expect(s.fertilityEstimatesEnabled, isFalse);
      final periods = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(periods, isEmpty);
      await disposeApp(tester, db);
    });

    testWidgets('choosing pregnancy planning shows the warning', (
      tester,
    ) async {
      useTallScreen(tester, height: 1000);
      final db = memoryDatabase();
      await tester.pumpWidget(
        testScope(overrides: testOverrides(db), child: _Router()),
      );
      await settle(tester);
      await tester.tap(find.text('Get Started'));
      await settle(tester, 2);
      await tester.tap(find.text('Plan for pregnancy'));
      await settle(tester, 1);
      expect(
        find.textContaining('cannot reliably prevent pregnancy'),
        findsOneWidget,
      );
      await disposeApp(tester, db);
    });
  });

  group('app lock', () {
    Future<void> enterPin(WidgetTester tester, String pin) async {
      for (final d in pin.split('')) {
        await tester.tap(find.bySemanticsLabel(d));
        await tester.pump();
      }
      await tester.tap(find.byIcon(Icons.check_rounded));
      await settle(tester);
    }

    testWidgets(
      'wrong PIN stays locked, right PIN opens, and nothing shows while locked',
      (tester) async {
        useTallScreen(tester, height: 1000);
        final db = memoryDatabase();
        final store = MemorySecureStore();
        await tester.runAsync(() async {
          await seedHistory(db);
          await AppLockService(store).setPin('4821');
        });
        await tester.pumpWidget(
          testScope(
            overrides: testOverrides(db, store: store),
            child: const LunaApp(),
          ),
        );
        await settle(tester, 12);
        await tester.pump(const Duration(seconds: 2));
        await settle(tester, 6);

        expect(find.byType(LockScreen), findsOneWidget);
        expect(find.text('Cycle Day'), findsNothing);
        expect(find.textContaining('Aiko'), findsNothing);

        await enterPin(tester, '1111');
        expect(find.textContaining('didn\'t match'), findsOneWidget);
        expect(find.byType(LockScreen), findsOneWidget);

        await enterPin(tester, '4821');
        expect(find.byType(LockScreen), findsNothing);
        expect(find.textContaining('Aiko'), findsOneWidget);
        await disposeApp(tester, db);
      },
    );
  });

  group('background privacy', () {
    testWidgets('leaving the app covers it, and locks when a PIN is set', (
      tester,
    ) async {
      useTallScreen(tester, height: 1000);
      final db = memoryDatabase();
      final store = MemorySecureStore();
      await tester.runAsync(() async {
        await seedHistory(db);
        await AppLockService(store).setPin('4821');
      });
      await tester.pumpWidget(
        testScope(
          overrides: testOverrides(db, store: store),
          child: const LunaApp(),
        ),
      );
      await settle(tester, 12);
      await tester.pump(const Duration(seconds: 2));
      await settle(tester, 6);
      await tester.tap(find.bySemanticsLabel('4'));
      for (final d in ['8', '2', '1']) {
        await tester.pump();
        await tester.tap(find.bySemanticsLabel(d));
      }
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check_rounded));
      await settle(tester);
      expect(find.byType(LockScreen), findsNothing);

      final binding = tester.binding;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(AppGuard), findsOneWidget);
      expect(find.bySemanticsLabel('LunaCycle logo'), findsWidgets);

      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(find.byType(LockScreen), findsOneWidget);
      await disposeApp(tester, db);
    });
  });

  group('navigation and theme', () {
    testWidgets('tabs switch and keep their state', (tester) async {
      useTallScreen(tester, height: 1000);
      final db = memoryDatabase();
      await tester.runAsync(() => seedHistory(db));
      await tester.pumpWidget(
        testScope(overrides: testOverrides(db), child: const LunaApp()),
      );
      await settle(tester, 12);
      await tester.pump(const Duration(seconds: 2));
      await settle(tester, 6);

      await tester.tap(find.bySemanticsLabel('Calendar tab'));
      await settle(tester);
      expect(find.text('June 2025'), findsOneWidget);
      await tester.tap(find.byTooltip('Next month'));
      await settle(tester);
      expect(find.text('July 2025'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Insights tab'));
      await settle(tester);
      expect(find.text('Insights'), findsWidgets);

      await tester.tap(find.bySemanticsLabel('Calendar tab'));
      await settle(tester);
      expect(find.text('July 2025'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Log today'));
      await settle(tester);
      expect(find.text('How to log a day'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('choosing dark mode and a palette applies them', (
      tester,
    ) async {
      final db = await open(tester, const AppearanceScreen());
      await tester.tap(find.text('Dark'));
      await settle(tester);
      await tester.tap(find.text('Matcha sage'));
      await settle(tester);
      final s = await tester.runAsync(() => DriftSettingsRepository(db).get());
      expect(s!.themeMode, AppThemeMode.dark);
      expect(s.palette, AppPalette.sage);
      await disposeApp(tester, db);
    });

    testWidgets('premium themes stay locked without an entitlement', (
      tester,
    ) async {
      final db = await open(tester, const AppearanceScreen());
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));
      await disposeApp(tester, db);
    });
  });

  group('accessibility', () {
    for (final (name, screen) in [
      ('home', const HomeScreen() as Widget),
      ('calendar', const CalendarScreen()),
      ('log', const LogScreen()),
      ('insights', const InsightsScreen()),
    ]) {
      testWidgets('$name lays out on a small phone at double text size', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320 * 3, 3000 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final db = memoryDatabase();
        await tester.runAsync(() => seedHistory(db));
        await tester.pumpWidget(
          testScope(overrides: testOverrides(db), child: themed(screen)),
        );
        await settle(tester);
        expect(tester.takeException(), isNull);
        await disposeApp(tester, db);
      });
    }

    testWidgets('main actions meet the minimum touch target', (tester) async {
      final db = await open(tester, const HomeScreen(), seed: true);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await disposeApp(tester, db);
    });
  });
}

class _Router extends StatefulWidget {
  @override
  State<_Router> createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  // Onboarding finishes by navigating, so it needs a router above it.
  final _router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/home', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: '/medications', builder: (_, _) => const SizedBox.shrink()),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: buildLunaTheme(AppPalette.blossom, Brightness.light),
    routerConfig: _router,
  );
}
