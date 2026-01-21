class LeaderBoardModel {
  bool? success;
  List<RankedUsers>? rankedUsers;

  LeaderBoardModel({this.success, this.rankedUsers});

  LeaderBoardModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['rankedUsers'] != null) {
      rankedUsers = <RankedUsers>[];
      json['rankedUsers'].forEach((v) {
        rankedUsers!.add(RankedUsers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (rankedUsers != null) {
      data['rankedUsers'] = rankedUsers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RankedUsers {
  int? rank;
  int? userId;
  String? name;
  List<String>? images;

  RankedUsers({this.rank, this.userId, this.name, this.images});

  RankedUsers.fromJson(Map<String, dynamic> json) {
    rank = json['rank'];
    userId = json['userId'];
    name = json['name'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rank'] = rank;
    data['userId'] = userId;
    data['name'] = name;
    data['images'] = images;
    return data;
  }
}
