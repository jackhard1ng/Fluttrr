import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../config/routes.dart';
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

  void _showActivityOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${item.action.text} ${item.eventName ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primaryBlue),
              title: Text('View ${item.userName}\'s Profile'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toUserProfile(
                  userId: 'feed_${item.userName.toLowerCase().replaceAll(' ', '_')}',
                  userName: item.userName,
                );
              },
            ),
            if (item.eventName != null)
              ListTile(
                leading: Icon(Icons.event, color: item.action.color),
                title: Text('View ${item.eventName}'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Nav.toDiscover();
                },
              ),
            ListTile(
              leading: Icon(Icons.thumb_up, color: AppColors.success),
              title: const Text('Like This'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  '👍 Liked!',
                  '${item.userName} will see your reaction',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.comment, color: AppColors.friendlyTeal),
              title: const Text('Comment'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                _showCommentDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.visibility_off, color: AppColors.mediumGrey),
              title: const Text('Hide This Update'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Update Hidden',
                  'You won\'t see similar updates from ${item.userName}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment on ${item.userName}\'s activity',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (commentController.text.trim().isNotEmpty) {
                      Get.snackbar(
                        'Comment Posted!',
                        '${item.userName} will be notified',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text('Post', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (item.eventName != null) {
          Nav.toDiscover();
        } else {
          Nav.toUserProfile(
            userId: 'feed_${item.userName.toLowerCase().replaceAll(' ', '_')}',
            userName: item.userName,
          );
        }
      },
      onLongPress: () => _showActivityOptions(context),
      child: Padding(
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
