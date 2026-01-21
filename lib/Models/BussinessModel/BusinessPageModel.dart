class BusinessPageModel {
  String? message;
  Profile? profile;
  int? totalEventsCreated;
  bool? isPremium;

  BusinessPageModel(
      {this.message, this.profile, this.totalEventsCreated, this.isPremium});

  BusinessPageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profile =
    json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    totalEventsCreated = json['totalEventsCreated'];
    isPremium = json['isPremium'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    data['totalEventsCreated'] = totalEventsCreated;
    data['isPremium'] = isPremium;
    return data;
  }
}

class Profile {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  Null location;
  String? websiteLink;
  String? facebookLink;
  String? instagramLink;
  String? logo;
  String? image;
  String? description;

  Profile(
      {this.id,
        this.name,
        this.email,
        this.phoneNumber,
        this.location,
        this.websiteLink,
        this.facebookLink,
        this.instagramLink,
        this.logo,
        this.image,
        this.description});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    location = json['location'];
    websiteLink = json['website_link'];
    facebookLink = json['facebook_link'];
    instagramLink = json['instagram_link'];
    logo = json['logo'];
    image = json['image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['location'] = location;
    data['website_link'] = websiteLink;
    data['facebook_link'] = facebookLink;
    data['instagram_link'] = instagramLink;
    data['logo'] = logo;
    data['image'] = image;
    data['description'] = description;
    return data;
  }
}
