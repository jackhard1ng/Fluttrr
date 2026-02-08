import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../models/chat_model.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFriend = false;
  bool _isPending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _showOptionsMenu(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.friendlyPurple,
                        ],
                      ),
                    ),
                  ),
                  // Profile info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 47,
                            backgroundColor: AppColors.primaryBlue.withAlpha(51),
                            child: Text(
                              widget.userName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.white.withAlpha(204)),
                            const SizedBox(width: 4),
                            Text(
                              'San Francisco, CA',
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: _isFriend
                          ? Icons.person_remove
                          : _isPending
                              ? Icons.hourglass_top
                              : Icons.person_add,
                      label: _isFriend
                          ? 'Friends'
                          : _isPending
                              ? 'Pending'
                              : 'Add Friend',
                      isPrimary: !_isFriend && !_isPending,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (_isFriend) {
                          _showUnfriendDialog();
                        } else if (!_isPending) {
                          setState(() => _isPending = true);
                          Get.snackbar(
                            'Request Sent',
                            'Friend request sent to ${widget.userName}',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.message,
                      label: 'Message',
                      onTap: () {
                        final conversation = ChatConversation(
                          id: 'conv_${widget.userId}',
                          displayName: widget.userName,
                          otherUserId: widget.userId,
                          lastMessage: '',
                          isOnline: false,
                          unreadCount: 0,
                        );
                        Nav.toChat(conversation);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(77),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(value: '24', label: 'Events'),
                    _StatItem(value: '156', label: 'Friends'),
                    _StatItem(value: '4.8', label: 'Rating'),
                  ],
                ),
              ),
            ),
          ),

          // About section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Love meeting new people and trying new experiences! Always up for coffee, hiking, or board game nights. Let\'s hang out!',
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Interests
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Hiking',
                      'Board Games',
                      'Coffee',
                      'Music',
                      'Photography',
                      'Travel',
                    ].map((interest) => _InterestChip(label: interest)).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Mutual friends
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mutual Friends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '3 friends',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _MutualFriendTile(name: 'Alex'),
                        _MutualFriendTile(name: 'Jordan'),
                        _MutualFriendTile(name: 'Taylor'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent events
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentEventTile(
                    title: 'Board Game Night',
                    date: 'Last week',
                    attendees: 8,
                  ),
                  _RecentEventTile(
                    title: 'Coffee Meetup',
                    date: '2 weeks ago',
                    attendees: 5,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.primaryBlue),
              title: const Text('Share Profile'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Share Link Copied',
                  'Profile link copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.error),
              title: Text('Block ${widget.userName}'),
              subtitle: Text(
                'They won\'t be able to see your profile or contact you',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Get.back();
                _showBlockDialog();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.friendlyOrange),
              title: Text('Report ${widget.userName}'),
              subtitle: Text(
                'Report inappropriate content or behavior',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Get.back();
                Nav.toReport(userName: widget.userName);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.primaryBlue),
              title: const Text('Get help'),
              subtitle: Text(
                'Contact support at support@fluttrr.com',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Get.back();
                Nav.toHelp();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUnfriendDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove ${widget.userName} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isFriend = false;
                _isPending = false;
              });
              Get.back();
            },
            child: Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Block ${widget.userName}?'),
        content: const Text(
          'They won\'t be able to see your profile or message you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
              Get.snackbar(
                'Blocked',
                '${widget.userName} has been blocked',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Block', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryBlue : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : AppColors.darkGrey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;

  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MutualFriendTile extends StatelessWidget {
  final String name;

  const _MutualFriendTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to mutual friend's profile
        Get.to(
          () => UserProfileScreen(
            userId: 'mutual_${name.toLowerCase()}',
            userName: name,
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.friendlyPurple.withAlpha(51),
              child: Text(
                name[0],
                style: TextStyle(
                  color: AppColors.friendlyPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEventTile extends StatelessWidget {
  final String title;
  final String date;
  final int attendees;

  const _RecentEventTile({
    required this.title,
    required this.date,
    required this.attendees,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Nav.toDiscover();
        Get.snackbar(
          title,
          'Viewing past event details',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.event, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$date • $attendees attended',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.mediumGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
