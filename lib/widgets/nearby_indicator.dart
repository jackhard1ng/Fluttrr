import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Nearby friends indicator
class NearbyFriends extends StatelessWidget {
  final int count;
  final List<String> names;
  final VoidCallback? onTap;

  const NearbyFriends({
    super.key,
    required this.count,
    this.names = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.friendlyTeal.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.near_me, size: 16, color: AppColors.friendlyTeal),
            const SizedBox(width: 8),
            Text(
              count == 1
                  ? '${names.isNotEmpty ? names.first : '1 friend'} nearby'
                  : '$count friends nearby',
              style: TextStyle(
                color: AppColors.friendlyTeal,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Distance badge
class DistanceBadge extends StatelessWidget {
  final String distance;

  const DistanceBadge({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, size: 12, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
          Text(
            distance,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Walking distance estimate
class WalkingTime extends StatelessWidget {
  final int minutes;

  const WalkingTime({super.key, required this.minutes});

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
          Icon(Icons.directions_walk, size: 14, color: AppColors.friendlyTeal),
          const SizedBox(width: 4),
          Text(
            '$minutes min',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.friendlyTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Location sharing toggle
class LocationSharing extends StatelessWidget {
  final bool isSharing;
  final Function(bool) onToggle;

  const LocationSharing({
    super.key,
    required this.isSharing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle(!isSharing);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSharing
              ? AppColors.friendlyTeal.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSharing ? AppColors.friendlyTeal : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSharing ? Icons.location_on : Icons.location_off,
              size: 18,
              color: isSharing ? AppColors.friendlyTeal : AppColors.mediumGrey,
            ),
            const SizedBox(width: 8),
            Text(
              isSharing ? 'Sharing Location' : 'Share Location',
              style: TextStyle(
                color: isSharing ? AppColors.friendlyTeal : AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple map pin indicator
class MapPinBadge extends StatelessWidget {
  final String label;
  final Color color;

  const MapPinBadge({
    super.key,
    required this.label,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
