import '../enums/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  StorageHelper._();

  static const String _authTokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  static Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  static Future<void> saveToken(String token) async {
    await saveString(_authTokenKey, token);
  }

  static Future<String?> getToken() async {
    return getString(_authTokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_authTokenKey);
  }

  static Future<void> saveRole(UserRole role) async {
    await saveString(_roleKey, role.value);
  }

  static Future<UserRole?> getRole() async {
    final value = await getString(_roleKey);
    if (value == null) {
      return null;
    }
    return UserRoleX.fromString(value);
  }

  static Future<void> clearRole() async {
    final prefs = await _prefs;
    await prefs.remove(_roleKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
