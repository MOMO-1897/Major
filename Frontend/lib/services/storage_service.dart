import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setBool(_isLoggedInKey, true);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs!.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    await init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.setBool(_isLoggedInKey, false);
  }

  // User data management
  static Future<void> saveUser(User user) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> removeUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  // Login status
  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}