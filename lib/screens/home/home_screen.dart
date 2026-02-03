import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../constants/utils.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/mates_controller.dart';
import '../../models/activity_model.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';
import '../activities/activity_details_screen.dart';
import '../mates/mate_profile_screen.dart';

/// Home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final activityController = Get.find<ActivityController>();
    final matesController = Get.find<MatesController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              profileController.loadProfile(),
              activityController.loadInitialData(),
              matesController.loadNearbyMates(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: const GradientText(
                  text: 'Fluttrr',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${profileController.userName}!',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Find activities and meet new friends',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          )),
                    ),

                    // Nearby mates section
                    _SectionHeader(
                      title: 'Nearby Mates',
                      onSeeAll: () {
                        // Navigate to mates tab
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NearbyMatesCarousel(),

                    const SizedBox(height: AppSpacing.lg),

                    // Daily activities section
                    _SectionHeader(
                      title: 'Daily Activities',
                      onSeeAll: () {
                        // Navigate to activities tab
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DailyActivitiesList(),

                    const SizedBox(height: AppSpacing.lg),

                    // Upcoming activities section
                    _SectionHeader(
                      title: 'Upcoming Activities',
                      onSeeAll: () {
                        // Navigate to activities
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _UpcomingActivitiesList(),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

/// Nearby mates carousel
class _NearbyMatesCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return SizedBox(
      height: 160,
      child: Obx(() {
        if (matesController.isLoading.value &&
            matesController.nearbyMates.isEmpty) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: ShimmerCard(
                width: 120,
                height: 160,
                borderRadius: AppRadius.lg,
              ),
            ),
          );
        }

        if (matesController.nearbyMates.isEmpty) {
          return Center(
            child: Text(
              'No mates nearby',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: matesController.nearbyMates.length,
          itemBuilder: (context, index) {
            final mate = matesController.nearbyMates[index];
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: _MateCard(mate: mate),
            );
          },
        );
      }),
    );
  }
}

/// Mate card widget
class _MateCard extends StatelessWidget {
  final MateModel mate;

  const _MateCard({required this.mate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => MateProfileScreen(userId: mate.userId!)),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mate.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mate.age != null)
                    Text(
                      '${mate.age} years',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Online indicator
            if (mate.isOnline)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Daily activities list
class _DailyActivitiesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Obx(() {
      if (activityController.isLoading.value &&
          activityController.dailyActivities.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ShimmerCard(height: 100),
              ),
            ),
          ),
        );
      }

      if (activityController.dailyActivities.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Text(
              'No activities today',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: activityController.dailyActivities.length.clamp(0, 3),
        itemBuilder: (context, index) {
          final activity = activityController.dailyActivities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ActivityCard(activity: activity),
          );
        },
      );
    });
  }
}

/// Activity card widget
class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
          () => ActivityDetailsScreen(activityId: activity.activityId!)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
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
              child: activity.primaryImage == null
                  ? const Icon(Icons.event, color: AppColors.grey)
                  : null,
            ),

            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
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
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.attendeeCount} attending',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Join indicator
            if (activity.userJoined)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
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
      ),
    );
  }
}

/// Upcoming activities list
class _UpcomingActivitiesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return SizedBox(
      height: 200,
      child: Obx(() {
        if (activityController.allActivities.isEmpty) {
          return Center(
            child: Text(
              'No upcoming activities',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return CarouselSlider.builder(
          itemCount: activityController.allActivities.length.clamp(0, 5),
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          itemBuilder: (context, index, realIndex) {
            final activity = activityController.allActivities[index];
            return _UpcomingActivityCard(activity: activity);
          },
        );
      }),
    );
  }
}

/// Upcoming activity card
class _UpcomingActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _UpcomingActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
          () => ActivityDetailsScreen(activityId: activity.activityId!)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activity.eventType != null)
                    Container(
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    activity.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location ?? 'Location TBD',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
