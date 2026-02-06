import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Simplified badge system - focused on meaningful milestones
class UserBadge {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int count;

  const UserBadge({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });
}

/// Attendance milestone badges for regular users
class AttendanceBadges {
  static List<UserBadge> getMilestones(int eventsAttended) {
    final milestones = [
      (1, 'First Event', Icons.celebration),
      (5, '5 Events', Icons.star_outline),
      (10, '10 Events', Icons.star_half),
      (25, '25 Events', Icons.star),
      (50, '50 Events', Icons.workspace_premium),
      (100, '100 Events', Icons.emoji_events),
    ];

    return milestones
        .where((m) => eventsAttended >= m.$1)
        .map((m) => UserBadge(
              id: 'attended_${m.$1}',
              name: m.$2,
              icon: m.$3,
              color: AppColors.primaryBlue,
              count: m.$1,
            ))
        .toList();
  }

  static UserBadge? getHighestBadge(int eventsAttended) {
    final badges = getMilestones(eventsAttended);
    return badges.isNotEmpty ? badges.last : null;
  }

  static (int, String)? getNextMilestone(int eventsAttended) {
    final milestones = [1, 5, 10, 25, 50, 100];
    for (final m in milestones) {
      if (eventsAttended < m) {
        return (m, '${m - eventsAttended} more to go');
      }
    }
    return null;
  }
}

/// Hosting milestone badges for businesses
class HostingBadges {
  static List<UserBadge> getMilestones(int eventsHosted) {
    final milestones = [
      (1, 'First Host', Icons.add_circle),
      (5, '5 Hosted', Icons.event_available),
      (10, '10 Hosted', Icons.event_repeat),
      (25, '25 Hosted', Icons.auto_awesome),
      (50, '50 Hosted', Icons.diamond),
      (100, '100 Hosted', Icons.military_tech),
    ];

    return milestones
        .where((m) => eventsHosted >= m.$1)
        .map((m) => UserBadge(
              id: 'hosted_${m.$1}',
              name: m.$2,
              icon: m.$3,
              color: const Color(0xFFFFD700),
              count: m.$1,
            ))
        .toList();
  }

  static UserBadge? getHighestBadge(int eventsHosted) {
    final badges = getMilestones(eventsHosted);
    return badges.isNotEmpty ? badges.last : null;
  }
}

/// Star rating badge for businesses
class RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool compact;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          'New',
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: AppColors.mediumGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final color = _getRatingColor(rating);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: compact ? 14 : 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (!compact && reviewCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppColors.success;
    if (rating >= 4.0) return AppColors.friendlyTeal;
    if (rating >= 3.0) return AppColors.friendlyOrange;
    return AppColors.error;
  }
}

/// Simple badge display widget
class SimpleBadge extends StatelessWidget {
  final UserBadge badge;
  final double size;

  const SimpleBadge({
    super.key,
    required this.badge,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(badge.name),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [badge.color, badge.color.withAlpha(179)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.color.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          badge.icon,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Events attended counter with milestone progress
class EventsAttendedBadge extends StatelessWidget {
  final int count;
  final bool showProgress;

  const EventsAttendedBadge({
    super.key,
    required this.count,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final badge = AttendanceBadges.getHighestBadge(count);
    final next = AttendanceBadges.getNextMilestone(count);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(51)),
      ),
      child: Row(
        children: [
          // Badge or count
          if (badge != null)
            SimpleBadge(badge: badge, size: 50)
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withAlpha(51),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
            ),

          const SizedBox(width: AppSpacing.md),

          // Count and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Events Attended',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (showProgress && next != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: count / next.$1,
                            backgroundColor: AppColors.lightGrey,
                            valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        next.$2,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Events hosted counter for businesses
class EventsHostedBadge extends StatelessWidget {
  final int count;
  final double? rating;
  final int reviewCount;

  const EventsHostedBadge({
    super.key,
    required this.count,
    this.rating,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final badge = HostingBadges.getHighestBadge(count);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withAlpha(26),
            const Color(0xFFFFA500).withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFFFD700).withAlpha(77)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Badge or count
              if (badge != null)
                SimpleBadge(badge: badge, size: 50)
              else
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

              const SizedBox(width: AppSpacing.md),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count Events Hosted',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (badge != null)
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                  ],
                ),
              ),

              // Rating
              if (rating != null)
                RatingBadge(
                  rating: rating!,
                  reviewCount: reviewCount,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact badge row for profiles
class BadgeRow extends StatelessWidget {
  final int eventsAttended;
  final int? eventsHosted;
  final double? rating;
  final int reviewCount;
  final bool isBusinessAccount;

  const BadgeRow({
    super.key,
    required this.eventsAttended,
    this.eventsHosted,
    this.rating,
    this.reviewCount = 0,
    this.isBusinessAccount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Events attended/hosted
        _StatBadge(
          icon: isBusinessAccount ? Icons.event_available : Icons.event,
          value: isBusinessAccount ? (eventsHosted ?? 0) : eventsAttended,
          label: isBusinessAccount ? 'hosted' : 'attended',
          color: isBusinessAccount ? const Color(0xFFFFD700) : AppColors.primaryBlue,
        ),

        const SizedBox(width: 12),

        // Rating (for businesses)
        if (isBusinessAccount && rating != null)
          RatingBadge(
            rating: rating!,
            reviewCount: reviewCount,
            compact: true,
          ),

        // Milestone badge (for regular users)
        if (!isBusinessAccount) ...[
          if (AttendanceBadges.getHighestBadge(eventsAttended) != null)
            SimpleBadge(
              badge: AttendanceBadges.getHighestBadge(eventsAttended)!,
              size: 32,
            ),
        ],
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
