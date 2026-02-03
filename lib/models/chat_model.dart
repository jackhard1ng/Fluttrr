/// Chat message model
class ChatMessage {
  final String? messageId;
  final int? senderId;
  final int? receiverId;
  final String? senderName;
  final String? content;
  final String? imageUrl;
  final DateTime? timestamp;
  final bool isRead;
  final bool isSent;
  final MessageType type;

  const ChatMessage({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.senderName,
    this.content,
    this.imageUrl,
    this.timestamp,
    this.isRead = false,
    this.isSent = true,
    this.type = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['message_id']?.toString() ?? json['_id']?.toString(),
      senderId: json['sender_id'] ?? json['senderId'] as int?,
      receiverId: json['receiver_id'] ?? json['receiverId'] as int?,
      senderName: json['sender_name'] ?? json['senderName'] as String?,
      content: json['content'] ?? json['message'] as String?,
      imageUrl: json['image_url'] ?? json['imageUrl'] as String?,
      timestamp: _parseTimestamp(json['timestamp'] ?? json['createdAt']),
      isRead: json['is_read'] == true || json['isRead'] == true,
      isSent: json['is_sent'] != false,
      type: _parseMessageType(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_name': senderName,
      'content': content,
      'image_url': imageUrl,
      'timestamp': timestamp?.toIso8601String(),
      'is_read': isRead,
      'is_sent': isSent,
      'type': type.name,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    int? senderId,
    int? receiverId,
    String? senderName,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
    MessageType? type,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      type: type ?? this.type,
    );
  }

  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;
  bool get isSystemMessage => type == MessageType.system;
}

/// Message type enum
enum MessageType {
  text,
  image,
  system,
}

/// Chat conversation model
class ChatConversation {
  final String? conversationId;
  final int? otherUserId;
  final String? otherUserName;
  final List<String> otherUserImages;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final String? groupName;
  final List<int> memberIds;

  const ChatConversation({
    this.conversationId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserImages = const [],
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.groupName,
    this.memberIds = const [],
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      conversationId: json['conversation_id']?.toString() ?? json['_id']?.toString(),
      otherUserId: json['other_user_id'] ?? json['userId'] as int?,
      otherUserName: json['other_user_name'] ?? json['userName'] as String?,
      otherUserImages: _parseStringList(json['other_user_images'] ?? json['images']),
      lastMessage: json['last_message'] ?? json['lastMessage'] as String?,
      lastMessageTime: _parseTimestamp(json['last_message_time'] ?? json['lastMessageTime']),
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      isGroup: json['is_group'] == true || json['isGroup'] == true,
      groupName: json['group_name'] ?? json['groupName'] as String?,
      memberIds: _parseIntList(json['member_ids'] ?? json['members']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_images': otherUserImages,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'is_online': isOnline,
      'is_group': isGroup,
      'group_name': groupName,
      'member_ids': memberIds,
    };
  }

  String get displayName => isGroup ? (groupName ?? 'Group') : (otherUserName ?? 'User');

  String? get profileImage => otherUserImages.isNotEmpty ? otherUserImages.first : null;

  bool get hasUnread => unreadCount > 0;
}

/// Chat list response
class ChatListResponse {
  final String? message;
  final List<ChatConversation> data;

  const ChatListResponse({
    this.message,
    this.data = const [],
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Group chat model
class GroupChat {
  final String? groupId;
  final String? groupName;
  final String? groupImage;
  final int? activityId;
  final String? activityName;
  final List<GroupMember> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const GroupChat({
    this.groupId,
    this.groupName,
    this.groupImage,
    this.activityId,
    this.activityName,
    this.members = const [],
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      groupId: json['group_id']?.toString() ?? json['_id']?.toString(),
      groupName: json['group_name'] ?? json['groupName'] as String?,
      groupImage: json['group_image'] ?? json['groupImage'] as String?,
      activityId: json['activity_id'] ?? json['activityId'] as int?,
      activityName: json['activity_name'] ?? json['activityName'] as String?,
      members: _parseGroupMembers(json['members']),
      lastMessage: json['last_message'] ?? json['lastMessage'] as String?,
      lastMessageTime: _parseTimestamp(json['last_message_time'] ?? json['lastMessageTime']),
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'group_image': groupImage,
      'activity_id': activityId,
      'activity_name': activityName,
      'members': members.map((m) => m.toJson()).toList(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  String get displayName => groupName ?? activityName ?? 'Group';

  int get memberCount => members.length;
}

/// Group member model
class GroupMember {
  final int? userId;
  final String? userName;
  final String? profileImage;
  final bool isAdmin;

  const GroupMember({
    this.userId,
    this.userName,
    this.profileImage,
    this.isAdmin = false,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['user_id'] ?? json['userId'] as int?,
      userName: json['user_name'] ?? json['userName'] as String?,
      profileImage: json['profile_image'] ?? json['profileImage'] as String?,
      isAdmin: json['is_admin'] == true || json['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'profile_image': profileImage,
      'is_admin': isAdmin,
    };
  }
}

/// Helper functions
DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

MessageType _parseMessageType(dynamic value) {
  if (value == null) return MessageType.text;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
  return MessageType.text;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<int> _parseIntList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<int>().toList();
  }
  return [];
}

List<GroupMember> _parseGroupMembers(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
