import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart' show ComparableExpr;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/encryption/backup_cipher.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';
import '../domain/data_snapshot.dart';
import 'lock_screen.dart';

const _guide = GuideContent(
  id: 'privacy',
  title: 'Protecting your information',
  steps: [
    'Turn on App lock to require a PIN when the app opens.',
    'Before changing phones, create an encrypted backup and keep the password safe.',
    'Plain exports are not encrypted, so store them carefully.',
  ],
);

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _busy = false;

  Future<T> _guarded<T>(Future<T> Function() f) =>
      ref.read(appLockProvider.notifier).withoutLocking(f);

  Future<void> _saveBytes(String name, Uint8List bytes) async {
    final path = await _guarded(
      () => FilePicker.saveFile(fileName: name, bytes: bytes),
    );
    if (mounted && path != null) showMessage(context, 'File saved.');
  }

  Future<void> _run(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
    } on AppFailure catch (f) {
      if (mounted) _showError(f.message);
    } catch (_) {
      if (mounted) {
        _showError(
          'That didn\'t work. Your saved information has not been changed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Something went wrong'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  String get _stamp => ref.read(todayProvider).toIso();

  Future<void> _exportPlain(bool csv) async {
    final ok = await confirmAction(
      context,
      title: 'Export without encryption?',
      message:
          'This file will not be encrypted. Anyone who opens it can read your health information, '
          'including if it is synced to cloud storage or shared.',
      confirmLabel: 'I understand, export',
    );
    if (!ok) return;
    await _run(() async {
      final service = ref.read(dataTransferProvider);
      final data = csv ? await service.exportCsv() : await service.exportJson();
      await _saveBytes(
        'lunacycle-$_stamp.${csv ? 'csv' : 'json'}',
        utf8.encode(data),
      );
    });
  }

  Future<String?> _askPassword({required bool confirm}) => showDialog<String>(
    context: context,
    builder: (_) => _PasswordDialog(confirm: confirm),
  );

  Future<void> _exportEncrypted() async {
    final password = await _askPassword(confirm: true);
    if (password == null) return;
    await _run(() async {
      final json = await ref.read(dataTransferProvider).exportJson();
      final sealed = await Isolate.run(
        () => const BackupCipher().encrypt(json, password),
      );
      await _saveBytes('lunacycle-$_stamp.lunabackup', sealed);
    });
  }

  Future<void> _import() async {
    final picked = await _guarded(() => FilePicker.pickFiles());
    if (picked.isEmpty) return;
    final bytes = await picked.single.readAsBytes();
    await FilePicker.clearTemporaryFiles();
    await _run(() async {
      var content = '';
      if (BackupCipher.looksEncrypted(bytes)) {
        final password = await _askPassword(confirm: false);
        if (password == null) return;
        content = await Isolate.run(
          () => const BackupCipher().decrypt(bytes, password),
        );
      } else {
        try {
          content = utf8.decode(bytes);
        } on FormatException {
          throw const AppFailure(
            FailureKind.invalidImport,
            'This file cannot be imported: it is not a LunaCycle export.',
          );
        }
      }
      final snapshot = DataSnapshot.parse(content);
      if (!mounted) return;
      final mode = await showDialog<ImportMode>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import this file?'),
          content: Text(
            'It contains ${snapshot.periodCount} periods and ${snapshot.dayCount} logged days.\n\n'
            'Add to my data: keeps everything you have and adds only what doesn\'t clash.\n\n'
            'Replace my data: erases what is on this phone first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImportMode.replace),
              child: const Text('Replace my data'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImportMode.merge),
              child: const Text('Add to my data'),
            ),
          ],
        ),
      );
      if (mode == null || !mounted) return;
      if (mode == ImportMode.replace) {
        final sure = await confirmAction(
          context,
          title: 'Replace everything?',
          message:
              'All data currently on this phone will be erased and replaced by this file.',
          confirmLabel: 'Replace',
          destructive: true,
        );
        if (!sure) return;
      }
      final report = await ref.read(dataTransferProvider).apply(snapshot, mode);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import finished'),
          content: Text(
            'Added ${report.periodsAdded} periods and ${report.daysAdded} days.'
            '${report.periodsSkipped + report.daysSkipped > 0 ? '\n\nKept your existing entries instead of ${report.periodsSkipped} periods and ${report.daysSkipped} days from the file, because they clashed.' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _clearHistory() async {
    final ok = await confirmAction(
      context,
      title: 'Clear cycle history?',
      message:
          'All recorded periods will be permanently deleted. Daily logs and settings are kept. This cannot be undone.',
      confirmLabel: 'Clear history',
      destructive: true,
    );
    if (ok) {
      await ref.read(periodRepositoryProvider).clearAll();
      if (mounted) showMessage(context, 'Cycle history cleared.');
    }
  }

  Future<void> _deleteOld() async {
    final years = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Delete entries older than'),
        children: [
          for (final y in const [1, 2, 5])
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              onPressed: () => Navigator.pop(context, y),
              child: Text('$y ${y == 1 ? 'year' : 'years'}'),
            ),
        ],
      ),
    );
    if (years == null || !mounted) return;
    final today = ref.read(todayProvider);
    final cutoff = CalendarDate(today.year - years, today.month, today.day);
    final ok = await confirmAction(
      context,
      title: 'Delete older entries?',
      message:
          'Periods and daily logs before ${ref.read(lunaDatesProvider).medium(cutoff)} will be permanently deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      await (db.delete(db.periodRecords)..where(
            (t) => t.startDate.dartCast<String>().isSmallerThanValue(
              cutoff.toIso(),
            ),
          ))
          .go();
      await (db.delete(db.dailyLogs)..where(
            (t) => t.localDate.dartCast<String>().isSmallerThanValue(
              cutoff.toIso(),
            ),
          ))
          .go();
      await (db.delete(db.temperatureRecords)..where(
            (t) => t.localDate.dartCast<String>().isSmallerThanValue(
              cutoff.toIso(),
            ),
          ))
          .go();
    });
    if (mounted) showMessage(context, 'Older entries deleted.');
  }

  Future<void> _deleteAll() async {
    final ok = await confirmAction(
      context,
      title: 'Delete all data?',
      message:
          'Every period, log, reminder and setting on this phone will be permanently erased, and app lock will be removed. '
          'Files you exported are not affected. This cannot be undone.',
      confirmLabel: 'Delete everything',
      destructive: true,
    );
    if (!ok) return;
    final db = ref.read(databaseProvider);
    await ref.read(notificationGatewayProvider).cancelAll();
    await db.wipeEverything();
    await db.customStatement('VACUUM');
    await ref.read(appLockProvider.notifier).disable();
    ref.read(dismissedGuidesProvider.notifier).resetAll();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    final s = ref.watch(currentSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final t = LunaTokens.of(context);
    return LunaPage(
      title: 'Privacy and security',
      showBack: true,
      guide: _guide,
      children: [
        if (_busy) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
        ],
        const SectionTitle('App lock'),
        SketchCard(
          seed: 4,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SwitchTile(
                title: 'Require a PIN',
                subtitle:
                    'If you forget it, you\'ll need to reinstall the app, which erases your data',
                value: lock.enabled,
                onChanged: (v) async {
                  if (v) {
                    await showPinSetup(context, ref);
                  } else {
                    final ok = await confirmAction(
                      context,
                      title: 'Turn off app lock?',
                      message:
                          'Anyone with your phone could then open LunaCycle.',
                      confirmLabel: 'Turn off',
                    );
                    if (ok) await ref.read(appLockProvider.notifier).disable();
                  }
                },
              ),
              if (lock.enabled) ...[
                SettingsTile(
                  title: 'Change PIN',
                  onTap: () => showPinSetup(context, ref),
                ),
                FutureBuilder<bool>(
                  future: ref.read(biometricsProvider).isAvailable(),
                  builder: (context, snap) => SwitchTile(
                    title: 'Unlock with biometrics',
                    subtitle: snap.data == false
                        ? 'Not available on this device'
                        : null,
                    value: lock.biometric,
                    onChanged: snap.data == true
                        ? (v) async {
                            final notifier = ref.read(appLockProvider.notifier);
                            if (v) {
                              final ok = await notifier.withoutLocking(
                                () => ref
                                    .read(biometricsProvider)
                                    .authenticate('Confirm it\'s you'),
                              );
                              if (!ok) return;
                            }
                            await notifier.setBiometric(v);
                          }
                        : null,
                  ),
                ),
                SwitchTile(
                  title: 'Lock when leaving the app',
                  value: s.lockOnBackground,
                  onChanged: (v) => repo.patch({'lockOnBackground': v}),
                ),
                SettingsTile(
                  title: 'Lock after inactivity',
                  trailing: DropdownButton<int>(
                    value: s.inactivityLockMinutes,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Never')),
                      DropdownMenuItem(value: 1, child: Text('1 minute')),
                      DropdownMenuItem(value: 5, child: Text('5 minutes')),
                      DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    ],
                    onChanged: (v) => repo.patch({'inactivityLockMinutes': v}),
                  ),
                ),
              ],
              SwitchTile(
                title: 'Hide app preview',
                subtitle:
                    'Covers the app in the app switcher and blocks screenshots on Android',
                value: s.hideAppPreview,
                onChanged: (v) => repo.patch({'hideAppPreview': v}),
              ),
            ],
          ),
        ),
        const SectionTitle('Backup and export'),
        SketchCard(
          seed: 6,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.enhanced_encryption_outlined,
                title: 'Create encrypted backup',
                subtitle: 'Protected with a password you choose',
                onTap: _busy ? null : _exportEncrypted,
              ),
              SettingsTile(
                icon: Icons.upload_file_outlined,
                title: 'Import or restore',
                subtitle: 'From a LunaCycle backup or JSON export',
                onTap: _busy ? null : _import,
              ),
              SettingsTile(
                icon: Icons.data_object_rounded,
                title: 'Export as JSON',
                subtitle: 'Not encrypted',
                onTap: _busy ? null : () => _exportPlain(false),
              ),
              SettingsTile(
                icon: Icons.table_chart_outlined,
                title: 'Export as CSV',
                subtitle: 'Not encrypted. For reading only; cannot be imported',
                onTap: _busy ? null : () => _exportPlain(true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const PrivacyNotice(
          'If you lose your backup password, the backup cannot be opened by anyone, including us.',
          warning: true,
        ),
        const SectionTitle('Delete data'),
        SketchCard(
          seed: 10,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.auto_delete_outlined,
                title: 'Delete older entries',
                onTap: _deleteOld,
              ),
              SettingsTile(
                icon: Icons.event_busy_outlined,
                title: 'Clear cycle history',
                onTap: _clearHistory,
              ),
              SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete all data',
                trailing: Icon(Icons.chevron_right_rounded, color: t.error),
                onTap: _deleteAll,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const PrivacyNotice(
          'To remove a single day or period, open it from the Calendar or Cycle history. There is no cloud copy: deleting here removes the data from this phone. Exported files must be deleted separately.',
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.confirm});
  final bool confirm;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.confirm && _a.text.length < 10) {
      setState(() => _error = 'Use at least 10 characters.');
      return;
    }
    if (widget.confirm && _a.text != _b.text) {
      setState(() => _error = 'The passwords don\'t match.');
      return;
    }
    if (_a.text.isEmpty) return;
    Navigator.pop(context, _a.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.confirm ? 'Choose a backup password' : 'Enter backup password',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _a,
            obscureText: true,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _b,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Repeat password'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: LunaTokens.of(context).error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}
