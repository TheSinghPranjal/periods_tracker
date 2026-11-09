import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:periods_tracker/app/theme/app_theme.dart';
import 'package:periods_tracker/core/database/app_database.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/features/calendar/presentation/calendar_screen.dart';
import 'package:periods_tracker/features/home/presentation/home_screen.dart';
import 'package:periods_tracker/features/insights/presentation/history_screen.dart';
import 'package:periods_tracker/features/insights/presentation/insights_screen.dart';
import 'package:periods_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:periods_tracker/features/period_logging/data/period_repository.dart';
import 'package:periods_tracker/features/privacy/presentation/privacy_screen.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';
import 'package:periods_tracker/features/settings/presentation/profile_screen.dart';
import 'package:periods_tracker/features/symptoms/data/drift_daily_log_repository.dart';
import 'package:periods_tracker/features/symptoms/presentation/day_editor_screen.dart';
import 'package:periods_tracker/features/symptoms/presentation/log_screen.dart';

import '../support/harness.dart';

Future<void> settle(WidgetTester tester, [int rounds = 8]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
  await tester.pump(const Duration(milliseconds: 400));
}

Future<AppDatabase> seeded(WidgetTester tester, Widget screen) async {
  useTallScreen(tester, height: 2600);
  final db = memoryDatabase();
  await tester.runAsync(() => seedHistory(db));
  await tester.pumpWidget(
    testScope(overrides: testOverrides(db), child: themed(screen)),
  );
  await settle(tester);
  return db;
}

GoRouter onboardingRouter() => GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, _) => const Text('HOME ROUTE')),
    GoRoute(path: '/calendar', builder: (_, _) => const Text('CALENDAR ROUTE')),
    GoRoute(path: '/medications', builder: (_, _) => const SizedBox.shrink()),
  ],
);

Widget onboardingApp(Brightness brightness) => MaterialApp.router(
  theme: buildLunaTheme(AppPalette.blossom, brightness),
  routerConfig: onboardingRouter(),
);

Future<void> advance(WidgetTester tester, int continues) async {
  await tester.tap(find.text('Get Started'));
  await settle(tester, 2);
  for (var i = 0; i < continues; i++) {
    final button = find.text('Continue');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await settle(tester, 2);
  }
}

void main() {
  group('actions started from a closing sheet', () {
    testWidgets('Log Period on a calendar day creates the period', (
      tester,
    ) async {
      final db = await seeded(tester, const CalendarScreen());
      await tester.tap(
        find.bySemanticsLabel(RegExp(r'^Tuesday, 10 June 2025')),
      );
      await settle(tester);
      await tester.tap(find.text('Log Period'));
      await settle(tester);
      final all = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(all!.map((p) => p.startDate), contains(CalendarDate(2025, 6, 10)));
      expect(find.textContaining('Period started'), findsOneWidget);
      await disposeApp(tester, db);
    });

    testWidgets('Delete from the period editor removes it and offers undo', (
      tester,
    ) async {
      final db = await seeded(tester, const HistoryScreen());
      final before = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      await tester.tap(find.textContaining('Period length').first);
      await settle(tester);
      await tester.tap(find.text('Delete this period'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect(tester.takeException(), isNull);
      final after = await tester.runAsync(
        () => DriftPeriodRepository(db).getAll(),
      );
      expect(after!.length, before!.length - 1);
      expect(find.text('Undo'), findsOneWidget);
      await disposeApp(tester, db);
    });
  });

  testWidgets('a note typed just before leaving is still saved', (
    tester,
  ) async {
    final day = CalendarDate(2025, 6, 18);
    final db = await seeded(
      tester,
      DayEditorScreen(date: day, focus: DayFocus.note),
    );
    await tester.enterText(find.byType(TextField), 'remember this');
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester, 3);
    final saved = await tester.runAsync(
      () => DriftDailyLogRepository(db).getRange(from: day, to: day),
    );
    expect(saved!.single.notes, 'remember this');
    await db.close();
    await tester.pump(const Duration(seconds: 1));
  });

  group('onboarding', () {
    testWidgets('Open My Calendar opens the calendar', (tester) async {
      useTallScreen(tester, height: 1200);
      final db = memoryDatabase();
      await tester.pumpWidget(
        testScope(
          overrides: testOverrides(db),
          child: onboardingApp(Brightness.light),
        ),
      );
      await settle(tester);
      await advance(tester, 7);
      await tester.tap(find.text('Open My Calendar'));
      await settle(tester);
      expect(find.text('CALENDAR ROUTE'), findsOneWidget);
      await disposeApp(tester, db);
    });

    for (final dark in [false, true]) {
      for (var step = 0; step <= 7; step++) {
        testWidgets(
          'step ${step + 1} fits a small phone at double text size (dark=$dark)',
          (tester) async {
            tester.view.physicalSize = const Size(320 * 3, 2400 * 3);
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);
            tester.platformDispatcher.textScaleFactorTestValue = 2;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final db = memoryDatabase();
            await tester.pumpWidget(
              testScope(
                overrides: testOverrides(db),
                child: onboardingApp(dark ? Brightness.dark : Brightness.light),
              ),
            );
            await settle(tester);
            await advance(tester, step);
            expect(tester.takeException(), isNull);
            await disposeApp(tester, db);
          },
        );
      }
    }
  });

  group('accessibility guidelines', () {
    final screens = <String, Widget>{
      'home': const HomeScreen(),
      'calendar': const CalendarScreen(),
      'log': const LogScreen(),
      'insights': const InsightsScreen(),
      'profile': const ProfileScreen(),
      'privacy': const PrivacyScreen(),
    };
    for (final entry in screens.entries) {
      testWidgets('${entry.key}: touch targets and labels', (tester) async {
        final semantics = tester.ensureSemantics();
        final db = await seeded(tester, entry.value);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
        await disposeApp(tester, db);
      });
    }
  });
}
