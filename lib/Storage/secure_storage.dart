import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Token speichern
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Token abrufen
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Token löschen
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}