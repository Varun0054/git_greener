import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _patKey = 'github_pat';

  /// Saves the GitHub Personal Access Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _patKey, value: token);
  }

  /// Retrieves the GitHub Personal Access Token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _patKey);
    } catch (e) {
      // Keystore corrupted — wipe and restart fresh
      await _storage.deleteAll();
      return null;
    }
  }

  /// Deletes the GitHub Personal Access Token
  Future<void> deleteToken() async {
    await _storage.delete(key: _patKey);
  }

  /// Saves the OpenRouter API Key
  Future<void> saveOpenRouterKey(String key) async {
    await _storage.write(key: 'openrouter_key', value: key);
  }

  /// Retrieves the OpenRouter API Key
  Future<String?> getOpenRouterKey() async {
    try {
      return await _storage.read(key: 'openrouter_key');
    } catch (_) {
      return null;
    }
  }
}
