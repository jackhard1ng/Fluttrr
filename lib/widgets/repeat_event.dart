import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Repeat event badge
class RepeatBadge extends StatelessWidget {
  final RepeatType type;
  final VoidCallback? onTap;

  const RepeatBadge({
    super.key,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.friendlyTeal.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat, size: 14, color: AppColors.friendlyTeal),
            const SizedBox(width: 5),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.friendlyTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum RepeatType {
  weekly('Weekly'),
  biweekly('Every 2 weeks'),
  monthly('Monthly'),
  custom('Recurring');

  final String label;

  const RepeatType(this.label);
}

/// Next occurrence display
class NextOccurrence extends StatelessWidget {
  final String date;
  final String time;

  const NextOccurrence({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.event_repeat, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next: $date',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
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

/// Repeat picker
class RepeatPicker extends StatelessWidget {
  final RepeatType? selected;
  final Function(RepeatType?) onSelect;

  const RepeatPicker({
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
          'Repeat',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RepeatOption(
              label: 'None',
              isSelected: selected == null,
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(null);
              },
            ),
            ...RepeatType.values.map((type) => _RepeatOption(
              label: type.label,
              isSelected: selected == type,
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(type);
              },
            )),
          ],
        ),
      ],
    );
  }
}

class _RepeatOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RepeatOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkGrey,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Series info
class SeriesInfo extends StatelessWidget {
  final String seriesName;
  final int eventNumber;
  final int totalEvents;
  final VoidCallback? onViewSeries;

  const SeriesInfo({
    super.key,
    required this.seriesName,
    required this.eventNumber,
    this.totalEvents = 0,
    this.onViewSeries,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewSeries,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyPurple.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Text(
                '#$eventNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.friendlyPurple,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seriesName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.friendlyPurple,
                    ),
                  ),
                  if (totalEvents > 0)
                    Text(
                      'Event $eventNumber of $totalEvents',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                ],
              ),
            ),
            if (onViewSeries != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mediumGrey,
              ),
          ],
        ),
      ),
    );
  }
}
