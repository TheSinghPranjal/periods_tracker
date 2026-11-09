import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../errors/app_failure.dart';

const kDatabaseFileName = 'lunacycle.db';

/// Opens the database through SQLite3MultipleCiphers. Its default cipher,
/// ChaCha20-Poly1305, authenticates every page.
QueryExecutor openEncryptedExecutor(File file, String hexKey) {
  return NativeDatabase.createInBackground(
    file,
    setup: (Database db) => applyEncryptionKey(db, hexKey),
  );
}

void applyEncryptionKey(Database db, String hexKey) {
  final cipher = db.select('PRAGMA cipher');
  if (cipher.isEmpty) {
    throw const AppFailure(
      FailureKind.encryptionUnavailable,
      'This build has no database encryption.',
    );
  }
  // The key is 64 hex characters, so it cannot break out of the quotes.
  db.execute("PRAGMA key = '$hexKey'");
  // Reading the schema is what actually verifies the key.
  db.select('SELECT count(*) FROM sqlite_master');
}

Future<File> databaseFile() async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return File(p.join(dir.path, kDatabaseFileName));
}
