import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Business dashboard stats
class BusinessStats extends StatelessWidget {
  final int totalEvents;
  final int totalAttendees;
  final double avgRating;
  final int followers;

  const BusinessStats({
    super.key,
    this.totalEvents = 0,
    this.totalAttendees = 0,
    this.avgRating = 0,
    this.followers = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          _StatTile(
            icon: Icons.event,
            value: '$totalEvents',
            label: 'Events',
            color: AppColors.primaryBlue,
          ),
          const _Divider(),
          _StatTile(
            icon: Icons.people,
            value: _formatNumber(totalAttendees),
            label: 'Attendees',
            color: AppColors.friendlyPurple,
          ),
          const _Divider(),
          _StatTile(
            icon: Icons.star,
            value: avgRating.toStringAsFixed(1),
            label: 'Rating',
            color: AppColors.warmYellow,
          ),
          const _Divider(),
          _StatTile(
            icon: Icons.favorite,
            value: _formatNumber(followers),
            label: 'Followers',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return '$num';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          Text(
            label,
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.lightGrey,
    );
  }
}

/// Quick stat card
class QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendUp;

  const QuickStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? AppColors.success.withAlpha(26)
                        : AppColors.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trendUp ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: trendUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
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

/// This week performance
class WeeklyPerformance extends StatelessWidget {
  final int eventsHosted;
  final int newFollowers;
  final int totalRsvps;

  const WeeklyPerformance({
    super.key,
    this.eventsHosted = 0,
    this.newFollowers = 0,
    this.totalRsvps = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PerformanceItem(
                value: '$eventsHosted',
                label: 'Events',
                icon: Icons.event,
              ),
              const SizedBox(width: 16),
              _PerformanceItem(
                value: '+$newFollowers',
                label: 'Followers',
                icon: Icons.person_add,
              ),
              const SizedBox(width: 16),
              _PerformanceItem(
                value: '$totalRsvps',
                label: 'RSVPs',
                icon: Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _PerformanceItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mediumGrey),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
