class ViewByDistanceModel {
  bool? success;
  List<Users>? users;

  ViewByDistanceModel({this.success, this.users});

  ViewByDistanceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? profileID;
  int? userID;
  List<String>? images;
  String? bio;
  String? gender;
  List<String>? interests;
  String? latitude;
  String? longitude;
  User? user;
  String? distance;

  Users(
      {this.profileID,
        this.userID,
        this.images,
        this.bio,
        this.gender,
        this.interests,
        this.latitude,
        this.longitude,
        this.user,
        this.distance});

  Users.fromJson(Map<String, dynamic> json) {
    profileID = json['profileID'];
    userID = json['userID'];
    images = json['images'].cast<String>();
    bio = json['bio'];
    gender = json['gender'];
    interests = json['interests'].cast<String>();
    latitude = json['latitude'];
    longitude = json['longitude'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profileID'] = profileID;
    data['userID'] = userID;
    data['images'] = images;
    data['bio'] = bio;
    data['gender'] = gender;
    data['interests'] = interests;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['distance'] = distance;
    return data;
  }
}

class User {
  String? userName;

  User({this.userName});

  User.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    return data;
  }
}
