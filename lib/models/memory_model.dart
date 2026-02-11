/// Model for event memories/photos shared after events
class EventMemoryModel {
  final String memoryId;
  final String eventId;
  final String eventName;
  final String uploaderId;
  final String uploaderName;
  final String? uploaderAvatar;
  final List<MemoryPhotoModel> photos;
  final String? caption;
  final int likeCount;
  final bool isLikedByMe;
  final List<MemoryCommentModel> recentComments;
  final int commentCount;
  final DateTime createdAt;
  final DateTime eventDate;
  final bool isApproved;
  final bool isFeatured;

  EventMemoryModel({
    required this.memoryId,
    required this.eventId,
    required this.eventName,
    required this.uploaderId,
    required this.uploaderName,
    this.uploaderAvatar,
    required this.photos,
    this.caption,
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.recentComments = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.eventDate,
    this.isApproved = true,
    this.isFeatured = false,
  });

  factory EventMemoryModel.fromJson(Map<String, dynamic> json) {
    return EventMemoryModel(
      memoryId: (json['memory_id'] ?? json['id'])?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      eventName: json['event_name'] as String? ?? '',
      uploaderId: json['uploader_id']?.toString() ?? '',
      uploaderName: json['uploader_name'] as String? ?? 'Unknown',
      uploaderAvatar: json['uploader_avatar'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => MemoryPhotoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      caption: json['caption'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      recentComments: (json['recent_comments'] as List<dynamic>?)
              ?.map((e) => MemoryCommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : DateTime.now(),
      isApproved: json['is_approved'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memory_id': memoryId,
      'event_id': eventId,
      'event_name': eventName,
      'uploader_id': uploaderId,
      'uploader_name': uploaderName,
      'uploader_avatar': uploaderAvatar,
      'photos': photos.map((p) => p.toJson()).toList(),
      'caption': caption,
      'like_count': likeCount,
      'is_liked_by_me': isLikedByMe,
      'recent_comments': recentComments.map((c) => c.toJson()).toList(),
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'is_approved': isApproved,
      'is_featured': isFeatured,
    };
  }

  EventMemoryModel copyWith({
    String? memoryId,
    String? eventId,
    String? eventName,
    String? uploaderId,
    String? uploaderName,
    String? uploaderAvatar,
    List<MemoryPhotoModel>? photos,
    String? caption,
    int? likeCount,
    bool? isLikedByMe,
    List<MemoryCommentModel>? recentComments,
    int? commentCount,
    DateTime? createdAt,
    DateTime? eventDate,
    bool? isApproved,
    bool? isFeatured,
  }) {
    return EventMemoryModel(
      memoryId: memoryId ?? this.memoryId,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
      photos: photos ?? this.photos,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      recentComments: recentComments ?? this.recentComments,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      eventDate: eventDate ?? this.eventDate,
      isApproved: isApproved ?? this.isApproved,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  /// Get the primary photo (first photo)
  MemoryPhotoModel? get primaryPhoto => photos.isNotEmpty ? photos.first : null;

  /// Get time since event
  String get timeSinceEvent {
    final difference = DateTime.now().difference(eventDate);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

/// Model for individual memory photos
class MemoryPhotoModel {
  final String photoId;
  final String url;
  final String? thumbnailUrl;
  final int width;
  final int height;
  final String? description;
  final List<PhotoTagModel> tags;
  final DateTime uploadedAt;

  MemoryPhotoModel({
    required this.photoId,
    required this.url,
    this.thumbnailUrl,
    this.width = 0,
    this.height = 0,
    this.description,
    this.tags = const [],
    required this.uploadedAt,
  });

  factory MemoryPhotoModel.fromJson(Map<String, dynamic> json) {
    return MemoryPhotoModel(
      photoId: json['photo_id'] as String? ?? json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => PhotoTagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'width': width,
      'height': height,
      'description': description,
      'tags': tags.map((t) => t.toJson()).toList(),
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  /// Get display URL (thumbnail if available, otherwise full)
  String get displayUrl => thumbnailUrl ?? url;

  /// Get aspect ratio
  double get aspectRatio => height > 0 ? width / height : 1.0;
}

/// Model for tagging people in photos
class PhotoTagModel {
  final String tagId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double xPosition; // 0-1 percentage
  final double yPosition; // 0-1 percentage

  PhotoTagModel({
    required this.tagId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.xPosition,
    required this.yPosition,
  });

  factory PhotoTagModel.fromJson(Map<String, dynamic> json) {
    return PhotoTagModel(
      tagId: json['tag_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      userAvatar: json['user_avatar'] as String?,
      xPosition: (json['x_position'] as num?)?.toDouble() ?? 0.5,
      yPosition: (json['y_position'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'x_position': xPosition,
      'y_position': yPosition,
    };
  }
}

/// Model for memory comments
class MemoryCommentModel {
  final String commentId;
  final String memoryId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLikedByMe;

  MemoryCommentModel({
    required this.commentId,
    required this.memoryId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByMe = false,
  });

  factory MemoryCommentModel.fromJson(Map<String, dynamic> json) {
    return MemoryCommentModel(
      commentId: json['comment_id'] as String? ?? json['id'] as String? ?? '',
      memoryId: json['memory_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'memory_id': memoryId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount,
      'is_liked_by_me': isLikedByMe,
    };
  }

  MemoryCommentModel copyWith({
    int? likeCount,
    bool? isLikedByMe,
  }) {
    return MemoryCommentModel(
      commentId: commentId,
      memoryId: memoryId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

/// Model for events that have memories
class EventWithMemoriesModel {
  final String eventId;
  final String eventName;
  final String? eventImage;
  final DateTime eventDate;
  final int memoryCount;
  final int photoCount;
  final List<String> previewPhotos;
  final int contributorCount;

  EventWithMemoriesModel({
    required this.eventId,
    required this.eventName,
    this.eventImage,
    required this.eventDate,
    this.memoryCount = 0,
    this.photoCount = 0,
    this.previewPhotos = const [],
    this.contributorCount = 0,
  });

  factory EventWithMemoriesModel.fromJson(Map<String, dynamic> json) {
    return EventWithMemoriesModel(
      eventId: json['event_id'] as String? ?? json['id'] as String? ?? '',
      eventName: json['event_name'] as String? ?? json['name'] as String? ?? '',
      eventImage: json['event_image'] as String?,
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : DateTime.now(),
      memoryCount: json['memory_count'] as int? ?? 0,
      photoCount: json['photo_count'] as int? ?? 0,
      previewPhotos: (json['preview_photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      contributorCount: json['contributor_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_image': eventImage,
      'event_date': eventDate.toIso8601String(),
      'memory_count': memoryCount,
      'photo_count': photoCount,
      'preview_photos': previewPhotos,
      'contributor_count': contributorCount,
    };
  }
}
