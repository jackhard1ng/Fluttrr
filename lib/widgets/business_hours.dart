import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Business hours display
class BusinessHours extends StatelessWidget {
  final List<DayHours> hours;
  final bool showAllDays;

  const BusinessHours({
    super.key,
    required this.hours,
    this.showAllDays = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Hours',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(width: 8),
            _OpenNowBadge(hours: hours),
          ],
        ),
        const SizedBox(height: 12),
        ...hours.map((day) => _DayRow(day: day)),
      ],
    );
  }
}

class DayHours {
  final String day;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;
  final bool isToday;

  DayHours({
    required this.day,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
    this.isToday = false,
  });
}

class _DayRow extends StatelessWidget {
  final DayHours day;

  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day.day,
              style: TextStyle(
                fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                color: day.isToday ? AppColors.primaryBlue : AppColors.darkGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              day.isClosed
                  ? 'Closed'
                  : '${day.openTime} - ${day.closeTime}',
              style: TextStyle(
                color: day.isClosed
                    ? AppColors.mediumGrey
                    : AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenNowBadge extends StatelessWidget {
  final List<DayHours> hours;

  const _OpenNowBadge({required this.hours});

  @override
  Widget build(BuildContext context) {
    // Simplified - in real app would check actual time
    final today = hours.where((h) => h.isToday).firstOrNull;
    final isOpen = today != null && !today.isClosed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withAlpha(26)
            : AppColors.error.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOpen ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

/// Compact hours badge
class HoursBadge extends StatelessWidget {
  final String hours;
  final bool isOpen;
  final VoidCallback? onTap;

  const HoursBadge({
    super.key,
    required this.hours,
    this.isOpen = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOpen ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hours,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Special hours notice
class SpecialHours extends StatelessWidget {
  final String date;
  final String hours;
  final String? reason;

  const SpecialHours({
    super.key,
    required this.date,
    required this.hours,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.friendlyOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.friendlyOrange.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.friendlyOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$date: $hours',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (reason != null)
                  Text(
                    reason!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hours editor row
class HoursEditorRow extends StatelessWidget {
  final String day;
  final bool isClosed;
  final String? openTime;
  final String? closeTime;
  final Function(bool) onClosedToggle;
  final VoidCallback? onEditTimes;

  const HoursEditorRow({
    super.key,
    required this.day,
    this.isClosed = false,
    this.openTime,
    this.closeTime,
    required this.onClosedToggle,
    this.onEditTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onClosedToggle(!isClosed);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isClosed
                    ? AppColors.error.withAlpha(26)
                    : AppColors.success.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Text(
                isClosed ? 'Closed' : 'Open',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isClosed ? AppColors.error : AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (!isClosed)
            Expanded(
              child: GestureDetector(
                onTap: onEditTimes,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withAlpha(128),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    openTime != null && closeTime != null
                        ? '$openTime - $closeTime'
                        : 'Set hours',
                    style: TextStyle(
                      color: openTime != null
                          ? AppColors.darkGrey
                          : AppColors.mediumGrey,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
