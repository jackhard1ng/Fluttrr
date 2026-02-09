import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../widgets/notification_badges.dart';
import '../../widgets/empty_states.dart';
import '../../widgets/advanced_ux.dart';

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
                    final removed = notification;
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    UndoAction.show(
                      message: 'Notification deleted',
                      onUndo: () {
                        setState(() {
                          _notifications.insert(index, removed);
                        });
                      },
                    );
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
                    onLongPress: () => _showNotificationActions(context, notification, index),
                  ),
                );
              },
            ),
    );
  }

  void _showNotificationActions(BuildContext context, _NotificationData notification, int index) {
    // Check if context is still mounted before showing bottom sheet (#84)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notification.type.color.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notification.type.icon, size: 20, color: notification.type.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                notification.isUnread ? Icons.mark_email_read : Icons.mark_email_unread,
                color: AppColors.primaryBlue,
              ),
              title: Text(notification.isUnread ? 'Mark as Read' : 'Mark as Unread'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                setState(() {
                  notification.isUnread = !notification.isUnread;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.open_in_new, color: AppColors.friendlyTeal),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                setState(() {
                  notification.isUnread = false;
                });
                _navigateByType(notification.type);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off, color: AppColors.mediumGrey),
              title: const Text('Turn Off This Type'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Notifications Updated',
                  '${_getTypeLabel(notification.type)} notifications muted',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                setState(() {
                  _notifications.removeAt(index);
                });
                Get.snackbar(
                  'Notification Deleted',
                  'Notification removed',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.friend:
        return 'Friend request';
      case NotificationType.event:
        return 'Event';
      case NotificationType.message:
        return 'Message';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.update:
        return 'Update';
    }
  }

  void _navigateByType(NotificationType type) {
    switch (type) {
      case NotificationType.friend:
        Nav.toChatList();
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
      case NotificationType.update:
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
