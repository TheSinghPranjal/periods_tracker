import 'package:flutter/foundation.dart';

import '../../../core/utils/calendar_date.dart';
import '../../prediction/domain/cycle_prediction_engine.dart';

enum TrackingGoal {
  understandCycle,
  symptomsAndMoods,
  planPregnancy,
  justPeriod,
}

enum AppThemeMode { system, light, dark }

enum AppPalette {
  blossom('Sakura blossom', premium: false),
  lavender('Wisteria lavender', premium: false),
  sage('Matcha sage', premium: false),
  momiji('Autumn momiji', premium: true),
  plum('Plum dusk', premium: true);

  const AppPalette(this.label, {required this.premium});
  final String label;
  final bool premium;
}

enum DateFormatStyle { dayFirst, monthFirst, yearFirst }

enum TemperatureUnit { celsius, fahrenheit }

enum WeightUnit { kilograms, pounds }

T _enumOr<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

int? _rangeOrNull(Object? value, int min, int max) {
  if (value is! int || value < min || value > max) return null;
  return value;
}

/// All preferences are kept in the encrypted database, as a typed value.
@immutable
class AppSettings {
  const AppSettings({
    this.onboardingCompleted = false,
    this.nickname,
    this.goals = const {},
    this.usualCycleLength,
    this.usualPeriodLength,
    this.regularity = Regularity.notSure,
    this.themeMode = AppThemeMode.system,
    this.palette = AppPalette.blossom,
    this.locale = 'en',
    this.fertilityEstimatesEnabled = false,
    this.ovulationMarkerEnabled = true,
    this.showSymptomMarkers = true,
    this.showPredictedPeriods = true,
    this.lutealDays = 14,
    this.historyWindow = 6,
    this.manualNextStart,
    this.manualAnchor,
    this.trackTemperature = false,
    this.trackMucus = false,
    this.trackWeight = false,
    this.trackSleep = false,
    this.trackSexualActivity = false,
    this.trackOvulationTests = false,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.weightUnit = WeightUnit.kilograms,
    this.dateFormat = DateFormatStyle.dayFirst,
    this.firstDayOfWeek = DateTime.monday,
    this.reduceMotion = false,
    this.discreetNotifications = true,
    this.quietHoursEnabled = false,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
    this.privacyMode = false,
    this.lockOnBackground = true,
    this.inactivityLockMinutes = 5,
    this.hideAppPreview = true,
  });

  factory AppSettings.fromJson(Map<String, Object?> j) {
    final goals = j['goals'];
    return AppSettings(
      onboardingCompleted: j['onboardingCompleted'] == true,
      nickname: j['nickname'] as String?,
      goals: goals is List
          ? TrackingGoal.values.where((g) => goals.contains(g.name)).toSet()
          : const {},
      usualCycleLength: _rangeOrNull(j['usualCycleLength'], 15, 60),
      usualPeriodLength: _rangeOrNull(j['usualPeriodLength'], 1, 10),
      regularity: _enumOr(
        Regularity.values,
        j['regularity'],
        Regularity.notSure,
      ),
      themeMode: _enumOr(
        AppThemeMode.values,
        j['themeMode'],
        AppThemeMode.system,
      ),
      palette: _enumOr(AppPalette.values, j['palette'], AppPalette.blossom),
      locale: j['locale'] as String? ?? 'en',
      fertilityEstimatesEnabled: j['fertilityEstimatesEnabled'] == true,
      ovulationMarkerEnabled: j['ovulationMarkerEnabled'] != false,
      showSymptomMarkers: j['showSymptomMarkers'] != false,
      showPredictedPeriods: j['showPredictedPeriods'] != false,
      lutealDays: _rangeOrNull(j['lutealDays'], 9, 18) ?? 14,
      historyWindow: _rangeOrNull(j['historyWindow'], 3, 12) ?? 6,
      manualNextStart: CalendarDate.tryParse(
        j['manualNextStart'] as String? ?? '',
      ),
      manualAnchor: CalendarDate.tryParse(j['manualAnchor'] as String? ?? ''),
      trackTemperature: j['trackTemperature'] == true,
      trackMucus: j['trackMucus'] == true,
      trackWeight: j['trackWeight'] == true,
      trackSleep: j['trackSleep'] == true,
      trackSexualActivity: j['trackSexualActivity'] == true,
      trackOvulationTests: j['trackOvulationTests'] == true,
      temperatureUnit: _enumOr(
        TemperatureUnit.values,
        j['temperatureUnit'],
        TemperatureUnit.celsius,
      ),
      weightUnit: _enumOr(
        WeightUnit.values,
        j['weightUnit'],
        WeightUnit.kilograms,
      ),
      dateFormat: _enumOr(
        DateFormatStyle.values,
        j['dateFormat'],
        DateFormatStyle.dayFirst,
      ),
      firstDayOfWeek:
          _rangeOrNull(j['firstDayOfWeek'], 1, 7) ?? DateTime.monday,
      reduceMotion: j['reduceMotion'] == true,
      discreetNotifications: j['discreetNotifications'] != false,
      quietHoursEnabled: j['quietHoursEnabled'] == true,
      quietStartMinutes:
          _rangeOrNull(j['quietStartMinutes'], 0, 1439) ?? 22 * 60,
      quietEndMinutes: _rangeOrNull(j['quietEndMinutes'], 0, 1439) ?? 7 * 60,
      privacyMode: j['privacyMode'] == true,
      lockOnBackground: j['lockOnBackground'] != false,
      inactivityLockMinutes:
          _rangeOrNull(j['inactivityLockMinutes'], 0, 60) ?? 5,
      hideAppPreview: j['hideAppPreview'] != false,
    );
  }

  final bool onboardingCompleted;
  final String? nickname;
  final Set<TrackingGoal> goals;
  final int? usualCycleLength;
  final int? usualPeriodLength;
  final Regularity regularity;
  final AppThemeMode themeMode;
  final AppPalette palette;
  final String locale;
  final bool fertilityEstimatesEnabled;
  final bool ovulationMarkerEnabled;
  final bool showSymptomMarkers;
  final bool showPredictedPeriods;
  final int lutealDays;
  final int historyWindow;

  /// Manual next-period date; only valid while [manualAnchor] is the most
  /// recent period start, so a newly logged period clears it naturally.
  final CalendarDate? manualNextStart;
  final CalendarDate? manualAnchor;
  final bool trackTemperature;
  final bool trackMucus;
  final bool trackWeight;
  final bool trackSleep;
  final bool trackSexualActivity;
  final bool trackOvulationTests;
  final TemperatureUnit temperatureUnit;
  final WeightUnit weightUnit;
  final DateFormatStyle dateFormat;
  final int firstDayOfWeek;
  final bool reduceMotion;
  final bool discreetNotifications;
  final bool quietHoursEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;
  final bool privacyMode;
  final bool lockOnBackground;

  /// 0 disables the inactivity timer.
  final int inactivityLockMinutes;
  final bool hideAppPreview;

  Map<String, Object?> toJson() => {
    'onboardingCompleted': onboardingCompleted,
    'nickname': nickname,
    'goals': goals.map((g) => g.name).toList(),
    'usualCycleLength': usualCycleLength,
    'usualPeriodLength': usualPeriodLength,
    'regularity': regularity.name,
    'themeMode': themeMode.name,
    'palette': palette.name,
    'locale': locale,
    'fertilityEstimatesEnabled': fertilityEstimatesEnabled,
    'ovulationMarkerEnabled': ovulationMarkerEnabled,
    'showSymptomMarkers': showSymptomMarkers,
    'showPredictedPeriods': showPredictedPeriods,
    'lutealDays': lutealDays,
    'historyWindow': historyWindow,
    'manualNextStart': manualNextStart?.toIso(),
    'manualAnchor': manualAnchor?.toIso(),
    'trackTemperature': trackTemperature,
    'trackMucus': trackMucus,
    'trackWeight': trackWeight,
    'trackSleep': trackSleep,
    'trackSexualActivity': trackSexualActivity,
    'trackOvulationTests': trackOvulationTests,
    'temperatureUnit': temperatureUnit.name,
    'weightUnit': weightUnit.name,
    'dateFormat': dateFormat.name,
    'firstDayOfWeek': firstDayOfWeek,
    'reduceMotion': reduceMotion,
    'discreetNotifications': discreetNotifications,
    'quietHoursEnabled': quietHoursEnabled,
    'quietStartMinutes': quietStartMinutes,
    'quietEndMinutes': quietEndMinutes,
    'privacyMode': privacyMode,
    'lockOnBackground': lockOnBackground,
    'inactivityLockMinutes': inactivityLockMinutes,
    'hideAppPreview': hideAppPreview,
  };

  /// Value-style update through the JSON form, which keeps a single list of
  /// fields and lets nullable values be set back to null.
  AppSettings patch(Map<String, Object?> changes) =>
      AppSettings.fromJson({...toJson(), ...changes});

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      mapEquals(other.toJson().map(_comparable), toJson().map(_comparable));

  static MapEntry<String, Object?> _comparable(String k, Object? v) =>
      MapEntry(k, v is List ? v.join(',') : v);

  @override
  int get hashCode =>
      Object.hashAll(toJson().values.map((v) => v is List ? v.join(',') : v));
}
