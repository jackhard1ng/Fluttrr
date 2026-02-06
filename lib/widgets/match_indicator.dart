import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Simple match percentage badge
class MatchBadge extends StatelessWidget {
  final int percentage;

  const MatchBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getColor().withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: _getColor().withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 12, color: _getColor()),
          const SizedBox(width: 4),
          Text(
            '$percentage% match',
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.friendlyTeal;
    if (percentage >= 40) return AppColors.friendlyOrange;
    return AppColors.mediumGrey;
  }
}

/// Shared interests count
class SharedInterestsBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const SharedInterestsBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.interests, size: 12, color: AppColors.friendlyPurple),
            const SizedBox(width: 4),
            Text(
              '$count shared',
              style: TextStyle(
                color: AppColors.friendlyPurple,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple match score circle
class MatchScore extends StatelessWidget {
  final int score;
  final double size;

  const MatchScore({
    super.key,
    required this.score,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_getColor(), _getColor().withAlpha(179)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.28,
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.friendlyTeal;
    if (score >= 40) return AppColors.friendlyOrange;
    return AppColors.mediumGrey;
  }
}

/// Why you match section
class WhyYouMatch extends StatelessWidget {
  final List<String> reasons;

  const WhyYouMatch({super.key, required this.reasons});

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 16, color: AppColors.friendlyPurple),
              const SizedBox(width: 6),
              Text(
                'Why you match',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.friendlyPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reasons.take(3).map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
