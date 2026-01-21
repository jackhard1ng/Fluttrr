class MatesFilterModel {
  String? message;
  List<Mates>? mates;

  MatesFilterModel({this.message, this.mates});

  MatesFilterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    mates = (json['mates'] as List?)?.map((v) => Mates.fromJson(v)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'mates': mates?.map((v) => v.toJson()).toList() ?? [],
    };
  }
}

class Mates {
  int? userID;
  String? userName;
  String? email;
  String? password;
  bool? verified;
  bool? onlineStatus;
  String? fcmToken;
  List<dynamic>? blockedUsers;
  List<dynamic>? likedActivities;
  String? createdAt;
  String? updatedAt;
  UserProfile? userProfile;
  bool hasLiked;

  Mates({
    this.userID,
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
    this.userProfile,
    this.hasLiked = false, // Default value to prevent null errors
  });

  Mates.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        userName = json['userName'],
        email = json['email'],
        password = json['password'],
        verified = json['verified'],
        onlineStatus = json['onlineStatus'],
        fcmToken = json['fcmToken'],
        blockedUsers = json['blockedUsers'] ?? [],
        likedActivities = json['likedActivities'] ?? [],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        userProfile = json['userProfile'] != null ? UserProfile.fromJson(json['userProfile']) : null,
        hasLiked = json['hasLiked'] ?? false; // Handle missing value safely

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'email': email,
      'password': password,
      'verified': verified,
      'onlineStatus': onlineStatus,
      'fcmToken': fcmToken,
      'blockedUsers': blockedUsers ?? [],
      'likedActivities': likedActivities ?? [],
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userProfile': userProfile?.toJson(),
      'hasLiked': hasLiked,
    };
  }
}

class UserProfile {
  List<String>? images;
  int? age;
  String? gender;
  String? bio;
  List<String>? interests;
  String? longitude;
  String? latitude;
  String? countryFlag;
  String? country;

  UserProfile(
      {this.images,
        this.age,
        this.gender,
        this.bio,
        this.interests,
        this.longitude,
        this.latitude,
        this.countryFlag,
        this.country});

  UserProfile.fromJson(Map<String, dynamic> json) {
    images = json['images'].cast<String>();
    age = json['age'];
    gender = json['gender'];
    bio = json['bio'];
    interests = json['interests'].cast<String>();
    longitude = json['longitude'];
    latitude = json['latitude'];
    countryFlag = json['countryFlag'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['images'] = images;
    data['age'] = age;
    data['gender'] = gender;
    data['bio'] = bio;
    data['interests'] = interests;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['countryFlag'] = countryFlag;
    data['country'] = country;
    return data;
  }
}
