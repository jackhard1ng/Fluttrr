import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Friend group card
class FriendGroupCard extends StatelessWidget {
  final String name;
  final String? emoji;
  final List<GroupMember> members;
  final int memberCount;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const FriendGroupCard({
    super.key,
    required this.name,
    this.emoji,
    required this.members,
    required this.memberCount,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      emoji ?? '👥',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$memberCount member${memberCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onMoreOptions != null)
                  GestureDetector(
                    onTap: onMoreOptions,
                    child: Icon(
                      Icons.more_horiz,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Member avatars
            Row(
              children: [
                ...members.take(5).asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(left: entry.key > 0 ? 0 : 0),
                    child: Transform.translate(
                      offset: Offset(-entry.key * 8.0, 0),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(51),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: entry.value.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(entry.value.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: entry.value.imageUrl == null
                            ? Center(
                                child: Text(
                                  entry.value.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
                if (memberCount > 5)
                  Transform.translate(
                    offset: Offset(-5 * 8.0, 0),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '+${memberCount - 5}',
                          style: TextStyle(
                            color: AppColors.mediumGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
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

/// Group member model
class GroupMember {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isAdmin;

  GroupMember({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isAdmin = false,
  });
}

/// Create group form
class CreateGroupCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateGroupCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primaryBlue.withAlpha(51),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Create a Group',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize your friends',
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group member list item
class GroupMemberItem extends StatelessWidget {
  final GroupMember member;
  final bool isCurrentUser;
  final VoidCallback? onRemove;
  final VoidCallback? onMakeAdmin;

  const GroupMemberItem({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.onRemove,
    this.onMakeAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              shape: BoxShape.circle,
              image: member.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(member.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: member.imageUrl == null
                ? Icon(Icons.person, color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentUser ? 'You' : member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.friendlyPurple.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.friendlyPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!isCurrentUser && (onRemove != null || onMakeAdmin != null))
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.mediumGrey),
              onSelected: (value) {
                if (value == 'remove') {
                  onRemove?.call();
                } else if (value == 'admin') {
                  onMakeAdmin?.call();
                }
              },
              itemBuilder: (context) => [
                if (onMakeAdmin != null && !member.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 20),
                        SizedBox(width: 8),
                        Text('Make admin'),
                      ],
                    ),
                  ),
                if (onRemove != null)
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, size: 20, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Add friends to group widget
class AddToGroupWidget extends StatelessWidget {
  final List<GroupMember> availableFriends;
  final List<String> selectedIds;
  final Function(String) onToggle;

  const AddToGroupWidget({
    super.key,
    required this.availableFriends,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add friends',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...availableFriends.map((friend) {
          final isSelected = selectedIds.contains(friend.id);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle(friend.id);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withAlpha(26)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.lightGrey,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(26),
                      shape: BoxShape.circle,
                      image: friend.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(friend.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: friend.imageUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      friend.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.mediumGrey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Group quick actions
class GroupQuickActions extends StatelessWidget {
  final VoidCallback? onMessage;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onInvite;

  const GroupQuickActions({
    super.key,
    this.onMessage,
    this.onCreateEvent,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.chat,
            label: 'Message',
            color: AppColors.primaryBlue,
            onTap: onMessage,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.event,
            label: 'Create Event',
            color: AppColors.friendlyPurple,
            onTap: onCreateEvent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.person_add,
            label: 'Invite',
            color: AppColors.friendlyTeal,
            onTap: onInvite,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group emoji picker
class GroupEmojiPicker extends StatelessWidget {
  final String? selectedEmoji;
  final Function(String) onSelect;

  const GroupEmojiPicker({
    super.key,
    this.selectedEmoji,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = [
      '👥', '🎉', '🎮', '⚽', '🎬', '🍕', '☕', '🏃',
      '📚', '🎵', '✈️', '🎨', '💼', '🏠', '🌟', '❤️',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emojis.map((emoji) {
        final isSelected = emoji == selectedEmoji;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(emoji);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withAlpha(26)
                  : AppColors.lightGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: isSelected
                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Group activity indicator
class GroupActivityIndicator extends StatelessWidget {
  final int activeMembers;
  final int totalMembers;
  final String? lastActivity;

  const GroupActivityIndicator({
    super.key,
    required this.activeMembers,
    required this.totalMembers,
    this.lastActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activeMembers > 0 ? AppColors.success : AppColors.mediumGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activeMembers > 0
                ? '$activeMembers of $totalMembers active'
                : 'No one active',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
          if (lastActivity != null) ...[
            const Text(' · '),
            Text(
              lastActivity!,
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
}
