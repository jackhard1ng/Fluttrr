import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Unread count badge
class UnreadBadge extends StatelessWidget {
  final int count;
  final bool isSmall;

  const UnreadBadge({
    super.key,
    required this.count,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    final displayCount = count > 99 ? '99+' : '$count';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 5 : 7,
        vertical: isSmall ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayCount,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmall ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Notification dot
class NotificationDot extends StatelessWidget {
  final Color? color;
  final double size;

  const NotificationDot({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// New badge
class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Updated badge
class UpdatedBadge extends StatelessWidget {
  final String? timeAgo;

  const UpdatedBadge({super.key, this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update, size: 12, color: AppColors.primaryBlue),
          const SizedBox(width: 4),
          Text(
            timeAgo ?? 'Updated',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification item
class NotificationItem extends StatelessWidget {
  final NotificationType type;
  final String title;
  final String? subtitle;
  final String timeAgo;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primaryBlue.withAlpha(13)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.lightGrey),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, size: 20, color: type.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              const NotificationDot(),
          ],
        ),
      ),
    );
  }
}

enum NotificationType {
  event(Icons.event, AppColors.primaryBlue),
  friend(Icons.person_add, AppColors.friendlyPurple),
  message(Icons.chat_bubble, AppColors.friendlyTeal),
  reminder(Icons.notifications, AppColors.friendlyOrange),
  update(Icons.info, AppColors.mediumGrey);

  final IconData icon;
  final Color color;

  const NotificationType(this.icon, this.color);
}

/// Notification permission prompt
class NotificationPrompt extends StatelessWidget {
  final VoidCallback? onEnable;
  final VoidCallback? onDismiss;

  const NotificationPrompt({
    super.key,
    this.onEnable,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(51)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stay in the loop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Get notified about events and friends',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 20, color: AppColors.mediumGrey),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onEnable,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Center(
                child: Text(
                  'Enable Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
