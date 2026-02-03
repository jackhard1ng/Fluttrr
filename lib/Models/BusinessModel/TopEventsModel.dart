class TopEventModel {
  String? message;
  List<Data>? data;

  TopEventModel({this.message, this.data});

  TopEventModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? eventId;
  String? name;
  String? location;
  String? latitude;
  String? longitude;
  String? description;
  String? eventType;
  String? image;
  int? remainingSlots;
  int? totalSlots;
  int? monthlyViews;
  List<dynamic>? attendees; // You may replace 'dynamic' with a specific type if applicable

  Data({
    this.eventId,
    this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.eventType,
    this.image,
    this.remainingSlots,
    this.totalSlots,
    this.monthlyViews,
    this.attendees,
  });

  Data.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    name = json['name'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    description = json['description'];
    eventType = json['event_type'];
    image = json['image'];
    remainingSlots = json['remaining_slots'];
    totalSlots = json['total_slots'];
    monthlyViews = json['monthlyViews'];

    if (json['attendees'] != null) {
      attendees = List<dynamic>.from(json['attendees']);
    } else {
      attendees = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['event_id'] = eventId;
    data['name'] = name;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['description'] = description;
    data['event_type'] = eventType;
    data['image'] = image;
    data['remaining_slots'] = remainingSlots;
    data['total_slots'] = totalSlots;
    data['monthlyViews'] = monthlyViews;
    data['attendees'] = attendees;
    return data;
  }
}
