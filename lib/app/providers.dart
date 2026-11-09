import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../core/encryption/secure_store.dart';
import '../core/notifications/notification_gateway.dart';
import '../core/security/app_lock_service.dart';
import '../core/utils/calendar_date.dart';
import '../features/period_logging/data/period_repository.dart';
import '../features/period_logging/domain/period_rules.dart';
import '../features/prediction/domain/cycle_prediction_engine.dart';
import '../features/privacy/data/data_transfer_service.dart';
import '../features/reminders/domain/reminder_planner.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/symptoms/data/drift_daily_log_repository.dart';
import '../features/symptoms/domain/day_entry.dart';
import 'bootstrap.dart';

final secureStoreProvider = Provider<SecureStore>(
  (_) => const PlatformSecureStore(),
);
final notificationGatewayProvider = Provider<NotificationGateway>(
  (_) => LocalNotificationGateway(),
);
final biometricsProvider = Provider<BiometricAuthenticator>(
  (_) => DeviceBiometrics(),
);
final bootstrapProvider = Provider<AppBootstrap>(
  (ref) => AppBootstrap(
    store: ref.watch(secureStoreProvider),
    notifications: ref.watch(notificationGatewayProvider),
  ),
);

final bootProvider = FutureProvider<AppDatabase>(
  (ref) => ref.watch(bootstrapProvider).run(),
  retry: (_, _) => null,
);

final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(bootProvider).requireValue,
);

final periodRepositoryProvider = Provider<PeriodRepository>(
  (ref) => DriftPeriodRepository(ref.watch(databaseProvider)),
);
final dailyLogRepositoryProvider = Provider<DailyLogRepository>(
  (ref) => DriftDailyLogRepository(ref.watch(databaseProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);
final dataTransferProvider = Provider<DataTransferService>(
  (ref) => DataTransferService(ref.watch(databaseProvider)),
);
final appLockServiceProvider = Provider<AppLockService>(
  (ref) => AppLockService(ref.watch(secureStoreProvider)),
);

class TodayNotifier extends Notifier<CalendarDate> {
  Timer? _timer;

  @override
  CalendarDate build() {
    ref.onDispose(() => _timer?.cancel());
    _arm();
    return CalendarDate.today();
  }

  void _arm() {
    _timer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(
      midnight.difference(now) + const Duration(seconds: 1),
      refresh,
    );
  }

  void refresh() {
    state = CalendarDate.today();
    _arm();
  }
}

final todayProvider = NotifierProvider<TodayNotifier, CalendarDate>(
  TodayNotifier.new,
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Settings once loaded; defaults for the brief moment before that.
final currentSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(settingsProvider).value ?? const AppSettings(),
);

final periodsProvider = StreamProvider<List<PeriodRecord>>(
  (ref) => ref.watch(periodRepositoryProvider).watchAll(),
);

final periodSpansProvider = Provider<List<PeriodSpan>>(
  (ref) => (ref.watch(periodsProvider).value ?? const []).map(spanOf).toList(),
);

final dayEntryProvider = StreamProvider.family<DayEntry, CalendarDate>(
  (ref, date) => ref.watch(dailyLogRepositoryProvider).watchDay(date),
);

final allDaysProvider = StreamProvider<List<DayEntry>>(
  (ref) => ref.watch(dailyLogRepositoryProvider).watchRange(),
);

final customSymptomsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(dailyLogRepositoryProvider).watchCustomSymptoms(),
);

final remindersProvider = StreamProvider<List<ReminderRecord>>(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).reminders)
      .watch(),
);

final medicationsProvider = StreamProvider<List<MedicationRecord>>(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).medications)
      .watch(),
);

final medicationLogsProvider = StreamProvider<List<MedicationLog>>(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).medicationLogs)
      .watch(),
);

/// Recomputed whenever history, baseline, preferences or the date changes.
final predictionProvider = Provider<AsyncValue<CyclePredictionResult>>((ref) {
  final periods = ref.watch(periodsProvider);
  final settings = ref.watch(settingsProvider);
  final today = ref.watch(todayProvider);

  final error = periods.hasError
      ? periods
      : (settings.hasError ? settings : null);
  if (error != null) {
    return AsyncError(error.error!, error.stackTrace ?? StackTrace.current);
  }
  if (!periods.hasValue || !settings.hasValue) return const AsyncLoading();

  final s = settings.requireValue;
  final records = periods.requireValue;
  final latest = records.isEmpty ? null : records.last.startDate;
  return AsyncData(
    const CyclePredictionEngine().predict(
      PredictionInput(
        periods: records
            .map((r) => PeriodObservation(start: r.startDate, end: r.endDate))
            .toList(),
        today: today,
        usualCycleLength: s.usualCycleLength,
        usualPeriodLength: s.usualPeriodLength,
        regularity: s.regularity,
        fertilityEnabled: s.fertilityEstimatesEnabled,
        manualNextStart: s.manualAnchor == latest ? s.manualNextStart : null,
        config: PredictionConfig(
          lutealDays: s.lutealDays,
          historyWindow: s.historyWindow,
        ),
      ),
    ),
  );
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

class GuideNotifier extends Notifier<Set<String>> {
  static const _key = 'guides.dismissed';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return prefs?.getStringList(_key)?.toSet() ?? const {};
  }

  void setDismissed(String id, bool dismissed) {
    state = dismissed ? {...state, id} : ({...state}..remove(id));
    ref
        .read(sharedPreferencesProvider)
        .value
        ?.setStringList(_key, state.toList());
  }

  void resetAll() {
    state = const {};
    ref.read(sharedPreferencesProvider).value?.remove(_key);
  }
}

final dismissedGuidesProvider = NotifierProvider<GuideNotifier, Set<String>>(
  GuideNotifier.new,
);

@immutable
class LockState {
  const LockState({
    this.enabled = false,
    this.locked = false,
    this.biometric = false,
  });
  final bool enabled;
  final bool locked;
  final bool biometric;
}

class AppLockController extends Notifier<LockState> {
  int _holds = 0;

  @override
  LockState build() => const LockState();

  AppLockService get _service => ref.read(appLockServiceProvider);

  Future<void> load() async {
    final enabled = await _service.isEnabled();
    state = LockState(
      enabled: enabled,
      locked: enabled,
      biometric: await _service.isBiometricEnabled(),
    );
  }

  void lockNow() {
    if (state.enabled && _holds == 0) {
      state = LockState(
        enabled: true,
        locked: true,
        biometric: state.biometric,
      );
    }
  }

  void unlock() =>
      state = LockState(enabled: state.enabled, biometric: state.biometric);

  Future<void> setPin(String pin) async {
    await _service.setPin(pin);
    state = LockState(enabled: true, biometric: state.biometric);
  }

  Future<void> disable() async {
    await _service.disable();
    state = const LockState();
  }

  Future<void> setBiometric(bool value) async {
    await _service.setBiometricEnabled(value);
    state = LockState(
      enabled: state.enabled,
      locked: state.locked,
      biometric: value,
    );
  }

  /// System sheets (file picker, biometric prompt) briefly background the
  /// app; this keeps those from locking it mid-task.
  Future<T> withoutLocking<T>(Future<T> Function() action) async {
    _holds++;
    try {
      return await action();
    } finally {
      // The resume event arrives just after the sheet closes.
      Timer(const Duration(milliseconds: 800), () => _holds--);
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, LockState>(
  AppLockController.new,
);

/// Keeps scheduled notifications in step with predictions and settings.
final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final sync = ReminderSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});

class ReminderSync {
  ReminderSync(this._ref) {
    void changed(Object? _, Object? _) => schedule();
    _ref.listen(predictionProvider, changed);
    _ref.listen(remindersProvider, changed);
    _ref.listen(medicationsProvider, changed);
    _ref.listen(settingsProvider, changed);
    schedule();
  }

  final Ref _ref;
  Timer? _debounce;

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _safeRun);
  }

  void dispose() => _debounce?.cancel();

  Future<void> _safeRun() async {
    try {
      await _run();
    } catch (error) {
      // Tracking must keep working if the OS refuses to schedule reminders.
      debugPrint('Reminder sync failed: ${error.runtimeType}');
    }
  }

  Future<void> _run() async {
    final prediction = _ref.read(predictionProvider);
    final reminders = _ref.read(remindersProvider);
    final medications = _ref.read(medicationsProvider);
    final settings = _ref.read(settingsProvider);
    if (!prediction.hasValue ||
        !reminders.hasValue ||
        !medications.hasValue ||
        !settings.hasValue) {
      return;
    }
    final s = settings.requireValue;
    final result = prediction.requireValue;
    await _recordPrediction(result);

    final plan = planNotifications(
      reminders: reminders.requireValue
          .map(
            (r) => ReminderSpec(
              type: r.type,
              enabled: r.enabled,
              minutes: r.minutes,
              leadDays: r.leadDays,
              label: r.label,
            ),
          )
          .toList(),
      medications: medications.requireValue
          .map(
            (m) => MedicationSpec(
              scheduleType: m.scheduleType,
              minutes: m.minutes,
              anchor: m.anchorDate,
              name: m.name,
              enabled: m.enabled,
              weekdays: (m.weekdays ?? '')
                  .split(',')
                  .where((d) => d.isNotEmpty)
                  .map(int.parse)
                  .toList(),
              intervalDays: m.intervalDays,
            ),
          )
          .toList(),
      prediction: result,
      fertilityEnabled: s.fertilityEstimatesEnabled,
      discreet: s.discreetNotifications,
      quiet: s.quietHoursEnabled
          ? QuietHours(s.quietStartMinutes, s.quietEndMinutes)
          : null,
      now: DateTime.now(),
    );
    await _ref.read(notificationGatewayProvider).replaceAll(plan);
  }

  /// Stores calculation metadata, separately from any observation.
  Future<void> _recordPrediction(CyclePredictionResult r) async {
    final db = _ref.read(databaseProvider);
    final last =
        await (db.select(db.cyclePredictions)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (last?.predictedStartDate == r.predictedStart &&
        last?.confidenceCategory == r.confidence.name &&
        last?.historyCount == r.historyCount) {
      return;
    }
    await db.transaction(() async {
      await db
          .into(db.cyclePredictions)
          .insert(
            CyclePredictionsCompanion.insert(
              calculatedAt: DateTime.now(),
              algorithmVersion: r.algorithmVersion,
              predictedStartDate: Value(r.predictedStart),
              earliestEstimatedDate: Value(r.earliestStart),
              latestEstimatedDate: Value(r.latestStart),
              confidenceCategory: r.confidence.name,
              historyCount: r.historyCount,
            ),
          );
      await db.customStatement(
        'DELETE FROM cycle_predictions WHERE id NOT IN '
        '(SELECT id FROM cycle_predictions ORDER BY id DESC LIMIT 30)',
      );
    });
  }
}
