import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/animated_widgets.dart';
import 'quick_create_event_screen.dart';
import 'business_events_screen.dart';
import 'business_reviews_screen.dart';
import 'event_photos_screen.dart';

/// Business dashboard - Main screen for business accounts
/// Designed for ease of use with quick actions and clear stats
class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
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
                            profileController.currentUser.value?.businessName ??
                                profileController.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      const Row(
                        children: [
                          Icon(Icons.verified, size: 12, color: Color(0xFFFFD700)),
                          SizedBox(width: 4),
                          Text(
                            'Business Account',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFFD700),
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
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
                    _QuickCreateEventCard(),

                    const SizedBox(height: AppSpacing.lg),

                    // Stats overview
                    _StatsOverview(),

                    const SizedBox(height: AppSpacing.lg),

                    // Quick actions grid
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionsGrid(),

                    const SizedBox(height: AppSpacing.lg),

                    // Recent reviews
                    _RecentReviewsSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Upcoming events
                    _UpcomingEventsSection(),

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
        onPressed: () => Get.to(() => const QuickCreateEventScreen()),
        backgroundColor: const Color(0xFFFFD700),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const QuickCreateEventScreen()),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withAlpha(77),
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
  @override
  Widget build(BuildContext context) {
    // Mock stats for demo
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.event,
            label: 'Events',
            value: '12',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            label: 'Attendees',
            value: '248',
            color: AppColors.friendlyTeal,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            label: 'Rating',
            value: '4.8',
            color: AppColors.friendlyOrange,
          ),
        ),
      ],
    );
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
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _QuickActionTile(
          icon: Icons.photo_library_outlined,
          label: 'Event Photos',
          subtitle: 'Upload & manage',
          color: AppColors.friendlyPurple,
          onTap: () => Get.to(() => const EventPhotosScreen()),
        ),
        _QuickActionTile(
          icon: Icons.history,
          label: 'Past Events',
          subtitle: 'View history',
          color: AppColors.primaryBlue,
          onTap: () => Get.to(() => const BusinessEventsScreen()),
        ),
        _QuickActionTile(
          icon: Icons.star_outline,
          label: 'Reviews',
          subtitle: '24 new',
          color: AppColors.friendlyOrange,
          onTap: () => Get.to(() => const BusinessReviewsScreen()),
        ),
        _QuickActionTile(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          subtitle: 'Coming soon',
          color: AppColors.friendlyTeal,
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
      onTap: onTap,
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const BusinessReviewsScreen()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Mock reviews
        _ReviewCard(
          userName: 'Sarah M.',
          rating: 5,
          review: 'Amazing event! The yoga session was so relaxing and well-organized.',
          date: '2 days ago',
          eventName: 'Morning Yoga',
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReviewCard(
          userName: 'Mike R.',
          rating: 4,
          review: 'Great atmosphere, would definitely come back for more events!',
          date: '1 week ago',
          eventName: 'Coffee Meetup',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final int rating;
  final String review;
  final String date;
  final String eventName;

  const _ReviewCard({
    required this.userName,
    required this.rating,
    required this.review,
    required this.date,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue.withAlpha(26),
                child: Text(
                  userName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: AppColors.friendlyOrange,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              eventName,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upcoming events section
class _UpcomingEventsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Get.to(() => const BusinessEventsScreen()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Mock upcoming events
        _UpcomingEventCard(
          name: 'Weekend Hiking Adventure',
          date: 'Saturday, Feb 8',
          time: '9:00 AM',
          attendees: 12,
          maxAttendees: 20,
        ),
        const SizedBox(height: AppSpacing.sm),
        _UpcomingEventCard(
          name: 'Coffee & Conversation',
          date: 'Sunday, Feb 9',
          time: '10:30 AM',
          attendees: 8,
          maxAttendees: null, // No limit
        ),
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show event options
            },
          ),
        ],
      ),
    );
  }
}
