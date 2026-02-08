import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SettingsController extends GetxController {
  static const _boxName = 'app_cache';

  // Theme
  final themeMode = ThemeMode.system.obs;

  // Notifications
  final pushNotificationsEnabled = true.obs;
  final eventReminders = true.obs;
  final friendRequests = true.obs;
  final messages = true.obs;
  final eventUpdates = true.obs;

  // Privacy
  final showOnlineStatus = true.obs;
  final showLastSeen = true.obs;
  final allowFriendRequests = true.obs;
  final showInNearby = true.obs;

  // App preferences
  final distanceUnit = 'miles'.obs;
  final defaultEventRadius = 25.0.obs;
  final autoPlayVideos = true.obs;
  final hapticFeedback = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);

      // Theme - with bounds checking (#68)
      final themeModeIndex = box.get('themeMode', defaultValue: 0);
      if (themeModeIndex is int && themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        themeMode.value = ThemeMode.values[themeModeIndex];
      } else {
        themeMode.value = ThemeMode.system;
      }

      // Notifications
      pushNotificationsEnabled.value = box.get('pushNotifications', defaultValue: true);
      eventReminders.value = box.get('eventReminders', defaultValue: true);
      friendRequests.value = box.get('friendRequests', defaultValue: true);
      messages.value = box.get('messages', defaultValue: true);
      eventUpdates.value = box.get('eventUpdates', defaultValue: true);

      // Privacy
      showOnlineStatus.value = box.get('showOnlineStatus', defaultValue: true);
      showLastSeen.value = box.get('showLastSeen', defaultValue: true);
      allowFriendRequests.value = box.get('allowFriendRequests', defaultValue: true);
      showInNearby.value = box.get('showInNearby', defaultValue: true);

      // Preferences
      distanceUnit.value = box.get('distanceUnit', defaultValue: 'miles');
      defaultEventRadius.value = box.get('defaultEventRadius', defaultValue: 25.0);
      autoPlayVideos.value = box.get('autoPlayVideos', defaultValue: true);
      hapticFeedback.value = box.get('hapticFeedback', defaultValue: true);
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveToBox(String key, dynamic value) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(key, value);
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  // Theme
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _saveToBox('themeMode', mode.index);
  }

  // Notifications
  void togglePushNotifications(bool value) {
    pushNotificationsEnabled.value = value;
    _saveToBox('pushNotifications', value);
  }

  void toggleEventReminders(bool value) {
    eventReminders.value = value;
    _saveToBox('eventReminders', value);
  }

  void toggleFriendRequests(bool value) {
    friendRequests.value = value;
    _saveToBox('friendRequests', value);
  }

  void toggleMessages(bool value) {
    messages.value = value;
    _saveToBox('messages', value);
  }

  void toggleEventUpdates(bool value) {
    eventUpdates.value = value;
    _saveToBox('eventUpdates', value);
  }

  // Privacy
  void toggleOnlineStatus(bool value) {
    showOnlineStatus.value = value;
    _saveToBox('showOnlineStatus', value);
  }

  void toggleLastSeen(bool value) {
    showLastSeen.value = value;
    _saveToBox('showLastSeen', value);
  }

  void toggleAllowFriendRequests(bool value) {
    allowFriendRequests.value = value;
    _saveToBox('allowFriendRequests', value);
  }

  void toggleShowInNearby(bool value) {
    showInNearby.value = value;
    _saveToBox('showInNearby', value);
  }

  // Preferences
  void setDistanceUnit(String unit) {
    distanceUnit.value = unit;
    _saveToBox('distanceUnit', unit);
  }

  void setDefaultEventRadius(double radius) {
    defaultEventRadius.value = radius;
    _saveToBox('defaultEventRadius', radius);
  }

  void toggleAutoPlayVideos(bool value) {
    autoPlayVideos.value = value;
    _saveToBox('autoPlayVideos', value);
  }

  void toggleHapticFeedback(bool value) {
    hapticFeedback.value = value;
    _saveToBox('hapticFeedback', value);
  }

  // Reset
  Future<void> resetToDefaults() async {
    themeMode.value = ThemeMode.system;
    pushNotificationsEnabled.value = true;
    eventReminders.value = true;
    friendRequests.value = true;
    messages.value = true;
    eventUpdates.value = true;
    showOnlineStatus.value = true;
    showLastSeen.value = true;
    allowFriendRequests.value = true;
    showInNearby.value = true;
    distanceUnit.value = 'miles';
    defaultEventRadius.value = 25.0;
    autoPlayVideos.value = true;
    hapticFeedback.value = true;

    try {
      final box = await Hive.openBox(_boxName);
      await box.clear();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}
