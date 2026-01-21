class privacyModel {
  String? message;
  Privacy? privacy;

  privacyModel({this.message, this.privacy});

  privacyModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    privacy =
    json['privacy'] != null ? Privacy.fromJson(json['privacy']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (privacy != null) {
      data['privacy'] = privacy!.toJson();
    }
    return data;
  }
}

class Privacy {
  bool? traveller;
  bool? local;
  bool? male;
  bool? female;
  bool? nonBinary;
  bool? everyone;
  bool? privateMode;
  int? ageRangeMin;
  int? ageRangeMax;

  Privacy(
      {this.traveller,
        this.local,
        this.male,
        this.female,
        this.nonBinary,
        this.everyone,
        this.privateMode,
        this.ageRangeMin,
        this.ageRangeMax});

  Privacy.fromJson(Map<String, dynamic> json) {
    traveller = json['traveller'];
    local = json['local'];
    male = json['male'];
    female = json['female'];
    nonBinary = json['non_binary'];
    everyone = json['everyone'];
    privateMode = json['private_mode'];
    ageRangeMin = json['age_range_min'];
    ageRangeMax = json['age_range_max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['traveller'] = traveller;
    data['local'] = local;
    data['male'] = male;
    data['female'] = female;
    data['non_binary'] = nonBinary;
    data['everyone'] = everyone;
    data['private_mode'] = privateMode;
    data['age_range_min'] = ageRangeMin;
    data['age_range_max'] = ageRangeMax;
    return data;
  }
}
