import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:local_auth/local_auth.dart';

import '../encryption/secure_store.dart';

const kPinHashKey = 'lock.pin_hash';
const kPinSaltKey = 'lock.pin_salt';
const kBiometricKey = 'lock.biometric';
const kFailedAttemptsKey = 'lock.failed';
const kLockedUntilKey = 'lock.until';

sealed class PinResult {
  const PinResult();
}

class PinAccepted extends PinResult {
  const PinAccepted();
}

class PinRejected extends PinResult {
  const PinRejected(this.lockedFor);
  final Duration? lockedFor;
}

abstract interface class BiometricAuthenticator {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class DeviceBiometrics implements BiometricAuthenticator {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Exception {
      return false;
    }
  }
}

/// The PIN gates the interface. The database itself is encrypted with a
/// separate random key, so forgetting the PIN does not orphan the data file.
class AppLockService {
  AppLockService(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final SecureStore _store;
  final DateTime Function() _clock;
  static const _freeAttempts = 5;

  Future<List<int>> _hash(String pin, List<int> salt) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
    return key.extractBytes();
  }

  Future<bool> isEnabled() async => await _store.read(kPinHashKey) != null;

  Future<bool> isBiometricEnabled() async =>
      await _store.read(kBiometricKey) == 'true';

  Future<void> setBiometricEnabled(bool value) =>
      _store.write(kBiometricKey, value.toString());

  Future<void> setPin(String pin) async {
    final random = Random.secure();
    final salt = List.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(pin, salt);
    await _store.write(kPinSaltKey, base64Encode(salt));
    await _store.write(kPinHashKey, base64Encode(hash));
    await _clearFailures();
  }

  Future<void> disable() async {
    await _store.delete(kPinHashKey);
    await _store.delete(kPinSaltKey);
    await _store.delete(kBiometricKey);
    await _clearFailures();
  }

  Future<void> _clearFailures() async {
    await _store.delete(kFailedAttemptsKey);
    await _store.delete(kLockedUntilKey);
  }

  Future<Duration?> remainingLockout() async {
    final until = int.tryParse(await _store.read(kLockedUntilKey) ?? '');
    if (until == null) return null;
    final left = DateTime.fromMillisecondsSinceEpoch(
      until,
    ).difference(_clock());
    return left.isNegative ? null : left;
  }

  Future<PinResult> verify(String pin) async {
    final lockout = await remainingLockout();
    if (lockout != null) return PinRejected(lockout);
    final saltText = await _store.read(kPinSaltKey);
    final hashText = await _store.read(kPinHashKey);
    if (saltText == null || hashText == null) return const PinRejected(null);

    final candidate = await _hash(pin, base64Decode(saltText));
    final expected = base64Decode(hashText);
    var difference = candidate.length ^ expected.length;
    for (var i = 0; i < candidate.length && i < expected.length; i++) {
      difference |= candidate[i] ^ expected[i];
    }
    if (difference == 0) {
      await _clearFailures();
      return const PinAccepted();
    }

    final failures =
        int.parse(await _store.read(kFailedAttemptsKey) ?? '0') + 1;
    await _store.write(kFailedAttemptsKey, '$failures');
    if (failures < _freeAttempts) return const PinRejected(null);
    final wait = Duration(
      seconds: 30 * pow(2, failures - _freeAttempts).toInt().clamp(1, 120),
    );
    await _store.write(
      kLockedUntilKey,
      '${_clock().add(wait).millisecondsSinceEpoch}',
    );
    return PinRejected(wait);
  }
}
