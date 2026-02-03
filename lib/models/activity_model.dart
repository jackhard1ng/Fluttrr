/// Activity/Event model
class ActivityModel {
  final int? activityId;
  final int? eventId;
  final String? name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? dateTime;
  final String? eventType;
  final List<String> images;
  final int? totalSlots;
  final int? remainingSlots;
  final List<Attendee> attendees;
  final bool userJoined;
  final bool userSaved;
  final int? creatorId;
  final String? creatorName;
  final List<String> creatorImages;

  const ActivityModel({
    this.activityId,
    this.eventId,
    this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.dateTime,
    this.eventType,
    this.images = const [],
    this.totalSlots,
    this.remainingSlots,
    this.attendees = const [],
    this.userJoined = false,
    this.userSaved = false,
    this.creatorId,
    this.creatorName,
    this.creatorImages = const [],
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'] as int?,
      eventId: json['event_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dateTime: _parseDateTime(json['date_time']),
      eventType: json['event_type'] as String?,
      images: _parseStringList(json['image']),
      totalSlots: json['total_slots'] as int?,
      remainingSlots: json['remaining_slots'] as int?,
      attendees: _parseAttendees(json['attendees']),
      userJoined: json['user_joined'] == true,
      userSaved: json['user_saved'] == true,
      creatorId: json['creator_id'] as int?,
      creatorName: json['creator_name'] as String?,
      creatorImages: _parseStringList(json['creator_image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'event_id': eventId,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date_time': dateTime?.toIso8601String(),
      'event_type': eventType,
      'image': images,
      'total_slots': totalSlots,
      'remaining_slots': remainingSlots,
      'attendees': attendees.map((a) => a.toJson()).toList(),
      'user_joined': userJoined,
      'user_saved': userSaved,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_image': creatorImages,
    };
  }

  ActivityModel copyWith({
    int? activityId,
    int? eventId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    String? eventType,
    List<String>? images,
    int? totalSlots,
    int? remainingSlots,
    List<Attendee>? attendees,
    bool? userJoined,
    bool? userSaved,
    int? creatorId,
    String? creatorName,
    List<String>? creatorImages,
  }) {
    return ActivityModel(
      activityId: activityId ?? this.activityId,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
      eventType: eventType ?? this.eventType,
      images: images ?? this.images,
      totalSlots: totalSlots ?? this.totalSlots,
      remainingSlots: remainingSlots ?? this.remainingSlots,
      attendees: attendees ?? this.attendees,
      userJoined: userJoined ?? this.userJoined,
      userSaved: userSaved ?? this.userSaved,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorImages: creatorImages ?? this.creatorImages,
    );
  }

  // Computed properties
  int get id => activityId ?? eventId ?? 0;

  String get displayName => name ?? 'Untitled Activity';

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  int get attendeeCount => attendees.length;

  int get filledSlots => (totalSlots ?? 0) - (remainingSlots ?? 0);

  bool get isFull => remainingSlots == 0;

  bool get hasLocation => latitude != null && longitude != null;

  bool get isUpcoming => dateTime?.isAfter(DateTime.now()) ?? false;

  bool get isPast => dateTime?.isBefore(DateTime.now()) ?? false;
}

/// Activity attendee model
class Attendee {
  final int? userId;
  final String? name;
  final List<String> images;

  const Attendee({
    this.userId,
    this.name,
    this.images = const [],
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      userId: json['user_id'] as int?,
      name: json['name'] as String?,
      images: _parseStringList(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'images': images,
    };
  }

  String? get profileImage => images.isNotEmpty ? images.first : null;
}

/// Activity list response
class ActivityListResponse {
  final String? message;
  final List<ActivityModel> data;

  const ActivityListResponse({
    this.message,
    this.data = const [],
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    return ActivityListResponse(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Helper functions
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<Attendee> _parseAttendees(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => Attendee.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
