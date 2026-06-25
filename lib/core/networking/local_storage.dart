import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/user_role.dart';
import '../../injection/core_providers.dart';

class LocalStorage {
  LocalStorage(this._prefs);
  final SharedPreferences _prefs;

  static const String _authTokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveToken(String token) async {
    await saveString(_authTokenKey, token);
  }

  String? getToken() {
    return getString(_authTokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_authTokenKey);
  }

  Future<void> clearRole() async {
    await _prefs.remove(_roleKey);
  }

  Future<void> saveRole(UserRole role) async {
    await saveString(_roleKey, role.value);
  }

  UserRole? getRole() {
    final value = getString(_roleKey);
    if (value == null) return null;
    return UserRoleX.fromString(value);
  }

  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> saveOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingCompletedKey, value);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

final localStorageProvider = Provider<LocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
});
