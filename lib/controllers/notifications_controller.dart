import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _notificationRepository = NotificationRepository();

  // State
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications with proper loading state management
  Future<void> loadNotifications() async {
    // Show loading spinner only on initial load (when list is empty)
    if (notifications.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _notificationRepository.getNotifications();

      if (response.success && response.data != null) {
        notifications.value = response.data!;
        _updateUnreadCount();
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load notifications. Please try again.';
      debugPrint('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh notifications with separate loading state for pull-to-refresh
  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    errorMessage.value = '';

    try {
      final response = await _notificationRepository.getNotifications();

      if (response.success && response.data != null) {
        notifications.value = response.data!;
        _updateUnreadCount();
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh notifications';
      debugPrint('Error refreshing notifications: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      notifications[index] = notification.copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _updateUnreadCount();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.notificationId == notificationId);
    _updateUnreadCount();
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
  }

  // Group notifications by date
  Map<String, List<NotificationModel>> get groupedNotifications {
    final Map<String, List<NotificationModel>> grouped = {};

    for (final notification in notifications) {
      final now = DateTime.now();
      final createdAt = notification.createdAt ?? now;
      final diff = now.difference(createdAt);

      String key;
      if (diff.inDays == 0) {
        key = 'Today';
      } else if (diff.inDays == 1) {
        key = 'Yesterday';
      } else if (diff.inDays < 7) {
        key = 'This Week';
      } else {
        key = 'Earlier';
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(notification);
    }

    return grouped;
  }
}
