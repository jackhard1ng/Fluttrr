import 'package:flutter/material.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';

/// Shows mutual friends between you and another user
class MutualFriendsRow extends StatelessWidget {
  final List<MutualFriend> friends;
  final VoidCallback? onTap;

  const MutualFriendsRow({
    super.key,
    required this.friends,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Stacked avatars
          SizedBox(
            width: 20 + (friends.take(3).length - 1) * 14.0,
            height: 24,
            child: Stack(
              children: [
                for (int i = 0; i < friends.take(3).length; i++)
                  Positioned(
                    left: i * 14.0,
                    child: _SmallAvatar(friend: friends[i]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildText(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _buildText() {
    if (friends.length == 1) {
      return '${friends[0].name} is a mutual friend';
    } else if (friends.length == 2) {
      return '${friends[0].name} and ${friends[1].name} are mutual friends';
    } else {
      return '${friends[0].name} and ${friends.length - 1} others are mutual friends';
    }
  }
}

class MutualFriend {
  final String name;
  final String? avatar;

  MutualFriend({required this.name, this.avatar});
}

class _SmallAvatar extends StatelessWidget {
  final MutualFriend friend;

  const _SmallAvatar({required this.friend});

  @override
  Widget build(BuildContext context) {
    final hasImage = friend.avatar != null &&
        ApiEndpoints.isValidImageUrl(friend.avatar);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryBlue.withAlpha(51),
        border: Border.all(color: Colors.white, width: 2),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(ApiEndpoints.getImageUrl(friend.avatar)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasImage
          ? Center(
              child: Text(
                friend.name[0],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            )
          : null,
    );
  }
}

/// Compact mutual friends badge
class MutualFriendsBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const MutualFriendsBadge({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people,
              size: 14,
              color: AppColors.friendlyPurple,
            ),
            const SizedBox(width: 4),
            Text(
              '$count mutual',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.friendlyPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nearby friends indicator
class NearbyFriendsIndicator extends StatelessWidget {
  final int count;
  final String? closestFriendName;
  final VoidCallback? onTap;

  const NearbyFriendsIndicator({
    super.key,
    required this.count,
    this.closestFriendName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.friendlyTeal.withAlpha(26),
              AppColors.primaryBlue.withAlpha(26),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyTeal.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.near_me,
              size: 18,
              color: AppColors.friendlyTeal,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count friend${count > 1 ? 's' : ''} nearby',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.friendlyTeal,
                    fontSize: 13,
                  ),
                ),
                if (closestFriendName != null)
                  Text(
                    '$closestFriendName is closest',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.friendlyTeal,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Friends also going" section
class FriendsGoingSection extends StatelessWidget {
  final List<MutualFriend> friends;
  final int totalGoing;

  const FriendsGoingSection({
    super.key,
    required this.friends,
    required this.totalGoing,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Friends Going',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const Spacer(),
              Text(
                '+${totalGoing - friends.length} others',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: friends.take(5).map((friend) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SmallAvatar(friend: friend),
                    const SizedBox(width: 6),
                    Text(
                      friend.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
