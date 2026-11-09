import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/calendar_date.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/calendar/presentation/year_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/insights/presentation/history_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/privacy/presentation/privacy_screen.dart';
import '../../features/reminders/presentation/medications_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screens.dart';
import '../../features/settings/presentation/support_screens.dart';
import '../../features/symptoms/presentation/day_editor_screen.dart';
import '../../features/symptoms/presentation/log_screen.dart';
import 'app_shell.dart';

GoRoute _page(String path, Widget Function(GoRouterState) build) =>
    GoRoute(path: path, builder: (_, state) => build(state));

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      _page('/splash', (_) => const SplashScreen()),
      _page('/onboarding', (_) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [_page('/home', (_) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [_page('/calendar', (_) => const CalendarScreen())],
          ),
          StatefulShellBranch(
            routes: [_page('/log', (_) => const LogScreen())],
          ),
          StatefulShellBranch(
            routes: [_page('/insights', (_) => const InsightsScreen())],
          ),
          StatefulShellBranch(
            routes: [_page('/profile', (_) => const ProfileScreen())],
          ),
        ],
      ),
      _page(
        '/day/:date',
        (s) => DayEditorScreen(
          date: CalendarDate.parse(s.pathParameters['date']!),
          focus: DayFocus.fromName(s.uri.queryParameters['focus']),
        ),
      ),
      _page('/year', (_) => const YearScreen()),
      _page('/history', (_) => const HistoryScreen()),
      _page('/reminders', (_) => const RemindersScreen()),
      _page('/medications', (_) => const MedicationsScreen()),
      _page('/privacy', (_) => const PrivacyScreen()),
      _page('/settings/cycle', (_) => const CycleSettingsScreen()),
      _page('/settings/appearance', (_) => const AppearanceScreen()),
      _page('/settings/general', (_) => const GeneralSettingsScreen()),
      _page('/settings/modules', (_) => const TrackingModulesScreen()),
      _page('/premium', (_) => const PremiumScreen()),
      _page('/help', (_) => const HelpScreen()),
      _page('/articles', (_) => const ArticlesScreen()),
      _page('/faq', (_) => const FaqScreen()),
      _page('/legal/:doc', (s) => LegalScreen(doc: s.pathParameters['doc']!)),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
