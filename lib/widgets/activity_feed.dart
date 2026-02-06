import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Simple activity feed showing friend updates
class ActivityFeed extends StatelessWidget {
  final List<FeedItem> items;

  const ActivityFeed({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: 20, color: AppColors.friendlyOrange),
            const SizedBox(width: 8),
            Text(
              'Friend Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _FeedItemCard(item: item)),
      ],
    );
  }
}

class FeedItem {
  final String userName;
  final String? userAvatar;
  final FeedAction action;
  final String? eventName;
  final String timeAgo;

  FeedItem({
    required this.userName,
    this.userAvatar,
    required this.action,
    this.eventName,
    required this.timeAgo,
  });
}

enum FeedAction {
  joined('joined', Icons.add_circle, AppColors.success),
  created('created', Icons.create, AppColors.friendlyPurple),
  reviewed('reviewed', Icons.star, AppColors.warmYellow),
  shared('shared', Icons.share, AppColors.primaryBlue),
  checkedIn('checked in at', Icons.location_on, AppColors.friendlyTeal);

  final String text;
  final IconData icon;
  final Color color;

  const FeedAction(this.text, this.icon, this.color);
}

class _FeedItemCard extends StatelessWidget {
  final FeedItem item;

  const _FeedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.action.color.withAlpha(51),
            ),
            child: Center(
              child: Text(
                item.userName[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item.action.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: item.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${item.action.text} '),
                      if (item.eventName != null)
                        TextSpan(
                          text: item.eventName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: item.action.color,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          // Action icon
          Icon(
            item.action.icon,
            size: 16,
            color: item.action.color,
          ),
        ],
      ),
    );
  }
}

/// Compact feed preview
class FeedPreview extends StatelessWidget {
  final int newUpdates;
  final VoidCallback? onTap;

  const FeedPreview({
    super.key,
    required this.newUpdates,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (newUpdates == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.friendlyOrange.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt,
              size: 16,
              color: AppColors.friendlyOrange,
            ),
            const SizedBox(width: 6),
            Text(
              '$newUpdates new update${newUpdates > 1 ? 's' : ''}',
              style: TextStyle(
                color: AppColors.friendlyOrange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
