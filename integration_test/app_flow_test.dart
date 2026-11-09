import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:periods_tracker/app/app.dart';
import 'package:periods_tracker/app/providers.dart';
import 'package:periods_tracker/core/database/app_database.dart';
import 'package:periods_tracker/core/database/encrypted_connection.dart';
import 'package:periods_tracker/core/notifications/notification_gateway.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';

/// Runs the real app, real plugins and the real encrypted database on a
/// device. Only the OS permission prompt is replaced, because a test cannot
/// answer it. Run with: flutter test integration_test -d DEVICE_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, [int ms = 700]) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await wait(tester, 150);
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for $finder');
  }

  Future<ProviderContainer> launch(
    WidgetTester tester,
    NoopNotificationGateway gateway,
  ) async {
    final container = ProviderContainer(
      overrides: [notificationGatewayProvider.overrideWithValue(gateway)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const LunaApp()),
    );
    return container;
  }

  Future<void> close(WidgetTester tester, ProviderContainer container) async {
    final AppDatabase db = container.read(databaseProvider);
    await tester.pumpWidget(const SizedBox.shrink());
    await wait(tester, 300);
    container.dispose();
    await db.close();
  }

  testWidgets('full journey on a device', (tester) async {
    final file = await databaseFile();
    if (file.existsSync()) file.deleteSync();

    final gateway = NoopNotificationGateway();
    var container = await launch(tester, gateway);

    // Onboarding.
    await waitFor(tester, find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await wait(tester);
    await tester.tap(find.text('Understand my cycle'));
    await wait(tester, 200);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Continue'));
      await wait(tester);
    }
    // Period length, cycle length, regularity, reminders, privacy.
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Continue'));
      await wait(tester);
    }
    await tester.tap(find.text('Open My Calendar'));
    await waitFor(tester, find.text('Home'));
    await wait(tester);
    await tester.tap(find.text('Home'));
    await waitFor(tester, find.text('Let\'s learn your cycle.'));

    // The database must be encrypted on disk.
    final header = file.readAsBytesSync().take(15).toList();
    expect(String.fromCharCodes(header), isNot('SQLite format 3'));

    // Log a period through the real repository and watch the UI respond.
    final today = CalendarDate.today();
    final periods = container.read(periodRepositoryProvider);
    final first = await periods.add(
      start: today.minusDays(57),
      end: today.minusDays(53),
      today: today,
    );
    await periods.add(
      start: today.minusDays(29),
      end: today.minusDays(25),
      today: today,
    );
    await periods.add(start: today.minusDays(1), end: today, today: today);
    await waitFor(tester, find.text('Cycle Day'));

    // Add a daily log through the screen.
    await tester.tap(find.text('Got it'));
    await wait(tester);
    await tester.scrollUntilVisible(
      find.text('Log Symptoms'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await wait(tester, 300);
    await tester.tap(find.text('Log Symptoms'));
    await waitFor(tester, find.text('Cramps'));
    await tester.tap(find.text('Cramps'));
    await waitFor(tester, find.text('How strong was cramps?'));
    await tester.tap(find.byTooltip('Back'));
    await wait(tester);

    // A historical correction changes the estimate.
    final before = container.read(predictionProvider).requireValue;
    await periods.updateDates(
      id: first.id,
      start: today.minusDays(60),
      end: today.minusDays(56),
      today: today,
    );
    await wait(tester);
    final after = container.read(predictionProvider).requireValue;
    expect(after.cycleLength, isNot(before.cycleLength));

    // Reminders are planned from the prediction.
    final db = container.read(databaseProvider);
    await (db.update(db.reminders)..where((t) => t.id.equals('period'))).write(
      const RemindersCompanion(enabled: Value(true)),
    );
    await wait(tester, 1200);
    expect(gateway.history.last, isNotEmpty);
    expect(
      gateway.history.last.first.body,
      'You have a reminder from LunaCycle.',
    );

    // Export contains what was logged.
    final exported =
        jsonDecode(await container.read(dataTransferProvider).exportJson())
            as Map<String, dynamic>;
    expect((exported['periods'] as List).length, 3);
    expect(exported['dailyLogs'].toString(), contains('cramps'));

    // Restart: everything is still there, read back with the stored key.
    await close(tester, container);
    container = await launch(tester, gateway);
    await waitFor(tester, find.text('Cycle Day'));
    expect((await container.read(periodRepositoryProvider).getAll()).length, 3);
    final kept = await container
        .read(dailyLogRepositoryProvider)
        .getRange(from: today, to: today);
    expect(kept.single.symptoms.keys, contains('cramps'));

    // Delete all data.
    await container.read(databaseProvider).wipeEverything();
    await wait(tester);
    expect(await container.read(periodRepositoryProvider).getAll(), isEmpty);
    await close(tester, container);

    // Leave the device as it was found.
    if (File(file.path).existsSync()) File(file.path).deleteSync();
  });
}
