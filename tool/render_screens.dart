// Renders key screens to build/screens/*.png for visual review.
// Run with: flutter test tool/render_screens.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/features/calendar/presentation/calendar_screen.dart';
import 'package:periods_tracker/features/home/presentation/home_screen.dart';
import 'package:periods_tracker/features/insights/presentation/insights_screen.dart';
import 'package:periods_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:periods_tracker/features/privacy/presentation/privacy_screen.dart';
import 'package:periods_tracker/features/settings/presentation/profile_screen.dart';
import 'package:periods_tracker/features/symptoms/presentation/log_screen.dart';

import '../test/support/harness.dart';

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _font('NunitoSans', [
      for (final w in [400, 600, 700, 800]) 'assets/fonts/nunito-sans-$w.ttf',
    ]);
    await _font('ShipporiMincho', [
      for (final w in [600, 700]) 'assets/fonts/shippori-mincho-$w.ttf',
    ]);
    await _font('Caveat', ['assets/fonts/caveat-600.ttf']);
    final root =
        Platform.environment['FLUTTER_ROOT'] ??
        '/Users/pranjalsingh/Development/flutter';
    await _font('MaterialIcons', [
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  final screens = <String, Widget>{
    'home': const HomeScreen(),
    'calendar': const CalendarScreen(),
    'log': const LogScreen(),
    'insights': const InsightsScreen(),
    'profile': const ProfileScreen(),
    'privacy': const PrivacyScreen(),
    'onboarding': const OnboardingScreen(),
  };

  for (final dark in [false, true]) {
    for (final entry in screens.entries) {
      if (dark && !{'home', 'calendar'}.contains(entry.key)) continue;
      testWidgets('render ${entry.key} dark=$dark', (tester) async {
        useTallScreen(tester, height: 860);
        tester.view.physicalSize = const Size(393 * 3, 860 * 3);
        final db = memoryDatabase();
        await tester.runAsync(() => seedHistory(db));
        final key = GlobalKey();
        await tester.pumpWidget(
          testScope(
            overrides: testOverrides(db, today: fixedToday),
            child: RepaintBoundary(
              key: key,
              child: themed(
                entry.value,
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
        );
        for (var i = 0; i < 12; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pump(const Duration(seconds: 1));
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('build/screens/${entry.key}${dark ? '_dark' : ''}.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(png!.buffer.asUint8List());
        });
        await disposeApp(tester, db);
      });
    }
  }
}
