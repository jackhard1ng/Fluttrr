import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Business contact info
class BusinessContact extends StatelessWidget {
  final String? phone;
  final String? email;
  final String? website;
  final String? address;

  const BusinessContact({
    super.key,
    this.phone,
    this.email,
    this.website,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        if (phone != null)
          _ContactRow(
            icon: Icons.phone,
            value: phone!,
            onTap: () => _copyToClipboard(phone!, 'Phone'),
          ),
        if (email != null)
          _ContactRow(
            icon: Icons.email,
            value: email!,
            onTap: () => _copyToClipboard(email!, 'Email'),
          ),
        if (website != null)
          _ContactRow(
            icon: Icons.language,
            value: website!,
            onTap: () => _copyToClipboard(website!, 'Website'),
          ),
        if (address != null)
          _ContactRow(
            icon: Icons.location_on,
            value: address!,
            onTap: () => _copyToClipboard(address!, 'Address'),
          ),
      ],
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Copied!',
      '$label copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ),
            Icon(Icons.copy, size: 16, color: AppColors.mediumGrey),
          ],
        ),
      ),
    );
  }
}

/// Social media links
class SocialLinks extends StatelessWidget {
  final String? instagram;
  final String? facebook;
  final String? twitter;
  final String? tiktok;

  const SocialLinks({
    super.key,
    this.instagram,
    this.facebook,
    this.twitter,
    this.tiktok,
  });

  @override
  Widget build(BuildContext context) {
    final links = <_SocialLink>[
      if (instagram != null)
        _SocialLink('Instagram', Icons.camera_alt, AppColors.friendlyPurple, instagram!),
      if (facebook != null)
        _SocialLink('Facebook', Icons.facebook, AppColors.primaryBlue, facebook!),
      if (twitter != null)
        _SocialLink('Twitter', Icons.alternate_email, Color(0xFF1DA1F2), twitter!),
      if (tiktok != null)
        _SocialLink('TikTok', Icons.music_note, AppColors.darkGrey, tiktok!),
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Row(
      children: links.map((link) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: link.url));
              Get.snackbar(
                'Copied!',
                '${link.name} link copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: link.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(link.icon, size: 20, color: link.color),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SocialLink {
  final String name;
  final IconData icon;
  final Color color;
  final String url;

  _SocialLink(this.name, this.icon, this.color, this.url);
}

/// Verified business badge
class VerifiedBusinessBadge extends StatelessWidget {
  final bool isLarge;

  const VerifiedBusinessBadge({super.key, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Verified Business',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 12, color: Colors.white),
    );
  }
}

/// Business type badge
class BusinessTypeBadge extends StatelessWidget {
  final BusinessType type;

  const BusinessTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: type.color),
          const SizedBox(width: 5),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 12,
              color: type.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum BusinessType {
  restaurant(Icons.restaurant, 'Restaurant', AppColors.friendlyOrange),
  bar(Icons.local_bar, 'Bar', AppColors.friendlyPurple),
  cafe(Icons.local_cafe, 'Cafe', Color(0xFF795548)),
  club(Icons.nightlife, 'Club', AppColors.primaryBlue),
  gym(Icons.fitness_center, 'Gym', AppColors.success),
  studio(Icons.palette, 'Studio', AppColors.warmYellow),
  venue(Icons.business, 'Venue', AppColors.mediumGrey),
  other(Icons.store, 'Business', AppColors.friendlyTeal);

  final IconData icon;
  final String label;
  final Color color;

  const BusinessType(this.icon, this.label, this.color);
}

/// Follow business button
class FollowBusinessButton extends StatelessWidget {
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onToggle;

  const FollowBusinessButton({
    super.key,
    this.isFollowing = false,
    this.followerCount = 0,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isFollowing
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primaryBlue,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowing ? Icons.check : Icons.add,
              size: 18,
              color: isFollowing ? AppColors.primaryBlue : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                color: isFollowing ? AppColors.primaryBlue : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (followerCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFollowing
                      ? AppColors.primaryBlue.withAlpha(26)
                      : Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  _formatCount(followerCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: isFollowing ? AppColors.primaryBlue : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}
