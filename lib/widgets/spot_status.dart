import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Spot availability indicator
class SpotAvailability extends StatelessWidget {
  final int spotsLeft;
  final int totalSpots;

  const SpotAvailability({
    super.key,
    required this.spotsLeft,
    this.totalSpots = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    final IconData icon;

    if (spotsLeft == 0) {
      color = AppColors.error;
      text = 'Full';
      icon = Icons.block;
    } else if (spotsLeft <= 3) {
      color = AppColors.friendlyOrange;
      text = 'Only $spotsLeft spot${spotsLeft > 1 ? 's' : ''} left!';
      icon = Icons.warning_amber;
    } else if (spotsLeft <= 10) {
      color = AppColors.warmYellow;
      text = '$spotsLeft spots left';
      icon = Icons.event_seat;
    } else {
      color = AppColors.success;
      text = 'Spots available';
      icon = Icons.check_circle;
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
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

/// Your spot is saved confirmation
class SpotSaved extends StatelessWidget {
  final String? spotNumber;
  final VoidCallback? onCancel;

  const SpotSaved({
    super.key,
    this.spotNumber,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your spot is saved!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (spotNumber != null)
                  Text(
                    'Spot #$spotNumber',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onCancel!();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Waitlist position
class WaitlistPosition extends StatelessWidget {
  final int position;
  final VoidCallback? onLeave;

  const WaitlistPosition({
    super.key,
    required this.position,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.friendlyOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.friendlyOrange.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.friendlyOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'On the waitlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'We\'ll notify you if a spot opens',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          if (onLeave != null)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onLeave!();
              },
              child: Text(
                'Leave',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Join waitlist button
class JoinWaitlistButton extends StatelessWidget {
  final int currentWaitlist;
  final VoidCallback onJoin;

  const JoinWaitlistButton({
    super.key,
    this.currentWaitlist = 0,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onJoin();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.friendlyOrange,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Join Waitlist',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (currentWaitlist > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  '$currentWaitlist waiting',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Capacity bar
class CapacityBar extends StatelessWidget {
  final int filled;
  final int total;

  const CapacityBar({
    super.key,
    required this.filled,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (filled / total).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (percentage >= 1.0) {
      barColor = AppColors.error;
    } else if (percentage >= 0.8) {
      barColor = AppColors.friendlyOrange;
    } else if (percentage >= 0.5) {
      barColor = AppColors.warmYellow;
    } else {
      barColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$filled / $total spots filled',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
            Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
