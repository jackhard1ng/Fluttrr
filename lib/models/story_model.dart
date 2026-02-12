/// Story model for ephemeral event content (24-hour expiring stories)

class StoryModel {
  final String storyId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? eventId;
  final String? eventName;
  final StoryType type;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final List<String> viewerIds;
  final bool isViewed;
  final List<StoryReaction> reactions;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.eventId,
    this.eventName,
    required this.type,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.viewerIds = const [],
    this.isViewed = false,
    this.reactions = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  String get remainingTimeText {
    final remaining = remainingTime;
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours > 0) return '${remaining.inHours}h';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}m';
    return '${remaining.inSeconds}s';
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['story_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['userAvatar'],
      eventId: json['event_id'] ?? json['eventId'],
      eventName: json['event_name'] ?? json['eventName'],
      type: StoryType.values.firstWhere(
        (t) => t.name == (json['type'] ?? 'image'),
        orElse: () => StoryType.image,
      ),
      mediaUrl: json['media_url'] ?? json['mediaUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      caption: json['caption'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ??
          DateTime.now().add(const Duration(hours: 24)),
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      viewerIds: ((json['viewer_ids'] ?? json['viewerIds']) is List
          ? (json['viewer_ids'] ?? json['viewerIds']) as List
          : []).map((e) => e.toString()).toList(),
      isViewed: json['is_viewed'] ?? json['isViewed'] ?? false,
      reactions: (json['reactions'] is List
          ? (json['reactions'] as List)
              .whereType<Map<String, dynamic>>()
              .map((r) => StoryReaction.fromJson(r))
              .toList()
          : <StoryReaction>[]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story_id': storyId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'event_id': eventId,
      'event_name': eventName,
      'type': type.name,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'view_count': viewCount,
      'viewer_ids': viewerIds,
      'is_viewed': isViewed,
      'reactions': reactions.map((r) => r.toJson()).toList(),
    };
  }
}

enum StoryType {
  image,
  video,
  text,
}

class StoryReaction {
  final String reactionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String emoji;
  final DateTime createdAt;

  StoryReaction({
    required this.reactionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.emoji,
    required this.createdAt,
  });

  factory StoryReaction.fromJson(Map<String, dynamic> json) {
    return StoryReaction(
      reactionId: json['reaction_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['userAvatar'],
      emoji: json['emoji'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reaction_id': reactionId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// A group of stories from the same user
class UserStoryGroup {
  final String userId;
  final String userName;
  final String? userAvatar;
  final List<StoryModel> stories;
  final bool hasUnviewed;

  UserStoryGroup({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.stories,
    required this.hasUnviewed,
  });

  StoryModel? get latestStory => stories.isNotEmpty ? stories.last : null;

  int get unviewedCount => stories.where((s) => !s.isViewed).length;

  factory UserStoryGroup.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List<dynamic>?)
        ?.map((s) => StoryModel.fromJson(s))
        .toList() ?? [];

    return UserStoryGroup(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['userAvatar'],
      stories: storiesList,
      hasUnviewed: storiesList.any((s) => !s.isViewed),
    );
  }
}

/// Stories grouped by event
class EventStoryGroup {
  final String eventId;
  final String eventName;
  final String? eventImage;
  final List<StoryModel> stories;
  final int contributorCount;
  final bool hasUnviewed;

  EventStoryGroup({
    required this.eventId,
    required this.eventName,
    this.eventImage,
    required this.stories,
    required this.contributorCount,
    required this.hasUnviewed,
  });

  StoryModel? get latestStory => stories.isNotEmpty ? stories.last : null;

  factory EventStoryGroup.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List<dynamic>?)
        ?.map((s) => StoryModel.fromJson(s))
        .toList() ?? [];

    return EventStoryGroup(
      eventId: json['event_id'] ?? '',
      eventName: json['event_name'] ?? json['eventName'] ?? 'Event',
      eventImage: json['event_image'] ?? json['eventImage'],
      stories: storiesList,
      contributorCount: json['contributor_count'] ?? json['contributorCount'] ??
          storiesList.map((s) => s.userId).toSet().length,
      hasUnviewed: storiesList.any((s) => !s.isViewed),
    );
  }
}
