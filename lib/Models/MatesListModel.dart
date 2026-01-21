class MateListModel {
  String? message;
  List<Users>? users;

  MateListModel({this.message, this.users});

  MateListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? userID;
  String? userName;
  String? email;
  String? password;
  bool? verified;
  bool? onlineStatus;
  String? fcmToken;
  List<int>? blockedUsers;
  List<int>? likedActivities;
  String? createdAt;
  String? updatedAt;
  UserProfile? userProfile;

  Users(
      {this.userID,
        this.userName,
        this.email,
        this.password,
        this.verified,
        this.onlineStatus,
        this.fcmToken,
        this.blockedUsers,
        this.likedActivities,
        this.createdAt,
        this.updatedAt,
        this.userProfile});

  Users.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    verified = json['verified'];
    onlineStatus = json['onlineStatus'];
    fcmToken = json['fcmToken'];
    blockedUsers = json['blockedUsers'].cast<int>();
    likedActivities = json['likedActivities'].cast<int>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['userName'] = userName;
    data['email'] = email;
    data['password'] = password;
    data['verified'] = verified;
    data['onlineStatus'] = onlineStatus;
    data['fcmToken'] = fcmToken;
    data['blockedUsers'] = blockedUsers;
    data['likedActivities'] = likedActivities;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    return data;
  }
}

class UserProfile {
  List<String>? images;
  int? age;
  String? bio;
  List<String>? interests;
  String? longitude;
  String? latitude;

  UserProfile(
      {this.images,
        this.age,
        this.bio,
        this.interests,
        this.longitude,
        this.latitude});

  UserProfile.fromJson(Map<String, dynamic> json) {
    images = json['images'].cast<String>();
    age = json['age'];
    bio = json['bio'];
    interests = json['interests'].cast<String>();
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['images'] = images;
    data['age'] = age;
    data['bio'] = bio;
    data['interests'] = interests;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}
