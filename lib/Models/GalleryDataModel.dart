class GalleryDataModel {
  String? message;
  List<Gallery>? gallery;

  GalleryDataModel({this.message, this.gallery});

  GalleryDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['gallery'] != null) {
      gallery = <Gallery>[];
      json['gallery'].forEach((v) {
        gallery!.add(Gallery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (gallery != null) {
      data['gallery'] = gallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gallery {
  int? id;
  int? userID;
  List<String>? images;
  String? description;
  String? createdAt;
  String? updatedAt;

  Gallery(
      {this.id,
        this.userID,
        this.images,
        this.description,
        this.createdAt,
        this.updatedAt});

  Gallery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userID = json['userID'];
    images = json['images'].cast<String>();
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userID'] = userID;
    data['images'] = images;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
