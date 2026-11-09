import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/privacy_channel.dart';
import '../core/widgets/sketch/sakura_art.dart';
import '../core/widgets/sketch/sketch_marks.dart';
import '../features/privacy/presentation/lock_screen.dart';
import '../features/settings/domain/app_settings.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LunaApp extends ConsumerWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(bootProvider).hasValue
        ? ref.watch(currentSettingsProvider)
        : const AppSettings();
    return MaterialApp.router(
      title: 'LunaCycle',
      debugShowCheckedModeBanner: false,
      theme: buildLunaTheme(settings.palette, Brightness.light),
      darkTheme: buildLunaTheme(settings.palette, Brightness.dark),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en', 'GB'), Locale('en', 'US')],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: media.disableAnimations || settings.reduceMotion,
          ),
          child: AppGuard(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Sits above all routes: enforces locking and hides the app when it is not
/// in the foreground, so no screen can show data past it.
class AppGuard extends ConsumerStatefulWidget {
  const AppGuard({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppGuard> createState() => _AppGuardState();
}

class _AppGuardState extends ConsumerState<AppGuard>
    with WidgetsBindingObserver {
  bool _obscured = false;
  bool? _sentHidePreview;
  Timer? _idle;

  bool get _booted => ref.read(bootProvider).hasValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _idle?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _resetIdle() {
    _idle?.cancel();
    if (!_booted) return;
    final minutes = ref.read(currentSettingsProvider).inactivityLockMinutes;
    if (minutes <= 0 || !ref.read(appLockProvider).enabled) return;
    _idle = Timer(Duration(minutes: minutes), () {
      ref.read(appLockProvider.notifier).lockNow();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_booted) return;
    final settings = ref.read(currentSettingsProvider);
    final foreground = state == AppLifecycleState.resumed;
    if (mounted) {
      setState(() => _obscured = !foreground && settings.hideAppPreview);
    }
    if (state == AppLifecycleState.paused && settings.lockOnBackground) {
      ref.read(appLockProvider.notifier).lockNow();
    }
    if (foreground) {
      ref.read(todayProvider.notifier).refresh();
      _resetIdle();
      _refreshTimeZone();
    }
  }

  Future<void> _refreshTimeZone() async {
    if (await ref.read(notificationGatewayProvider).refreshTimeZone()) {
      ref.read(reminderSyncProvider).schedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booted = ref.watch(bootProvider).hasValue;
    final lock = ref.watch(appLockProvider);
    if (booted) {
      ref.watch(reminderSyncProvider);
      final hide = ref.watch(
        currentSettingsProvider.select((s) => s.hideAppPreview),
      );
      if (hide != _sentHidePreview) {
        _sentHidePreview = hide;
        PrivacyChannel.setHidePreview(hide);
      }
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdle(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(offstage: lock.locked, child: widget.child),
          if (lock.locked) const Positioned.fill(child: LockScreen()),
          if (_obscured) const Positioned.fill(child: _PrivacyCover()),
        ],
      ),
    );
  }
}

class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        SakuraBackdrop(style: BackdropStyle.full),
        Center(child: LunaLogo(size: 110)),
      ],
    );
  }
}
