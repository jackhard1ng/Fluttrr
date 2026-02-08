/// Reward type enum
enum RewardType {
  userReferral,
  eventCreation,
  attendeeCount,
  engagement,
  milestone,
  promotion,
}

/// Reward status
enum RewardStatus {
  pending,
  claimed,
  expired,
  processing,
}

/// Business reward model
class BusinessRewardModel {
  final String? rewardId;
  final int? businessId;
  final RewardType type;
  final String? title;
  final String? description;
  final int points;
  final double? cashValue;
  final String? currency;
  final RewardStatus status;
  final DateTime? earnedAt;
  final DateTime? claimedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  const BusinessRewardModel({
    this.rewardId,
    this.businessId,
    this.type = RewardType.userReferral,
    this.title,
    this.description,
    this.points = 0,
    this.cashValue,
    this.currency,
    this.status = RewardStatus.pending,
    this.earnedAt,
    this.claimedAt,
    this.expiresAt,
    this.metadata,
  });

  factory BusinessRewardModel.fromJson(Map<String, dynamic> json) {
    return BusinessRewardModel(
      rewardId: json['reward_id']?.toString(),
      businessId: json['business_id'] as int?,
      type: _parseRewardType(json['type']),
      title: json['title'] as String?,
      description: json['description'] as String?,
      points: json['points'] as int? ?? 0,
      cashValue: (json['cash_value'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      status: _parseRewardStatus(json['status']),
      earnedAt: _parseDateTime(json['earned_at']),
      claimedAt: _parseDateTime(json['claimed_at']),
      expiresAt: _parseDateTime(json['expires_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_id': rewardId,
      'business_id': businessId,
      'type': type.name,
      'title': title,
      'description': description,
      'points': points,
      'cash_value': cashValue,
      'currency': currency,
      'status': status.name,
      'earned_at': earnedAt?.toIso8601String(),
      'claimed_at': claimedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get canClaim => status == RewardStatus.pending;
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;
}

/// Business rewards summary
class BusinessRewardsSummary {
  final int? businessId;
  final int totalPoints;
  final double totalCashEarned;
  final int pendingRewards;
  final int claimedRewards;
  final int usersReferred;
  final int eventsHosted;
  final int totalAttendees;
  final String? tier;
  final int tierProgress;
  final int pointsToNextTier;
  final List<BusinessRewardModel> recentRewards;

  const BusinessRewardsSummary({
    this.businessId,
    this.totalPoints = 0,
    this.totalCashEarned = 0.0,
    this.pendingRewards = 0,
    this.claimedRewards = 0,
    this.usersReferred = 0,
    this.eventsHosted = 0,
    this.totalAttendees = 0,
    this.tier,
    this.tierProgress = 0,
    this.pointsToNextTier = 0,
    this.recentRewards = const [],
  });

  factory BusinessRewardsSummary.fromJson(Map<String, dynamic> json) {
    return BusinessRewardsSummary(
      businessId: json['business_id'] as int?,
      totalPoints: json['total_points'] as int? ?? 0,
      totalCashEarned: (json['total_cash_earned'] as num?)?.toDouble() ?? 0.0,
      pendingRewards: json['pending_rewards'] as int? ?? 0,
      claimedRewards: json['claimed_rewards'] as int? ?? 0,
      usersReferred: json['users_referred'] as int? ?? 0,
      eventsHosted: json['events_hosted'] as int? ?? 0,
      totalAttendees: json['total_attendees'] as int? ?? 0,
      tier: json['tier'] as String?,
      tierProgress: json['tier_progress'] as int? ?? 0,
      pointsToNextTier: json['points_to_next_tier'] as int? ?? 0,
      recentRewards: _parseRewards(json['recent_rewards']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'total_points': totalPoints,
      'total_cash_earned': totalCashEarned,
      'pending_rewards': pendingRewards,
      'claimed_rewards': claimedRewards,
      'users_referred': usersReferred,
      'events_hosted': eventsHosted,
      'total_attendees': totalAttendees,
      'tier': tier,
      'tier_progress': tierProgress,
      'points_to_next_tier': pointsToNextTier,
      'recent_rewards': recentRewards.map((r) => r.toJson()).toList(),
    };
  }
}

/// Referral tracking for businesses
class BusinessReferralModel {
  final String? referralId;
  final int? businessId;
  final String? referralCode;
  final int? referredUserId;
  final String? referredUserName;
  final DateTime? referredAt;
  final bool userSignedUp;
  final bool userAttendedEvent;
  final int pointsEarned;
  final bool rewardClaimed;

  const BusinessReferralModel({
    this.referralId,
    this.businessId,
    this.referralCode,
    this.referredUserId,
    this.referredUserName,
    this.referredAt,
    this.userSignedUp = false,
    this.userAttendedEvent = false,
    this.pointsEarned = 0,
    this.rewardClaimed = false,
  });

  factory BusinessReferralModel.fromJson(Map<String, dynamic> json) {
    return BusinessReferralModel(
      referralId: json['referral_id']?.toString(),
      businessId: json['business_id'] as int?,
      referralCode: json['referral_code'] as String?,
      referredUserId: json['referred_user_id'] as int?,
      referredUserName: json['referred_user_name'] as String?,
      referredAt: _parseDateTime(json['referred_at']),
      userSignedUp: json['user_signed_up'] == true,
      userAttendedEvent: json['user_attended_event'] == true,
      pointsEarned: json['points_earned'] as int? ?? 0,
      rewardClaimed: json['reward_claimed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referral_id': referralId,
      'business_id': businessId,
      'referral_code': referralCode,
      'referred_user_id': referredUserId,
      'referred_user_name': referredUserName,
      'referred_at': referredAt?.toIso8601String(),
      'user_signed_up': userSignedUp,
      'user_attended_event': userAttendedEvent,
      'points_earned': pointsEarned,
      'reward_claimed': rewardClaimed,
    };
  }
}

/// Reward tier definitions
class RewardTier {
  static const Map<String, int> tiers = {
    'Bronze': 0,
    'Silver': 1000,
    'Gold': 5000,
    'Platinum': 15000,
    'Diamond': 50000,
  };

  static const Map<String, double> multipliers = {
    'Bronze': 1.0,
    'Silver': 1.25,
    'Gold': 1.5,
    'Platinum': 2.0,
    'Diamond': 3.0,
  };

  static String getTierForPoints(int points) {
    if (points >= 50000) return 'Diamond';
    if (points >= 15000) return 'Platinum';
    if (points >= 5000) return 'Gold';
    if (points >= 1000) return 'Silver';
    return 'Bronze';
  }

  static int getPointsToNextTier(int currentPoints) {
    final tiers = [1000, 5000, 15000, 50000];
    for (final tier in tiers) {
      if (currentPoints < tier) return tier - currentPoints;
    }
    return 0;
  }
}

RewardType _parseRewardType(dynamic value) {
  if (value == null) return RewardType.userReferral;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'event_creation':
      case 'eventcreation':
        return RewardType.eventCreation;
      case 'attendee_count':
      case 'attendeecount':
        return RewardType.attendeeCount;
      case 'engagement':
        return RewardType.engagement;
      case 'milestone':
        return RewardType.milestone;
      case 'promotion':
        return RewardType.promotion;
      default:
        return RewardType.userReferral;
    }
  }
  return RewardType.userReferral;
}

RewardStatus _parseRewardStatus(dynamic value) {
  if (value == null) return RewardStatus.pending;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'claimed':
        return RewardStatus.claimed;
      case 'expired':
        return RewardStatus.expired;
      case 'processing':
        return RewardStatus.processing;
      default:
        return RewardStatus.pending;
    }
  }
  return RewardStatus.pending;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<BusinessRewardModel> _parseRewards(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => BusinessRewardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
