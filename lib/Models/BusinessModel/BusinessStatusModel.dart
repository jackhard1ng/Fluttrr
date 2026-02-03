class BusinessstatusModel {
  bool? success;
  bool? hasBusinessProfile;

  BusinessstatusModel({this.success, this.hasBusinessProfile});

  BusinessstatusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    hasBusinessProfile = json['hasBusinessProfile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['hasBusinessProfile'] = hasBusinessProfile;
    return data;
  }
}
