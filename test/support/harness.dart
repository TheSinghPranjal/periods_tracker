import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/app/providers.dart';
import 'package:periods_tracker/app/theme/app_theme.dart';
import 'package:periods_tracker/core/database/app_database.dart';
import 'package:periods_tracker/core/encryption/secure_store.dart';
import 'package:periods_tracker/core/notifications/notification_gateway.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/core/utils/health_enums.dart';
import 'package:periods_tracker/features/period_logging/data/period_repository.dart';
import 'package:periods_tracker/features/prediction/domain/cycle_prediction_engine.dart';
import 'package:periods_tracker/features/settings/data/settings_repository.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';
import 'package:periods_tracker/features/symptoms/data/drift_daily_log_repository.dart';

final fixedToday = CalendarDate(2025, 6, 20);

class FixedToday extends TodayNotifier {
  FixedToday(this.date);
  final CalendarDate date;

  @override
  CalendarDate build() => date;

  @override
  void refresh() {}
}

AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Overrides that run the real app logic against an in-memory database.
List<dynamic> testOverrides(
  AppDatabase db, {
  CalendarDate? today,
  NotificationGateway? notifications,
  SecureStore? store,
}) => [
  bootProvider.overrideWith((ref) async => db),
  databaseProvider.overrideWithValue(db),
  todayProvider.overrideWith(() => FixedToday(today ?? fixedToday)),
  notificationGatewayProvider.overrideWithValue(
    notifications ?? NoopNotificationGateway(),
  ),
  secureStoreProvider.overrideWithValue(store ?? MemorySecureStore()),
];

/// Opaque scope so tests stay independent of Riverpod's override type.
Widget testScope({required List<dynamic> overrides, required Widget child}) =>
    ProviderScope(overrides: overrides.cast(), child: child);

Widget themed(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLunaTheme(AppPalette.blossom, brightness),
      home: child,
    );

/// A wide tall viewport so that lists build all their children.
void useTallScreen(WidgetTester tester, {double height = 2400}) {
  tester.view.physicalSize = Size(420 * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await db.close();
  await tester.pump(const Duration(seconds: 1));
}

/// Six months of realistic entries for screens that need history.
Future<void> seedHistory(AppDatabase db, {CalendarDate? today}) async {
  final now = today ?? fixedToday;
  await DriftSettingsRepository(db).save(
    const AppSettings(
      onboardingCompleted: true,
      usualCycleLength: 28,
      usualPeriodLength: 5,
      regularity: Regularity.regular,
      nickname: 'Aiko',
      fertilityEstimatesEnabled: true,
    ),
  );
  final periods = DriftPeriodRepository(db);
  final days = DriftDailyLogRepository(db);
  var start = now.minusDays(120);
  for (final gap in const [28, 30, 27, 29, 28]) {
    await periods.add(start: start, end: start.plusDays(4), today: now);
    await days.patch(
      start,
      const DailyLogsCompanion(flowLevel: Value('heavy'), painLevel: Value(2)),
    );
    await days.patch(
      start.plusDays(1),
      const DailyLogsCompanion(flowLevel: Value('medium'), painLevel: Value(1)),
    );
    await days.setSymptom(start, 'cramps', 2);
    await days.setSymptom(start.plusDays(1), 'fatigue', 1);
    await days.setSymptom(start.plusDays(2), 'headache', 1);
    await days.setMoods(start.plusDays(3), {MoodKind.calm, MoodKind.tired});
    await days.setMoods(start.plusDays(10), {MoodKind.happy});
    start = start.plusDays(gap);
  }
  await days.setSymptom(now.minusDays(1), 'cramps', 1);
  await days.setSymptom(now.minusDays(3), 'cramps', 2);
  await days.setSymptom(now, 'bloating', 2);
  await days.setMoods(now, {MoodKind.calm});
}
