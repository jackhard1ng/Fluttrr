import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class ChatSettingsScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String? userAvatar;
  final bool isGroup;

  const ChatSettingsScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.userAvatar,
    this.isGroup = false,
  });

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _isMuted = false;
  bool _isBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with profile
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryBlue.withAlpha(26),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryBlue.withAlpha(51),
                      child: widget.isGroup
                          ? Icon(Icons.group, size: 40, color: AppColors.primaryBlue)
                          : Text(
                              widget.userName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!widget.isGroup)
                      Text(
                        'Active now',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      // View profile
                    },
                  ),
                  _ActionButton(
                    icon: _isMuted ? Icons.notifications_off : Icons.notifications,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isMuted = !_isMuted);
                    },
                  ),
                  _ActionButton(
                    icon: Icons.search,
                    label: 'Search',
                    onTap: () {
                      // Search in chat
                    },
                  ),
                ],
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media section
                  _SectionHeader(title: 'Shared Media'),
                  _MediaPreviewRow(),
                  const SizedBox(height: 24),

                  // Notifications
                  _SectionHeader(title: 'Notifications'),
                  _SettingsTile(
                    icon: Icons.notifications,
                    title: 'Mute Notifications',
                    trailing: Switch(
                      value: _isMuted,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        setState(() => _isMuted = v);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.volume_up,
                    title: 'Custom Notification Sound',
                    subtitle: 'Default',
                    onTap: () {
                      // Choose sound
                    },
                  ),
                  const SizedBox(height: 24),

                  // Privacy
                  _SectionHeader(title: 'Privacy'),
                  _SettingsTile(
                    icon: Icons.lock,
                    title: 'Encryption',
                    subtitle: 'Messages are end-to-end encrypted',
                    onTap: () {
                      _showEncryptionInfo();
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.timer,
                    title: 'Disappearing Messages',
                    subtitle: 'Off',
                    onTap: () {
                      _showDisappearingOptions();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  _SectionHeader(title: 'Actions'),
                  if (!widget.isGroup) ...[
                    _SettingsTile(
                      icon: Icons.block,
                      title: _isBlocked ? 'Unblock ${widget.userName}' : 'Block ${widget.userName}',
                      isDestructive: !_isBlocked,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showBlockConfirmation();
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.report,
                      title: 'Report ${widget.userName}',
                      isDestructive: true,
                      onTap: () {
                        // Report user
                      },
                    ),
                  ],
                  _SettingsTile(
                    icon: Icons.delete,
                    title: 'Delete Chat',
                    isDestructive: true,
                    onTap: () {
                      _showDeleteConfirmation();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEncryptionInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 48, color: AppColors.success),
            const SizedBox(height: 16),
            const Text(
              'End-to-End Encryption',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Messages and calls are secured with end-to-end encryption. Only you and ${widget.userName} can read or listen to them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDisappearingOptions() {
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
            const Text(
              'Disappearing Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...['Off', '24 hours', '7 days', '90 days'].map((option) {
              return ListTile(
                title: Text(option),
                trailing: option == 'Off'
                    ? Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () => Get.back(),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(_isBlocked ? 'Unblock' : 'Block ${widget.userName}?'),
        content: Text(
          _isBlocked
              ? '${widget.userName} will be able to message you again.'
              : '${widget.userName} will no longer be able to message you or see your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _isBlocked = !_isBlocked);
              Get.back();
              Get.snackbar(
                _isBlocked ? 'Blocked' : 'Unblocked',
                _isBlocked
                    ? '${widget.userName} has been blocked'
                    : '${widget.userName} has been unblocked',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text(
              _isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(color: _isBlocked ? null : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text(
          'This will permanently delete all messages in this chat. This action cannot be undone.',
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
                'Chat Deleted',
                'The chat has been deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withAlpha(128),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.mediumGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MediaPreviewRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...List.generate(5, (index) {
            return Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.image, color: AppColors.mediumGrey),
            );
          }),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Show all media
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: AppColors.primaryBlue),
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.darkGrey;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withAlpha(13)
              : AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
