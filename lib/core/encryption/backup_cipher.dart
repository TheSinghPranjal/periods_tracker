import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_failure.dart';

const kBackupMagic = 'lunacycle-encrypted-backup';
const kBackupFormatVersion = 1;

@immutable
class KdfParams {
  const KdfParams({
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });
  final int memoryKiB;
  final int iterations;
  final int parallelism;
}

/// Password-based backup: Argon2id for the key, AES-256-GCM for the content.
/// The header is authenticated too, so it cannot be altered undetected.
class BackupCipher {
  const BackupCipher({this.params = const KdfParams()});
  final KdfParams params;

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt, KdfParams p) {
    return Argon2id(
      memory: p.memoryKiB,
      iterations: p.iterations,
      parallelism: p.parallelism,
      hashLength: 32,
    ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  }

  Future<Uint8List> encrypt(String plaintext, String password) async {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final header = <String, Object?>{
      'magic': kBackupMagic,
      'version': kBackupFormatVersion,
      'kdf': {
        'name': 'argon2id',
        'memoryKiB': params.memoryKiB,
        'iterations': params.iterations,
        'parallelism': params.parallelism,
        'salt': base64Encode(salt),
      },
      'cipher': {'name': 'aes-256-gcm', 'nonce': base64Encode(nonce)},
    };
    final key = await _deriveKey(password, salt, params);
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
      aad: utf8.encode(jsonEncode(header)),
    );
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'header': header,
          'data': base64Encode(box.cipherText),
          'tag': base64Encode(box.mac.bytes),
        }),
      ),
    );
  }

  static bool looksEncrypted(Uint8List bytes) {
    final head = utf8.decode(bytes.take(200).toList(), allowMalformed: true);
    return head.contains(kBackupMagic);
  }

  Future<String> decrypt(Uint8List bytes, String password) async {
    final Map<String, dynamic> envelope;
    final Map<String, dynamic> header;
    final KdfParams kdf;
    final List<int> salt, nonce, data, tag;
    try {
      envelope = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      header = envelope['header'] as Map<String, dynamic>;
      if (header['magic'] != kBackupMagic) throw const FormatException();
      if (header['version'] != kBackupFormatVersion) {
        throw const AppFailure(
          FailureKind.unsupportedBackupVersion,
          'This backup was made by a newer version of LunaCycle.',
        );
      }
      final k = header['kdf'] as Map<String, dynamic>;
      kdf = KdfParams(
        memoryKiB: k['memoryKiB'] as int,
        iterations: k['iterations'] as int,
        parallelism: k['parallelism'] as int,
      );
      salt = base64Decode(k['salt'] as String);
      nonce = base64Decode(
        (header['cipher'] as Map<String, dynamic>)['nonce'] as String,
      );
      data = base64Decode(envelope['data'] as String);
      tag = base64Decode(envelope['tag'] as String);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure(
        FailureKind.corruptBackup,
        'This backup file is damaged or incomplete.',
      );
    }

    try {
      final key = await _deriveKey(password, salt, kdf);
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(data, nonce: nonce, mac: Mac(tag)),
        secretKey: key,
        aad: utf8.encode(jsonEncode(header)),
      );
      return utf8.decode(clear);
    } on SecretBoxAuthenticationError {
      throw const AppFailure(
        FailureKind.wrongBackupPassword,
        'That password does not match this backup, or the file has been changed.',
      );
    }
  }
}
