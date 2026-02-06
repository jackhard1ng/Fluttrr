import 'package:flutter/material.dart';

/// Event model
class EventModel {
  final String id;
  final String title;
  final String? description;
  final String hostId;
  final String hostName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String location;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final int maxAttendees;
  final int currentAttendees;
  final List<String> categories;
  final List<String> tags;
  final String? vibe;
  final bool isPrivate;
  final bool isFeatured;
  final String? emoji;
  final String? imageUrl;
  final EventStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.hostId,
    required this.hostName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.location,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.maxAttendees = 20,
    this.currentAttendees = 0,
    this.categories = const [],
    this.tags = const [],
    this.vibe,
    this.isPrivate = false,
    this.isFeatured = false,
    this.emoji,
    this.imageUrl,
    this.status = EventStatus.upcoming,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isFull => currentAttendees >= maxAttendees;
  int get spotsLeft => maxAttendees - currentAttendees;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      hostId: json['host_id'] ?? '',
      hostName: json['host_name'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: _parseTime(json['start_time']),
      endTime: json['end_time'] != null ? _parseTime(json['end_time']) : null,
      location: json['location'] ?? '',
      locationAddress: json['location_address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      maxAttendees: json['max_attendees'] ?? 20,
      currentAttendees: json['current_attendees'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      vibe: json['vibe'],
      isPrivate: json['is_private'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      emoji: json['emoji'],
      imageUrl: json['image_url'],
      status: EventStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'host_id': hostId,
      'host_name': hostName,
      'date': date.toIso8601String(),
      'start_time': '${startTime.hour}:${startTime.minute}',
      'end_time': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
      'location': location,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'categories': categories,
      'tags': tags,
      'vibe': vibe,
      'is_private': isPrivate,
      'is_featured': isFeatured,
      'emoji': emoji,
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    int? maxAttendees,
    int? currentAttendees,
    List<String>? categories,
    List<String>? tags,
    String? vibe,
    bool? isPrivate,
    EventStatus? status,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId,
      hostName: hostName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      locationAddress: locationAddress,
      latitude: latitude,
      longitude: longitude,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      vibe: vibe ?? this.vibe,
      isPrivate: isPrivate ?? this.isPrivate,
      isFeatured: isFeatured,
      emoji: emoji,
      imageUrl: imageUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

/// Event attendee
class EventAttendee {
  final String id;
  final String userId;
  final String userName;
  final String eventId;
  final RsvpStatus rsvpStatus;
  final ArrivalStatus? arrivalStatus;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final bool hasPlusOne;
  final String? plusOneName;
  final DateTime createdAt;

  EventAttendee({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventId,
    this.rsvpStatus = RsvpStatus.going,
    this.arrivalStatus,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.hasPlusOne = false,
    this.plusOneName,
    required this.createdAt,
  });

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      eventId: json['event_id'] ?? '',
      rsvpStatus: RsvpStatus.values.firstWhere(
        (s) => s.name == json['rsvp_status'],
        orElse: () => RsvpStatus.going,
      ),
      arrivalStatus: json['arrival_status'] != null
          ? ArrivalStatus.values.firstWhere(
              (s) => s.name == json['arrival_status'],
            )
          : null,
      isCheckedIn: json['is_checked_in'] ?? false,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'])
          : null,
      hasPlusOne: json['has_plus_one'] ?? false,
      plusOneName: json['plus_one_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum RsvpStatus {
  going,
  maybe,
  notGoing,
}

enum ArrivalStatus {
  early,
  onTime,
  late,
}

/// Saved event
class SavedEvent {
  final String id;
  final String userId;
  final String eventId;
  final DateTime savedAt;

  SavedEvent({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.savedAt,
  });
}
