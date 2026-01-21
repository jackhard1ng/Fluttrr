class profileModel {
  String? userName;
  int? userId;
  String? onlineStatus;
  Profile? profile;
  Activities? activities;
  int? completionPercentage;

  profileModel(
      {this.userName,
        this.userId,
        this.onlineStatus,
        this.profile,
        this.activities,
        this.completionPercentage});

  profileModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    onlineStatus = json['onlineStatus'];
    profile =
    json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    activities = json['activities'] != null
        ? Activities.fromJson(json['activities'])
        : null;
    completionPercentage = json['completionPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['userId'] = userId;
    data['onlineStatus'] = onlineStatus;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    if (activities != null) {
      data['activities'] = activities!.toJson();
    }
    data['completionPercentage'] = completionPercentage;
    return data;
  }
}

class Profile {
  int? age;
  String? status;
  String? gender;
  String? bio;
  List<String>? interests;
  List<String>? images;
  String? location;
  List<String>? coverImage; // ✅ Fixed here
  List<String>? language;

  Profile({
    this.age,
    this.status,
    this.gender,
    this.bio,
    this.interests,
    this.images,
    this.location,
    this.coverImage, // ✅ updated type
    this.language,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    status = json['status'];
    gender = json['gender'];
    bio = json['bio'];
    interests = json['interests'] != null ? List<String>.from(json['interests']) : [];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    location = json['location'];
    coverImage = json['coverImage'] != null ? List<String>.from(json['coverImage']) : []; // ✅ fixed
    language = json['Language'] != null ? List<String>.from(json['Language']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['status'] = status;
    data['gender'] = gender;
    data['bio'] = bio;
    data['interests'] = interests;
    data['images'] = images;
    data['location'] = location;
    data['coverImage'] = coverImage; // ✅ fixed
    data['Language'] = language;
    return data;
  }
}



class Activities {
  int? created;
  int? joined;

  Activities({this.created, this.joined});

  Activities.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    joined = json['joined'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created'] = created;
    data['joined'] = joined;
    return data;
  }
}
