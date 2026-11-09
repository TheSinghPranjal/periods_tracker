import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/database/app_database.dart';
import '../core/database/encrypted_connection.dart';
import '../core/encryption/secure_store.dart';
import '../core/errors/app_failure.dart';
import '../core/notifications/notification_gateway.dart';
import '../core/security/app_lock_service.dart';
import '../core/security/privacy_channel.dart';

const kDatabaseKeyName = 'db.key';

/// Startup order: secure storage, database, notifications. The lock state is
/// loaded before any screen can read data.
class AppBootstrap {
  AppBootstrap({required this.store, required this.notifications});
  final SecureStore store;
  final NotificationGateway notifications;

  Future<AppDatabase> run() async {
    final file = await databaseFile();
    if (!file.existsSync()) await _clearLeftoverSecrets();
    var key = await store.read(kDatabaseKeyName);
    if (key == null) {
      if (file.existsSync() && file.lengthSync() > 0) {
        throw const AppFailure(
          FailureKind.encryptionKeyLost,
          'Your data is on this device, but the key that unlocks it is missing.',
        );
      }
      key = _generateKey();
      await store.write(kDatabaseKeyName, key);
    }

    final database = AppDatabase(openEncryptedExecutor(file, key));
    try {
      await database.customSelect('SELECT count(*) FROM period_records').get();
    } on AppFailure {
      await database.close();
      rethrow;
    } catch (error) {
      await database.close();
      debugPrint('Database open failed: ${error.runtimeType}');
      throw const AppFailure(
        FailureKind.databaseUnreadable,
        'Your data could not be opened. It has not been changed.',
      );
    }

    await PrivacyChannel.excludeFromBackup(file.path);
    try {
      await notifications.initialize();
    } catch (error) {
      // Reminders are optional; tracking must still work without them.
      debugPrint('Notifications unavailable: ${error.runtimeType}');
    }
    return database;
  }

  /// iOS keeps Keychain items after an app is uninstalled. A missing database
  /// means a fresh install, so an old PIN must not lock the new one.
  Future<void> _clearLeftoverSecrets() async {
    for (final key in const [
      kDatabaseKeyName,
      kPinHashKey,
      kPinSaltKey,
      kBiometricKey,
      kFailedAttemptsKey,
      kLockedUntilKey,
    ]) {
      await store.delete(key);
    }
  }

  /// Only ever reached from an explicit, confirmed choice on the error screen.
  Future<void> resetStorage() async {
    final file = await databaseFile();
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File('${file.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    await _clearLeftoverSecrets();
  }

  String _generateKey() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
