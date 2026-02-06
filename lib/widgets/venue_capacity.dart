import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Venue capacity display
class VenueCapacity extends StatelessWidget {
  final int current;
  final int max;
  final bool showBar;

  const VenueCapacity({
    super.key,
    required this.current,
    required this.max,
    this.showBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final status = _getStatus(percentage);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.color.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: status.color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 18, color: status.color),
                  const SizedBox(width: 8),
                  Text(
                    'Capacity',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status.color.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$current',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: status.color,
                ),
              ),
              Text(
                ' / $max',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 10),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _CapacityStatus _getStatus(double percentage) {
    if (percentage >= 1.0) {
      return _CapacityStatus('Full', AppColors.error);
    } else if (percentage >= 0.9) {
      return _CapacityStatus('Almost Full', AppColors.friendlyOrange);
    } else if (percentage >= 0.7) {
      return _CapacityStatus('Filling Up', AppColors.warmYellow);
    } else {
      return _CapacityStatus('Available', AppColors.success);
    }
  }
}

class _CapacityStatus {
  final String label;
  final Color color;

  _CapacityStatus(this.label, this.color);
}

/// Compact capacity badge
class CapacityBadge extends StatelessWidget {
  final int current;
  final int max;

  const CapacityBadge({
    super.key,
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max) : 0.0;
    Color color;

    if (percentage >= 1.0) {
      color = AppColors.error;
    } else if (percentage >= 0.8) {
      color = AppColors.friendlyOrange;
    } else {
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '$current/$max',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Capacity editor
class CapacityEditor extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;

  const CapacityEditor({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 1000,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max Capacity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _CapacityButton(
              icon: Icons.remove,
              onTap: value > min
                  ? () {
                      HapticFeedback.lightImpact();
                      onChanged(value - 1);
                    }
                  : null,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            _CapacityButton(
              icon: Icons.add,
              onTap: value < max
                  ? () {
                      HapticFeedback.lightImpact();
                      onChanged(value + 1);
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [10, 25, 50, 100].map((preset) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(preset);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: value == preset
                      ? AppColors.primaryBlue
                      : AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  '$preset',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: value == preset ? Colors.white : AppColors.darkGrey,
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

class _CapacityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CapacityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primaryBlue
              : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : AppColors.mediumGrey,
        ),
      ),
    );
  }
}

/// Venue type badge
class VenueTypeBadge extends StatelessWidget {
  final VenueType type;

  const VenueTypeBadge({super.key, required this.type});

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
          Icon(type.icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            type.label,
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

enum VenueType {
  restaurant(Icons.restaurant, 'Restaurant'),
  bar(Icons.local_bar, 'Bar'),
  cafe(Icons.local_cafe, 'Cafe'),
  club(Icons.nightlife, 'Club'),
  outdoors(Icons.park, 'Outdoor'),
  coworking(Icons.business, 'Coworking'),
  gallery(Icons.palette, 'Gallery'),
  gym(Icons.fitness_center, 'Gym'),
  other(Icons.place, 'Venue');

  final IconData icon;
  final String label;

  const VenueType(this.icon, this.label);
}
