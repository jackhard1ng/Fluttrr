import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/business_controller.dart';
import '../../controllers/profile_controller.dart';

/// Business dashboard - Main screen for business accounts
/// Designed for ease of use with quick actions and clear stats
class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure BusinessController is registered before widgets use it
    if (!Get.isRegistered<BusinessController>()) {
      Get.put(BusinessController());
    }
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar with business badge
            SliverAppBar(
              floating: true,
              pinned: false,
              expandedHeight: 60,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: [
                  // Business icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentBlue],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => Text(
                            profileController.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      const Row(
                        children: [
                          Icon(Icons.verified, size: 12, color: AppColors.primaryBlue),
                          SizedBox(width: 4),
                          Text(
                            'Business Account',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Nav.toNotifications(),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Nav.toSettings(),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to host your next event?',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Quick Create Event Button - THE MAIN ACTION
                    const _QuickCreateEventCard(),

                    const SizedBox(height: AppSpacing.lg),

                    // Stats overview
                    const _StatsOverview(),

                    const SizedBox(height: AppSpacing.lg),

                    // Quick actions grid
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _QuickActionsGrid(),

                    const SizedBox(height: AppSpacing.lg),

                    // Recent reviews
                    const _RecentReviewsSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Upcoming events
                    const _UpcomingEventsSection(),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating action button for quick event creation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Nav.toBusinessCreateEvent(),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

/// Big, prominent create event card
class _QuickCreateEventCard extends StatelessWidget {
  const _QuickCreateEventCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Nav.toBusinessCreateEvent(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap here to quickly create and publish your next event',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats overview cards
class _StatsOverview extends StatelessWidget {
  const _StatsOverview();

  @override
  Widget build(BuildContext context) {
    final businessController = Get.isRegistered<BusinessController>()
        ? Get.find<BusinessController>()
        : Get.put(BusinessController());

    return Obx(() {
      final analytics = businessController.analytics.value;
      final eventsCount = businessController.myBusinessEvents.length;
      final totalAttendees = analytics?.totalAttendees ?? 0;
      final rating = businessController.businessProfile.value?.rating ?? 0.0;

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event,
              label: 'Events',
              value: '$eventsCount',
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.people,
              label: 'Attendees',
              value: '$totalAttendees',
              color: AppColors.friendlyTeal,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.star,
              label: 'Rating',
              value: rating > 0 ? rating.toStringAsFixed(1) : '--',
              color: AppColors.warmYellow,
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions grid
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.8,
      children: [
        _QuickActionTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          subtitle: 'View updates',
          color: AppColors.primaryBlue,
          onTap: () => Nav.toNotifications(),
        ),
        _QuickActionTile(
          icon: Icons.store_outlined,
          label: 'Profile',
          subtitle: 'Business info',
          color: AppColors.accentBlue,
          onTap: () => Nav.toBusinessHome(),
        ),
        _QuickActionTile(
          icon: Icons.photo_library_outlined,
          label: 'Event Photos',
          subtitle: 'Upload & manage',
          color: AppColors.friendlyPurple,
          onTap: () => Nav.toBusinessPhotos(),
        ),
        _QuickActionTile(
          icon: Icons.history,
          label: 'Past Events',
          subtitle: 'View history',
          color: AppColors.friendlyTeal,
          onTap: () => Nav.toBusinessEvents(),
        ),
        _QuickActionTile(
          icon: Icons.star_outline,
          label: 'Reviews',
          subtitle: 'View ratings',
          color: AppColors.warmYellow,
          onTap: () => Nav.toBusinessReviews(),
        ),
        _QuickActionTile(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          subtitle: 'Coming soon',
          color: AppColors.friendlyPurple,
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Analytics feature will be available soon!',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent reviews section
class _RecentReviewsSection extends StatelessWidget {
  const _RecentReviewsSection();

  @override
  Widget build(BuildContext context) {
    final businessController = Get.find<BusinessController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews & Ratings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Nav.toBusinessReviews(),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final profile = businessController.businessProfile.value;
          final rating = profile?.averageRating ?? 0.0;
          final reviewCount = profile?.reviewCount ?? 0;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: reviewCount > 0
                ? Row(
                    children: [
                      // Rating display
                      Column(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: AppColors.warmYellow,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$reviewCount reviews',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your customers love your events!',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "See All" to read all reviews and respond to feedback.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 40,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reviews will appear here once attendees rate your events.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ],
    );
  }
}

/// Upcoming events section
class _UpcomingEventsSection extends StatelessWidget {
  const _UpcomingEventsSection();

  @override
  Widget build(BuildContext context) {
    final businessController = Get.find<BusinessController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Upcoming Events',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Nav.toBusinessEvents(),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final now = DateTime.now();
          final upcoming = businessController.myBusinessEvents
              .where((e) => e.startDate != null && e.startDate!.isAfter(now))
              .take(3)
              .toList();

          if (upcoming.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 40,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No upcoming events',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first event to get started!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: upcoming.map((event) {
              final dateStr = event.startDate != null
                  ? DateFormat('EEEE, MMM d').format(event.startDate!)
                  : 'Date TBD';
              final timeStr = event.startDate != null
                  ? DateFormat('h:mm a').format(event.startDate!)
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _UpcomingEventCard(
                  name: event.name ?? 'Untitled Event',
                  date: dateStr,
                  time: timeStr,
                  attendees: event.attendeesCount ?? 0,
                  maxAttendees: event.totalSlots,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final int attendees;
  final int? maxAttendees;

  const _UpcomingEventCard({
    required this.name,
    required this.date,
    required this.time,
    required this.attendees,
    this.maxAttendees,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = maxAttendees != null;
    final isFull = hasLimit && attendees >= maxAttendees!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Text(
                  date.split(',')[0], // Day name
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: isFull ? AppColors.error : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasLimit
                          ? '$attendees/$maxAttendees joined'
                          : '$attendees joined',
                      style: TextStyle(
                        fontSize: 12,
                        color: isFull ? AppColors.error : AppColors.mediumGrey,
                      ),
                    ),
                    if (isFull) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FULL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Get.snackbar(
                    'Coming Soon',
                    'Event editing will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  break;
                case 'view':
                  Nav.toBusinessEvents();
                  break;
                case 'cancel':
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Cancel Event'),
                      content: const Text(
                        'Are you sure you want to cancel this event? Attendees will be notified.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('No, keep it'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.snackbar(
                              'Event Cancelled',
                              'The event has been cancelled and attendees notified',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: const Text(
                            'Yes, cancel',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: AppSpacing.sm),
                    Text('Edit Event'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: AppSpacing.sm),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: AppColors.error),
                    SizedBox(width: AppSpacing.sm),
                    Text('Cancel Event', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
