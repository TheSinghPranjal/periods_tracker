import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminders/domain/reminder_planner.dart';

abstract interface class NotificationGateway {
  Future<void> initialize();

  /// Re-reads the device timezone. True when it changed.
  Future<bool> refreshTimeZone();
  Future<bool> requestPermission();
  Future<void> replaceAll(List<PlannedNotification> plan);
  Future<void> cancelAll();
}

class LocalNotificationGateway implements NotificationGateway {
  final _plugin = FlutterLocalNotificationsPlugin();
  String? _zone;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'lunacycle_reminders',
      'Reminders',
      channelDescription: 'Reminders you have set in LunaCycle',
      importance: Importance.defaultImportance,
      visibility: NotificationVisibility.private,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await refreshTimeZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_luna'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> refreshTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final changed = _zone != null && _zone != info.identifier;
      _zone = info.identifier;
      tz.setLocalLocation(tz.getLocation(info.identifier));
      return changed;
    } on Exception {
      // Unknown zone name: scheduling then falls back to the library default.
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {
    await _plugin.cancelAll();
    for (final item in plan) {
      await _plugin.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledDate: tz.TZDateTime(
          tz.local,
          item.at.year,
          item.at.month,
          item.at.day,
          item.at.hour,
          item.at.minute,
        ),
        notificationDetails: _details,
        // Inexact alarms need no special permission and are enough here.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: switch (item.repeat) {
          ReminderRepeat.daily => DateTimeComponents.time,
          ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
          ReminderRepeat.once => null,
        },
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

class NoopNotificationGateway implements NotificationGateway {
  final List<List<PlannedNotification>> history = [];
  bool permission = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> refreshTimeZone() async => false;

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async =>
      history.add(plan);

  @override
  Future<void> cancelAll() async => history.add(const []);
}
