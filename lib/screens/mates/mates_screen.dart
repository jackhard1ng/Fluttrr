import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../config/routes.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';

/// Mates/friend discovery screen with swipeable cards - emphasizing platonic connections
class MatesScreen extends StatelessWidget {
  const MatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with friendly branding
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.friendlyTeal],
                        ).createShader(bounds),
                        child: const Text(
                          'Find Friends',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Connect with people nearby',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: AppColors.darkGrey),
                          onPressed: () => _showFilters(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Connections button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.friendlyTeal.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.people, color: AppColors.friendlyTeal),
                          onPressed: Nav.toMatches,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Platonic friendship reminder
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(13),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primaryBlue.withAlpha(26)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Swipe right to connect as friends',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Swipeable cards
            Expanded(
              child: Obx(() {
                if (matesController.isLoading.value &&
                    matesController.nearbyMates.isEmpty) {
                  return const LoadingIndicator();
                }

                if (matesController.nearbyMates.isEmpty) {
                  return _EmptyFriendsState(
                    title: 'No Friends Nearby Yet',
                    subtitle: 'Try adjusting your filters or check back later',
                    onRefresh: matesController.loadNearbyMates,
                  );
                }

                if (!matesController.hasMoreMates) {
                  return _EmptyFriendsState(
                    title: "You've met everyone!",
                    subtitle: 'Check back later for new friends',
                    onRefresh: () {
                      matesController.currentSwipeIndex.value = 0;
                      matesController.loadNearbyMates();
                    },
                    buttonText: 'Start Over',
                  );
                }

                return _SwipeableCards(controller: matesController);
              }),
            ),

            // Action buttons - friendlier icons
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
                      label: 'Skip',
                      color: AppColors.mediumGrey,
                      onPressed: matesController.swipeLeft,
                    ),
                    _ActionButton(
                      icon: Icons.person,
                      label: 'Profile',
                      color: AppColors.primaryBlue,
                      size: 50,
                      onPressed: () {
                        final mate = matesController.currentMate;
                        if (mate?.userId != null) {
                          Nav.toMateProfile(mate!.userId!);
                        }
                      },
                    ),
                    _ActionButton(
                      icon: Icons.waving_hand,
                      label: 'Wave',
                      color: AppColors.friendlyTeal,
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

/// Mate card widget with safe image loading
class _MateCard extends StatelessWidget {
  final MateModel mate;

  const _MateCard({required this.mate});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        image: hasValidImage
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
        gradient: !hasValidImage
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withAlpha(51),
                  AppColors.friendlyPurple.withAlpha(51),
                ],
              )
            : null,
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
                  Colors.black.withAlpha(179),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),

          // Default avatar if no image
          if (!hasValidImage)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 70,
                  color: AppColors.primaryBlue,
                ),
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
                          color: Colors.white.withAlpha(51),
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

/// Empty state for friends screen
class _EmptyFriendsState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  final String buttonText;

  const _EmptyFriendsState({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    this.buttonText = 'Refresh',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 50,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: buttonText,
              width: 140,
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button widget with label
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  const _ActionButton({
    required this.icon,
    this.label,
    required this.color,
    required this.onPressed,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(51),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: color.withAlpha(51),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.45,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            label!,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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
            'Find Your People',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Adjust filters to find friends who match your vibe',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGrey,
            ),
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
