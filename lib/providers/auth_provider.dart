import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthNotifier(storage);
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final StorageService _storage;

  AuthNotifier(this._storage) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _storage.getToken();
      state = AsyncValue.data(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String token) async {
    state = const AsyncValue.loading();
    try {
      await _storage.saveToken(token);
      state = AsyncValue.data(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _storage.deleteToken();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setOpenRouterKey(String key) async {
    await _storage.saveOpenRouterKey(key);
  }

  Future<String?> getOpenRouterKey() async {
    return await _storage.getOpenRouterKey();
  }
}

final openRouterKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getOpenRouterKey();
});
