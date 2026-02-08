/// Business page model
class BusinessModel {
  final int? businessId;
  final String? businessName;
  final String? name;
  final String? email;
  final String? phone;
  final String? description;
  final String? category;
  final String? address;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? website;
  final String? facebook;
  final String? instagram;
  final List<String> images;
  final String? profileImage;
  final String? coverImage;
  final bool isVerified;
  final int followerCount;
  final int eventCount;
  final bool isFollowing;
  final SubscriptionStatus? subscriptionStatus;

  const BusinessModel({
    this.businessId,
    this.businessName,
    this.name,
    this.email,
    this.phone,
    this.description,
    this.category,
    this.address,
    this.location,
    this.latitude,
    this.longitude,
    this.website,
    this.facebook,
    this.instagram,
    this.images = const [],
    this.profileImage,
    this.coverImage,
    this.isVerified = false,
    this.followerCount = 0,
    this.eventCount = 0,
    this.isFollowing = false,
    this.subscriptionStatus,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: (json['business_id'] ?? json['businessId']) as int?,
      businessName: (json['business_name'] ?? json['businessName']) as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      website: json['website'] as String?,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      images: _parseStringList(json['images']),
      profileImage: (json['profile_image'] ?? json['profileImage']) as String?,
      coverImage: (json['cover_image'] ?? json['coverImage']) as String?,
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      followerCount: (json['follower_count'] ?? json['followerCount'] ?? 0) as int,
      eventCount: (json['event_count'] ?? json['eventCount'] ?? 0) as int,
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
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'category': category,
      'address': address,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'images': images,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'is_verified': isVerified,
      'follower_count': followerCount,
      'event_count': eventCount,
      'is_following': isFollowing,
      'subscription_status': subscriptionStatus?.toJson(),
    };
  }

  String get displayName => name ?? businessName ?? 'Business';
}

/// Business event model
class BusinessEvent {
  final int? id;
  final int? eventId;
  final int? businessId;
  final String? name;
  final String? description;
  final String? location;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? eventType;
  final String? privacy;
  final String? image;
  final List<String> images;
  final int? totalSlots;
  final int? maxAttendees;
  final int? remainingSlots;
  final double? price;
  final String? currency;
  final String? ticketUrl;
  final int? attendeesCount;
  final int? views;
  final int? clicks;
  final int? saves;
  final bool userJoined;
  final bool userSaved;

  const BusinessEvent({
    this.id,
    this.eventId,
    this.businessId,
    this.name,
    this.description,
    this.location,
    this.locationName,
    this.latitude,
    this.longitude,
    this.startDate,
    this.endDate,
    this.eventType,
    this.privacy,
    this.image,
    this.images = const [],
    this.totalSlots,
    this.maxAttendees,
    this.remainingSlots,
    this.price,
    this.currency,
    this.ticketUrl,
    this.attendeesCount,
    this.views,
    this.clicks,
    this.saves,
    this.userJoined = false,
    this.userSaved = false,
  });

  factory BusinessEvent.fromJson(Map<String, dynamic> json) {
    return BusinessEvent(
      id: json['id'] as int?,
      eventId: (json['event_id'] ?? json['eventId']) as int?,
      businessId: (json['business_id'] ?? json['businessId']) as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      locationName: (json['location_name'] ?? json['locationName']) as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startDate: _parseDateTime(json['start_date'] ?? json['startDate'] ?? json['start_time'] ?? json['startTime']),
      endDate: _parseDateTime(json['end_date'] ?? json['endDate'] ?? json['end_time'] ?? json['endTime']),
      eventType: (json['event_type'] ?? json['eventType']) as String?,
      privacy: json['privacy'] as String?,
      image: json['image'] as String?,
      images: _parseStringList(json['images']),
      totalSlots: (json['total_slots'] ?? json['totalSlots']) as int?,
      maxAttendees: (json['max_attendees'] ?? json['maxAttendees']) as int?,
      remainingSlots: (json['remaining_slots'] ?? json['remainingSlots']) as int?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      ticketUrl: (json['ticket_url'] ?? json['ticketUrl']) as String?,
      attendeesCount: (json['attendees_count'] ?? json['attendeesCount'] ?? json['attendee_count'] ?? json['attendeeCount']) as int?,
      views: (json['views'] ?? json['view_count'] ?? json['viewCount']) as int?,
      clicks: (json['clicks'] ?? json['click_count'] ?? json['clickCount']) as int?,
      saves: (json['saves'] ?? json['save_count'] ?? json['saveCount']) as int?,
      userJoined: json['user_joined'] == true || json['userJoined'] == true,
      userSaved: json['user_saved'] == true || json['userSaved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'business_id': businessId,
      'name': name,
      'description': description,
      'location': location,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'event_type': eventType,
      'privacy': privacy,
      'image': image,
      'images': images,
      'total_slots': totalSlots,
      'max_attendees': maxAttendees,
      'remaining_slots': remainingSlots,
      'price': price,
      'currency': currency,
      'ticket_url': ticketUrl,
      'attendees_count': attendeesCount,
      'views': views,
      'clicks': clicks,
      'saves': saves,
      'user_joined': userJoined,
      'user_saved': userSaved,
    };
  }

  String get displayName => name ?? 'Event';

  String? get primaryImage => image ?? (images.isNotEmpty ? images.first : null);

  bool get isFree => eventType == 'Free' || price == null || price == 0;

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
  final DateTime? expiryDate;
  final bool isActive;

  const SubscriptionStatus({
    this.planId,
    this.planName,
    this.status,
    this.startDate,
    this.expiryDate,
    this.isActive = false,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      planId: (json['plan_id'] ?? json['planId']) as String?,
      planName: (json['plan_name'] ?? json['planName']) as String?,
      status: json['status'] as String?,
      startDate: _parseDateTime(json['start_date'] ?? json['startDate']),
      expiryDate: _parseDateTime(json['expiry_date'] ?? json['expiryDate'] ?? json['end_date'] ?? json['endDate']),
      isActive: json['is_active'] == true || json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name': planName,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isExpired => expiryDate?.isBefore(DateTime.now()) ?? false;
}

/// Business analytics model
class BusinessAnalytics {
  final int totalViews;
  final int totalClicks;
  final int totalFollowers;
  final int totalEvents;
  final int totalAttendees;
  final double? viewRate;
  final double? clickRate;
  final double? conversionRate;
  final int? followers;
  final double? followersGrowth;
  final int? eventsCreatedThisPeriod;
  final double? eventsGrowth;
  final int? totalEngagement;
  final double? engagementGrowth;
  final List<TopEvent> topEvents;
  final Map<String, int> viewsByDay;

  const BusinessAnalytics({
    this.totalViews = 0,
    this.totalClicks = 0,
    this.totalFollowers = 0,
    this.totalEvents = 0,
    this.totalAttendees = 0,
    this.viewRate,
    this.clickRate,
    this.conversionRate,
    this.followers,
    this.followersGrowth,
    this.eventsCreatedThisPeriod,
    this.eventsGrowth,
    this.totalEngagement,
    this.engagementGrowth,
    this.topEvents = const [],
    this.viewsByDay = const {},
  });

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) {
    return BusinessAnalytics(
      totalViews: (json['total_views'] ?? json['totalViews'] ?? 0) as int,
      totalClicks: (json['total_clicks'] ?? json['totalClicks'] ?? 0) as int,
      totalFollowers: (json['total_followers'] ?? json['totalFollowers'] ?? 0) as int,
      totalEvents: (json['total_events'] ?? json['totalEvents'] ?? 0) as int,
      totalAttendees: (json['total_attendees'] ?? json['totalAttendees'] ?? 0) as int,
      viewRate: ((json['view_rate'] ?? json['viewRate']) as num?)?.toDouble(),
      clickRate: ((json['click_rate'] ?? json['clickRate']) as num?)?.toDouble(),
      conversionRate: ((json['conversion_rate'] ?? json['conversionRate']) as num?)?.toDouble(),
      followers: json['followers'] as int?,
      followersGrowth: ((json['followers_growth'] ?? json['followersGrowth']) as num?)?.toDouble(),
      eventsCreatedThisPeriod: (json['events_created_this_period'] ?? json['eventsCreatedThisPeriod']) as int?,
      eventsGrowth: ((json['events_growth'] ?? json['eventsGrowth']) as num?)?.toDouble(),
      totalEngagement: (json['total_engagement'] ?? json['totalEngagement']) as int?,
      engagementGrowth: ((json['engagement_growth'] ?? json['engagementGrowth']) as num?)?.toDouble(),
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
      'view_rate': viewRate,
      'click_rate': clickRate,
      'conversion_rate': conversionRate,
      'followers': followers,
      'followers_growth': followersGrowth,
      'events_created_this_period': eventsCreatedThisPeriod,
      'events_growth': eventsGrowth,
      'total_engagement': totalEngagement,
      'engagement_growth': engagementGrowth,
      'top_events': topEvents.map((e) => e.toJson()).toList(),
      'views_by_day': viewsByDay,
    };
  }
}

/// Top event model for analytics
class TopEvent {
  final int? eventId;
  final String? name;
  final int? views;
  final int? clicks;
  final int? attendees;

  const TopEvent({
    this.eventId,
    this.name,
    this.views,
    this.clicks,
    this.attendees,
  });

  factory TopEvent.fromJson(Map<String, dynamic> json) {
    return TopEvent(
      eventId: (json['event_id'] ?? json['eventId']) as int?,
      name: json['name'] as String?,
      views: json['views'] as int?,
      clicks: json['clicks'] as int?,
      attendees: json['attendees'] as int?,
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
