import 'package:get/get.dart';

import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  // State
  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      // Mock data - in real app would fetch from API
      await Future.delayed(const Duration(milliseconds: 500));
      notifications.value = _mockNotifications;
      _updateUnreadCount();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
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
    notifications.removeWhere((n) => n.id == notificationId);
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
      final diff = now.difference(notification.createdAt);

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

  // Mock data
  List<NotificationModel> get _mockNotifications => [
    NotificationModel(
      id: '1',
      type: NotificationType.friendRequest,
      title: 'New friend request',
      message: 'Alex wants to connect with you',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      data: {'userId': 'user1'},
    ),
    NotificationModel(
      id: '2',
      type: NotificationType.eventReminder,
      title: 'Event starting soon',
      message: 'Board Game Night starts in 2 hours',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      data: {'eventId': 'event1'},
    ),
    NotificationModel(
      id: '3',
      type: NotificationType.newMessage,
      title: 'New message',
      message: 'Jordan: Hey, are you coming tonight?',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      data: {'chatId': 'chat1'},
    ),
    NotificationModel(
      id: '4',
      type: NotificationType.eventUpdate,
      title: 'Event updated',
      message: 'Hiking Adventure location has changed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      data: {'eventId': 'event2'},
    ),
    NotificationModel(
      id: '5',
      type: NotificationType.newAttendee,
      title: 'New attendee',
      message: 'Taylor is going to your Coffee Meetup',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      data: {'eventId': 'event3', 'userId': 'user3'},
    ),
  ];
}
