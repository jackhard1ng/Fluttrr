import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Last seen at event badge
class LastSeenBadge extends StatelessWidget {
  final String eventName;
  final String timeAgo;
  final VoidCallback? onTap;

  const LastSeenBadge({
    super.key,
    required this.eventName,
    required this.timeAgo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 14, color: AppColors.mediumGrey),
            const SizedBox(width: 6),
            Text(
              'Seen at ',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
            Text(
              eventName,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Online status indicator
class OnlineStatus extends StatelessWidget {
  final bool isOnline;
  final String? lastSeen;

  const OnlineStatus({
    super.key,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppColors.success : AppColors.mediumGrey,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'Online' : lastSeen ?? 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: isOnline ? AppColors.success : AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

/// Profile last active
class LastActive extends StatelessWidget {
  final String activity;
  final String timeAgo;

  const LastActive({
    super.key,
    required this.activity,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: AppColors.mediumGrey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
                children: [
                  TextSpan(text: activity),
                  TextSpan(
                    text: ' • $timeAgo',
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mutual event attended
class MutualEventBadge extends StatelessWidget {
  final String eventName;
  final VoidCallback? onTap;

  const MutualEventBadge({
    super.key,
    required this.eventName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available, size: 14, color: AppColors.friendlyPurple),
            const SizedBox(width: 6),
            Text(
              'Both at $eventName',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.friendlyPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Events in common count
class EventsInCommon extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const EventsInCommon({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.friendlyTeal.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_repeat, size: 14, color: AppColors.friendlyTeal),
            const SizedBox(width: 5),
            Text(
              '$count event${count > 1 ? 's' : ''} together',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.friendlyTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
