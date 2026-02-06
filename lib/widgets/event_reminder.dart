import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Event reminder options
class ReminderPicker extends StatelessWidget {
  final ReminderOption? selected;
  final Function(ReminderOption) onSelect;

  const ReminderPicker({
    super.key,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Remind me',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReminderOption.values.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum ReminderOption {
  none('No reminder'),
  oneHour('1 hour before'),
  threeHours('3 hours before'),
  oneDay('1 day before'),
  twoDays('2 days before');

  final String label;

  const ReminderOption(this.label);
}

/// Compact reminder badge
class ReminderBadge extends StatelessWidget {
  final ReminderOption reminder;
  final VoidCallback? onTap;

  const ReminderBadge({
    super.key,
    required this.reminder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reminder == ReminderOption.none) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active,
              size: 14,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 4),
            Text(
              reminder.label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Set reminder button
class SetReminderButton extends StatelessWidget {
  final bool hasReminder;
  final VoidCallback onTap;

  const SetReminderButton({
    super.key,
    this.hasReminder = false,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hasReminder
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasReminder ? AppColors.primaryBlue : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasReminder ? Icons.notifications_active : Icons.notifications_none,
              size: 18,
              color: hasReminder ? AppColors.primaryBlue : AppColors.mediumGrey,
            ),
            const SizedBox(width: 8),
            Text(
              hasReminder ? 'Reminder Set' : 'Set Reminder',
              style: TextStyle(
                color: hasReminder ? AppColors.primaryBlue : AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reminder notification preview
class ReminderNotification extends StatelessWidget {
  final String eventName;
  final String timeUntil;
  final VoidCallback? onView;
  final VoidCallback? onDismiss;

  const ReminderNotification({
    super.key,
    required this.eventName,
    required this.timeUntil,
    this.onView,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.event,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coming up!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  eventName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Starts in $timeUntil',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
