import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/security/app_lock_service.dart';
import '../../../core/widgets/sketch/sakura_art.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../../../core/widgets/sketch/sketch_marks.dart';

const kMinPinLength = 4;
const kMaxPinLength = 8;

class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.length,
    required this.onDigit,
    required this.onDelete,
    this.extra,
  });
  final int length;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    Widget key(String digit) => _PadKey(
      semantic: digit,
      onTap: () => onDigit(digit),
      child: Text(digit, style: Theme.of(context).textTheme.headlineSmall),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '$length digits entered',
          liveRegion: true,
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < length; i++)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: BlossomIcon(size: 22),
                  ),
                if (length == 0)
                  Text(
                    'Enter your PIN',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map(key).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            extra ?? const SizedBox(width: 84),
            key('0'),
            _PadKey(
              semantic: 'Delete digit',
              onTap: onDelete,
              child: Icon(Icons.backspace_outlined, color: t.ink),
            ),
          ],
        ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    required this.semantic,
    required this.onTap,
    required this.child,
  });
  final String semantic;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantic,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 38,
        child: SizedBox(width: 84, height: 68, child: Center(child: child)),
      ),
    );
  }
}

/// Replaces the whole app until unlocked. Nothing behind it is painted.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with WidgetsBindingObserver {
  String _pin = '';
  String? _message;
  bool _busy = false;
  bool _biometricTried = false;
  bool _prompting = false;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The prompt itself only makes the app inactive, so this cannot loop.
    if (state == AppLifecycleState.paused) _wasBackgrounded = true;
    if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      _wasBackgrounded = false;
      _biometricTried = false;
      unawaited(_tryBiometric());
    }
  }

  Future<void> _tryBiometric() async {
    final lock = ref.read(appLockProvider);
    if (!lock.biometric || _biometricTried || _prompting || !mounted) return;
    // The app locks as it goes to the background; a prompt can't show there.
    final appState = WidgetsBinding.instance.lifecycleState;
    if (appState != null && appState != AppLifecycleState.resumed) return;
    _biometricTried = true;
    _prompting = true;
    final notifier = ref.read(appLockProvider.notifier);
    final ok = await notifier.withoutLocking(
      () => ref.read(biometricsProvider).authenticate('Unlock LunaCycle'),
    );
    _prompting = false;
    if (ok && mounted) notifier.unlock();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(appLockServiceProvider).verify(_pin);
    if (!mounted) return;
    switch (result) {
      case PinAccepted():
        ref.read(appLockProvider.notifier).unlock();
      case PinRejected(:final lockedFor):
        setState(() {
          _pin = '';
          _message = lockedFor == null
              ? 'That PIN didn\'t match. Please try again.'
              : 'Too many attempts. Try again in ${lockedFor.inSeconds} seconds.';
        });
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SakuraBackdrop(style: BackdropStyle.full),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LunaLogo(size: 76),
                    const SizedBox(height: 8),
                    Text('LunaCycle is locked', style: text.headlineSmall),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _message ?? 'Enter your PIN, then tap the tick.',
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(
                            color: _message == null ? t.inkSoft : t.error,
                          ),
                        ),
                      ),
                    ),
                    PinPad(
                      length: _pin.length,
                      onDigit: (d) {
                        if (_pin.length < kMaxPinLength) {
                          setState(() => _pin += d);
                        }
                      },
                      onDelete: () {
                        if (_pin.isNotEmpty) {
                          setState(
                            () => _pin = _pin.substring(0, _pin.length - 1),
                          );
                        }
                      },
                      extra: lock.biometric
                          ? SizedBox(
                              width: 84,
                              child: IconButton(
                                icon: Icon(
                                  Icons.fingerprint_rounded,
                                  semanticLabel: 'Unlock with biometrics',
                                  size: 34,
                                  color: t.periodFill,
                                ),
                                onPressed: () {
                                  _biometricTried = false;
                                  unawaited(_tryBiometric());
                                },
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    IconButton.filledTonal(
                      iconSize: 28,
                      onPressed: _pin.length >= kMinPinLength && !_busy
                          ? _submit
                          : null,
                      icon: const Icon(
                        Icons.check_rounded,
                        semanticLabel: 'Unlock',
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

/// Bottom sheet that asks for a new PIN twice. Returns true once saved.
Future<bool> showPinSetup(BuildContext context, WidgetRef ref) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _PinSetup(),
  );
  return result ?? false;
}

class _PinSetup extends ConsumerStatefulWidget {
  const _PinSetup();

  @override
  ConsumerState<_PinSetup> createState() => _PinSetupState();
}

class _PinSetupState extends ConsumerState<_PinSetup> {
  String? _first;
  String _pin = '';
  String? _error;
  bool _saving = false;

  Future<void> _next() async {
    if (_first == null) {
      setState(() {
        _first = _pin;
        _pin = '';
        _error = null;
      });
      return;
    }
    if (_first != _pin) {
      setState(() {
        _first = null;
        _pin = '';
        _error = 'Those PINs didn\'t match. Please start again.';
      });
      return;
    }
    setState(() => _saving = true);
    await ref.read(appLockProvider.notifier).setPin(_pin);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = LunaTokens.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _first == null ? 'Choose a PIN' : 'Enter it once more',
              style: text.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _error ??
                  'Use $kMinPinLength to $kMaxPinLength digits. If you forget it, you will need to reinstall the app, which erases your data.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(
                color: _error == null ? t.inkSoft : t.error,
              ),
            ),
            const SizedBox(height: 14),
            PinPad(
              length: _pin.length,
              onDigit: (d) {
                if (_pin.length < kMaxPinLength) setState(() => _pin += d);
              },
              onDelete: () {
                if (_pin.isNotEmpty) {
                  setState(() => _pin = _pin.substring(0, _pin.length - 1));
                }
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: _first == null ? 'Continue' : 'Save PIN',
                onPressed: _pin.length >= kMinPinLength && !_saving
                    ? _next
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
