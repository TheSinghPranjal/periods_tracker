import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native privacy controls: blocking screenshots and app-switcher previews,
/// and keeping the database out of iCloud / iTunes backups.
abstract final class PrivacyChannel {
  static const _channel = MethodChannel('lunacycle/privacy');

  static Future<void> setHidePreview(bool hide) =>
      _call('setHidePreview', {'hide': hide});

  static Future<void> excludeFromBackup(String path) =>
      _call('excludeFromBackup', {'path': path});

  static Future<void> _call(String method, Map<String, Object?> args) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Desktop and test hosts have no native side.
    } on PlatformException catch (e) {
      debugPrint('Privacy channel failed: ${e.code}');
    }
  }
}
