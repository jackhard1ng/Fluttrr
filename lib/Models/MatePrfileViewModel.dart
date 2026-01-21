class MateProfileViewModel {
  String? message;
  User? user;
  Profile? profile;

  MateProfileViewModel({this.message, this.user, this.profile});

  MateProfileViewModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    profile =
    json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class User {
  String? userName;
  bool? onlineStatus;

  User({this.userName, this.onlineStatus});

  User.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    onlineStatus = json['onlineStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['onlineStatus'] = onlineStatus;
    return data;
  }
}

class Profile {
  int? age;
  String? gender;
  String? status;
  String? bio;
  List<String>? interests;
  List<String>? images;
  String? country;
  List<String>? language;
  String? countryFlag;
  Location? location;

  Profile(
      {this.age,
        this.gender,
        this.status,
        this.bio,
        this.interests,
        this.images,
        this.country,
        this.language,
        this.countryFlag,
        this.location});

  Profile.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    gender = json['gender'];
    status = json['status'];
    bio = json['bio'];
    interests = json['interests'].cast<String>();
    images = json['images'].cast<String>();
    country = json['country'];
    language = json['language'].cast<String>();
    countryFlag = json['countryFlag'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['gender'] = gender;
    data['status'] = status;
    data['bio'] = bio;
    data['interests'] = interests;
    data['images'] = images;
    data['country'] = country;
    data['language'] = language;
    data['countryFlag'] = countryFlag;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

class Location {
  String? longitude;
  String? latitude;

  Location({this.longitude, this.latitude});

  Location.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}
