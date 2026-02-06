import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/mates_controller.dart';
import '../../models/activity_model.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';
import '../activities/activity_details_screen.dart';
import '../mates/mate_profile_screen.dart';

/// Home screen with improved brand identity
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
          color: AppColors.primaryBlue,
          onRefresh: () async {
            await Future.wait([
              profileController.loadProfile(),
              activityController.loadInitialData(),
              matesController.loadNearbyMates(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Custom App Bar with logo
              SliverAppBar(
                floating: true,
                pinned: false,
                expandedHeight: 60,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Row(
                  children: [
                    // Butterfly logo
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(38),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/lgo1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primaryDark,
                              child: const Icon(
                                Icons.flutter_dash,
                                size: 20,
                                color: AppColors.primaryBlue,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // App name
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentBlue],
                      ).createShader(bounds),
                      child: const Text(
                        'fluttrr.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Notifications button
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.darkGrey,
                      ),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section with personalized greeting
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profileController.userName.isNotEmpty
                                ? profileController.userName
                                : 'Friend',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Quick action chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _QuickActionChip(
                                  icon: Icons.explore_outlined,
                                  label: 'Discover',
                                  color: AppColors.friendlyTeal,
                                  onTap: () {
                                    // Navigate to discover
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _QuickActionChip(
                                  icon: Icons.event_outlined,
                                  label: 'Host Activity',
                                  color: AppColors.friendlyPurple,
                                  onTap: () {
                                    // Create activity
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _QuickActionChip(
                                  icon: Icons.groups_outlined,
                                  label: 'Find Mates',
                                  color: AppColors.primaryBlue,
                                  onTap: () {
                                    // Navigate to mates
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Nearby mates section - renamed to "Potential Friends"
                    _SectionHeader(
                      title: 'Potential Friends Nearby',
                      subtitle: 'People who share your interests',
                      onSeeAll: () {
                        // Navigate to mates tab
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NearbyMatesCarousel(),

                    const SizedBox(height: AppSpacing.lg),

                    // Daily activities section - renamed
                    _SectionHeader(
                      title: "Today's Hangouts",
                      subtitle: 'Activities happening today',
                      onSeeAll: () {
                        // Navigate to activities tab
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DailyActivitiesList(),

                    const SizedBox(height: AppSpacing.lg),

                    // Upcoming activities section
                    _SectionHeader(
                      title: 'Coming Up',
                      subtitle: 'Plan your next hangout',
                      onSeeAll: () {
                        // Navigate to activities
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _UpcomingActivitiesList(),

                    const SizedBox(height: AppSpacing.lg),

                    // Bottom message about platonic friendships
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withAlpha(26),
                            AppColors.friendlyTeal.withAlpha(26),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(38),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meaningful Friendships',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fluttrr is a safe space for platonic connections',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mediumGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}

/// Quick action chip widget
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header widget with subtitle
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Nearby mates carousel - improved with safe image loading
class _NearbyMatesCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return SizedBox(
      height: 180,
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
                width: 130,
                height: 180,
                borderRadius: AppRadius.lg,
              ),
            ),
          );
        }

        if (matesController.nearbyMates.isEmpty) {
          return _EmptyStateCard(
            icon: Icons.people_outline,
            title: 'No friends nearby yet',
            subtitle: 'Invite people or check back later',
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

/// Empty state card for sections
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.mediumGrey),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mate card widget - improved design
class _MateCard extends StatelessWidget {
  final MateModel mate;

  const _MateCard({required this.mate});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return GestureDetector(
      onTap: () {
        if (mate.userId != null) {
          Get.to(() => MateProfileScreen(userId: mate.userId!));
        }
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          image: hasValidImage
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: AppColors.lightGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Default avatar if no image
            if (!hasValidImage)
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.5, 1],
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
                  if (mate.age != null || mate.location != null)
                    Text(
                      [
                        if (mate.age != null) '${mate.age}',
                        if (mate.location != null) mate.location,
                      ].join(' • '),
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Daily activities list - improved
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
              2,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: _EmptyStateCard(
            icon: Icons.event_outlined,
            title: 'No activities today',
            subtitle: 'Be the first to create one!',
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

/// Activity card widget - improved design
class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(activity.primaryImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(activity.primaryImage);

    return GestureDetector(
      onTap: () {
        if (activity.activityId != null) {
          Get.to(() => ActivityDetailsScreen(activityId: activity.activityId!));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with rounded corners
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                image: hasValidImage
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.primaryBlue.withAlpha(26),
              ),
              child: !hasValidImage
                  ? const Icon(
                      Icons.event,
                      color: AppColors.primaryBlue,
                      size: 32,
                    )
                  : null,
            ),

            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event type badge
                  if (activity.eventType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.friendlyPurple.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        activity.eventType!,
                        style: const TextStyle(
                          color: AppColors.friendlyPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    activity.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location ?? 'Location TBD',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.attendeeCount} going',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Join indicator / action
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Going',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Upcoming activities list - improved carousel
class _UpcomingActivitiesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return SizedBox(
      height: 200,
      child: Obx(() {
        if (activityController.allActivities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _EmptyStateCard(
              icon: Icons.calendar_today_outlined,
              title: 'No upcoming activities',
              subtitle: 'Create one and invite friends!',
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
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
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

/// Upcoming activity card - improved design
class _UpcomingActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _UpcomingActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(activity.primaryImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(activity.primaryImage);

    return GestureDetector(
      onTap: () {
        if (activity.activityId != null) {
          Get.to(() => ActivityDetailsScreen(activityId: activity.activityId!));
        }
      },
      child: Container(
        width: double.infinity,
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
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.friendlyPurple,
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(51),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x33000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.5, 1],
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
                      fontSize: 20,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.attendeeCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
