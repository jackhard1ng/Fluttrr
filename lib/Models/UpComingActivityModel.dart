class UpComingActivitiesModel {
  List<Activities>? activities;

  UpComingActivitiesModel({this.activities});

  UpComingActivitiesModel.fromJson(Map<String, dynamic> json) {
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(Activities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (activities != null) {
      data['activities'] = activities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Activities {
  int? activityID;
  String? name;
  String? dateTime;
  List<int>? participants;
  List<String>? images;
  String? location;
  String? description;
  String? totalTime;
  int? slots;
  int? totalSlots;
  List<int>? savedBy;
  bool? joined;
  List<String>? creatorImage; // ✅ Add this line

  Activities({
    this.activityID,
    this.name,
    this.dateTime,
    this.participants,
    this.images,
    this.location,
    this.description,
    this.totalTime,
    this.slots,
    this.totalSlots,
    this.savedBy,
    this.joined,
    this.creatorImage, // ✅ Add this line
  });

  Activities.fromJson(Map<String, dynamic> json) {
    activityID = json['activityID'];
    name = json['name'];
    dateTime = json['date_time'];
    participants = json['participants']?.cast<int>();
    images = json['images']?.cast<String>();
    location = json['location'];
    description = json['description'];
    totalTime = json['total_time'];
    slots = json['slots'];
    totalSlots = json['totalSlots'];
    savedBy = json['saved_by']?.cast<int>();
    joined = json['joined'];
    creatorImage = json['creatorImage']?.cast<String>(); // ✅ Add this line
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['activityID'] = activityID;
    data['name'] = name;
    data['date_time'] = dateTime;
    data['participants'] = participants;
    data['images'] = images;
    data['location'] = location;
    data['description'] = description;
    data['total_time'] = totalTime;
    data['slots'] = slots;
    data['totalSlots'] = totalSlots;
    data['saved_by'] = savedBy;
    data['joined'] = joined;
    data['creatorImage'] = creatorImage; // ✅ Add this line
    return data;
  }
}

