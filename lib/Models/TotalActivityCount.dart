class TotalActivityCount {
  bool? success;
  String? message;
  int? totalActivitiesCreated;

  TotalActivityCount({this.success, this.message, this.totalActivitiesCreated});

  TotalActivityCount.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    totalActivitiesCreated = json['total_activities_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['total_activities_created'] = totalActivitiesCreated;
    return data;
  }
}
