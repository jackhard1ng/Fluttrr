import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/activity_controller.dart';
import '../../models/activity_model.dart';
import '../../widgets/common_widgets.dart';
import 'activity_details_screen.dart';
import 'create_activity_screen.dart';

/// Activities main screen
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

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
                    text: 'Activities',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _showSearchBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            const _FilterChips(),

            // Activities list
            Expanded(
              child: Obx(() {
                if (activityController.isLoading.value &&
                    activityController.allActivities.isEmpty) {
                  return const LoadingIndicator();
                }

                if (activityController.allActivities.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_busy,
                    title: 'No Activities Found',
                    subtitle: 'Be the first to create an activity!',
                    action: GradientButton(
                      text: 'Create Activity',
                      width: 180,
                      onPressed: () =>
                          Get.to(() => const CreateActivityScreen()),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => activityController.loadActivities(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: activityController.allActivities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == activityController.allActivities.length) {
                        return _buildLoadMore(activityController);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ActivityCard(
                          activity: activityController.allActivities[index],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateActivityScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLoadMore(ActivityController controller) {
    if (!controller.hasMorePages.value) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: LoadingIndicator(size: 30),
        );
      }

      return TextButton(
        onPressed: controller.loadMoreActivities,
        child: const Text('Load More'),
      );
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _FilterBottomSheet(controller: activityController),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => const _SearchBottomSheet(),
    );
  }
}

/// Filter chips row
class _FilterChips extends StatelessWidget {
  const _FilterChips();

  static const List<String> _eventTypes = [
    'All',
    'Sports',
    'Music',
    'Food',
    'Art',
    'Social',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return SizedBox(
      height: 40,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _eventTypes.length,
            itemBuilder: (context, index) {
              final type = _eventTypes[index];
              final isSelected = activityController.filterEventType.value ==
                      (type == 'All' ? '' : type);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) {
                    activityController.filterEventType.value =
                        type == 'All' ? '' : type;
                    activityController.loadActivities(refresh: true);
                  },
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkGrey,
                  ),
                  checkmarkColor: Colors.white,
                ),
              );
            },
          )),
    );
  }
}

/// Activity card widget
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => ActivityDetailsScreen(activityId: activity.activityId!)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                image: activity.primaryImage != null
                    ? DecorationImage(
                        image: NetworkImage(activity.primaryImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.lightGrey,
              ),
              child: Stack(
                children: [
                  if (activity.primaryImage == null)
                    const Center(
                      child: Icon(
                        Icons.event,
                        size: 50,
                        color: AppColors.grey,
                      ),
                    ),

                  // Event type badge
                  if (activity.eventType != null)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          activity.eventType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Save button
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _SaveButton(activity: activity),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location ?? 'Location TBD',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.attendeeCount}/${activity.totalSlots ?? "∞"}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (activity.userJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'Joined',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Save button widget
class _SaveButton extends StatelessWidget {
  final ActivityModel activity;

  const _SaveButton({required this.activity});

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return GestureDetector(
      onTap: () => activityController.toggleSaveActivity(activity.activityId!),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.small,
        ),
        child: Icon(
          activity.userSaved ? Icons.bookmark : Icons.bookmark_border,
          color: activity.userSaved ? AppColors.primaryBlue : AppColors.grey,
          size: 20,
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatelessWidget {
  final ActivityController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Activities',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Distance slider
          Text(
            'Distance',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => Slider(
                value: controller.filterRadius.value,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${controller.filterRadius.value.round()} km',
                onChanged: (value) => controller.filterRadius.value = value,
              )),

          const SizedBox(height: AppSpacing.lg),

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
                    controller.loadActivities(refresh: true);
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search bottom sheet
class _SearchBottomSheet extends StatefulWidget {
  const _SearchBottomSheet();

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _searchController,
            hintText: 'Search activities...',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) => activityController.searchActivities(value),
          ),
          const SizedBox(height: AppSpacing.md),

          Obx(() {
            if (activityController.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: activityController.searchResults.length,
                itemBuilder: (context, index) {
                  final activity = activityController.searchResults[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        image: activity.primaryImage != null
                            ? DecorationImage(
                                image: NetworkImage(activity.primaryImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    title: Text(activity.displayName),
                    subtitle: Text(activity.location ?? ''),
                    onTap: () {
                      Get.back();
                      Get.to(() => ActivityDetailsScreen(
                          activityId: activity.activityId!));
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
