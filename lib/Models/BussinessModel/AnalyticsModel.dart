class AnalyticsModel {
  String? message;
  Analytics? analytics;

  AnalyticsModel({this.message, this.analytics});

  AnalyticsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    analytics = json['analytics'] != null
        ? Analytics.fromJson(json['analytics'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (analytics != null) {
      data['analytics'] = analytics!.toJson();
    }
    return data;
  }
}

class Analytics {
  Total? total;
  Total? daily;
  Total? weekly;
  Total? monthly;

  Analytics({this.total, this.daily, this.weekly, this.monthly});

  Analytics.fromJson(Map<String, dynamic> json) {
    total = json['total'] != null ? Total.fromJson(json['total']) : null;
    daily = json['daily'] != null ? Total.fromJson(json['daily']) : null;
    weekly = json['weekly'] != null ? Total.fromJson(json['weekly']) : null;
    monthly =
    json['monthly'] != null ? Total.fromJson(json['monthly']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (total != null) {
      data['total'] = total!.toJson();
    }
    if (daily != null) {
      data['daily'] = daily!.toJson();
    }
    if (weekly != null) {
      data['weekly'] = weekly!.toJson();
    }
    if (monthly != null) {
      data['monthly'] = monthly!.toJson();
    }
    return data;
  }
}

class Total {
  int? views;
  int? clicks;
  int? joins;
  int? followers;

  Total({this.views, this.clicks, this.joins, this.followers});

  Total.fromJson(Map<String, dynamic> json) {
    views = json['views'];
    clicks = json['clicks'];
    joins = json['joins'];
    followers = json['followers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['views'] = views;
    data['clicks'] = clicks;
    data['joins'] = joins;
    data['followers'] = followers;
    return data;
  }
}
