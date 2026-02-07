import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Share button
class ShareButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool compact;

  const ShareButton({
    super.key,
    this.onTap,
    this.compact = false,
  });

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (onTap != null) {
      onTap!();
    } else {
      _showShareSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: _handleTap,
        child: Icon(Icons.share, color: AppColors.mediumGrey),
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share, size: 18, color: AppColors.darkGrey),
            const SizedBox(width: 8),
            Text(
              'Share',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet() {
    Get.bottomSheet(const ShareSheet());
  }
}

/// Share sheet with platform options
class ShareSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final String? url;

  const ShareSheet({
    super.key,
    this.title,
    this.message,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Share',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.message,
                label: 'Message',
                color: AppColors.success,
                onTap: () {
                  Get.back();
                  // Would open messages
                },
              ),
              _ShareOption(
                icon: Icons.copy,
                label: 'Copy Link',
                color: AppColors.mediumGrey,
                onTap: () {
                  Get.back();
                  Clipboard.setData(ClipboardData(text: url ?? 'fluttrr.app/share'));
                  Get.snackbar(
                    'Copied',
                    'Link copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _ShareOption(
                icon: Icons.mail,
                label: 'Email',
                color: AppColors.primaryBlue,
                onTap: () {
                  Get.back();
                  // Would open email
                },
              ),
              _ShareOption(
                icon: Icons.more_horiz,
                label: 'More',
                color: AppColors.friendlyPurple,
                onTap: () {
                  Get.back();
                  // Would open system share
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Send to friends
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Send to Friends',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FriendShareTile(name: 'Alex', onTap: () {}),
                _FriendShareTile(name: 'Jordan', onTap: () {}),
                _FriendShareTile(name: 'Taylor', onTap: () {}),
                _FriendShareTile(name: 'Sam', onTap: () {}),
                _FriendShareTile(name: 'Chris', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
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

class _FriendShareTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _FriendShareTile({
    required this.name,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryBlue.withAlpha(26),
              child: Text(
                name[0],
                style: TextStyle(
                  color: AppColors.primaryBlue,
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

/// Invite friends widget
class InviteFriends extends StatelessWidget {
  final String title;
  final VoidCallback? onInvite;

  const InviteFriends({
    super.key,
    this.title = 'Invite Friends',
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple.withAlpha(26),
            AppColors.primaryBlue.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bring your friends along!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onInvite?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Invite',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// QR code share card
class QRShareCard extends StatelessWidget {
  final String code;
  final String? title;

  const QRShareCard({
    super.key,
    required this.code,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Placeholder QR code
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 80,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan to join',
            style: TextStyle(
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
