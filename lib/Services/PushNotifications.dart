import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configure local notifications
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Configure Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingClickHandler);
  }

  static Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
    if (message.notification != null) {
      final notification = message.notification!;
      await _showLocalNotification(
        notification.title ?? "No Title",
        notification.body ?? "No Body",
      );
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background message
  }

  static void _firebaseMessagingClickHandler(RemoteMessage message) {
    // Navigate to a specific screen if required
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'channel_id', // Channel ID
      'Channel Name', // Channel Name
      channelDescription: 'This is the channel description',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification Title
      body, // Notification Body
      notificationDetails,
    );
  }
}