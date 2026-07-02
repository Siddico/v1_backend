import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _authTokenKey = 'auth_token';
  static const String _resetTokenKey = 'reset_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> saveResetToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetTokenKey, token);
  }

  static Future<String?> getResetToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resetTokenKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_resetTokenKey);
  }
}
