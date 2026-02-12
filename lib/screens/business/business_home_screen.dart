import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/business_controller.dart';
import '../../models/business_model.dart';
import '../../widgets/common_widgets.dart';

/// Business home screen with Profile and Events tabs
class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _businessController = Get.isRegistered<BusinessController>()
      ? Get.find<BusinessController>()
      : Get.put(BusinessController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const GradientText(
          text: 'Business',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Nav.toBusinessAnalytics(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BusinessProfileTab(controller: _businessController),
          _BusinessEventsTab(controller: _businessController),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Nav.toBusinessNewEvent(),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Business Profile Tab - shows business info
class _BusinessProfileTab extends StatelessWidget {
  final BusinessController controller;

  const _BusinessProfileTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final business = controller.businessProfile.value;

      if (business == null) {
        return const Center(
          child: EmptyState(
            icon: Icons.store_outlined,
            title: 'No Profile Yet',
            subtitle: 'Set up your business profile to get started',
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryHorizontal,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: business.profileImage,
                    size: 70,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (business.category != null)
                          Text(
                            business.category!,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            business.subscriptionStatus?.planName ?? 'Free Plan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Business Details section
            Text(
              'Business Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.small,
              ),
              child: Column(
                children: [
                  if (business.description != null && business.description!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      value: business.description!,
                    ),
                  if (business.location != null && business.location!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: business.location!,
                    ),
                  if (business.address != null && business.address!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.home_outlined,
                      label: 'Address',
                      value: business.address!,
                    ),
                  if (business.phone != null && business.phone!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: business.phone!,
                    ),
                  if (business.email != null && business.email!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: business.email!,
                    ),
                  if (business.website != null && business.website!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: business.website!,
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Stats row
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event,
                    label: 'Events',
                    value: '${controller.myBusinessEvents.length}',
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    label: 'Followers',
                    value: '${business.followerCount ?? 0}',
                    color: AppColors.friendlyTeal,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    label: 'Rating',
                    value: (business.averageRating ?? 0) > 0
                        ? (business.averageRating ?? 0).toStringAsFixed(1)
                        : '--',
                    color: AppColors.warmYellow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Edit profile button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Nav.toBusinessCreateProfile(),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Business Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  foregroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
    });
  }
}

/// Detail row for business profile
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card for business profile
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Business Events Tab
class _BusinessEventsTab extends StatefulWidget {
  final BusinessController controller;

  const _BusinessEventsTab({required this.controller});

  @override
  State<_BusinessEventsTab> createState() => _BusinessEventsTabState();
}

class _BusinessEventsTabState extends State<_BusinessEventsTab>
    with SingleTickerProviderStateMixin {
  late TabController _eventTabController;

  @override
  void initState() {
    super.initState();
    _eventTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _eventTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _eventTabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _eventTabController,
            children: [
              _EventsList(
                controller: widget.controller,
                filter: EventFilter.all,
              ),
              _EventsList(
                controller: widget.controller,
                filter: EventFilter.upcoming,
              ),
              _EventsList(
                controller: widget.controller,
                filter: EventFilter.past,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Event filter enum
enum EventFilter { all, upcoming, past }

/// Events list widget
class _EventsList extends StatelessWidget {
  final BusinessController controller;
  final EventFilter filter;

  const _EventsList({required this.controller, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.myBusinessEvents.isEmpty) {
        return const LoadingIndicator();
      }

      final events = _getFilteredEvents(controller.myBusinessEvents);

      if (events.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: 'No Events',
          subtitle: _getEmptySubtitle(),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadMyBusinessEvents,
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
      onTap: () => Nav.toBusinessEventDetails(event),
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
                        color: AppColors.primaryBlue,
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
                      _EventStatItem(
                        icon: Icons.people,
                        value: '${event.attendeesCount ?? 0}',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _EventStatItem(
                        icon: Icons.visibility,
                        value: '${event.views ?? 0}',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _EventStatItem(
                        icon: Icons.touch_app,
                        value: '${event.clicks ?? 0}',
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

/// Event stat item widget
class _EventStatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _EventStatItem({
    required this.icon,
    required this.value,
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
