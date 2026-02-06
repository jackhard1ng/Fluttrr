import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Activity timeline showing what friends are doing
class ActivityTimeline extends StatelessWidget {
  final List<FriendActivity> activities;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const ActivityTimeline({
    super.key,
    required this.activities,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const _EmptyTimeline();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: activities.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final activity = activities[index];
        final showDate = index == 0 ||
            !_isSameDay(activities[index - 1].timestamp, activity.timestamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDate) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  _formatDateHeader(activity.timestamp),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mediumGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            _ActivityItem(activity: activity),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }
}

class _ActivityItem extends StatelessWidget {
  final FriendActivity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type).withAlpha(26),
                  shape: BoxShape.circle,
                  image: activity.userImage != null
                      ? DecorationImage(
                          image: NetworkImage(activity.userImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: activity.userImage == null
                    ? Icon(
                        Icons.person,
                        color: _getActivityColor(activity.type),
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),

              // Name and action
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                        children: [
                          TextSpan(
                            text: activity.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${activity.actionText}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(activity.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Activity type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type).withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: _getActivityColor(activity.type),
                  size: 18,
                ),
              ),
            ],
          ),

          // Event/content preview
          if (activity.eventName != null || activity.preview != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  if (activity.eventImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: Image.network(
                        activity.eventImage!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activity.eventName != null)
                          Text(
                            activity.eventName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (activity.preview != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            activity.preview!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          if (activity.showActions) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ActionChip(
                  icon: Icons.favorite_border,
                  label: activity.likeCount > 0 ? '${activity.likeCount}' : 'Like',
                  isActive: activity.isLiked,
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comment',
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                const Spacer(),
                if (activity.canJoin)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.joinedEvent:
        return AppColors.success;
      case ActivityType.createdEvent:
        return AppColors.friendlyPurple;
      case ActivityType.newFriend:
        return AppColors.friendlyTeal;
      case ActivityType.checkedIn:
        return AppColors.primaryBlue;
      case ActivityType.sharedPhoto:
        return AppColors.friendlyOrange;
      case ActivityType.achievement:
        return AppColors.warmYellow;
      case ActivityType.review:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.joinedEvent:
        return Icons.event_available;
      case ActivityType.createdEvent:
        return Icons.add_circle_outline;
      case ActivityType.newFriend:
        return Icons.people;
      case ActivityType.checkedIn:
        return Icons.location_on;
      case ActivityType.sharedPhoto:
        return Icons.photo_camera;
      case ActivityType.achievement:
        return Icons.emoji_events;
      case ActivityType.review:
        return Icons.star;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.favorite : icon,
              size: 16,
              color: isActive ? AppColors.error : AppColors.mediumGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primaryBlue : AppColors.mediumGrey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No activity yet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with friends to see\nwhat they\'re up to',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact activity feed widget
class CompactActivityFeed extends StatelessWidget {
  final List<FriendActivity> activities;
  final int maxItems;
  final VoidCallback? onSeeAll;

  const CompactActivityFeed({
    super.key,
    required this.activities,
    this.maxItems = 3,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Friends Activity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (onSeeAll != null && activities.length > maxItems)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...displayActivities.map((activity) {
          return _CompactActivityItem(activity: activity);
        }),
      ],
    );
  }
}

class _CompactActivityItem extends StatelessWidget {
  final FriendActivity activity;

  const _CompactActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              shape: BoxShape.circle,
              image: activity.userImage != null
                  ? DecorationImage(
                      image: NetworkImage(activity.userImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: activity.userImage == null
                ? const Icon(Icons.person, size: 18, color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(width: 10),

          // Text
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
                children: [
                  TextSpan(
                    text: activity.userName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' ${activity.shortActionText}'),
                ],
              ),
            ),
          ),

          // Time
          Text(
            _formatTimeShort(activity.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeShort(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

/// Activity types enum
enum ActivityType {
  joinedEvent,
  createdEvent,
  newFriend,
  checkedIn,
  sharedPhoto,
  achievement,
  review,
}

/// Friend activity model
class FriendActivity {
  final String id;
  final String userName;
  final String? userImage;
  final ActivityType type;
  final String actionText;
  final String shortActionText;
  final DateTime timestamp;
  final String? eventName;
  final String? eventImage;
  final String? preview;
  final bool showActions;
  final bool canJoin;
  final int likeCount;
  final bool isLiked;

  FriendActivity({
    required this.id,
    required this.userName,
    this.userImage,
    required this.type,
    required this.actionText,
    String? shortActionText,
    required this.timestamp,
    this.eventName,
    this.eventImage,
    this.preview,
    this.showActions = true,
    this.canJoin = false,
    this.likeCount = 0,
    this.isLiked = false,
  }) : shortActionText = shortActionText ?? actionText;
}
