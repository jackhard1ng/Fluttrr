/// Follow relationship model for businesses
class BusinessFollowModel {
  final String? followId;
  final int? userId;
  final int? businessId;
  final String? businessName;
  final String? businessImage;
  final String? businessCategory;
  final bool isVerified;
  final DateTime? followedAt;
  final bool notificationsEnabled;
  final int upcomingEventCount;

  const BusinessFollowModel({
    this.followId,
    this.userId,
    this.businessId,
    this.businessName,
    this.businessImage,
    this.businessCategory,
    this.isVerified = false,
    this.followedAt,
    this.notificationsEnabled = true,
    this.upcomingEventCount = 0,
  });

  factory BusinessFollowModel.fromJson(Map<String, dynamic> json) {
    return BusinessFollowModel(
      followId: json['follow_id']?.toString(),
      userId: json['user_id'] as int?,
      businessId: json['business_id'] as int?,
      businessName: json['business_name'] as String?,
      businessImage: json['business_image'] as String?,
      businessCategory: json['business_category'] as String?,
      isVerified: json['is_verified'] == true,
      followedAt: _parseDateTime(json['followed_at']),
      notificationsEnabled: json['notifications_enabled'] != false,
      upcomingEventCount: json['upcoming_event_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follow_id': followId,
      'user_id': userId,
      'business_id': businessId,
      'business_name': businessName,
      'business_image': businessImage,
      'business_category': businessCategory,
      'is_verified': isVerified,
      'followed_at': followedAt?.toIso8601String(),
      'notifications_enabled': notificationsEnabled,
      'upcoming_event_count': upcomingEventCount,
    };
  }

  BusinessFollowModel copyWith({
    String? followId,
    int? userId,
    int? businessId,
    String? businessName,
    String? businessImage,
    String? businessCategory,
    bool? isVerified,
    DateTime? followedAt,
    bool? notificationsEnabled,
    int? upcomingEventCount,
  }) {
    return BusinessFollowModel(
      followId: followId ?? this.followId,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      businessImage: businessImage ?? this.businessImage,
      businessCategory: businessCategory ?? this.businessCategory,
      isVerified: isVerified ?? this.isVerified,
      followedAt: followedAt ?? this.followedAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      upcomingEventCount: upcomingEventCount ?? this.upcomingEventCount,
    );
  }
}

/// Followed businesses list response
class FollowedBusinessesResponse {
  final List<BusinessFollowModel> businesses;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  const FollowedBusinessesResponse({
    this.businesses = const [],
    this.totalCount = 0,
    this.page = 1,
    this.limit = 20,
    this.hasMore = false,
  });

  factory FollowedBusinessesResponse.fromJson(Map<String, dynamic> json) {
    return FollowedBusinessesResponse(
      businesses: _parseBusinessFollows(json['businesses'] ?? json['data']),
      totalCount: json['total_count'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      hasMore: json['has_more'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businesses': businesses.map((b) => b.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'limit': limit,
      'has_more': hasMore,
    };
  }
}

/// Business follower model (for businesses to see their followers)
class BusinessFollowerModel {
  final String? followerId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final DateTime? followedAt;
  final int eventsAttended;
  final bool isActive;

  const BusinessFollowerModel({
    this.followerId,
    this.userId,
    this.userName,
    this.userImage,
    this.followedAt,
    this.eventsAttended = 0,
    this.isActive = true,
  });

  factory BusinessFollowerModel.fromJson(Map<String, dynamic> json) {
    return BusinessFollowerModel(
      followerId: json['follower_id']?.toString(),
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      followedAt: _parseDateTime(json['followed_at']),
      eventsAttended: json['events_attended'] as int? ?? 0,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower_id': followerId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'followed_at': followedAt?.toIso8601String(),
      'events_attended': eventsAttended,
      'is_active': isActive,
    };
  }
}

/// Follow notification settings
class FollowNotificationSettings {
  final int? businessId;
  final bool newEvents;
  final bool eventReminders;
  final bool promotions;
  final bool updates;

  const FollowNotificationSettings({
    this.businessId,
    this.newEvents = true,
    this.eventReminders = true,
    this.promotions = false,
    this.updates = true,
  });

  factory FollowNotificationSettings.fromJson(Map<String, dynamic> json) {
    return FollowNotificationSettings(
      businessId: json['business_id'] as int?,
      newEvents: json['new_events'] != false,
      eventReminders: json['event_reminders'] != false,
      promotions: json['promotions'] == true,
      updates: json['updates'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'new_events': newEvents,
      'event_reminders': eventReminders,
      'promotions': promotions,
      'updates': updates,
    };
  }

  FollowNotificationSettings copyWith({
    int? businessId,
    bool? newEvents,
    bool? eventReminders,
    bool? promotions,
    bool? updates,
  }) {
    return FollowNotificationSettings(
      businessId: businessId ?? this.businessId,
      newEvents: newEvents ?? this.newEvents,
      eventReminders: eventReminders ?? this.eventReminders,
      promotions: promotions ?? this.promotions,
      updates: updates ?? this.updates,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<BusinessFollowModel> _parseBusinessFollows(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => BusinessFollowModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
