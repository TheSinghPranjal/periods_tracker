import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/calendar_date.dart';
import '../domain/period_rules.dart';

class PeriodConflict implements Exception {
  const PeriodConflict(this.issues);
  final List<PeriodIssue> issues;
}

abstract interface class PeriodRepository {
  Stream<List<PeriodRecord>> watchAll();
  Future<List<PeriodRecord>> getAll();

  /// Throws [PeriodConflict] rather than overwriting an existing record.
  Future<PeriodRecord> add({
    required CalendarDate start,
    CalendarDate? end,
    String source = 'manual',
    required CalendarDate today,
  });
  Future<void> updateDates({
    required String id,
    required CalendarDate start,
    required CalendarDate? end,
    required CalendarDate today,
  });
  Future<PeriodRecord?> delete(String id);
  Future<void> restore(PeriodRecord record);
  Future<void> clearAll();
}

PeriodSpan spanOf(PeriodRecord r) =>
    PeriodSpan(id: r.id, start: r.startDate, end: r.endDate);

class DriftPeriodRepository implements PeriodRepository {
  DriftPeriodRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  SimpleSelectStatement<$PeriodRecordsTable, PeriodRecord> get _ordered =>
      _db.select(_db.periodRecords)
        ..orderBy([(t) => OrderingTerm.asc(t.startDate)]);

  @override
  Stream<List<PeriodRecord>> watchAll() => _ordered.watch();

  @override
  Future<List<PeriodRecord>> getAll() => _ordered.get();

  void _validate(
    List<PeriodRecord> existing,
    CalendarDate start,
    CalendarDate? end,
    CalendarDate today, {
    String? ignoreId,
  }) {
    final issues = validatePeriodRange(
      start: start,
      end: end,
      others: existing.map(spanOf).toList(),
      today: today,
      ignoreId: ignoreId,
    );
    if (issues.isNotEmpty) throw PeriodConflict(issues);
  }

  @override
  Future<PeriodRecord> add({
    required CalendarDate start,
    CalendarDate? end,
    String source = 'manual',
    required CalendarDate today,
  }) => _db.transaction(() async {
    _validate(await getAll(), start, end, today);
    final now = DateTime.now();
    return _db
        .into(_db.periodRecords)
        .insertReturning(
          PeriodRecordsCompanion.insert(
            id: _uuid.v4(),
            startDate: start,
            endDate: Value(end),
            source: Value(source),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  @override
  Future<void> updateDates({
    required String id,
    required CalendarDate start,
    required CalendarDate? end,
    required CalendarDate today,
  }) => _db.transaction(() async {
    _validate(await getAll(), start, end, today, ignoreId: id);
    await (_db.update(_db.periodRecords)..where((t) => t.id.equals(id))).write(
      PeriodRecordsCompanion(
        startDate: Value(start),
        endDate: Value(end),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  @override
  Future<PeriodRecord?> delete(String id) => _db.transaction(() async {
    final found = await (_db.select(
      _db.periodRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.periodRecords)..where((t) => t.id.equals(id))).go();
    return found;
  });

  @override
  Future<void> restore(PeriodRecord record) =>
      _db.into(_db.periodRecords).insertOnConflictUpdate(record);

  @override
  Future<void> clearAll() => _db.delete(_db.periodRecords).go();
}
