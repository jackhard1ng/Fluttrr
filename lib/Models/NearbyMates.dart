class NearbyMates {
  String? message;
  List<Users>? users;

  NearbyMates({this.message, this.users});

  NearbyMates.fromJson(Map<String, dynamic> json) {
    try {
      message = json['message']?.toString();
      if (json['users'] != null && json['users'] is List) {
        users = (json['users'] as List).map((v) {
          if (v is Map<String, dynamic>) {
            return Users.fromJson(v);
          }
          return Users(); // fallback
        }).toList();
      }
    } catch (e) {
      print('Error parsing NearbyMates: $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
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
  String? countryFlag;
  String? gender;
  List<String>? interests;
  String? latitude;
  String? longitude;
  String? status;
  int? age;
  User? user;
  String? distance;
  bool? hasLiked;

  Users({
    this.profileID,
    this.userID,
    this.images,
    this.bio,
    this.countryFlag,
    this.gender,
    this.interests,
    this.latitude,
    this.longitude,
    this.status,
    this.age,
    this.user,
    this.distance,
    this.hasLiked = false,
  });

  Users.fromJson(Map<String, dynamic> json) {
    try {
      profileID = _toInt(json['profileID']);
      userID = _toInt(json['userID']);
      images = _toStringList(json['images']);
      bio = json['bio']?.toString();
      countryFlag = json['countryFlag']?.toString();
      gender = json['gender']?.toString();
      interests = _toStringList(json['interests']);
      latitude = json['latitude']?.toString();
      longitude = json['longitude']?.toString();
      status = json['status']?.toString();
      age = _toInt(json['age']);
      user = json['User'] is Map<String, dynamic> ? User.fromJson(json['User']) : null;
      distance = json['distance']?.toString();
      hasLiked = json['hasLiked'] is bool ? json['hasLiked'] : false;
    } catch (e) {
      print('Error parsing Users: $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['profileID'] = profileID;
    data['userID'] = userID;
    data['images'] = images;
    data['bio'] = bio;
    data['countryFlag'] = countryFlag;
    data['gender'] = gender;
    data['interests'] = interests;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['age'] = age;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['distance'] = distance;
    data['hasLiked'] = hasLiked;
    return data;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<String>? _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }
}

class User {
  String? userName;

  User({this.userName});

  User.fromJson(Map<String, dynamic> json) {
    try {
      userName = json['userName']?.toString();
    } catch (e) {
      print('Error parsing User: $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userName'] = userName;
    return data;
  }
}
