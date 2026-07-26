import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyToken = 'access_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyDisplayName = 'display_name';

  // In-memory fallback cache
  static String? _inMemoryToken;
  static String? _inMemoryUserId;
  static String? _inMemoryUsername;
  static String? _inMemoryDisplayName;

  static Future<SharedPreferences?> _getPrefs() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences init error (using memory cache): $e');
      return null;
    }
  }

  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String username,
    required String displayName,
  }) async {
    _inMemoryToken = token;
    _inMemoryUserId = userId;
    _inMemoryUsername = username;
    _inMemoryDisplayName = displayName;
    debugPrint('SharedPreferences (Memory Cache) saved: userId=$userId, name=$displayName');

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyToken, token);
        await prefs.setString(_keyUserId, userId);
        await prefs.setString(_keyUsername, username);
        await prefs.setString(_keyDisplayName, displayName);
        debugPrint('SharedPreferences (Disk) saved successfully.');
      }
    } catch (e) {
      debugPrint('SharedPreferences save error: $e');
    }
  }

  static Future<String?> getAccessToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_keyToken);
      if (val != null && val.isNotEmpty) _inMemoryToken = val;
      return val;
    } catch (e) {
      debugPrint('SharedPreferences getAccessToken error: $e');
      return _inMemoryToken;
    }
  }

  static Future<String?> getUserId() async {
    if (_inMemoryUserId != null && _inMemoryUserId!.isNotEmpty) {
      return _inMemoryUserId;
    }
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_keyUserId);
      if (val != null && val.isNotEmpty) _inMemoryUserId = val;
      return val;
    } catch (e) {
      debugPrint('SharedPreferences getUserId error: $e');
      return _inMemoryUserId;
    }
  }

  static Future<String?> getUsername() async {
    if (_inMemoryUsername != null && _inMemoryUsername!.isNotEmpty) {
      return _inMemoryUsername;
    }
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_keyUsername);
      if (val != null && val.isNotEmpty) _inMemoryUsername = val;
      return val;
    } catch (e) {
      return _inMemoryUsername;
    }
  }

  static Future<String?> getDisplayName() async {
    if (_inMemoryDisplayName != null && _inMemoryDisplayName!.isNotEmpty) {
      return _inMemoryDisplayName;
    }
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_keyDisplayName);
      if (val != null && val.isNotEmpty) _inMemoryDisplayName = val;
      return val;
    } catch (e) {
      return _inMemoryDisplayName;
    }
  }

  static Future<void> clearAuthData() async {
    _inMemoryToken = null;
    _inMemoryUserId = null;
    _inMemoryUsername = null;
    _inMemoryDisplayName = null;

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove(_keyToken);
        await prefs.remove(_keyUserId);
        await prefs.remove(_keyUsername);
        await prefs.remove(_keyDisplayName);
        debugPrint('SharedPreferences auth data cleared.');
      }
    } catch (e) {
      debugPrint('SharedPreferences clear error: $e');
    }
  }
}
