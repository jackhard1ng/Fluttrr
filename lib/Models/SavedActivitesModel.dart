class SavedEventsResponse {
  String? message;
  List<Data>? data;

  SavedEventsResponse({this.message, this.data});

  SavedEventsResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
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
  int? id;
  String? name;
  String? location;
  double? latitude;
  double? longitude;
  String? description;
  String? dateTime;
  String? totalTime;
  String? eventType;
  List<String>? image;
  int? remainingSlots;
  int? totalSlots;
  List<Attendees>? attendees;
  bool? userJoined;
  Creator? creator;

  Data({
    this.id,
    this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.dateTime,
    this.totalTime,
    this.eventType,
    this.image,
    this.remainingSlots,
    this.totalSlots,
    this.attendees,
    this.userJoined,
    this.creator,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['activity_id'] ?? json['event_id'];
    name = json['name'];
    location = json['location'];
    latitude = (json['latitude'] ?? 0).toDouble();
    longitude = (json['longitude'] ?? 0).toDouble();
    description = json['description'];
    dateTime = json['date_time'];
    totalTime = json['total_time'];
    eventType = json['event_type'];
    image = json['image'] != null ? List<String>.from(json['image']) : [];
    remainingSlots = json['remaining_slots'];
    totalSlots = json['total_slots'];
    userJoined = json['user_joined'];

    if (json['attendees'] != null) {
      attendees = <Attendees>[];
      json['attendees'].forEach((v) {
        attendees!.add(Attendees.fromJson(v));
      });
    }

    creator =
    json['creator'] != null ? Creator.fromJson(json['creator']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (eventType != null) {
      data['event_id'] = id;
    } else {
      data['activity_id'] = id;
    }
    data['name'] = name;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['description'] = description;
    data['date_time'] = dateTime;
    data['total_time'] = totalTime;
    data['event_type'] = eventType;
    data['image'] = image;
    data['remaining_slots'] = remainingSlots;
    data['total_slots'] = totalSlots;
    data['user_joined'] = userJoined;
    if (attendees != null) {
      data['attendees'] = attendees!.map((v) => v.toJson()).toList();
    }
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    return data;
  }
}

class Attendees {
  int? userId;
  String? userName;
  List<String>? profileImage;

  Attendees({this.userId, this.userName, this.profileImage});

  Attendees.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    profileImage = json['profile_image'] != null
        ? List<String>.from(json['profile_image'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['profile_image'] = profileImage;
    return data;
  }
}

class Creator {
  int? userId;
  String? userName;
  List<String>? profileImage;

  Creator({this.userId, this.userName, this.profileImage});

  Creator.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    profileImage = json['profile_image'] != null
        ? List<String>.from(json['profile_image'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['profile_image'] = profileImage;
    return data;
  }
}
