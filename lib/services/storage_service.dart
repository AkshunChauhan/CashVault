import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the encryption key for the Hive database.
/// Uses Android Keystore via flutter_secure_storage.
class StorageService {
  static const _keyName = 'cash_vault_hive_key';
  final FlutterSecureStorage _secureStorage;

  StorageService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Retrieves or generates the 32-byte encryption key for Hive.
  Future<List<int>> getEncryptionKey() async {
    final stored = await _secureStorage.read(key: _keyName);

    if (stored != null) {
      return base64Url.decode(stored);
    }

    // Generate a new 32-byte key
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await _secureStorage.write(
      key: _keyName,
      value: base64Url.encode(key),
    );

    return key;
  }

  /// Deletes the stored encryption key (for account reset scenarios).
  Future<void> deleteKey() async {
    await _secureStorage.delete(key: _keyName);
  }
}
