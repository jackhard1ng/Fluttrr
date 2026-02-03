/// Privacy settings model
class PrivacySettings {
  final bool showOnlineStatus;
  final bool showLastSeen;
  final bool showLocation;
  final bool showAge;
  final bool showDistance;
  final ProfileVisibility profileVisibility;
  final bool allowMessages;
  final bool allowActivityInvites;
  final bool showInNearby;
  final bool showInSearch;

  const PrivacySettings({
    this.showOnlineStatus = true,
    this.showLastSeen = true,
    this.showLocation = true,
    this.showAge = true,
    this.showDistance = true,
    this.profileVisibility = ProfileVisibility.everyone,
    this.allowMessages = true,
    this.allowActivityInvites = true,
    this.showInNearby = true,
    this.showInSearch = true,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showOnlineStatus: json['show_online_status'] ?? json['showOnlineStatus'] ?? true,
      showLastSeen: json['show_last_seen'] ?? json['showLastSeen'] ?? true,
      showLocation: json['show_location'] ?? json['showLocation'] ?? true,
      showAge: json['show_age'] ?? json['showAge'] ?? true,
      showDistance: json['show_distance'] ?? json['showDistance'] ?? true,
      profileVisibility: _parseProfileVisibility(json['profile_visibility'] ?? json['profileVisibility']),
      allowMessages: json['allow_messages'] ?? json['allowMessages'] ?? true,
      allowActivityInvites: json['allow_activity_invites'] ?? json['allowActivityInvites'] ?? true,
      showInNearby: json['show_in_nearby'] ?? json['showInNearby'] ?? true,
      showInSearch: json['show_in_search'] ?? json['showInSearch'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_online_status': showOnlineStatus,
      'show_last_seen': showLastSeen,
      'show_location': showLocation,
      'show_age': showAge,
      'show_distance': showDistance,
      'profile_visibility': profileVisibility.name,
      'allow_messages': allowMessages,
      'allow_activity_invites': allowActivityInvites,
      'show_in_nearby': showInNearby,
      'show_in_search': showInSearch,
    };
  }

  PrivacySettings copyWith({
    bool? showOnlineStatus,
    bool? showLastSeen,
    bool? showLocation,
    bool? showAge,
    bool? showDistance,
    ProfileVisibility? profileVisibility,
    bool? allowMessages,
    bool? allowActivityInvites,
    bool? showInNearby,
    bool? showInSearch,
  }) {
    return PrivacySettings(
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      showLocation: showLocation ?? this.showLocation,
      showAge: showAge ?? this.showAge,
      showDistance: showDistance ?? this.showDistance,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      allowMessages: allowMessages ?? this.allowMessages,
      allowActivityInvites: allowActivityInvites ?? this.allowActivityInvites,
      showInNearby: showInNearby ?? this.showInNearby,
      showInSearch: showInSearch ?? this.showInSearch,
    );
  }
}

/// Profile visibility enum
enum ProfileVisibility {
  everyone,
  matchesOnly,
  nobody,
}

/// Notification preferences model
class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool newMatchNotifications;
  final bool messageNotifications;
  final bool activityNotifications;
  final bool activityReminderNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool marketingNotifications;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.newMatchNotifications = true,
    this.messageNotifications = true,
    this.activityNotifications = true,
    this.activityReminderNotifications = true,
    this.likeNotifications = true,
    this.commentNotifications = true,
    this.marketingNotifications = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['push_enabled'] ?? json['pushEnabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? json['emailEnabled'] ?? true,
      newMatchNotifications: json['new_match_notifications'] ?? json['newMatchNotifications'] ?? true,
      messageNotifications: json['message_notifications'] ?? json['messageNotifications'] ?? true,
      activityNotifications: json['activity_notifications'] ?? json['activityNotifications'] ?? true,
      activityReminderNotifications: json['activity_reminder_notifications'] ?? json['activityReminderNotifications'] ?? true,
      likeNotifications: json['like_notifications'] ?? json['likeNotifications'] ?? true,
      commentNotifications: json['comment_notifications'] ?? json['commentNotifications'] ?? true,
      marketingNotifications: json['marketing_notifications'] ?? json['marketingNotifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'new_match_notifications': newMatchNotifications,
      'message_notifications': messageNotifications,
      'activity_notifications': activityNotifications,
      'activity_reminder_notifications': activityReminderNotifications,
      'like_notifications': likeNotifications,
      'comment_notifications': commentNotifications,
      'marketing_notifications': marketingNotifications,
    };
  }

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? newMatchNotifications,
    bool? messageNotifications,
    bool? activityNotifications,
    bool? activityReminderNotifications,
    bool? likeNotifications,
    bool? commentNotifications,
    bool? marketingNotifications,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      newMatchNotifications: newMatchNotifications ?? this.newMatchNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      activityNotifications: activityNotifications ?? this.activityNotifications,
      activityReminderNotifications: activityReminderNotifications ?? this.activityReminderNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
    );
  }
}

/// Helper function
ProfileVisibility _parseProfileVisibility(dynamic value) {
  if (value == null) return ProfileVisibility.everyone;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'matches_only':
      case 'matchesonly':
        return ProfileVisibility.matchesOnly;
      case 'nobody':
        return ProfileVisibility.nobody;
      default:
        return ProfileVisibility.everyone;
    }
  }
  return ProfileVisibility.everyone;
}
