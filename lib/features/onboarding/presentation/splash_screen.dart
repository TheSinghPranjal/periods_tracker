import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sakura_art.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _visible = false;
  bool _routed = false;
  late final Future<void> _minimum = Future<void>.delayed(
    const Duration(milliseconds: 1300),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  Future<void> _route() async {
    if (_routed) return;
    _routed = true;
    // The lock state must be known before the next screen can be built.
    await ref.read(appLockProvider.notifier).load();
    final settings = await ref.read(settingsRepositoryProvider).get();
    await _minimum;
    if (!mounted) return;
    context.go(settings.onboardingCompleted ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final boot = ref.watch(bootProvider);
    if (boot.hasValue) unawaited(_route());
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SakuraBackdrop(style: BackdropStyle.full),
          SafeArea(
            child: Center(
              child: boot.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(22),
                      child: _BootFailure(error: boot.error!),
                    )
                  : AnimatedOpacity(
                      opacity: _visible ? 1 : 0,
                      duration: const Duration(milliseconds: 350),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LunaLogo(size: 118),
                          const SizedBox(height: 18),
                          Text('LunaCycle', style: text.displayMedium),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Understand your cycle. Feel more prepared.',
                              textAlign: TextAlign.center,
                              style: text.bodyLarge?.copyWith(color: t.inkSoft),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootFailure extends ConsumerWidget {
  const _BootFailure({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final failure = error is AppFailure ? error as AppFailure : null;
    final canReset =
        failure?.kind == FailureKind.encryptionKeyLost ||
        failure?.kind == FailureKind.databaseUnreadable;
    return SketchCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('We couldn\'t open LunaCycle', style: text.titleLarge),
          const SizedBox(height: 8),
          Text(
            failure?.message ??
                'Something stopped the app from starting. Your data has not been changed.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Try again',
            onPressed: () => ref.invalidate(bootProvider),
          ),
          if (canReset) ...[
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Erase and start fresh',
              destructive: true,
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Erase everything?',
                  message:
                      'This permanently deletes the data file on this device. It cannot be undone. '
                      'If you have a backup, you can restore it afterwards.',
                  confirmLabel: 'Erase',
                  destructive: true,
                );
                if (!ok) return;
                await ref.read(bootstrapProvider).resetStorage();
                ref.invalidate(bootProvider);
              },
            ),
          ],
        ],
      ),
    );
  }
}
