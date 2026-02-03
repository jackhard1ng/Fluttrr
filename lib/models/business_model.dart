/// Business page model
class BusinessModel {
  final int? businessId;
  final String? businessName;
  final String? email;
  final String? phone;
  final String? description;
  final String? category;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? website;
  final List<String> images;
  final String? coverImage;
  final bool isVerified;
  final int followerCount;
  final int eventCount;
  final bool isFollowing;
  final SubscriptionStatus? subscriptionStatus;

  const BusinessModel({
    this.businessId,
    this.businessName,
    this.email,
    this.phone,
    this.description,
    this.category,
    this.address,
    this.latitude,
    this.longitude,
    this.website,
    this.images = const [],
    this.coverImage,
    this.isVerified = false,
    this.followerCount = 0,
    this.eventCount = 0,
    this.isFollowing = false,
    this.subscriptionStatus,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: json['business_id'] ?? json['businessId'] as int?,
      businessName: json['business_name'] ?? json['businessName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      website: json['website'] as String?,
      images: _parseStringList(json['images']),
      coverImage: json['cover_image'] ?? json['coverImage'] as String?,
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      followerCount: json['follower_count'] ?? json['followerCount'] ?? 0,
      eventCount: json['event_count'] ?? json['eventCount'] ?? 0,
      isFollowing: json['is_following'] == true || json['isFollowing'] == true,
      subscriptionStatus: json['subscription_status'] != null
          ? SubscriptionStatus.fromJson(json['subscription_status'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'business_name': businessName,
      'email': email,
      'phone': phone,
      'description': description,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'images': images,
      'cover_image': coverImage,
      'is_verified': isVerified,
      'follower_count': followerCount,
      'event_count': eventCount,
      'is_following': isFollowing,
      'subscription_status': subscriptionStatus?.toJson(),
    };
  }

  String get displayName => businessName ?? 'Business';

  String? get profileImage => images.isNotEmpty ? images.first : null;
}

/// Business event model
class BusinessEvent {
  final int? eventId;
  final int? businessId;
  final String? name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? eventType;
  final List<String> images;
  final int? totalSlots;
  final int? remainingSlots;
  final double? price;
  final String? currency;
  final int attendeeCount;
  final int viewCount;
  final int clickCount;
  final bool userJoined;
  final bool userSaved;

  const BusinessEvent({
    this.eventId,
    this.businessId,
    this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.startTime,
    this.endTime,
    this.eventType,
    this.images = const [],
    this.totalSlots,
    this.remainingSlots,
    this.price,
    this.currency,
    this.attendeeCount = 0,
    this.viewCount = 0,
    this.clickCount = 0,
    this.userJoined = false,
    this.userSaved = false,
  });

  factory BusinessEvent.fromJson(Map<String, dynamic> json) {
    return BusinessEvent(
      eventId: json['event_id'] ?? json['eventId'] as int?,
      businessId: json['business_id'] ?? json['businessId'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startTime: _parseDateTime(json['start_time'] ?? json['startTime']),
      endTime: _parseDateTime(json['end_time'] ?? json['endTime']),
      eventType: json['event_type'] ?? json['eventType'] as String?,
      images: _parseStringList(json['images'] ?? json['image']),
      totalSlots: json['total_slots'] ?? json['totalSlots'] as int?,
      remainingSlots: json['remaining_slots'] ?? json['remainingSlots'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      attendeeCount: json['attendee_count'] ?? json['attendeeCount'] ?? 0,
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      clickCount: json['click_count'] ?? json['clickCount'] ?? 0,
      userJoined: json['user_joined'] == true || json['userJoined'] == true,
      userSaved: json['user_saved'] == true || json['userSaved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'business_id': businessId,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'event_type': eventType,
      'images': images,
      'total_slots': totalSlots,
      'remaining_slots': remainingSlots,
      'price': price,
      'currency': currency,
      'attendee_count': attendeeCount,
      'view_count': viewCount,
      'click_count': clickCount,
      'user_joined': userJoined,
      'user_saved': userSaved,
    };
  }

  String get displayName => name ?? 'Event';

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  bool get isFree => price == null || price == 0;

  bool get isFull => remainingSlots == 0;

  String get priceText {
    if (isFree) return 'Free';
    return '${currency ?? '\$'}${price!.toStringAsFixed(2)}';
  }
}

/// Subscription status model
class SubscriptionStatus {
  final String? planId;
  final String? planName;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const SubscriptionStatus({
    this.planId,
    this.planName,
    this.status,
    this.startDate,
    this.endDate,
    this.isActive = false,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      planId: json['plan_id'] ?? json['planId'] as String?,
      planName: json['plan_name'] ?? json['planName'] as String?,
      status: json['status'] as String?,
      startDate: _parseDateTime(json['start_date'] ?? json['startDate']),
      endDate: _parseDateTime(json['end_date'] ?? json['endDate']),
      isActive: json['is_active'] == true || json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name': planName,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isExpired => endDate?.isBefore(DateTime.now()) ?? false;
}

/// Business analytics model
class BusinessAnalytics {
  final int totalViews;
  final int totalClicks;
  final int totalFollowers;
  final int totalEvents;
  final int totalAttendees;
  final List<TopEvent> topEvents;
  final Map<String, int> viewsByDay;

  const BusinessAnalytics({
    this.totalViews = 0,
    this.totalClicks = 0,
    this.totalFollowers = 0,
    this.totalEvents = 0,
    this.totalAttendees = 0,
    this.topEvents = const [],
    this.viewsByDay = const {},
  });

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) {
    return BusinessAnalytics(
      totalViews: json['total_views'] ?? json['totalViews'] ?? 0,
      totalClicks: json['total_clicks'] ?? json['totalClicks'] ?? 0,
      totalFollowers: json['total_followers'] ?? json['totalFollowers'] ?? 0,
      totalEvents: json['total_events'] ?? json['totalEvents'] ?? 0,
      totalAttendees: json['total_attendees'] ?? json['totalAttendees'] ?? 0,
      topEvents: _parseTopEvents(json['top_events'] ?? json['topEvents']),
      viewsByDay: _parseViewsByDay(json['views_by_day'] ?? json['viewsByDay']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_views': totalViews,
      'total_clicks': totalClicks,
      'total_followers': totalFollowers,
      'total_events': totalEvents,
      'total_attendees': totalAttendees,
      'top_events': topEvents.map((e) => e.toJson()).toList(),
      'views_by_day': viewsByDay,
    };
  }
}

/// Top event model for analytics
class TopEvent {
  final int? eventId;
  final String? name;
  final int views;
  final int clicks;
  final int attendees;

  const TopEvent({
    this.eventId,
    this.name,
    this.views = 0,
    this.clicks = 0,
    this.attendees = 0,
  });

  factory TopEvent.fromJson(Map<String, dynamic> json) {
    return TopEvent(
      eventId: json['event_id'] ?? json['eventId'] as int?,
      name: json['name'] as String?,
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
      attendees: json['attendees'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'name': name,
      'views': views,
      'clicks': clicks,
      'attendees': attendees,
    };
  }
}

/// Helper functions
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<TopEvent> _parseTopEvents(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => TopEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

Map<String, int> _parseViewsByDay(dynamic value) {
  if (value == null) return {};
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v as int? ?? 0));
  }
  return {};
}
