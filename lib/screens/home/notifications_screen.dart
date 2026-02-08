import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../widgets/notification_badges.dart';
import '../../widgets/empty_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationData> _notifications = [
    _NotificationData(
      type: NotificationType.friend,
      title: 'Sarah sent you a friend request',
      subtitle: 'You have 3 mutual friends',
      timeAgo: '2 min ago',
      isUnread: true,
    ),
    _NotificationData(
      type: NotificationType.event,
      title: 'Game Night is starting soon',
      subtitle: 'Starts in 2 hours',
      timeAgo: '1 hour ago',
      isUnread: true,
    ),
    _NotificationData(
      type: NotificationType.message,
      title: 'Mike sent you a message',
      subtitle: 'Hey! Are you coming tonight?',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    _NotificationData(
      type: NotificationType.event,
      title: 'New event near you',
      subtitle: 'Coffee & Chat at The Roastery',
      timeAgo: 'Yesterday',
      isUnread: false,
    ),
    _NotificationData(
      type: NotificationType.reminder,
      title: 'Don\'t forget to RSVP',
      subtitle: 'Weekend Hike is filling up',
      timeAgo: 'Yesterday',
      isUnread: false,
    ),
    _NotificationData(
      type: NotificationType.friend,
      title: 'Jordan accepted your request',
      subtitle: 'You\'re now connected',
      timeAgo: '2 days ago',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  for (var n in _notifications) {
                    n.isUnread = false;
                  }
                });
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const NoNotificationsState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key('notification_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: NotificationItem(
                    type: notification.type,
                    title: notification.title,
                    subtitle: notification.subtitle,
                    timeAgo: notification.timeAgo,
                    isUnread: notification.isUnread,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        notification.isUnread = false;
                      });
                      _navigateByType(notification.type);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _navigateByType(NotificationType type) {
    switch (type) {
      case NotificationType.friend:
        Nav.toMatches();
        break;
      case NotificationType.event:
        Nav.toDiscover();
        break;
      case NotificationType.message:
        Nav.toMessages();
        break;
      case NotificationType.reminder:
        Nav.toDiscover();
        break;
    }
  }
}

class _NotificationData {
  final NotificationType type;
  final String title;
  final String? subtitle;
  final String timeAgo;
  bool isUnread;

  _NotificationData({
    required this.type,
    required this.title,
    this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
  });
}
