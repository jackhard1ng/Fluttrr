import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Simple bookmark button
class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;
  final double size;

  const BookmarkButton({
    super.key,
    this.isBookmarked = false,
    required this.onToggle,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          key: ValueKey(isBookmarked),
          size: size,
          color: isBookmarked ? AppColors.warmYellow : AppColors.mediumGrey,
        ),
      ),
    );
  }
}

/// Bookmarked events list header
class BookmarkedHeader extends StatelessWidget {
  final int count;

  const BookmarkedHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.bookmark, size: 20, color: AppColors.warmYellow),
        const SizedBox(width: 8),
        Text(
          'Saved Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.warmYellow.withAlpha(51),
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.warmYellow,
            ),
          ),
        ),
      ],
    );
  }
}

/// Saved event card (compact)
class SavedEventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const SavedEventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.event, color: AppColors.warmYellow),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.place, size: 12, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRemove!();
                },
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.mediumGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Save for later toast notification
void showSavedToast(BuildContext context, {bool removed = false}) {
  Get.snackbar(
    removed ? 'Removed' : 'Saved!',
    removed ? 'Event removed from saved' : 'Event saved for later',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: removed ? AppColors.mediumGrey : AppColors.warmYellow,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
    icon: Icon(
      removed ? Icons.bookmark_remove : Icons.bookmark_added,
      color: Colors.white,
    ),
  );
}

/// Empty saved state
class EmptySavedEvents extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptySavedEvents({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No saved events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon to save\nevents for later',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
              ),
            ),
            if (onExplore != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onExplore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Text(
                    'Explore Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
