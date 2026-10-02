import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getApiToken() =>
      _storage.read(key: AppConstants.secureStorageKeyApiToken);

  Future<void> setApiToken(String token) =>
      _storage.write(key: AppConstants.secureStorageKeyApiToken, value: token);

  Future<void> deleteApiToken() =>
      _storage.delete(key: AppConstants.secureStorageKeyApiToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.secureStorageKeyRefreshToken);

  Future<void> setRefreshToken(String token) => _storage.write(
    key: AppConstants.secureStorageKeyRefreshToken,
    value: token,
  );

  Future<void> deleteRefreshToken() =>
      _storage.delete(key: AppConstants.secureStorageKeyRefreshToken);

  Future<String?> getUserId() =>
      _storage.read(key: AppConstants.secureStorageKeyUserId);

  Future<void> setUserId(String userId) =>
      _storage.write(key: AppConstants.secureStorageKeyUserId, value: userId);

  Future<void> deleteUserId() =>
      _storage.delete(key: AppConstants.secureStorageKeyUserId);

  Future<String?> getClonedVoiceData() =>
      _storage.read(key: AppConstants.secureStorageKeyClonedVoiceData);

  Future<void> setClonedVoiceData(String data) => _storage.write(
    key: AppConstants.secureStorageKeyClonedVoiceData,
    value: data,
  );

  Future<void> deleteClonedVoiceData() =>
      _storage.delete(key: AppConstants.secureStorageKeyClonedVoiceData);

  Future<void> clearAll() => _storage.deleteAll();

  Future<Map<String, String>> readAll() => _storage.readAll();

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}
