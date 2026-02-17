// core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Access Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    print('✅ Access token saved');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    print('✅ Refresh token saved');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // Ikkala token'ni birga saqlash
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
    print('✅ All tokens cleared');
  }
}