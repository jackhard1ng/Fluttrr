import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Simple streak counter
class StreakBadge extends StatelessWidget {
  final int days;
  final StreakType type;

  const StreakBadge({
    super.key,
    required this.days,
    this.type = StreakType.events,
  });

  @override
  Widget build(BuildContext context) {
    if (days == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.friendlyOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$days ${type.label}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.friendlyOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum StreakType {
  events('event streak'),
  weekly('week streak'),
  monthly('months active');

  final String label;

  const StreakType(this.label);
}

/// Weekly activity dots
class WeeklyActivity extends StatelessWidget {
  final List<bool> activeDays; // Sun-Sat (7 days)

  const WeeklyActivity({super.key, required this.activeDays});

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final isActive = i < activeDays.length && activeDays[i];
        return Padding(
          padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.success
                      : AppColors.lightGrey.withAlpha(128),
                ),
                child: Center(
                  child: isActive
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                days[i],
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// This week's activity summary
class WeeklySummary extends StatelessWidget {
  final int eventsAttended;
  final int friendsMade;
  final int hoursSpent;

  const WeeklySummary({
    super.key,
    this.eventsAttended = 0,
    this.friendsMade = 0,
    this.hoursSpent = 0,
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
          Text(
            'This Week',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(
                icon: Icons.event,
                value: '$eventsAttended',
                label: 'Events',
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 20),
              _StatItem(
                icon: Icons.people,
                value: '$friendsMade',
                label: 'Friends',
                color: AppColors.friendlyPurple,
              ),
              const SizedBox(width: 20),
              _StatItem(
                icon: Icons.schedule,
                value: '${hoursSpent}h',
                label: 'Time',
                color: AppColors.friendlyTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Monthly goal progress
class MonthlyGoal extends StatelessWidget {
  final int current;
  final int goal;
  final String label;

  const MonthlyGoal({
    super.key,
    required this.current,
    required this.goal,
    this.label = 'events this month',
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= goal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withAlpha(26)
            : AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isComplete ? AppColors.success : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete ? 'Goal Complete!' : 'Monthly Goal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isComplete ? AppColors.success : AppColors.darkGrey,
                ),
              ),
              Text(
                '$current / $goal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isComplete ? AppColors.success : AppColors.primaryBlue,
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
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.success : AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
