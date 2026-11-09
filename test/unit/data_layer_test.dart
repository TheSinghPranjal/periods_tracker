import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/core/database/app_database.dart';
import 'package:periods_tracker/core/database/encrypted_connection.dart';
import 'package:periods_tracker/core/encryption/backup_cipher.dart';
import 'package:periods_tracker/core/encryption/secure_store.dart';
import 'package:periods_tracker/core/errors/app_failure.dart';
import 'package:periods_tracker/core/security/app_lock_service.dart';
import 'package:periods_tracker/core/utils/calendar_date.dart';
import 'package:periods_tracker/core/utils/health_enums.dart';
import 'package:periods_tracker/features/period_logging/data/period_repository.dart';
import 'package:periods_tracker/features/period_logging/domain/period_rules.dart';
import 'package:periods_tracker/features/privacy/data/data_transfer_service.dart';
import 'package:periods_tracker/features/privacy/domain/data_snapshot.dart';
import 'package:periods_tracker/features/settings/data/settings_repository.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';
import 'package:periods_tracker/features/symptoms/data/drift_daily_log_repository.dart';

const fastKdf = BackupCipher(params: KdfParams(memoryKiB: 64, iterations: 1));
const key = 'aa11bb22cc33dd44aa11bb22cc33dd44aa11bb22cc33dd44aa11bb22cc33dd44';

void main() {
  late AppDatabase db;
  late DriftPeriodRepository periods;
  late DriftDailyLogRepository days;
  final today = CalendarDate(2025, 6, 20);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    periods = DriftPeriodRepository(db);
    days = DriftDailyLogRepository(db);
  });
  tearDown(() => db.close());

  group('periods', () {
    test('saves, reloads, updates and deletes', () async {
      final saved = await periods.add(
        start: CalendarDate(2025, 5, 1),
        end: CalendarDate(2025, 5, 5),
        today: today,
      );
      expect(
        (await periods.getAll()).single.startDate,
        CalendarDate(2025, 5, 1),
      );
      await periods.updateDates(
        id: saved.id,
        start: CalendarDate(2025, 5, 2),
        end: CalendarDate(2025, 5, 6),
        today: today,
      );
      expect((await periods.getAll()).single.endDate, CalendarDate(2025, 5, 6));
      final removed = await periods.delete(saved.id);
      expect(await periods.getAll(), isEmpty);
      await periods.restore(removed!);
      expect((await periods.getAll()).single.id, saved.id);
    });

    test('refuses overlaps instead of overwriting', () async {
      await periods.add(
        start: CalendarDate(2025, 5, 1),
        end: CalendarDate(2025, 5, 5),
        today: today,
      );
      await expectLater(
        periods.add(
          start: CalendarDate(2025, 5, 3),
          end: CalendarDate(2025, 5, 7),
          today: today,
        ),
        throwsA(
          isA<PeriodConflict>().having(
            (c) => c.issues.single,
            'issue',
            isA<OverlapsPeriod>(),
          ),
        ),
      );
      expect((await periods.getAll()).length, 1);
    });

    test('database rejects an end before the start', () async {
      final now = DateTime.now();
      await expectLater(
        db
            .into(db.periodRecords)
            .insert(
              PeriodRecordsCompanion.insert(
                id: 'bad',
                startDate: CalendarDate(2025, 5, 5),
                endDate: Value(CalendarDate(2025, 5, 1)),
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
    });
  });

  group('daily logs', () {
    final date = CalendarDate(2025, 6, 10);

    test('stores flow, moods and symptoms for one day', () async {
      await days.patch(
        date,
        const DailyLogsCompanion(
          flowLevel: Value('heavy'),
          painLevel: Value(2),
        ),
      );
      await days.setMoods(date, {MoodKind.calm, MoodKind.tired});
      await days.setSymptom(date, 'cramps', 3);
      final e = (await days.getRange(from: date, to: date)).single;
      expect(e.flow, FlowLevel.heavy);
      expect(e.moods, {MoodKind.calm, MoodKind.tired});
      expect(e.symptoms, {'cramps': 3});
    });

    test('clearing the last value removes the row', () async {
      await days.setSymptom(date, 'cramps', 1);
      await days.setSymptom(date, 'cramps', null);
      expect(await days.getRange(from: date, to: date), isEmpty);
    });

    test('delete can be undone in full', () async {
      await days.patch(date, const DailyLogsCompanion(notes: Value('note')));
      await days.setMoods(date, {MoodKind.happy});
      await days.setSymptom(date, 'nausea', 2);
      final removed = await days.deleteDay(date);
      expect(await days.getRange(from: date, to: date), isEmpty);
      await days.restoreDay(removed);
      final e = (await days.getRange(from: date, to: date)).single;
      expect(e.notes, 'note');
      expect(e.moods, {MoodKind.happy});
      expect(e.symptoms, {'nausea': 2});
    });

    test('watchDay reacts to edits', () async {
      final seen = <int>[];
      final sub = days
          .watchDay(date)
          .listen((e) => seen.add(e.symptoms.length));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await days.setSymptom(date, 'acne', 1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      expect(seen.last, 1);
    });
  });

  group('settings', () {
    test('survive a round trip and reject out-of-range values', () async {
      final repo = DriftSettingsRepository(db);
      expect((await repo.get()).onboardingCompleted, isFalse);
      await repo.patch({'usualCycleLength': 31, 'onboardingCompleted': true});
      final s = await repo.get();
      expect(s.usualCycleLength, 31);
      expect(s.onboardingCompleted, isTrue);
      expect(
        const AppSettings().patch({'usualCycleLength': 500}).usualCycleLength,
        isNull,
      );
    });

    test('cycle-sensitive defaults stay private and discreet', () {
      const s = AppSettings();
      expect(s.discreetNotifications, isTrue);
      expect(s.fertilityEstimatesEnabled, isFalse);
      expect(s.trackSexualActivity, isFalse);
    });
  });

  group('export and import', () {
    late DataTransferService transfer;
    setUp(() => transfer = DataTransferService(db));

    Future<void> seed() async {
      await periods.add(
        start: CalendarDate(2025, 5, 1),
        end: CalendarDate(2025, 5, 5),
        today: today,
      );
      await days.patch(
        CalendarDate(2025, 5, 2),
        const DailyLogsCompanion(
          flowLevel: Value('medium'),
          notes: Value('hello'),
        ),
      );
      await days.setSymptom(CalendarDate(2025, 5, 2), 'cramps', 2);
      await days.setMoods(CalendarDate(2025, 5, 2), {MoodKind.sad});
    }

    test('json export restores identically after replace', () async {
      await seed();
      final text = await transfer.exportJson();
      await db.wipeEverything();
      final report = await transfer.apply(
        DataSnapshot.parse(text),
        ImportMode.replace,
      );
      expect(report.periodsAdded, 1);
      final e = (await days.getRange(
        from: CalendarDate(2025, 5, 2),
        to: CalendarDate(2025, 5, 2),
      )).single;
      expect(e.notes, 'hello');
      expect(e.symptoms['cramps'], 2);
      expect(e.moods, {MoodKind.sad});
    });

    test('merge keeps existing entries and reports what it skipped', () async {
      await seed();
      final text = await transfer.exportJson();
      final report = await transfer.apply(
        DataSnapshot.parse(text),
        ImportMode.merge,
      );
      expect(report.periodsSkipped, 1);
      expect(report.daysSkipped, 1);
      expect((await periods.getAll()).length, 1);
    });

    test('csv neutralises spreadsheet formulas', () async {
      await days.patch(
        CalendarDate(2025, 5, 3),
        const DailyLogsCompanion(notes: Value('=HYPERLINK("x")')),
      );
      final csv = await transfer.exportCsv();
      expect(csv, contains('\'=HYPERLINK'));
      expect(csvCell('a,b'), '"a,b"');
    });

    Map<String, Object?> base() => {'app': 'lunacycle', 'schema': 1};

    test('rejects garbage, other apps and newer versions', () {
      Matcher fails = throwsA(
        isA<AppFailure>().having(
          (f) => f.kind,
          'kind',
          FailureKind.invalidImport,
        ),
      );
      expect(() => DataSnapshot.parse('not json'), fails);
      expect(() => DataSnapshot.parse('{"app":"other","schema":1}'), fails);
      expect(
        () => DataSnapshot.parse('{"app":"lunacycle","schema":99}'),
        fails,
      );
    });

    test('rejects invalid dates, overlaps and bad values', () {
      Matcher fails = throwsA(isA<AppFailure>());
      String json(Map<String, Object?> extra) =>
          jsonEncode({...base(), ...extra});
      expect(
        () => DataSnapshot.parse(
          json({
            'periods': [
              {'id': 'a', 'startDate': '2025-02-30'},
            ],
          }),
        ),
        fails,
      );
      expect(
        () => DataSnapshot.parse(
          json({
            'periods': [
              {'id': 'a', 'startDate': '2025-05-01', 'endDate': '2025-05-05'},
              {'id': 'b', 'startDate': '2025-05-04', 'endDate': '2025-05-08'},
            ],
          }),
        ),
        fails,
      );
      expect(
        () => DataSnapshot.parse(
          json({
            'dailyLogs': [
              {'id': 'a', 'localDate': '2025-05-01', 'painLevel': 9},
            ],
          }),
        ),
        fails,
      );
    });
  });

  test(
    'backup works through the background helpers at real strength',
    () async {
      final sealed = await sealBackupInBackground('{"a":1}', 'a long password');
      expect(
        await openBackupInBackground(sealed, 'a long password'),
        '{"a":1}',
      );
    },
  );

  group('encrypted backup', () {
    test('round-trips and hides the content', () async {
      final sealed = await fastKdf.encrypt(
        '{"notes":"very private"}',
        'correct horse',
      );
      expect(utf8.decode(sealed), isNot(contains('very private')));
      expect(BackupCipher.looksEncrypted(sealed), isTrue);
      expect(
        await fastKdf.decrypt(sealed, 'correct horse'),
        '{"notes":"very private"}',
      );
    });

    test('wrong password is reported as such', () async {
      final sealed = await fastKdf.encrypt('data', 'right');
      await expectLater(
        fastKdf.decrypt(sealed, 'wrong'),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.kind,
            'kind',
            FailureKind.wrongBackupPassword,
          ),
        ),
      );
    });

    test('a tampered file fails authentication', () async {
      final sealed = await fastKdf.encrypt('some data here', 'pw');
      final envelope = jsonDecode(utf8.decode(sealed)) as Map<String, dynamic>;
      final data = base64Decode(envelope['data'] as String);
      data[0] ^= 1;
      envelope['data'] = base64Encode(data);
      await expectLater(
        fastKdf.decrypt(utf8.encode(jsonEncode(envelope)), 'pw'),
        throwsA(isA<AppFailure>()),
      );
    });

    test('corrupt file is reported as corrupt', () async {
      await expectLater(
        fastKdf.decrypt(utf8.encode('rubbish'), 'pw'),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.kind,
            'kind',
            FailureKind.corruptBackup,
          ),
        ),
      );
    });
  });

  group('database encryption', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('luna'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('file on disk is unreadable and needs the right key', () async {
      final file = File('${dir.path}/test.db');
      final secure = AppDatabase(
        NativeDatabase(file, setup: (d) => applyEncryptionKey(d, key)),
      );
      await DriftDailyLogRepository(secure).patch(
        CalendarDate(2025, 1, 1),
        const DailyLogsCompanion(notes: Value('PLAINTEXT_MARKER')),
      );
      await secure.close();

      final bytes = file.readAsBytesSync();
      expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));
      expect(latin1.decode(bytes).contains('PLAINTEXT_MARKER'), isFalse);

      final wrongKey = key.replaceFirst('aa', 'bb');
      final wrong = AppDatabase(
        NativeDatabase(file, setup: (d) => applyEncryptionKey(d, wrongKey)),
      );
      await expectLater(wrong.select(wrong.dailyLogs).get(), throwsA(anything));
      await wrong.close();

      final again = AppDatabase(
        NativeDatabase(file, setup: (d) => applyEncryptionKey(d, key)),
      );
      expect(
        (await again.select(again.dailyLogs).getSingle()).notes,
        'PLAINTEXT_MARKER',
      );
      await again.close();
    });
  });

  group('sensitive data stays out of logs', () {
    test('failures never print their message', () {
      const failure = AppFailure(FailureKind.storage, 'private detail');
      expect(failure.toString(), isNot(contains('private detail')));
    });

    test('source only logs error types, never entries', () {
      final risky = RegExp(
        r'(print|debugPrint|log)\(.*(notes|symptom|mood|period|entry|settings)',
        caseSensitive: false,
      );
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
          .expand((f) => f.readAsLinesSync().where(risky.hasMatch))
          .toList();
      expect(offenders, isEmpty);
    });
  });

  group('app lock', () {
    late MemorySecureStore store;
    late DateTime now;
    late AppLockService lock;
    setUp(() {
      store = MemorySecureStore();
      now = DateTime(2025, 1, 1);
      lock = AppLockService(store, clock: () => now);
    });

    test('never stores the PIN itself', () async {
      await lock.setPin('4821');
      expect(store.values.values.join(), isNot(contains('4821')));
    });

    test('accepts the right PIN and rejects the wrong one', () async {
      await lock.setPin('4821');
      expect(await lock.verify('4821'), isA<PinAccepted>());
      expect(await lock.verify('0000'), isA<PinRejected>());
    });

    test('repeated failures impose a lockout that expires', () async {
      await lock.setPin('4821');
      PinResult result = const PinAccepted();
      for (var i = 0; i < 5; i++) {
        result = await lock.verify('0000');
      }
      expect((result as PinRejected).lockedFor, const Duration(seconds: 30));
      expect(await lock.verify('4821'), isA<PinRejected>());
      now = now.add(const Duration(seconds: 31));
      expect(await lock.verify('4821'), isA<PinAccepted>());
    });

    test('disable clears every stored secret', () async {
      await lock.setPin('4821');
      await lock.setBiometricEnabled(true);
      await lock.disable();
      expect(store.values, isEmpty);
      expect(await lock.isEnabled(), isFalse);
    });
  });
}
