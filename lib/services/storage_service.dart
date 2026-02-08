import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Local storage service using Hive
class StorageService {
  static const String _userBox = 'user_data';
  static const String _cacheBox = 'app_cache';
  static const String _prefsBox = 'preferences';

  // Initialize storage
  static Future<void> init() async {
    try {
      await Hive.openBox(_userBox);
      await Hive.openBox(_cacheBox);
      await Hive.openBox(_prefsBox);
    } catch (e) {
      debugPrint('Storage init error: $e');
    }
  }

  // User data
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final box = Hive.box(_userBox);
    await box.put('current_user', userData);
  }

  static Map<String, dynamic>? getUser() {
    final box = Hive.box(_userBox);
    final data = box.get('current_user');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> clearUser() async {
    final box = Hive.box(_userBox);
    await box.delete('current_user');
  }

  // Auth token
  static Future<void> saveToken(String token) async {
    final box = Hive.box(_userBox);
    await box.put('auth_token', token);
  }

  static String? getToken() {
    final box = Hive.box(_userBox);
    return box.get('auth_token');
  }

  static Future<void> clearToken() async {
    final box = Hive.box(_userBox);
    await box.delete('auth_token');
  }

  // Preferences
  static Future<void> setPreference(String key, dynamic value) async {
    final box = Hive.box(_prefsBox);
    await box.put(key, value);
  }

  static T? getPreference<T>(String key, {T? defaultValue}) {
    try {
      final box = Hive.box(_prefsBox);
      final value = box.get(key, defaultValue: defaultValue);
      if (value is T) return value;
      return defaultValue;
    } catch (e) {
      debugPrint('Error getting preference $key: $e');
      return defaultValue;
    }
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return getPreference<bool>(key, defaultValue: defaultValue) ?? defaultValue;
  }

  static String? getString(String key) {
    return getPreference<String>(key);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return getPreference<int>(key, defaultValue: defaultValue) ?? defaultValue;
  }

  // Cache
  static Future<void> cache(String key, dynamic value, {Duration? expiry}) async {
    final box = Hive.box(_cacheBox);
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await box.put(key, data);
  }

  static T? getCached<T>(String key) {
    try {
      final box = Hive.box(_cacheBox);
      final data = box.get(key);

      if (data == null) return null;

      final cached = Map<String, dynamic>.from(data);
      final timestamp = (cached['timestamp'] as num?)?.toInt();
      final expiry = (cached['expiry'] as num?)?.toInt();

      if (timestamp != null && expiry != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (elapsed > expiry) {
          box.delete(key);
          return null;
        }
      }

      final value = cached['value'];
      if (value is T) return value;
      return null;
    } catch (e) {
      debugPrint('Error getting cached value for $key: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }

  // Recently viewed
  static Future<void> addRecentlyViewed(String type, String id) async {
    final key = 'recently_viewed_$type';
    final box = Hive.box(_cacheBox);
    final stored = box.get(key);
    List<String> items = stored is List ? stored.whereType<String>().toList() : [];

    items.remove(id);
    items.insert(0, id);

    if (items.length > 20) {
      items = items.sublist(0, 20);
    }

    await box.put(key, items);
  }

  static List<String> getRecentlyViewed(String type) {
    final key = 'recently_viewed_$type';
    final box = Hive.box(_cacheBox);
    final stored = box.get(key);
    return stored is List ? stored.whereType<String>().toList() : [];
  }

  // Search history
  static Future<void> addSearchHistory(String query) async {
    final box = Hive.box(_cacheBox);
    final stored = box.get('search_history');
    List<String> history = stored is List ? stored.whereType<String>().toList() : [];

    history.remove(query);
    history.insert(0, query);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put('search_history', history);
  }

  static List<String> getSearchHistory() {
    final box = Hive.box(_cacheBox);
    final stored = box.get('search_history');
    return stored is List ? stored.whereType<String>().toList() : [];
  }

  static Future<void> clearSearchHistory() async {
    final box = Hive.box(_cacheBox);
    await box.delete('search_history');
  }

  // Draft
  static Future<void> saveDraft(String key, Map<String, dynamic> data) async {
    final box = Hive.box(_cacheBox);
    await box.put('draft_$key', {
      ...data,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Map<String, dynamic>? getDraft(String key) {
    final box = Hive.box(_cacheBox);
    final data = box.get('draft_$key');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> deleteDraft(String key) async {
    final box = Hive.box(_cacheBox);
    await box.delete('draft_$key');
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_cacheBox).clear();
    await Hive.box(_prefsBox).clear();
  }

  // Onboarding
  static Future<void> setOnboardingCompleted() async {
    await setPreference('onboarding_completed', true);
  }

  static bool isOnboardingCompleted() {
    return getBool('onboarding_completed');
  }

  // First launch
  static Future<void> setFirstLaunch(bool value) async {
    await setPreference('first_launch', value);
  }

  static bool isFirstLaunch() {
    return getBool('first_launch', defaultValue: true);
  }
}

/// Preference keys
class PrefKeys {
  static const themeMode = 'theme_mode';
  static const notifications = 'notifications_enabled';
  static const locationSharing = 'location_sharing';
  static const distanceUnit = 'distance_unit';
  static const language = 'language';
  static const hapticFeedback = 'haptic_feedback';
  static const autoPlayVideos = 'auto_play_videos';
  static const showOnlineStatus = 'show_online_status';
  static const lastSyncTime = 'last_sync_time';
}
