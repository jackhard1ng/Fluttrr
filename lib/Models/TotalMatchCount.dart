class TotalMatchCount {
  int? totalMates;

  TotalMatchCount({this.totalMates});

  TotalMatchCount.fromJson(Map<String, dynamic> json) {
    totalMates = json['totalMates'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalMates'] = totalMates;
    return data;
  }
}
