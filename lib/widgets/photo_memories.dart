import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Simple photo memories grid
class PhotoMemories extends StatelessWidget {
  final List<String> photoUrls;
  final int totalPhotos;
  final VoidCallback? onViewAll;

  const PhotoMemories({
    super.key,
    required this.photoUrls,
    this.totalPhotos = 0,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) return const SizedBox.shrink();

    final displayCount = photoUrls.take(4).length;
    final remaining = totalPhotos - displayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, size: 18, color: AppColors.friendlyPurple),
                const SizedBox(width: 8),
                Text(
                  'Memories',
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
                  'View All',
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
          height: 100,
          child: Row(
            children: [
              ...photoUrls.take(4).toList().asMap().entries.map((entry) {
                final isLast = entry.key == 3 && remaining > 0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: entry.key < 3 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isLast && onViewAll != null) {
                          onViewAll!();
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: AppColors.lightGrey,
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ),
                            if (isLast)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: Text(
                                    '+$remaining',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add photo button
class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddPhotoButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.friendlyPurple.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyPurple.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo, size: 18, color: AppColors.friendlyPurple),
            const SizedBox(width: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                color: AppColors.friendlyPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Photo count badge
class PhotoCountBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const PhotoCountBadge({
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
            Icon(Icons.photo, size: 14, color: AppColors.friendlyPurple),
            const SizedBox(width: 4),
            Text(
              '$count photo${count != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.friendlyPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Memory card from past event
class MemoryCard extends StatelessWidget {
  final String eventName;
  final String date;
  final int photoCount;
  final int friendCount;
  final VoidCallback? onTap;

  const MemoryCard({
    super.key,
    required this.eventName,
    required this.date,
    this.photoCount = 0,
    this.friendCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.friendlyPurple.withAlpha(26),
              AppColors.primaryBlue.withAlpha(26),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.friendlyPurple.withAlpha(51)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.friendlyPurple),
                const SizedBox(width: 6),
                Text(
                  'Memory',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.friendlyPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              eventName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (photoCount > 0) ...[
                  Icon(Icons.photo, size: 14, color: AppColors.mediumGrey),
                  const SizedBox(width: 4),
                  Text(
                    '$photoCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (friendCount > 0) ...[
                  Icon(Icons.people, size: 14, color: AppColors.mediumGrey),
                  const SizedBox(width: 4),
                  Text(
                    '$friendCount friends',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
