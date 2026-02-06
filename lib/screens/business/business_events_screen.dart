import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../widgets/common_widgets.dart';

/// Screen showing business's past and upcoming events
class BusinessEventsScreen extends StatefulWidget {
  const BusinessEventsScreen({super.key});

  @override
  State<BusinessEventsScreen> createState() => _BusinessEventsScreenState();
}

class _BusinessEventsScreenState extends State<BusinessEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.mediumGrey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _UpcomingEventsList(),
          const _PastEventsList(),
        ],
      ),
    );
  }
}

class _UpcomingEventsList extends StatelessWidget {
  const _UpcomingEventsList();

  @override
  Widget build(BuildContext context) {
    final events = [
      _EventData(
        name: 'Board Game Night',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '7:00 PM',
        location: 'The Game Cafe',
        attendees: 12,
        capacity: 20,
        type: 'games',
      ),
      _EventData(
        name: 'Coffee & Conversations',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '10:00 AM',
        location: 'Central Perk Coffee',
        attendees: 8,
        capacity: 15,
        type: 'coffee',
      ),
      _EventData(
        name: 'Photography Walk',
        date: DateTime.now().add(const Duration(days: 8)),
        time: '4:00 PM',
        location: 'Downtown Arts District',
        attendees: 5,
        capacity: null,
        type: 'outdoor',
      ),
    ];

    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available,
        title: 'No upcoming events',
        subtitle: 'Create your first event to start connecting with people',
        actionLabel: 'Create Event',
        onAction: () => Nav.toBusinessCreateEvent(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _UpcomingEventCard(event: events[index]);
      },
    );
  }
}

class _PastEventsList extends StatelessWidget {
  const _PastEventsList();

  @override
  Widget build(BuildContext context) {
    final events = [
      _EventData(
        name: 'Hiking Meetup',
        date: DateTime.now().subtract(const Duration(days: 3)),
        time: '9:00 AM',
        location: 'Mountain Trail Park',
        attendees: 15,
        capacity: 20,
        type: 'outdoor',
        photoCount: 12,
        reviewCount: 8,
        averageRating: 4.8,
      ),
      _EventData(
        name: 'Board Game Night',
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: '7:00 PM',
        location: 'The Game Cafe',
        attendees: 18,
        capacity: 20,
        type: 'games',
        photoCount: 8,
        reviewCount: 5,
        averageRating: 4.6,
      ),
      _EventData(
        name: 'Coffee & Conversations',
        date: DateTime.now().subtract(const Duration(days: 17)),
        time: '10:00 AM',
        location: 'Central Perk Coffee',
        attendees: 14,
        capacity: 15,
        type: 'coffee',
        photoCount: 5,
        reviewCount: 7,
        averageRating: 4.9,
      ),
    ];

    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.history,
        title: 'No past events',
        subtitle: 'Your completed events will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _PastEventCard(event: events[index]);
      },
    );
  }
}

class _EventData {
  final String name;
  final DateTime date;
  final String time;
  final String location;
  final int attendees;
  final int? capacity;
  final String type;
  final int? photoCount;
  final int? reviewCount;
  final double? averageRating;

  _EventData({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.attendees,
    this.capacity,
    required this.type,
    this.photoCount,
    this.reviewCount,
    this.averageRating,
  });
}

class _UpcomingEventCard extends StatelessWidget {
  final _EventData event;

  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
      child: Column(
        children: [
          // Event header with gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getEventColor(event.type),
                  _getEventColor(event.type).withAlpha(179),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(event.date),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.time,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
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

          // Event details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Attendees progress
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 18,
                      color: AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: EventCapacityIndicator(
                        current: event.attendees,
                        capacity: event.capacity,
                        showProgress: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Edit event
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // View attendees
                        },
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Attendees'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.friendlyPurple,
                          side: const BorderSide(color: AppColors.friendlyPurple),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        // Share event
                        Get.snackbar(
                          'Share',
                          'Event link copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: Icon(
                        Icons.share_outlined,
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
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getEventColor(String type) {
    final colors = {
      'games': AppColors.friendlyPurple,
      'coffee': AppColors.friendlyOrange,
      'outdoor': AppColors.friendlyTeal,
      'social': AppColors.primaryBlue,
    };
    return colors[type] ?? AppColors.primaryBlue;
  }

  IconData _getEventIcon(String type) {
    final icons = {
      'games': Icons.casino,
      'coffee': Icons.coffee,
      'outdoor': Icons.terrain,
      'social': Icons.groups,
    };
    return icons[type] ?? Icons.event;
  }
}

class _PastEventCard extends StatelessWidget {
  final _EventData event;

  const _PastEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getEventColor(event.type).withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getEventIcon(event.type),
                  color: _getEventColor(event.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Completed badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.people,
                  value: '${event.attendees}',
                  label: 'Attended',
                  color: AppColors.primaryBlue,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.lightGrey,
                ),
                _StatColumn(
                  icon: Icons.photo_library,
                  value: '${event.photoCount ?? 0}',
                  label: 'Photos',
                  color: AppColors.friendlyPurple,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.lightGrey,
                ),
                _StatColumn(
                  icon: Icons.star,
                  value: event.averageRating?.toStringAsFixed(1) ?? '-',
                  label: '${event.reviewCount ?? 0} reviews',
                  color: AppColors.friendlyOrange,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_a_photo,
                  label: 'Add Photos',
                  color: AppColors.friendlyPurple,
                  onTap: () => Nav.toBusinessPhotos(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.rate_review_outlined,
                  label: 'View Reviews',
                  color: AppColors.friendlyOrange,
                  onTap: () => Nav.toBusinessReviews(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.copy,
                  label: 'Duplicate',
                  color: AppColors.friendlyTeal,
                  onTap: () {
                    Get.snackbar(
                      'Event Duplicated',
                      'A copy has been created as a draft',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getEventColor(String type) {
    final colors = {
      'games': AppColors.friendlyPurple,
      'coffee': AppColors.friendlyOrange,
      'outdoor': AppColors.friendlyTeal,
      'social': AppColors.primaryBlue,
    };
    return colors[type] ?? AppColors.primaryBlue;
  }

  IconData _getEventIcon(String type) {
    final icons = {
      'games': Icons.casino,
      'coffee': Icons.coffee,
      'outdoor': Icons.terrain,
      'social': Icons.groups,
    };
    return icons[type] ?? Icons.event;
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(77)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
