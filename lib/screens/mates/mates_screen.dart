import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../config/routes.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';

/// Mates/friend discovery screen with list view - HelloTalk style
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                        ).createShader(bounds),
                        child: const Text(
                          'People Nearby',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '${matesController.nearbyMates.length} people near you',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                          )),
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
                      // My Connections button
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.mediumGrey),
                    const SizedBox(width: 12),
                    Text(
                      'Search by name or interests...',
                      style: TextStyle(color: AppColors.mediumGrey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Quick filters row
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _QuickFilterChip(
                    label: 'Online Now',
                    icon: Icons.circle,
                    iconColor: AppColors.success,
                    isSelected: false,
                    onTap: () {},
                  ),
                  _QuickFilterChip(
                    label: 'New Members',
                    icon: Icons.fiber_new,
                    isSelected: false,
                    onTap: () {},
                  ),
                  _QuickFilterChip(
                    label: 'Same Interests',
                    icon: Icons.favorite_border,
                    isSelected: false,
                    onTap: () {},
                  ),
                  _QuickFilterChip(
                    label: 'Nearby',
                    icon: Icons.near_me,
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // People list
            Expanded(
              child: Obx(() {
                if (matesController.isLoading.value &&
                    matesController.nearbyMates.isEmpty) {
                  return const LoadingIndicator();
                }

                if (matesController.nearbyMates.isEmpty) {
                  return _EmptyState(
                    onRefresh: matesController.loadNearbyMates,
                  );
                }

                return RefreshIndicator(
                  onRefresh: matesController.loadNearbyMates,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: matesController.nearbyMates.length,
                    itemBuilder: (context, index) {
                      final mate = matesController.nearbyMates[index];
                      return _PersonCard(
                        mate: mate,
                        onConnect: () {
                          HapticFeedback.mediumImpact();
                          if (mate.userId != null) {
                            matesController.likeMate(mate.userId!);
                          }
                        },
                        onViewProfile: () {
                          if (mate.userId != null) {
                            Nav.toMateProfile(mate.userId!);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
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

/// Person card for list view - HelloTalk style
class _PersonCard extends StatelessWidget {
  final MateModel mate;
  final VoidCallback onConnect;
  final VoidCallback onViewProfile;

  const _PersonCard({
    required this.mate,
    required this.onConnect,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return GestureDetector(
      onTap: onViewProfile,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture with online indicator
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    image: hasValidImage
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: hasValidImage ? null : AppColors.primaryBlue.withAlpha(26),
                  ),
                  child: hasValidImage
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 35,
                          color: AppColors.primaryBlue,
                        ),
                ),
                if (mate.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mate.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (mate.age != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${mate.age}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (mate.location != null || mate.distanceText.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.mediumGrey,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            mate.location ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mediumGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mate.distanceText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(26),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              mate.distanceText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (mate.bio != null && mate.bio!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      mate.bio!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (mate.interests.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: mate.interests.take(3).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.friendlyTeal.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.friendlyTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Connect button
            Column(
              children: [
                GestureDetector(
                  onTap: onConnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick filter chip
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: isSelected
              ? null
              : Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (iconColor ?? AppColors.mediumGrey),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

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
              'No People Nearby Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filters or check back later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: 'Refresh',
              width: 140,
              onPressed: onRefresh,
            ),
          ],
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
            'Find Your People',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Adjust filters to find people who share your interests',
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
