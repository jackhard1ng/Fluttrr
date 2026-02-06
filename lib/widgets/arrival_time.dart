import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Set your arrival time
class ArrivalTimePicker extends StatelessWidget {
  final ArrivalTime? selected;
  final Function(ArrivalTime) onSelect;

  const ArrivalTimePicker({
    super.key,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When are you arriving?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ArrivalTime.values.map((time) {
            final isSelected = selected == time;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelect(time);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: time != ArrivalTime.late ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? time.color.withAlpha(26)
                        : AppColors.lightGrey.withAlpha(77),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? time.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(time.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        time.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? time.color : AppColors.darkGrey,
                        ),
                      ),
                    ],
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

enum ArrivalTime {
  early('🏃', 'Early', AppColors.friendlyTeal),
  onTime('👍', 'On Time', AppColors.success),
  late('🐢', 'A Bit Late', AppColors.friendlyOrange);

  final String emoji;
  final String label;
  final Color color;

  const ArrivalTime(this.emoji, this.label, this.color);
}

/// Shows who's arriving when
class ArrivalSummary extends StatelessWidget {
  final int earlyCount;
  final int onTimeCount;
  final int lateCount;

  const ArrivalSummary({
    super.key,
    this.earlyCount = 0,
    this.onTimeCount = 0,
    this.lateCount = 0,
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
          _ArrivalCount(
            time: ArrivalTime.early,
            count: earlyCount,
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.lightGrey,
          ),
          _ArrivalCount(
            time: ArrivalTime.onTime,
            count: onTimeCount,
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.lightGrey,
          ),
          _ArrivalCount(
            time: ArrivalTime.late,
            count: lateCount,
          ),
        ],
      ),
    );
  }
}

class _ArrivalCount extends StatelessWidget {
  final ArrivalTime time;
  final int count;

  const _ArrivalCount({required this.time, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(time.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: time.color,
          ),
        ),
        Text(
          time.label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

/// Quick RSVP buttons
class QuickRsvp extends StatelessWidget {
  final RsvpStatus? status;
  final Function(RsvpStatus) onSelect;

  const QuickRsvp({
    super.key,
    this.status,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RsvpStatus.values.map((s) {
        final isSelected = status == s;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onSelect(s);
            },
            child: Container(
              margin: EdgeInsets.only(
                right: s != RsvpStatus.maybe ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? s.color : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? s.color : AppColors.lightGrey,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s.icon,
                    size: 18,
                    color: isSelected ? Colors.white : s.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : s.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

enum RsvpStatus {
  going(Icons.check_circle, 'Going', AppColors.success),
  notGoing(Icons.cancel, 'Can\'t Go', AppColors.error),
  maybe(Icons.help, 'Maybe', AppColors.friendlyOrange);

  final IconData icon;
  final String label;
  final Color color;

  const RsvpStatus(this.icon, this.label, this.color);
}
