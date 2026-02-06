import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../models/business_model.dart';
import '../../widgets/common_widgets.dart';
import 'business_analytics_screen.dart';
import 'business_event_details_screen.dart';
import 'create_business_event_screen.dart';
import 'subscription_screen.dart';

/// Business home screen (dashboard)
class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _businessController = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    _businessController.loadBusinessProfile();
    _businessController.loadMyBusinessEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Business profile card
            Obx(() => _buildProfileCard()),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.primaryBlue,
              tabs: const [
                Tab(text: 'All Events'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),

            // Events list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _EventsList(filter: EventFilter.all),
                  _EventsList(filter: EventFilter.upcoming),
                  _EventsList(filter: EventFilter.past),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateBusinessEventScreen()),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const GradientText(
            text: 'Business',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => Get.to(() => const BusinessAnalyticsScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.workspace_premium),
                onPressed: () => Get.to(() => const SubscriptionScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final business = _businessController.businessProfile.value;

    if (business == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryHorizontal,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: business.profileImage,
            size: 60,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name ?? 'Business Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      business.location ?? 'Location',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              business.subscriptionStatus?.planName ?? 'Free',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Event filter enum
enum EventFilter { all, upcoming, past }

/// Events list widget
class _EventsList extends StatelessWidget {
  final EventFilter filter;

  const _EventsList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final businessController = Get.find<BusinessController>();

    return Obx(() {
      if (businessController.isLoading.value &&
          businessController.myBusinessEvents.isEmpty) {
        return const LoadingIndicator();
      }

      final events = _getFilteredEvents(businessController.myBusinessEvents);

      if (events.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: 'No Events',
          subtitle: _getEmptySubtitle(),
        );
      }

      return RefreshIndicator(
        onRefresh: businessController.loadMyBusinessEvents,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _BusinessEventCard(event: events[index]);
          },
        ),
      );
    });
  }

  List<BusinessEvent> _getFilteredEvents(List<BusinessEvent> events) {
    final now = DateTime.now();

    switch (filter) {
      case EventFilter.all:
        return events;
      case EventFilter.upcoming:
        return events.where((e) {
          final startDate = e.startDate;
          return startDate != null && startDate.isAfter(now);
        }).toList();
      case EventFilter.past:
        return events.where((e) {
          final endDate = e.endDate ?? e.startDate;
          return endDate != null && endDate.isBefore(now);
        }).toList();
    }
  }

  String _getEmptySubtitle() {
    switch (filter) {
      case EventFilter.all:
        return 'Create your first event to get started';
      case EventFilter.upcoming:
        return 'No upcoming events scheduled';
      case EventFilter.past:
        return 'No past events yet';
    }
  }
}

/// Business event card widget
class _BusinessEventCard extends StatelessWidget {
  final BusinessEvent event;

  const _BusinessEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => BusinessEventDetailsScreen(event: event)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: Stack(
                children: [
                  Image.network(
                    event.image ?? '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: AppColors.lightGrey,
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  // Event type badge
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: event.eventType == 'Free'
                            ? AppColors.success
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        event.eventType ?? 'Event',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? 'Event Name',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.startDate != null
                            ? DateFormat('MMM d, y • h:mm a')
                                .format(event.startDate!)
                            : 'Date TBD',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.locationName ?? 'Location TBD',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Stats row
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.people,
                        value: '${event.attendeesCount ?? 0}',
                        label: 'Attendees',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatItem(
                        icon: Icons.visibility,
                        value: '${event.views ?? 0}',
                        label: 'Views',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatItem(
                        icon: Icons.touch_app,
                        value: '${event.clicks ?? 0}',
                        label: 'Clicks',
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

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
