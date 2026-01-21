class JoinedActivitesModel {
  bool? success;
  String? message;
  List<Activities>? activities;

  JoinedActivitesModel({this.success, this.message, this.activities});

  JoinedActivitesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(Activities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (activities != null) {
      data['activities'] = activities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Activities {
  int? activityId;
  String? name;
  String? location;
  String? description;
  String? dateTime;
  int? remainingSlots;
  int? slot;
  List<String>? image;
  List<Attendees>? attendees;

  Activities(
      {this.activityId,
        this.name,
        this.location,
        this.description,
        this.dateTime,
        this.remainingSlots,
        this.slot,
        this.image,
        this.attendees});

  Activities.fromJson(Map<String, dynamic> json) {
    activityId = json['activity_id'];
    name = json['name'];
    location = json['location'];
    description = json['description'];
    dateTime = json['date_time'];
    remainingSlots = json['remaining_slots'];
    slot = json['slot'];
    image = json['image'].cast<String>();
    if (json['attendees'] != null) {
      attendees = <Attendees>[];
      json['attendees'].forEach((v) {
        attendees!.add(Attendees.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activity_id'] = activityId;
    data['name'] = name;
    data['location'] = location;
    data['description'] = description;
    data['date_time'] = dateTime;
    data['remaining_slots'] = remainingSlots;
    data['slot'] = slot;
    data['image'] = image;
    if (attendees != null) {
      data['attendees'] = attendees!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attendees {
  int? userId;
  String? name;
  List<String>? images;

  Attendees({this.userId, this.name, this.images});

  Attendees.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['images'] = images;
    return data;
  }
}
