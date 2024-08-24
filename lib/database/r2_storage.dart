import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class R2Storage {
  static final _storage = FlutterSecureStorage();

  static Future<void> save(String key, String value) async {
    await _storage.write(key:key, value:value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key:key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'authtoken', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'authtoken');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'authtoken');
  }
}