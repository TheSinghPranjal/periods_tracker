enum FailureKind {
  encryptionUnavailable,
  encryptionKeyLost,
  databaseUnreadable,
  storage,
  invalidImport,
  wrongBackupPassword,
  corruptBackup,
  unsupportedBackupVersion,
}

/// A failure with a message safe to show to the person. It must never include
/// health data, because failures can reach logs.
class AppFailure implements Exception {
  const AppFailure(this.kind, this.message);
  final FailureKind kind;
  final String message;

  @override
  String toString() => 'AppFailure(${kind.name})';
}
