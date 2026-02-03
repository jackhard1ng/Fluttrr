/// Notification model
class NotificationModel {
  final String? notificationId;
  final String? title;
  final String? body;
  final NotificationType type;
  final int? senderId;
  final String? senderName;
  final String? senderImage;
  final int? relatedId;
  final String? relatedType;
  final DateTime? createdAt;
  final bool isRead;

  const NotificationModel({
    this.notificationId,
    this.title,
    this.body,
    this.type = NotificationType.general,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.relatedId,
    this.relatedType,
    this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id']?.toString() ?? json['_id']?.toString(),
      title: json['title'] as String?,
      body: json['body'] ?? json['message'] as String?,
      type: _parseNotificationType(json['type']),
      senderId: json['sender_id'] ?? json['senderId'] as int?,
      senderName: json['sender_name'] ?? json['senderName'] as String?,
      senderImage: json['sender_image'] ?? json['senderImage'] as String?,
      relatedId: json['related_id'] ?? json['relatedId'] as int?,
      relatedType: json['related_type'] ?? json['relatedType'] as String?,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      isRead: json['is_read'] == true || json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'title': title,
      'body': body,
      'type': type.name,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'related_id': relatedId,
      'related_type': relatedType,
      'created_at': createdAt?.toIso8601String(),
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? title,
    String? body,
    NotificationType? type,
    int? senderId,
    String? senderName,
    String? senderImage,
    int? relatedId,
    String? relatedType,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notification type enum
enum NotificationType {
  general,
  like,
  match,
  message,
  activityInvite,
  activityUpdate,
  activityReminder,
  follow,
  comment,
  badge,
}

/// Notification list response
class NotificationListResponse {
  final String? message;
  final List<NotificationModel> data;
  final int unreadCount;

  const NotificationListResponse({
    this.message,
    this.data = const [],
    this.unreadCount = 0,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
    );
  }
}

/// Helper functions
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

NotificationType _parseNotificationType(dynamic value) {
  if (value == null) return NotificationType.general;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'match':
        return NotificationType.match;
      case 'message':
        return NotificationType.message;
      case 'activity_invite':
      case 'activityinvite':
        return NotificationType.activityInvite;
      case 'activity_update':
      case 'activityupdate':
        return NotificationType.activityUpdate;
      case 'activity_reminder':
      case 'activityreminder':
        return NotificationType.activityReminder;
      case 'follow':
        return NotificationType.follow;
      case 'comment':
        return NotificationType.comment;
      case 'badge':
        return NotificationType.badge;
      default:
        return NotificationType.general;
    }
  }
  return NotificationType.general;
}
