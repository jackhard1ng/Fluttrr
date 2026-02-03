class MYEventsDetailsModel {
  String? message;
  Data? data;

  MYEventsDetailsModel({this.message, this.data});

  factory MYEventsDetailsModel.fromJson(Map<String, dynamic> json) {
    return MYEventsDetailsModel(
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  int? eventId;
  String? name;
  String? dateTime;
  String? endTime;
  String? location;
  String? latitude;
  String? longitude;
  String? description;
  String? eventType;
  String? image;
  int? remainingSlots;
  int? totalSlots;
  List<Attendees>? attendees;
  List<Comments>? comments;

  Data({
    this.eventId,
    this.name,
    this.dateTime,
    this.endTime,
    this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.eventType,
    this.image,
    this.remainingSlots,
    this.totalSlots,
    this.attendees,
    this.comments,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      eventId: json['event_id'],
      name: json['name'],
      dateTime: json['date_time'], // Added this
      endTime: json['end_time'], // Added this
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      eventType: json['event_type'],
      image: json['image'],
      remainingSlots: json['remaining_slots'],
      totalSlots: json['total_slots'],
      attendees: (json['attendees'] as List?)?.map((e) => Attendees.fromJson(e)).toList() ?? [],
      comments: (json['comments'] as List?)?.map((e) => Comments.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'name': name,
      'date_time': dateTime, // Added this
      'end_time': endTime, // Added this
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'event_type': eventType,
      'image': image,
      'remaining_slots': remainingSlots,
      'total_slots': totalSlots,
      'attendees': attendees?.map((e) => e.toJson()).toList() ?? [],
      'comments': comments?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}


class Attendees {
  int? userId;
  String? name;
  List<String>? images;

  Attendees({this.userId, this.name, this.images});

  factory Attendees.fromJson(Map<String, dynamic> json) {
    return Attendees(
      userId: json['user_id'],
      name: json['name'],
      images: (json['images'] as List?)?.cast<String>(), // Safe casting
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'images': images,
    };
  }
}

class Comments {
  int? commentId;
  int? userId;
  String? userName;
  List<String>? userImage;
  String? content;
  String? createdAt;
  int? parentCommentId;
  List<dynamic>? replies; // Changed from `List<Null>?` to `List<dynamic>?`

  Comments({
    this.commentId,
    this.userId,
    this.userName,
    this.userImage,
    this.content,
    this.createdAt,
    this.parentCommentId,
    this.replies,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      commentId: json['comment_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userImage: (json['user_image'] as List?)?.cast<String>(), // Safe casting
      content: json['content'],
      createdAt: json['created_at'],
      parentCommentId: json['parent_comment_id'],
      replies: json['replies'] as List<dynamic>?, // Directly assigning dynamic list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'content': content,
      'created_at': createdAt,
      'parent_comment_id': parentCommentId,
      'replies': replies,
    };
  }
}
