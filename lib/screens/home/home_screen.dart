import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/discover_controller.dart';
import '../../controllers/notifications_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    if (!Get.isRegistered<DiscoverController>()) {
      Get.put(DiscoverController());
    }
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            final discoverController = Get.find<DiscoverController>();
            await discoverController.refreshEvents();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              const _HomeAppBar(),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Search
                    const _GreetingSection(),

                    // Free Right Now Card
                    const _FreeNowCard(),

                    // Your Upcoming Events
                    const _YourEventsSection(),

                    // What Friends Are Doing
                    const _FriendsActivitySection(),

                    // Quick Browse Categories
                    const _QuickCategoriesSection(),

                    // Happening Today
                    const _TodayEventsSection(),

                    // Trending Near You
                    const _TrendingSection(),

                    // Suggested For You
                    const _SuggestedSection(),

                    // Create Your Own
                    const _CreateEventPrompt(),

                    // Bottom padding
                    const SizedBox(height: 100),
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

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.friendlyPurple],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🦋', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.friendlyPurple],
            ).createShader(bounds),
            child: const Text(
              'fluttrr',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Notifications
        GetBuilder<NotificationsController>(
          init: NotificationsController(),
          builder: (controller) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Nav.toNotifications();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(128),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_outlined, color: AppColors.darkGrey),
                    ),
                    if (controller.unreadCount.value > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${controller.unreadCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        // Profile
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to profile
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withAlpha(51),
              child: Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready to hang out?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Nav.toSearch();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.mediumGrey),
                  const SizedBox(width: 12),
                  Text(
                    'Search events, people, places...',
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeNowCard extends StatelessWidget {
  const _FreeNowCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.friendlyTeal, AppColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Text('☕', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free right now?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '3 friends are looking to hang out nearby',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.arrow_forward, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }
}

class _YourEventsSection extends StatelessWidget {
  const _YourEventsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Upcoming',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _YourEventCard(
                emoji: '🎮',
                title: 'Board Game Night',
                date: 'Tomorrow, 7 PM',
                attendees: 8,
                color: AppColors.friendlyPurple,
              ),
              _YourEventCard(
                emoji: '🥾',
                title: 'Morning Hike',
                date: 'Saturday, 8 AM',
                attendees: 5,
                color: AppColors.success,
              ),
              const _AddEventCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _YourEventCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String date;
  final int attendees;
  final Color color;

  const _YourEventCard({
    required this.emoji,
    required this.title,
    required this.date,
    required this.attendees,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  '$attendees going',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: AppColors.mediumGrey),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddEventCard extends StatelessWidget {
  const _AddEventCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Nav.toCreateEvent();
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 12),
            Text(
              'Create Event',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsActivitySection extends StatelessWidget {
  const _FriendsActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Friends Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FriendActivityItem(
                name: 'Alex',
                action: 'joined Board Game Night',
                timeAgo: '2h ago',
              ),
              _FriendActivityItem(
                name: 'Jordan',
                action: 'is hosting Coffee Meetup',
                timeAgo: '4h ago',
              ),
              _FriendActivityItem(
                name: 'Taylor',
                action: 'is free right now',
                timeAgo: 'Now',
                isLive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String timeAgo;
  final bool isLive;

  const _FriendActivityItem({
    required this.name,
    required this.action,
    required this.timeAgo,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLive ? AppColors.success.withAlpha(26) : AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isLive ? Border.all(color: AppColors.success.withAlpha(77)) : null,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue.withAlpha(51),
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isLive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $action',
                        style: TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLive ? AppColors.success : AppColors.mediumGrey,
                    fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCategoriesSection extends StatelessWidget {
  const _QuickCategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Browse by Vibe',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _CategoryChip(emoji: '☕', label: 'Chill', color: AppColors.warmYellow),
              _CategoryChip(emoji: '🎮', label: 'Games', color: AppColors.friendlyPurple),
              _CategoryChip(emoji: '🏃', label: 'Active', color: AppColors.success),
              _CategoryChip(emoji: '🍕', label: 'Food', color: AppColors.friendlyOrange),
              _CategoryChip(emoji: '🎨', label: 'Creative', color: AppColors.primaryBlue),
              _CategoryChip(emoji: '📚', label: 'Learning', color: AppColors.friendlyTeal),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEventsSection extends StatelessWidget {
  const _TodayEventsSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiscoverController>(
      init: DiscoverController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Happening Today',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final events = controller.filteredEvents.take(3).toList();
              if (events.isEmpty) {
                return const _EmptyTodayCard();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventListItem(
                    emoji: event.emoji ?? '📅',
                    title: event.title,
                    location: event.location,
                    time: '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} PM',
                    attendees: event.currentAttendees,
                    maxAttendees: event.maxAttendees,
                    hostName: event.hostName,
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Text('🌤️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Nothing happening yet today',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to create something!',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String location;
  final String time;
  final int attendees;
  final int maxAttendees;
  final String hostName;

  const _EventListItem({
    required this.emoji,
    required this.title,
    required this.location,
    required this.time,
    required this.attendees,
    required this.maxAttendees,
    required this.hostName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Text(
                      '$attendees/$maxAttendees',
                      style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mediumGrey),
        ],
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  const _TrendingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.friendlyOrange),
              const SizedBox(width: 8),
              const Text(
                'Trending Near You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _TrendingCard(
                emoji: '🎯',
                title: 'Trivia Night',
                location: 'The Pub House',
                attendees: 24,
                trending: '+12 today',
              ),
              _TrendingCard(
                emoji: '🧘',
                title: 'Sunrise Yoga',
                location: 'Central Park',
                attendees: 18,
                trending: '+8 today',
              ),
              _TrendingCard(
                emoji: '📖',
                title: 'Book Club Meetup',
                location: 'City Library',
                attendees: 15,
                trending: '+6 today',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String location;
  final int attendees;
  final String trending;

  const _TrendingCard({
    required this.emoji,
    required this.title,
    required this.location,
    required this.attendees,
    required this.trending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.friendlyOrange.withAlpha(26),
            AppColors.warmYellow.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.friendlyOrange.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyOrange,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        trending,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: AppColors.darkGrey),
                const SizedBox(width: 4),
                Text(
                  '$attendees interested',
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _SuggestedSection extends StatelessWidget {
  const _SuggestedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.friendlyPurple),
              const SizedBox(width: 8),
              const Text(
                'Suggested For You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Based on your interests',
            style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.friendlyPurple.withAlpha(26),
                AppColors.primaryBlue.withAlpha(26),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Text('🎲', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.friendlyPurple,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text(
                        '92% match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'D&D Campaign Night',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saturday • 6 PM • 3 spots left',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateEventPrompt extends StatelessWidget {
  const _CreateEventPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have something in mind?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create an event and find people who want to join!',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Nav.toCreateEvent();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    'Create',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
