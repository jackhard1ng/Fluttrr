import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Review summary for business
class ReviewSummary extends StatelessWidget {
  final double avgRating;
  final int totalReviews;
  final Map<int, int> distribution; // 1-5 star counts

  const ReviewSummary({
    super.key,
    required this.avgRating,
    required this.totalReviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Rating display
          Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < avgRating.round() ? Icons.star : Icons.star_border,
                    size: 18,
                    color: AppColors.warmYellow,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews reviews',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final stars = 5 - i;
                final count = distribution[stars] ?? 0;
                final percentage = totalReviews > 0
                    ? count / totalReviews
                    : 0.0;
                return _DistributionBar(
                  stars: stars,
                  percentage: percentage,
                  count: count,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final int stars;
  final double percentage;
  final int count;

  const _DistributionBar({
    required this.stars,
    required this.percentage,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: AppColors.warmYellow),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
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
                    color: AppColors.warmYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single review card
class ReviewCard extends StatelessWidget {
  final String reviewerName;
  final int rating;
  final String comment;
  final String timeAgo;
  final String? eventName;
  final VoidCallback? onReply;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    this.eventName,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withAlpha(26),
                ),
                child: Center(
                  child: Text(
                    reviewerName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: AppColors.warmYellow,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              color: AppColors.darkGrey,
              height: 1.4,
            ),
          ),
          if (eventName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 12, color: AppColors.mediumGrey),
                  const SizedBox(width: 4),
                  Text(
                    eventName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onReply != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onReply,
              child: Text(
                'Reply',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Recent feedback preview
class RecentFeedback extends StatelessWidget {
  final int newReviews;
  final double avgRating;
  final VoidCallback? onViewAll;

  const RecentFeedback({
    super.key,
    this.newReviews = 0,
    required this.avgRating,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warmYellow.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.warmYellow.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: AppColors.warmYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Feedback',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '${avgRating.toStringAsFixed(1)} avg',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warmYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (newReviews > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            '$newReviews new',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Request review prompt
class RequestReviewPrompt extends StatelessWidget {
  final String eventName;
  final VoidCallback? onRequest;
  final VoidCallback? onDismiss;

  const RequestReviewPrompt({
    super.key,
    required this.eventName,
    this.onRequest,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Text('💬', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask for feedback',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Send review request to $eventName attendees',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRequest?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
