import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Event duration badge
class DurationBadge extends StatelessWidget {
  final int hours;
  final int minutes;

  const DurationBadge({
    super.key,
    required this.hours,
    this.minutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    if (hours == 0) {
      text = '$minutes min';
    } else if (minutes == 0) {
      text = '$hours hr${hours > 1 ? 's' : ''}';
    } else {
      text = '${hours}h ${minutes}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time range display
class TimeRange extends StatelessWidget {
  final String startTime;
  final String endTime;

  const TimeRange({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 6),
        Text(
          startTime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward, size: 14, color: AppColors.mediumGrey),
        ),
        Text(
          endTime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

/// Flexible timing badge
class FlexibleTiming extends StatelessWidget {
  final String note;

  const FlexibleTiming({super.key, this.note = 'Flexible timing'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.friendlyTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_time, size: 14, color: AppColors.friendlyTeal),
          const SizedBox(width: 5),
          Text(
            note,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.friendlyTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Event is happening now
class HappeningNow extends StatelessWidget {
  final String? endsIn;

  const HappeningNow({super.key, this.endsIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            endsIn != null ? 'Now · Ends in $endsIn' : 'Happening Now',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Starting soon badge
class StartingSoon extends StatelessWidget {
  final String timeUntil;

  const StartingSoon({super.key, required this.timeUntil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.friendlyOrange,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'Starts in $timeUntil',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// All day event badge
class AllDayEvent extends StatelessWidget {
  const AllDayEvent({super.key});

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
          Icon(Icons.wb_sunny, size: 14, color: AppColors.friendlyPurple),
          const SizedBox(width: 5),
          Text(
            'All Day',
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

/// Multi-day event indicator
class MultiDayEvent extends StatelessWidget {
  final int days;

  const MultiDayEvent({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            '$days days',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
