import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Similar events section
class SimilarEvents extends StatelessWidget {
  final List<SimilarEventItem> events;
  final VoidCallback? onViewMore;

  const SimilarEvents({
    super.key,
    required this.events,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You might also like',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),
            if (onViewMore != null)
              GestureDetector(
                onTap: onViewMore,
                child: Text(
                  'See more',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < events.length - 1 ? 12 : 0),
                child: _SimilarEventCard(event: events[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SimilarEventItem {
  final String id;
  final String title;
  final String date;
  final String? emoji;
  final int attendeeCount;
  final VoidCallback? onTap;

  SimilarEventItem({
    required this.id,
    required this.title,
    required this.date,
    this.emoji,
    this.attendeeCount = 0,
    this.onTap,
  });
}

class _SimilarEventCard extends StatelessWidget {
  final SimilarEventItem event;

  const _SimilarEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        event.onTap?.call();
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.emoji != null)
              Text(event.emoji!, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            Text(
              event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              event.date,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
            if (event.attendeeCount > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.people, size: 12, color: AppColors.mediumGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${event.attendeeCount} going',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friends going to similar events
class FriendsGoingTo extends StatelessWidget {
  final String eventTitle;
  final List<String> friendNames;
  final VoidCallback? onTap;

  const FriendsGoingTo({
    super.key,
    required this.eventTitle,
    required this.friendNames,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (friendNames.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // Stacked avatars
            SizedBox(
              width: 30 + (friendNames.take(2).length - 1) * 12.0,
              height: 24,
              child: Stack(
                children: friendNames.take(2).toList().asMap().entries.map((entry) {
                  return Positioned(
                    left: entry.key * 12.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.friendlyPurple,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          entry.value[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
                  children: [
                    TextSpan(
                      text: friendNames.length == 1
                          ? friendNames.first
                          : '${friendNames.first} +${friendNames.length - 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: ' going to ',
                      style: TextStyle(color: AppColors.mediumGrey),
                    ),
                    TextSpan(
                      text: eventTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.friendlyPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Trending events badge
class TrendingBadge extends StatelessWidget {
  const TrendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.friendlyOrange, AppColors.warmYellow],
        ),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Text(
            'Trending',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Featured event badge
class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warmYellow,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Featured',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
