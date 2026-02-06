import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Quick share options for events
class ShareOptions extends StatelessWidget {
  final String eventName;
  final String? eventUrl;
  final VoidCallback? onCopyLink;
  final VoidCallback? onShareMessage;

  const ShareOptions({
    super.key,
    required this.eventName,
    this.eventUrl,
    this.onCopyLink,
    this.onShareMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShareButton(
            icon: Icons.link,
            label: 'Copy Link',
            color: AppColors.primaryBlue,
            onTap: onCopyLink ?? () {
              HapticFeedback.mediumImpact();
              Get.snackbar(
                'Link Copied!',
                'Share it with anyone',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryBlue,
                colorText: Colors.white,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShareButton(
            icon: Icons.message,
            label: 'Send Invite',
            color: AppColors.friendlyTeal,
            onTap: onShareMessage ?? () => _showShareSheet(context),
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareMessageSheet(eventName: eventName),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Share message composer
class ShareMessageSheet extends StatelessWidget {
  final String eventName;

  const ShareMessageSheet({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) {
    final messages = [
      "Hey! Want to join me at $eventName?",
      "Found this cool event - $eventName. You in?",
      "This looks fun! $eventName - let's go together!",
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with a message',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...messages.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: msg));
                      Navigator.pop(context);
                      Get.snackbar(
                        'Copied!',
                        'Message ready to paste',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(77),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              msg,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Icon(
                            Icons.copy,
                            size: 18,
                            color: AppColors.mediumGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

/// Compact share button
class ShareButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ShareButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.share_outlined,
          size: 20,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}

/// Save/bookmark button
class SaveButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onToggle;

  const SaveButton({
    super.key,
    required this.isSaved,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSaved
              ? AppColors.warmYellow.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_outline,
          size: 20,
          color: isSaved ? AppColors.warmYellow : AppColors.darkGrey,
        ),
      ),
    );
  }
}
