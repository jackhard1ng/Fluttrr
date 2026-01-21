class TotalMatchListModel {
  bool? success;
  String? message;
  List<LikedMates>? likedMates;

  TotalMatchListModel({this.success, this.message, this.likedMates});

  TotalMatchListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['likedMates'] != null) {
      likedMates = <LikedMates>[];
      json['likedMates'].forEach((v) {
        likedMates!.add(LikedMates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (likedMates != null) {
      data['likedMates'] = likedMates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LikedMates {
  int? id;
  int? likerId;
  int? likedId;
  String? createdAt;
  Liked? liked;

  LikedMates({this.id, this.likerId, this.likedId, this.createdAt, this.liked});

  LikedMates.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    likerId = json['likerId'];
    likedId = json['likedId'];
    createdAt = json['createdAt'];
    liked = json['liked'] != null ? Liked.fromJson(json['liked']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['likerId'] = likerId;
    data['likedId'] = likedId;
    data['createdAt'] = createdAt;
    if (liked != null) {
      data['liked'] = liked!.toJson();
    }
    return data;
  }
}

class Liked {
  int? userID;
  String? userName;
  String? email;
  bool? onlineStatus;
  UserProfile? userProfile;

  Liked(
      {this.userID,
        this.userName,
        this.email,
        this.onlineStatus,
        this.userProfile});

  Liked.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    onlineStatus = json['onlineStatus'];
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['userName'] = userName;
    data['email'] = email;
    data['onlineStatus'] = onlineStatus;
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    return data;
  }
}

class UserProfile {
  List<String>? interests;
  String? status;
  List<String>? images;
  int? age;

  UserProfile({this.interests, this.status, this.images, this.age});

  UserProfile.fromJson(Map<String, dynamic> json) {
    interests = json['interests'].cast<String>();
    status = json['status'];
    images = json['images'].cast<String>();
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['interests'] = interests;
    data['status'] = status;
    data['images'] = images;
    data['age'] = age;
    return data;
  }
}
