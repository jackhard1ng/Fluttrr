import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Models/Notifications/NotificationsModel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await controller.Notifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_as_unread),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        id: "Activity_update",
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: controller.notificationsModel!.notifications!.length,
              itemBuilder: (context, index) {
                final notification =
                    controller.notificationsModel!.notifications![index];
                return _buildNotificationItem(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Notifications notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id!);
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isSeen ?? false
                ? Colors.white
                : Colors.grey.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (notification.isSeen ?? false)
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message ?? '',
                      style: TextStyle(
                        color: (notification.isSeen ?? false)
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!(notification.isSeen ?? false))
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _markAllAsRead() async {
    // await controller.markAllAsRead();
  }

  Future<void> _deleteNotification(int id) async {
    // await controller.deleteNotification(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification dismissed')),
    );
  }

  void _handleNotificationTap(Notifications notification) {
    if (!(notification.isSeen ?? false)) {
      // controller.markAsRead(notification.id!);
    }
    // Handle navigation if needed
  }
}
