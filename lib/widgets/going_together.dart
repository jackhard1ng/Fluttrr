import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Simple "Going with" indicator
class GoingWithBadge extends StatelessWidget {
  final List<String> friendNames;
  final VoidCallback? onTap;

  const GoingWithBadge({
    super.key,
    required this.friendNames,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (friendNames.isEmpty) return const SizedBox.shrink();

    String text;
    if (friendNames.length == 1) {
      text = 'Going with ${friendNames.first}';
    } else if (friendNames.length == 2) {
      text = 'Going with ${friendNames.first} & ${friendNames[1]}';
    } else {
      text = 'Going with ${friendNames.first} +${friendNames.length - 1}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invite friends to go together
class InviteToGoTogether extends StatelessWidget {
  final List<FriendToInvite> friends;
  final Function(String friendId) onInvite;

  const InviteToGoTogether({
    super.key,
    required this.friends,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.group_add, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Invite friends to join',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FriendInviteChip(
                  friend: friend,
                  onInvite: () => onInvite(friend.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FriendToInvite {
  final String id;
  final String name;
  final bool isInvited;
  final bool isGoing;

  FriendToInvite({
    required this.id,
    required this.name,
    this.isInvited = false,
    this.isGoing = false,
  });
}

class _FriendInviteChip extends StatelessWidget {
  final FriendToInvite friend;
  final VoidCallback onInvite;

  const _FriendInviteChip({required this.friend, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    final color = friend.isGoing
        ? AppColors.success
        : friend.isInvited
            ? AppColors.friendlyOrange
            : AppColors.primaryBlue;

    return GestureDetector(
      onTap: friend.isGoing ? null : () {
        HapticFeedback.lightImpact();
        onInvite();
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(26),
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    friend.name[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ),
              ),
              if (friend.isGoing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            friend.name.split(' ').first,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Squad indicator - your usual group
class SquadBadge extends StatelessWidget {
  final String squadName;
  final int memberCount;
  final VoidCallback? onTap;

  const SquadBadge({
    super.key,
    required this.squadName,
    required this.memberCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyPurple.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups, size: 18, color: AppColors.friendlyPurple),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  squadName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.friendlyPurple,
                  ),
                ),
                Text(
                  '$memberCount members',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple "also going" indicator
class AlsoGoing extends StatelessWidget {
  final List<String> names;

  const AlsoGoing({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    String text;
    if (names.length == 1) {
      text = '${names.first} is also going';
    } else if (names.length == 2) {
      text = '${names.first} and ${names[1]} are going';
    } else {
      text = '${names.first}, ${names[1]} +${names.length - 2} are going';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.friendlyTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Stacked avatars
          SizedBox(
            width: 40 + (names.take(3).length - 1) * 15.0,
            height: 30,
            child: Stack(
              children: names.take(3).toList().asMap().entries.map((entry) {
                return Positioned(
                  left: entry.key * 15.0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.friendlyTeal,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        entry.value[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.friendlyTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
