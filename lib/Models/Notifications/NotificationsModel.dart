class NotificationsModel {
  bool? success;
  List<Notifications>? notifications;

  NotificationsModel({this.success, this.notifications});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (notifications != null) {
      data['notifications'] =
          notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notifications {
  int? id;
  String? message;
  bool? isSeen;
  String? createdAt;

  Notifications({this.id, this.message, this.isSeen, this.createdAt});

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    isSeen = json['isSeen'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['isSeen'] = isSeen;
    data['createdAt'] = createdAt;
    return data;
  }
}
