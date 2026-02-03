import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';
import 'mate_profile_screen.dart';
import 'matches_screen.dart';

/// Mates/matching screen with swipeable cards
class MatesScreen extends StatelessWidget {
  const MatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GradientText(
                    text: 'Mates',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => _showFilters(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () => Get.to(() => const MatchesScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Swipeable cards
            Expanded(
              child: Obx(() {
                if (matesController.isLoading.value &&
                    matesController.nearbyMates.isEmpty) {
                  return const LoadingIndicator();
                }

                if (matesController.nearbyMates.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Mates Nearby',
                    subtitle: 'Try adjusting your filters or check back later',
                    action: GradientButton(
                      text: 'Refresh',
                      width: 120,
                      onPressed: matesController.loadNearbyMates,
                    ),
                  );
                }

                if (!matesController.hasMoreMates) {
                  return EmptyState(
                    icon: Icons.check_circle_outline,
                    title: "You've seen everyone!",
                    subtitle: 'Check back later for new mates',
                    action: GradientButton(
                      text: 'Start Over',
                      width: 120,
                      onPressed: () {
                        matesController.currentSwipeIndex.value = 0;
                        matesController.loadNearbyMates();
                      },
                    ),
                  );
                }

                return _SwipeableCards(controller: matesController);
              }),
            ),

            // Action buttons
            Obx(() {
              if (matesController.nearbyMates.isEmpty ||
                  !matesController.hasMoreMates) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.close,
                      color: AppColors.error,
                      onPressed: matesController.swipeLeft,
                    ),
                    _ActionButton(
                      icon: Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 50,
                      onPressed: () {
                        final mate = matesController.currentMate;
                        if (mate?.userId != null) {
                          Get.to(() => MateProfileScreen(userId: mate!.userId!));
                        }
                      },
                    ),
                    _ActionButton(
                      icon: Icons.favorite,
                      color: AppColors.success,
                      onPressed: matesController.swipeRight,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final matesController = Get.find<MatesController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _FilterSheet(controller: matesController),
    );
  }
}

/// Swipeable cards widget
class _SwipeableCards extends StatelessWidget {
  final MatesController controller;

  const _SwipeableCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CardSwiper(
        cardsCount: controller.nearbyMates.length,
        cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
          if (index >= controller.nearbyMates.length) {
            return const SizedBox.shrink();
          }
          return _MateCard(mate: controller.nearbyMates[index]);
        },
        onSwipe: (previousIndex, currentIndex, direction) {
          if (direction == CardSwiperDirection.right) {
            final mate = controller.nearbyMates[previousIndex];
            if (mate.userId != null) {
              controller.likeMate(mate.userId!);
            }
          }
          controller.currentSwipeIndex.value = currentIndex ?? 0;
          return true;
        },
        onEnd: () {
          controller.currentSwipeIndex.value = controller.nearbyMates.length;
        },
        numberOfCardsDisplayed: 2,
        padding: EdgeInsets.zero,
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
          horizontal: true,
        ),
      ),
    );
  }
}

/// Mate card widget
class _MateCard extends StatelessWidget {
  final MateModel mate;

  const _MateCard({required this.mate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        image: mate.profileImage != null
            ? DecorationImage(
                image: NetworkImage(mate.profileImage!),
                fit: BoxFit.cover,
              )
            : null,
        color: AppColors.lightGrey,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),

          // Default avatar if no image
          if (mate.profileImage == null)
            const Center(
              child: Icon(
                Icons.person,
                size: 100,
                color: AppColors.grey,
              ),
            ),

          // Online indicator
          if (mate.isOnline)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mate.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mate.age != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${mate.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ],
                ),

                if (mate.location != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mate.location!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      if (mate.distanceText.isNotEmpty) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          mate.distanceText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                if (mate.bio != null && mate.bio!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    mate.bio!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (mate.interests.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: mate.interests.take(3).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.medium,
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterSheet extends StatelessWidget {
  final MatesController controller;

  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Mates',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Age range
          Text(
            'Age Range',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => RangeSlider(
                values: RangeValues(
                  controller.minAge.value.toDouble(),
                  controller.maxAge.value.toDouble(),
                ),
                min: 18,
                max: 80,
                divisions: 62,
                labels: RangeLabels(
                  controller.minAge.value.toString(),
                  controller.maxAge.value.toString(),
                ),
                onChanged: (values) {
                  controller.minAge.value = values.start.round();
                  controller.maxAge.value = values.end.round();
                },
              )),

          const SizedBox(height: AppSpacing.md),

          // Gender
          Text(
            'Gender',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => Wrap(
                spacing: AppSpacing.sm,
                children: ['All', 'Male', 'Female', 'Other'].map((gender) {
                  final isSelected =
                      controller.selectedGender.value == (gender == 'All' ? '' : gender);
                  return ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.selectedGender.value = gender == 'All' ? '' : gender,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGrey,
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: AppSpacing.md),

          // Distance
          Text(
            'Maximum Distance',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => Slider(
                value: controller.maxDistance.value,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${controller.maxDistance.value.round()} km',
                onChanged: (value) => controller.maxDistance.value = value,
              )),

          const SizedBox(height: AppSpacing.lg),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GradientButton(
                  text: 'Apply',
                  onPressed: () {
                    controller.filterMates();
                    Get.back();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
