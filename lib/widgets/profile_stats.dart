import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Profile stats row
class ProfileStats extends StatelessWidget {
  final int eventsAttended;
  final int friendsCount;
  final int hostingCount;

  const ProfileStats({
    super.key,
    this.eventsAttended = 0,
    this.friendsCount = 0,
    this.hostingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: '$eventsAttended',
              label: 'Events',
              icon: Icons.event,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGrey,
          ),
          Expanded(
            child: _StatColumn(
              value: '$friendsCount',
              label: 'Friends',
              icon: Icons.people,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGrey,
          ),
          Expanded(
            child: _StatColumn(
              value: '$hostingCount',
              label: 'Hosted',
              icon: Icons.star,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
  });

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
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: AppColors.mediumGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact stat badge
class StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? color;

  const StatBadge({
    super.key,
    required this.icon,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Member since badge
class MemberSince extends StatelessWidget {
  final String date;

  const MemberSince({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: AppColors.mediumGrey),
          const SizedBox(width: 5),
          Text(
            'Member since $date',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile completion indicator
class ProfileCompletion extends StatelessWidget {
  final int percentage;
  final VoidCallback? onComplete;

  const ProfileCompletion({
    super.key,
    required this.percentage,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (percentage >= 100) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onComplete,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primaryBlue.withAlpha(51)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complete your profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// About section
class AboutSection extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AboutSection({
    super.key,
    required this.text,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.darkGrey,
            height: 1.4,
          ),
        ),
        if (text.length > 100 && onToggle != null)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? 'Show less' : 'Read more',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Verified badge
class VerifiedBadge extends StatelessWidget {
  final bool isSmall;

  const VerifiedBadge({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 2 : 4),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: isSmall ? 10 : 14,
        color: Colors.white,
      ),
    );
  }
}
