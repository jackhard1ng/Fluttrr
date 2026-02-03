class GetTickets {
  bool? success;
  List<Data>? data;

  GetTickets({this.success, this.data});

  GetTickets.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userID;
  String? complaintType;
  String? description;
  String? date;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? user;

  Data(
      {this.id,
        this.userID,
        this.complaintType,
        this.description,
        this.date,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.user});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userID = json['userID'];
    complaintType = json['complaint_type'];
    description = json['description'];
    date = json['date'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userID'] = userID;
    data['complaint_type'] = complaintType;
    data['description'] = description;
    data['date'] = date;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (user != null) {
      data['User'] = user!.toJson();
    }
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
