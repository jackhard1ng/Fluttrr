import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// User badge display
class UserBadge extends StatelessWidget {
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const UserBadge({
    super.key,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge collection display
class BadgeCollection extends StatelessWidget {
  final List<BadgeItem> badges;
  final int maxDisplay;
  final VoidCallback? onViewAll;

  const BadgeCollection({
    super.key,
    required this.badges,
    this.maxDisplay = 4,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayBadges = badges.take(maxDisplay).toList();
    final remaining = badges.length - maxDisplay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...displayBadges.map((badge) => GestureDetector(
                  onTap: () => _showBadgeDetails(badge),
                  child: UserBadge(
                    name: badge.name,
                    icon: badge.icon,
                    color: badge.color,
                  ),
                )),
            if (remaining > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showBadgeDetails(BadgeItem badge) {
    HapticFeedback.lightImpact();
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
            UserBadge(
              name: badge.name,
              description: badge.description,
              icon: badge.icon,
              color: badge.color,
              isLarge: true,
            ),
            const SizedBox(height: 20),
            if (badge.earnedAt != null)
              Text(
                'Earned on ${_formatDate(badge.earnedAt!)}',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class BadgeItem {
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  final DateTime? earnedAt;

  BadgeItem({
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.earnedAt,
  });
}

/// Achievement unlocked animation
class AchievementUnlocked extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;

  const AchievementUnlocked({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.color = Colors.amber,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withAlpha(179),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievement Unlocked!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: Colors.white.withAlpha(179)),
            ),
        ],
      ),
    );
  }
}

/// Verified badge
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showTooltip;

  const VerifiedBadge({
    super.key,
    this.size = 16,
    this.showTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.7,
      ),
    );

    if (showTooltip) {
      return Tooltip(
        message: 'Verified Account',
        child: badge,
      );
    }

    return badge;
  }
}

/// Host badge
class HostBadge extends StatelessWidget {
  final bool isVerified;

  const HostBadge({super.key, this.isVerified = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.friendlyOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: AppColors.friendlyOrange),
          const SizedBox(width: 4),
          Text(
            'Host',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.friendlyOrange,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            VerifiedBadge(size: 12),
          ],
        ],
      ),
    );
  }
}

/// New user badge
class NewUserBadge extends StatelessWidget {
  const NewUserBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Premium badge
class PremiumBadge extends StatelessWidget {
  final bool isSmall;

  const PremiumBadge({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    if (isSmall) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warmYellow, AppColors.friendlyOrange],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.diamond, size: 10, color: Colors.white),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warmYellow, AppColors.friendlyOrange],
        ),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
