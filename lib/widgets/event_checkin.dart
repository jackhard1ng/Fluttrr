import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Check-in button
class CheckInButton extends StatelessWidget {
  final bool isCheckedIn;
  final VoidCallback onCheckIn;

  const CheckInButton({
    super.key,
    this.isCheckedIn = false,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCheckedIn
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onCheckIn();
              Get.snackbar(
                'Checked In!',
                'Have a great time!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isCheckedIn ? AppColors.success : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCheckedIn ? Icons.check_circle : Icons.login,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isCheckedIn ? 'Checked In' : 'Check In',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Check-in status badge
class CheckedInBadge extends StatelessWidget {
  final String? time;

  const CheckedInBadge({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 5),
          Text(
            time != null ? 'Checked in $time' : 'Checked in',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Check-in count display
class CheckInCount extends StatelessWidget {
  final int count;
  final int total;

  const CheckInCount({
    super.key,
    required this.count,
    this.total = 0,
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
          Icon(Icons.people, size: 16, color: AppColors.mediumGrey),
          const SizedBox(width: 6),
          Text(
            total > 0 ? '$count / $total checked in' : '$count checked in',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Who's here list
class WhosHere extends StatelessWidget {
  final List<String> names;
  final VoidCallback? onViewAll;

  const WhosHere({
    super.key,
    required this.names,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.group, size: 18, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  "Who's Here",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: names.take(8).map((name) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name.split(' ').first,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (names.length > 8) ...[
          const SizedBox(height: 8),
          Text(
            '+${names.length - 8} more',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ],
    );
  }
}

/// First to arrive badge
class FirstToArrive extends StatelessWidget {
  const FirstToArrive({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warmYellow,
            AppColors.friendlyOrange,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text(
            'First to arrive!',
            style: TextStyle(
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
