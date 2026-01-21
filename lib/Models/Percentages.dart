class Percentage {
  int? completionPercentage;

  Percentage({this.completionPercentage});

  Percentage.fromJson(Map<String, dynamic> json) {
    completionPercentage = json['completionPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['completionPercentage'] = completionPercentage;
    return data;
  }
}
