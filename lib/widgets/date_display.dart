import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Calendar date display
class CalendarDate extends StatelessWidget {
  final String day;
  final String month;
  final String? year;
  final bool isHighlighted;

  const CalendarDate({
    super.key,
    required this.day,
    required this.month,
    this.year,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primaryBlue
            : AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white70 : AppColors.mediumGrey,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : AppColors.darkGrey,
            ),
          ),
          if (year != null)
            Text(
              year!,
              style: TextStyle(
                fontSize: 10,
                color: isHighlighted ? Colors.white70 : AppColors.mediumGrey,
              ),
            ),
        ],
      ),
    );
  }
}

/// Date chip
class DateChip extends StatelessWidget {
  final String date;
  final bool isToday;
  final bool isTomorrow;

  const DateChip({
    super.key,
    required this.date,
    this.isToday = false,
    this.isTomorrow = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = date;
    Color? bgColor;
    Color? textColor;

    if (isToday) {
      displayText = 'Today';
      bgColor = AppColors.success;
      textColor = Colors.white;
    } else if (isTomorrow) {
      displayText = 'Tomorrow';
      bgColor = AppColors.friendlyOrange;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.darkGrey,
        ),
      ),
    );
  }
}

/// Time ago display
class TimeAgo extends StatelessWidget {
  final String time;
  final bool showIcon;

  const TimeAgo({
    super.key,
    required this.time,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(Icons.schedule, size: 12, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

/// Day of week badge
class DayOfWeek extends StatelessWidget {
  final String day;
  final bool isActive;

  const DayOfWeek({
    super.key,
    required this.day,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.primaryBlue
            : AppColors.lightGrey.withAlpha(128),
      ),
      child: Center(
        child: Text(
          day.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.mediumGrey,
          ),
        ),
      ),
    );
  }
}

/// Date range badge
class DateRange extends StatelessWidget {
  final String startDate;
  final String endDate;

  const DateRange({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            startDate,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward, size: 12, color: AppColors.mediumGrey),
          ),
          Text(
            endDate,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// This weekend badge
class ThisWeekend extends StatelessWidget {
  const ThisWeekend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.weekend, size: 14, color: AppColors.friendlyPurple),
          const SizedBox(width: 5),
          Text(
            'This Weekend',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.friendlyPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown days
class CountdownDays extends StatelessWidget {
  final int days;

  const CountdownDays({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days <= 0) return const SizedBox.shrink();

    Color color;
    if (days <= 1) {
      color = AppColors.error;
    } else if (days <= 3) {
      color = AppColors.friendlyOrange;
    } else {
      color = AppColors.primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        days == 1 ? 'In 1 day' : 'In $days days',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
