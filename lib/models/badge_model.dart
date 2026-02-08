/// Badge/Achievement model
class BadgeModel {
  final int? badgeId;
  final String? name;
  final String? description;
  final String? iconUrl;
  final BadgeCategory category;
  final int requiredProgress;
  final int currentProgress;
  final bool isUnlocked;
  final bool isClaimed;
  final DateTime? unlockedAt;
  final int? xpReward;

  const BadgeModel({
    this.badgeId,
    this.name,
    this.description,
    this.iconUrl,
    this.category = BadgeCategory.general,
    this.requiredProgress = 1,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.isClaimed = false,
    this.unlockedAt,
    this.xpReward,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      badgeId: (json['badge_id'] ?? json['badgeId']) as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      iconUrl: (json['icon_url'] ?? json['iconUrl'] ?? json['icon']) as String?,
      category: _parseBadgeCategory(json['category']),
      requiredProgress: (json['required_progress'] ?? json['requiredProgress'] ?? 1) as int,
      currentProgress: (json['current_progress'] ?? json['currentProgress'] ?? 0) as int,
      isUnlocked: json['is_unlocked'] == true || json['isUnlocked'] == true,
      isClaimed: json['is_claimed'] == true || json['isClaimed'] == true,
      unlockedAt: _parseDateTime(json['unlocked_at'] ?? json['unlockedAt']),
      xpReward: (json['xp_reward'] ?? json['xpReward']) as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badge_id': badgeId,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category.name,
      'required_progress': requiredProgress,
      'current_progress': currentProgress,
      'is_unlocked': isUnlocked,
      'is_claimed': isClaimed,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'xp_reward': xpReward,
    };
  }

  double get progressPercentage {
    if (requiredProgress == 0) return 1.0;
    return (currentProgress / requiredProgress).clamp(0.0, 1.0);
  }

  bool get canClaim => isUnlocked && !isClaimed;
}

/// Badge category enum
enum BadgeCategory {
  general,
  activity,
  social,
  streak,
  milestone,
  special,
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int? rank;
  final int? userId;
  final String? userName;
  final List<String> userImages;
  final int totalXp;
  final int activitiesCreated;
  final int activitiesJoined;
  final int matchCount;
  final int badgeCount;

  const LeaderboardEntry({
    this.rank,
    this.userId,
    this.userName,
    this.userImages = const [],
    this.totalXp = 0,
    this.activitiesCreated = 0,
    this.activitiesJoined = 0,
    this.matchCount = 0,
    this.badgeCount = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int?,
      userId: (json['user_id'] ?? json['userId']) as int?,
      userName: (json['user_name'] ?? json['userName']) as String?,
      userImages: _parseStringList(json['user_images'] ?? json['images']),
      totalXp: (json['total_xp'] ?? json['totalXp'] ?? 0) as int,
      activitiesCreated: (json['activities_created'] ?? json['activitiesCreated'] ?? 0) as int,
      activitiesJoined: (json['activities_joined'] ?? json['activitiesJoined'] ?? 0) as int,
      matchCount: (json['match_count'] ?? json['matchCount'] ?? 0) as int,
      badgeCount: (json['badge_count'] ?? json['badgeCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'user_name': userName,
      'user_images': userImages,
      'total_xp': totalXp,
      'activities_created': activitiesCreated,
      'activities_joined': activitiesJoined,
      'match_count': matchCount,
      'badge_count': badgeCount,
    };
  }

  String? get profileImage => userImages.isNotEmpty ? userImages.first : null;
}

/// Badge list response
class BadgeListResponse {
  final String? message;
  final List<BadgeModel> data;

  const BadgeListResponse({
    this.message,
    this.data = const [],
  });

  factory BadgeListResponse.fromJson(Map<String, dynamic> json) {
    return BadgeListResponse(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Leaderboard response
class LeaderboardResponse {
  final String? message;
  final List<LeaderboardEntry> data;
  final LeaderboardEntry? currentUser;

  const LeaderboardResponse({
    this.message,
    this.data = const [],
    this.currentUser,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentUser: json['current_user'] != null
          ? LeaderboardEntry.fromJson(json['current_user'])
          : null,
    );
  }
}

/// Helper functions
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

BadgeCategory _parseBadgeCategory(dynamic value) {
  if (value == null) return BadgeCategory.general;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'activity':
        return BadgeCategory.activity;
      case 'social':
        return BadgeCategory.social;
      case 'streak':
        return BadgeCategory.streak;
      case 'milestone':
        return BadgeCategory.milestone;
      case 'special':
        return BadgeCategory.special;
      default:
        return BadgeCategory.general;
    }
  }
  return BadgeCategory.general;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}
