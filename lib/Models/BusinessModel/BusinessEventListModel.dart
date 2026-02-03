class BusinessEventListModel {
  String? message;
  List<Event>? currentEvents;
  List<Event>? upcomingEvents;
  List<Event>? pastEvents;
  List<Event>? expiredEvents;

  BusinessEventListModel({
    this.message,
    this.currentEvents,
    this.upcomingEvents,
    this.pastEvents,
    this.expiredEvents,
  });

  BusinessEventListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    currentEvents = (json['current_events'] as List?)?.map((e) => Event.fromJson(e)).toList() ?? [];
    upcomingEvents = (json['upcoming_events'] as List?)?.map((e) => Event.fromJson(e)).toList() ?? [];
    pastEvents = (json['past_events'] as List?)?.map((e) => Event.fromJson(e)).toList() ?? [];
    expiredEvents = (json['expired_events'] as List?)?.map((e) => Event.fromJson(e)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'current_events': currentEvents?.map((e) => e.toJson()).toList(),
      'upcoming_events': upcomingEvents?.map((e) => e.toJson()).toList(),
      'past_events': pastEvents?.map((e) => e.toJson()).toList(),
      'expired_events': expiredEvents?.map((e) => e.toJson()).toList(),
    };
  }
}

class Event {
  int? eventId;
  String? name;
  String? location;
  String? latitude;
  String? longitude;
  String? description;
  String? eventType;
  String? image;
  String? creatorImage;
  int? remainingSlots;
  int? totalSlots;
  DateTime? endTime;
  DateTime? dateTime;
  String? ticketingWebsite;
  String? eventPrivacy;
  List<Attendee>? attendees;

  Event({
    this.eventId,
    this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.eventType,
    this.image,
    this.creatorImage,
    this.remainingSlots,
    this.totalSlots,
    this.endTime,
    this.dateTime,
    this.ticketingWebsite,
    this.eventPrivacy,
    this.attendees,
  });

  Event.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    name = json['name'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    description = json['description'];
    eventType = json['event_type'];
    image = json['image'];
    creatorImage = json['creator_image'];
    remainingSlots = json['remaining_slots'];
    totalSlots = json['total_slots'];
    endTime = json['end_time'] != null ? DateTime.parse(json['end_time']) : null;
    dateTime = json['date_time'] != null ? DateTime.parse(json['date_time']) : null;
    ticketingWebsite = json['ticketing_website']?.trim(); // Trim to remove extra spaces or newline
    eventPrivacy = json['event_privacy'];
    attendees = (json['attendees'] as List?)?.map((e) => Attendee.fromJson(e)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'event_type': eventType,
      'image': image,
      'creator_image': creatorImage,
      'remaining_slots': remainingSlots,
      'total_slots': totalSlots,
      'end_time': endTime?.toIso8601String(),
      'date_time': dateTime?.toIso8601String(),
      'ticketing_website': ticketingWebsite,
      'event_privacy': eventPrivacy,
      'attendees': attendees?.map((e) => e.toJson()).toList(),
    };
  }
}


class Attendee {
  String? name;

  Attendee({this.name});

  Attendee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
