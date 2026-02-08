/// Group type
enum GroupType {
  interest,
  activity,
  event,
  social,
  custom,
}

/// Group privacy
enum GroupPrivacy {
  public,
  private,
  secret,
}

/// Group member role
enum GroupMemberRole {
  owner,
  admin,
  moderator,
  member,
}

/// Group model
class GroupModel {
  final String? groupId;
  final String? name;
  final String? description;
  final GroupType type;
  final GroupPrivacy privacy;
  final String? image;
  final String? coverImage;
  final List<String> interests;
  final List<String> tags;
  final int? creatorId;
  final String? creatorName;
  final int memberCount;
  final int eventCount;
  final bool isActive;
  final bool userIsMember;
  final GroupMemberRole? userRole;
  final DateTime? createdAt;
  final String? location;
  final double? latitude;
  final double? longitude;
  final GroupSettings? settings;

  const GroupModel({
    this.groupId,
    this.name,
    this.description,
    this.type = GroupType.interest,
    this.privacy = GroupPrivacy.public,
    this.image,
    this.coverImage,
    this.interests = const [],
    this.tags = const [],
    this.creatorId,
    this.creatorName,
    this.memberCount = 0,
    this.eventCount = 0,
    this.isActive = true,
    this.userIsMember = false,
    this.userRole,
    this.createdAt,
    this.location,
    this.latitude,
    this.longitude,
    this.settings,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['group_id']?.toString(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      type: _parseGroupType(json['type']),
      privacy: _parseGroupPrivacy(json['privacy']),
      image: json['image'] as String?,
      coverImage: json['cover_image'] as String?,
      interests: _parseStringList(json['interests']),
      tags: _parseStringList(json['tags']),
      creatorId: json['creator_id'] as int?,
      creatorName: json['creator_name'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      eventCount: json['event_count'] as int? ?? 0,
      isActive: json['is_active'] != false,
      userIsMember: json['user_is_member'] == true,
      userRole: _parseGroupMemberRole(json['user_role']),
      createdAt: _parseDateTime(json['created_at']),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      settings: json['settings'] != null
          ? GroupSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'name': name,
      'description': description,
      'type': type.name,
      'privacy': privacy.name,
      'image': image,
      'cover_image': coverImage,
      'interests': interests,
      'tags': tags,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'member_count': memberCount,
      'event_count': eventCount,
      'is_active': isActive,
      'user_is_member': userIsMember,
      'user_role': userRole?.name,
      'created_at': createdAt?.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'settings': settings?.toJson(),
    };
  }

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? description,
    GroupType? type,
    GroupPrivacy? privacy,
    String? image,
    String? coverImage,
    List<String>? interests,
    List<String>? tags,
    int? creatorId,
    String? creatorName,
    int? memberCount,
    int? eventCount,
    bool? isActive,
    bool? userIsMember,
    GroupMemberRole? userRole,
    DateTime? createdAt,
    String? location,
    double? latitude,
    double? longitude,
    GroupSettings? settings,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      image: image ?? this.image,
      coverImage: coverImage ?? this.coverImage,
      interests: interests ?? this.interests,
      tags: tags ?? this.tags,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      memberCount: memberCount ?? this.memberCount,
      eventCount: eventCount ?? this.eventCount,
      isActive: isActive ?? this.isActive,
      userIsMember: userIsMember ?? this.userIsMember,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      settings: settings ?? this.settings,
    );
  }

  bool get isOwner => userRole == GroupMemberRole.owner;
  bool get isAdmin => userRole == GroupMemberRole.admin || isOwner;
  bool get isModerator => userRole == GroupMemberRole.moderator || isAdmin;
  bool get canManageMembers => isAdmin;
  bool get canCreateEvents => userIsMember;
  bool get isPublic => privacy == GroupPrivacy.public;
}

/// Group settings
class GroupSettings {
  final bool allowMemberPosts;
  final bool allowMemberEvents;
  final bool requireApproval;
  final bool showMemberList;
  final bool allowInvites;
  final int? maxMembers;
  final List<String> blockedWords;
  final bool notifyNewMembers;
  final bool notifyNewEvents;
  final bool notifyNewPosts;

  const GroupSettings({
    this.allowMemberPosts = true,
    this.allowMemberEvents = true,
    this.requireApproval = false,
    this.showMemberList = true,
    this.allowInvites = true,
    this.maxMembers,
    this.blockedWords = const [],
    this.notifyNewMembers = true,
    this.notifyNewEvents = true,
    this.notifyNewPosts = true,
  });

  factory GroupSettings.fromJson(Map<String, dynamic> json) {
    return GroupSettings(
      allowMemberPosts: json['allow_member_posts'] != false,
      allowMemberEvents: json['allow_member_events'] != false,
      requireApproval: json['require_approval'] == true,
      showMemberList: json['show_member_list'] != false,
      allowInvites: json['allow_invites'] != false,
      maxMembers: json['max_members'] as int?,
      blockedWords: _parseStringList(json['blocked_words']),
      notifyNewMembers: json['notify_new_members'] != false,
      notifyNewEvents: json['notify_new_events'] != false,
      notifyNewPosts: json['notify_new_posts'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allow_member_posts': allowMemberPosts,
      'allow_member_events': allowMemberEvents,
      'require_approval': requireApproval,
      'show_member_list': showMemberList,
      'allow_invites': allowInvites,
      'max_members': maxMembers,
      'blocked_words': blockedWords,
      'notify_new_members': notifyNewMembers,
      'notify_new_events': notifyNewEvents,
      'notify_new_posts': notifyNewPosts,
    };
  }
}

/// Group member model
class GroupMemberModel {
  final String? memberId;
  final String? groupId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final GroupMemberRole role;
  final DateTime? joinedAt;
  final bool isActive;
  final String? bio;

  const GroupMemberModel({
    this.memberId,
    this.groupId,
    this.userId,
    this.userName,
    this.userImage,
    this.role = GroupMemberRole.member,
    this.joinedAt,
    this.isActive = true,
    this.bio,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      memberId: json['member_id']?.toString(),
      groupId: json['group_id']?.toString(),
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      role: _parseGroupMemberRole(json['role']) ?? GroupMemberRole.member,
      joinedAt: _parseDateTime(json['joined_at']),
      isActive: json['is_active'] != false,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'role': role.name,
      'joined_at': joinedAt?.toIso8601String(),
      'is_active': isActive,
      'bio': bio,
    };
  }
}

/// Group join request
class GroupJoinRequest {
  final String? requestId;
  final String? groupId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final String? message;
  final DateTime? requestedAt;
  final bool isPending;

  const GroupJoinRequest({
    this.requestId,
    this.groupId,
    this.userId,
    this.userName,
    this.userImage,
    this.message,
    this.requestedAt,
    this.isPending = true,
  });

  factory GroupJoinRequest.fromJson(Map<String, dynamic> json) {
    return GroupJoinRequest(
      requestId: json['request_id']?.toString(),
      groupId: json['group_id']?.toString(),
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      message: json['message'] as String?,
      requestedAt: _parseDateTime(json['requested_at']),
      isPending: json['is_pending'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'message': message,
      'requested_at': requestedAt?.toIso8601String(),
      'is_pending': isPending,
    };
  }
}

/// Interest category for groups
class InterestCategory {
  static const Map<String, List<String>> categories = {
    'Sports & Fitness': [
      'Running',
      'Hiking',
      'Cycling',
      'Yoga',
      'CrossFit',
      'Swimming',
      'Tennis',
      'Basketball',
      'Soccer',
      'Golf',
    ],
    'Arts & Culture': [
      'Photography',
      'Painting',
      'Music',
      'Dance',
      'Theater',
      'Film',
      'Writing',
      'Crafts',
    ],
    'Food & Drink': [
      'Cooking',
      'Wine Tasting',
      'Coffee',
      'Craft Beer',
      'Vegan',
      'Baking',
      'Food Tours',
    ],
    'Technology': [
      'Programming',
      'Gaming',
      'AI/ML',
      'Startups',
      'Crypto',
      'Design',
      'Web Development',
    ],
    'Outdoor & Adventure': [
      'Camping',
      'Rock Climbing',
      'Kayaking',
      'Surfing',
      'Skiing',
      'Travel',
      'Road Trips',
    ],
    'Social': [
      'Networking',
      'Book Clubs',
      'Language Exchange',
      'Singles',
      'New in Town',
      'Professionals',
    ],
    'Health & Wellness': [
      'Meditation',
      'Mental Health',
      'Nutrition',
      'Fitness',
      'Self-Improvement',
    ],
    'Games & Hobbies': [
      'Board Games',
      'Card Games',
      'Video Games',
      'Trivia',
      'Escape Rooms',
      'Puzzles',
    ],
  };

  static List<String> getAllInterests() {
    return categories.values.expand((list) => list).toList();
  }

  static String? getCategoryForInterest(String interest) {
    for (final entry in categories.entries) {
      if (entry.value.contains(interest)) {
        return entry.key;
      }
    }
    return null;
  }
}

GroupType _parseGroupType(dynamic value) {
  if (value == null) return GroupType.interest;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'activity':
        return GroupType.activity;
      case 'event':
        return GroupType.event;
      case 'social':
        return GroupType.social;
      case 'custom':
        return GroupType.custom;
      default:
        return GroupType.interest;
    }
  }
  return GroupType.interest;
}

GroupPrivacy _parseGroupPrivacy(dynamic value) {
  if (value == null) return GroupPrivacy.public;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'private':
        return GroupPrivacy.private;
      case 'secret':
        return GroupPrivacy.secret;
      default:
        return GroupPrivacy.public;
    }
  }
  return GroupPrivacy.public;
}

GroupMemberRole? _parseGroupMemberRole(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'owner':
        return GroupMemberRole.owner;
      case 'admin':
        return GroupMemberRole.admin;
      case 'moderator':
        return GroupMemberRole.moderator;
      case 'member':
        return GroupMemberRole.member;
    }
  }
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}
