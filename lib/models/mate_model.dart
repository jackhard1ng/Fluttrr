/// Mate (user match) model
class MateModel {
  final int? userId;
  final String? userName;
  final int? age;
  final String? gender;
  final String? bio;
  final String? location;
  final String? onlineStatus;
  final List<String> images;
  final List<String> interests;
  final double? distance;
  final bool isLiked;
  final bool isMatched;

  const MateModel({
    this.userId,
    this.userName,
    this.age,
    this.gender,
    this.bio,
    this.location,
    this.onlineStatus,
    this.images = const [],
    this.interests = const [],
    this.distance,
    this.isLiked = false,
    this.isMatched = false,
  });

  factory MateModel.fromJson(Map<String, dynamic> json) {
    return MateModel(
      userId: json['user_id'] ?? json['userId'] as int?,
      userName: json['userName'] ?? json['user_name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      onlineStatus: json['onlineStatus'] ?? json['online_status'] as String?,
      images: _parseStringList(json['images']),
      interests: _parseStringList(json['interests']),
      distance: (json['distance'] as num?)?.toDouble(),
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      isMatched: json['is_matched'] == true || json['isMatched'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'userName': userName,
      'age': age,
      'gender': gender,
      'bio': bio,
      'location': location,
      'onlineStatus': onlineStatus,
      'images': images,
      'interests': interests,
      'distance': distance,
      'is_liked': isLiked,
      'is_matched': isMatched,
    };
  }

  MateModel copyWith({
    int? userId,
    String? userName,
    int? age,
    String? gender,
    String? bio,
    String? location,
    String? onlineStatus,
    List<String>? images,
    List<String>? interests,
    double? distance,
    bool? isLiked,
    bool? isMatched,
  }) {
    return MateModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      images: images ?? this.images,
      interests: interests ?? this.interests,
      distance: distance ?? this.distance,
      isLiked: isLiked ?? this.isLiked,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  // Computed properties
  bool get isOnline => onlineStatus?.toLowerCase() == 'online';

  String get displayName => userName ?? 'User';

  String? get profileImage => images.isNotEmpty ? images.first : null;

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) return '${(distance! * 1000).round()} m away';
    return '${distance!.toStringAsFixed(1)} km away';
  }
}

/// Mates list response
class MatesListResponse {
  final String? message;
  final List<MateModel> data;
  final int? totalCount;

  const MatesListResponse({
    this.message,
    this.data = const [],
    this.totalCount,
  });

  factory MatesListResponse.fromJson(Map<String, dynamic> json) {
    return MatesListResponse(
      message: json['message'] as String?,
      data: _parseMatesList(json['data']),
      totalCount: json['total_count'] ?? json['totalCount'] as int?,
    );
  }
}

/// Match model (mutual like)
class MatchModel {
  final int? matchId;
  final int? userId;
  final String? userName;
  final List<String> images;
  final DateTime? matchedAt;

  const MatchModel({
    this.matchId,
    this.userId,
    this.userName,
    this.images = const [],
    this.matchedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['match_id'] as int?,
      userId: json['user_id'] ?? json['userId'] as int?,
      userName: json['userName'] ?? json['user_name'] as String?,
      images: _parseStringList(json['images']),
      matchedAt: json['matched_at'] != null
          ? DateTime.tryParse(json['matched_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_id': matchId,
      'user_id': userId,
      'userName': userName,
      'images': images,
      'matched_at': matchedAt?.toIso8601String(),
    };
  }

  String? get profileImage => images.isNotEmpty ? images.first : null;
}

/// Helper functions
List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<MateModel> _parseMatesList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => MateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
