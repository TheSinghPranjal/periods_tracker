import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_settings.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
  Future<void> patch(Map<String, Object?> changes);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);
  final AppDatabase _db;

  AppSettings _decode(UserPreferencesRow? row) {
    if (row == null) return const AppSettings();
    return AppSettings.fromJson(
      jsonDecode(row.settingsJson) as Map<String, Object?>,
    );
  }

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.userPreferences).watchSingleOrNull().map(_decode);

  @override
  Future<AppSettings> get() async =>
      _decode(await _db.select(_db.userPreferences).getSingleOrNull());

  @override
  Future<void> save(AppSettings settings) async {
    final now = DateTime.now();
    await _db
        .into(_db.userPreferences)
        .insert(
          UserPreferencesCompanion.insert(
            id: const Value(1),
            onboardingCompleted: Value(settings.onboardingCompleted),
            settingsJson: jsonEncode(settings.toJson()),
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (old) => UserPreferencesCompanion(
              onboardingCompleted: Value(settings.onboardingCompleted),
              settingsJson: Value(jsonEncode(settings.toJson())),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  @override
  Future<void> patch(Map<String, Object?> changes) => _db.transaction(() async {
    await save((await get()).patch(changes));
  });
}
