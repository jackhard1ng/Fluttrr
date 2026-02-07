import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Event performance card
class EventPerformance extends StatelessWidget {
  final String eventName;
  final int views;
  final int rsvps;
  final int checkins;
  final double? rating;

  const EventPerformance({
    super.key,
    required this.eventName,
    this.views = 0,
    this.rsvps = 0,
    this.checkins = 0,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final conversionRate = views > 0 ? (rsvps / views * 100).toDouble() : 0.0;
    final attendanceRate = rsvps > 0 ? (checkins / rsvps * 100).toDouble() : 0.0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricTile(
                icon: Icons.visibility,
                value: '$views',
                label: 'Views',
                color: AppColors.primaryBlue,
              ),
              _MetricTile(
                icon: Icons.how_to_reg,
                value: '$rsvps',
                label: 'RSVPs',
                color: AppColors.friendlyPurple,
              ),
              _MetricTile(
                icon: Icons.login,
                value: '$checkins',
                label: 'Check-ins',
                color: AppColors.success,
              ),
              if (rating != null)
                _MetricTile(
                  icon: Icons.star,
                  value: rating!.toStringAsFixed(1),
                  label: 'Rating',
                  color: AppColors.warmYellow,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RateBadge(
                  label: 'Conversion',
                  rate: conversionRate,
                  isGood: conversionRate >= 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RateBadge(
                  label: 'Attendance',
                  rate: attendanceRate,
                  isGood: attendanceRate >= 70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricTile({
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

class _RateBadge extends StatelessWidget {
  final String label;
  final double rate;
  final bool isGood;

  const _RateBadge({
    required this.label,
    required this.rate,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isGood
            ? AppColors.success.withAlpha(26)
            : AppColors.friendlyOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${rate.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isGood ? AppColors.success : AppColors.friendlyOrange,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isGood ? AppColors.success : AppColors.friendlyOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick analytics row
class QuickAnalytics extends StatelessWidget {
  final int totalEvents;
  final int totalRsvps;
  final int totalCheckins;

  const QuickAnalytics({
    super.key,
    this.totalEvents = 0,
    this.totalRsvps = 0,
    this.totalCheckins = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickStat(value: '$totalEvents', label: 'Events'),
          _QuickStat(value: '$totalRsvps', label: 'RSVPs'),
          _QuickStat(value: '$totalCheckins', label: 'Attended'),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;

  const _QuickStat({required this.value, required this.label});

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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

/// Popular times chart (simplified)
class PopularTimes extends StatelessWidget {
  final List<int> hourlyData; // 24 hours, 0-100 popularity

  const PopularTimes({super.key, required this.hourlyData});

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
              'Popular Times',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (hour) {
              final value = hour < hourlyData.length
                  ? hourlyData[hour].clamp(0, 100)
                  : 0;
              final isNow = DateTime.now().hour == hour;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: value * 0.6,
                  decoration: BoxDecoration(
                    color: isNow
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlue.withAlpha(77),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12am', style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
            Text('6am', style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
            Text('12pm', style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
            Text('6pm', style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
            Text('12am', style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
          ],
        ),
      ],
    );
  }
}

/// Top performing events
class TopEvents extends StatelessWidget {
  final List<TopEventItem> events;

  const TopEvents({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Top Performing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...events.take(3).toList().asMap().entries.map((entry) {
          return _TopEventRow(
            rank: entry.key + 1,
            event: entry.value,
          );
        }),
      ],
    );
  }
}

class TopEventItem {
  final String name;
  final int attendees;
  final double rating;

  TopEventItem({
    required this.name,
    required this.attendees,
    required this.rating,
  });
}

class _TopEventRow extends StatelessWidget {
  final int rank;
  final TopEventItem event;

  const _TopEventRow({required this.rank, required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppColors.warmYellow
                  : AppColors.lightGrey.withAlpha(128),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.white : AppColors.mediumGrey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Icon(Icons.people, size: 14, color: AppColors.mediumGrey),
              const SizedBox(width: 4),
              Text(
                '${event.attendees}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 14, color: AppColors.warmYellow),
              const SizedBox(width: 4),
              Text(
                event.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
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
