import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Public-facing business profile that users can view and review
class PublicBusinessProfileScreen extends StatefulWidget {
  final String businessId;

  const PublicBusinessProfileScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<PublicBusinessProfileScreen> createState() =>
      _PublicBusinessProfileScreenState();
}

class _PublicBusinessProfileScreenState
    extends State<PublicBusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return;

    setState(() => _isFollowLoading = true);

    try {
      final businessController = Get.find<BusinessController>();
      final businessId = int.tryParse(widget.businessId);

      if (businessId != null) {
        final success = await businessController.toggleFollowBusiness(businessId);

        if (success) {
          setState(() => _isFollowing = !_isFollowing);
          Get.snackbar(
            _isFollowing ? 'Following!' : 'Unfollowed',
            _isFollowing
                ? 'You\'ll see their events in your feed'
                : 'You won\'t see their events anymore',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _isFollowing ? AppColors.success : AppColors.mediumGrey,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Could not update follow status. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with cover image
          _BusinessHeader(
            isFollowing: _isFollowing,
            isLoading: _isFollowLoading,
            onFollowTap: _toggleFollow,
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: const ['Events', 'Photos', 'Reviews'],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _EventsTab(),
                const _PhotosTab(),
                _ReviewsTab(
                  onWriteReview: _showWriteReviewSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WriteReviewSheet(
        businessName: 'The Social Hub',
        onSubmit: (rating, comment) {
          Navigator.pop(context);
          Get.snackbar(
            'Review Submitted!',
            'Thank you for your feedback',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        },
      ),
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  final bool isFollowing;
  final bool isLoading;
  final VoidCallback onFollowTap;

  const _BusinessHeader({
    required this.isFollowing,
    required this.onFollowTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.darkGrey,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.friendlyPurple,
                  ],
                ),
              ),
            ),

            // Pattern overlay
            Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
              ),
            ),

            // Content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(128),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and name
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'SH',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'The Social Hub',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const BusinessBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Downtown Area',
                                    style: TextStyle(
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

                    const SizedBox(height: 12),

                    // Stats row
                    Row(
                      children: [
                        _StatBadge(icon: Icons.event, value: '24', label: 'Events'),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.star, value: '4.8', label: 'Rating'),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.people, value: '1.2k', label: 'Followers'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : onFollowTap,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    isFollowing ? Icons.check : Icons.add,
                                    size: 18,
                                  ),
                            label: Text(isLoading
                                ? ''
                                : (isFollowing ? 'Following' : 'Follow')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? Colors.white.withAlpha(51)
                                  : Colors.white,
                              foregroundColor: isFollowing
                                  ? Colors.white
                                  : AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Share business - copy link to clipboard
                              const shareUrl = 'https://fluttrr.app/business/the-social-hub';
                              Clipboard.setData(const ClipboardData(text: shareUrl));
                              HapticFeedback.lightImpact();
                              Get.snackbar(
                                'Link Copied!',
                                'Share link copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.success,
                                colorText: Colors.white,
                              );
                            },
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Message business
                            },
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _showBusinessOptionsMenu(context);
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.error),
              title: const Text('Report business'),
              subtitle: Text(
                'Report inappropriate content or behavior',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Navigator.pop(context);
                Nav.toReport(businessName: 'The Social Hub');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.primaryBlue),
              title: const Text('Get help'),
              subtitle: Text(
                'Contact support at support@fluttrr.com',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Navigator.pop(context);
                Nav.toHelp();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;

  _TabBarDelegate({
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.mediumGrey,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _EventsTab extends StatefulWidget {
  const _EventsTab();

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  String _filter = 'upcoming'; // 'upcoming', 'past', 'all'

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = [
      _EventItem(
        name: 'Board Game Night',
        date: 'Tomorrow, 7:00 PM',
        location: 'The Game Cafe',
        attendees: 12,
        capacity: 20,
        type: 'games',
        isPast: false,
      ),
      _EventItem(
        name: 'Coffee & Conversations',
        date: 'Sat, Feb 10, 10:00 AM',
        location: 'Central Perk Coffee',
        attendees: 8,
        capacity: 15,
        type: 'coffee',
        isPast: false,
      ),
      _EventItem(
        name: 'Photography Walk',
        date: 'Sun, Feb 11, 4:00 PM',
        location: 'Downtown Arts District',
        attendees: 5,
        capacity: null,
        type: 'outdoor',
        isPast: false,
      ),
    ];

    final pastEvents = [
      _EventItem(
        name: 'Movie Night: Classics',
        date: 'Jan 28, 2024',
        location: 'The Cinema Lounge',
        attendees: 18,
        capacity: 25,
        type: 'social',
        isPast: true,
        rating: 4.7,
        reviewCount: 12,
      ),
      _EventItem(
        name: 'Trivia Tuesday',
        date: 'Jan 23, 2024',
        location: 'The Game Cafe',
        attendees: 24,
        capacity: 30,
        type: 'games',
        isPast: true,
        rating: 4.9,
        reviewCount: 18,
      ),
      _EventItem(
        name: 'Hiking Meetup: Sunrise Trail',
        date: 'Jan 20, 2024',
        location: 'Mountain View Park',
        attendees: 15,
        capacity: 20,
        type: 'outdoor',
        isPast: true,
        rating: 5.0,
        reviewCount: 14,
      ),
      _EventItem(
        name: 'Coffee Tasting Workshop',
        date: 'Jan 15, 2024',
        location: 'Central Perk Coffee',
        attendees: 12,
        capacity: 15,
        type: 'coffee',
        isPast: true,
        rating: 4.5,
        reviewCount: 8,
      ),
      _EventItem(
        name: 'Book Club: January Read',
        date: 'Jan 10, 2024',
        location: 'The Library Cafe',
        attendees: 8,
        capacity: 12,
        type: 'social',
        isPast: true,
        rating: 4.8,
        reviewCount: 6,
      ),
      _EventItem(
        name: 'New Year Mixer',
        date: 'Jan 1, 2024',
        location: 'The Social Hub',
        attendees: 45,
        capacity: 50,
        type: 'social',
        isPast: true,
        rating: 4.6,
        reviewCount: 32,
      ),
    ];

    List<_EventItem> displayEvents;
    if (_filter == 'upcoming') {
      displayEvents = upcomingEvents;
    } else if (_filter == 'past') {
      displayEvents = pastEvents;
    } else {
      displayEvents = [...upcomingEvents, ...pastEvents];
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Filter tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              _FilterTab(
                label: 'Upcoming',
                count: upcomingEvents.length,
                isSelected: _filter == 'upcoming',
                onTap: () => setState(() => _filter = 'upcoming'),
              ),
              _FilterTab(
                label: 'Past Events',
                count: pastEvents.length,
                isSelected: _filter == 'past',
                onTap: () => setState(() => _filter = 'past'),
              ),
              _FilterTab(
                label: 'All',
                count: upcomingEvents.length + pastEvents.length,
                isSelected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Section header
        if (_filter == 'upcoming' || _filter == 'all')
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.event_available,
                  color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  _filter == 'all' ? 'Upcoming' : 'Upcoming Events',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Upcoming events
        if (_filter == 'upcoming' || _filter == 'all')
          ...upcomingEvents.map((event) => _EventCard(event: event)),

        // Past events header
        if (_filter == 'past' || _filter == 'all')
          Padding(
            padding: EdgeInsets.only(
              top: _filter == 'all' ? AppSpacing.lg : 0,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(Icons.history,
                  color: AppColors.mediumGrey, size: 20),
                const SizedBox(width: 8),
                Text(
                  _filter == 'all' ? 'Past' : 'Past Events',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_filter != 'past')
                  TextButton(
                    onPressed: () => setState(() => _filter = 'past'),
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),

        // Past events (show limited if viewing all)
        if (_filter == 'past' || _filter == 'all')
          ...((_filter == 'all' ? pastEvents.take(3) : pastEvents)
              .map((event) => _EventCard(event: event))),

        // Empty state
        if (displayEvents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Icon(Icons.event_busy,
                    size: 64, color: AppColors.lightGrey),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No events found',
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
                  fontSize: 13,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventItem {
  final String name;
  final String date;
  final String location;
  final int attendees;
  final int? capacity;
  final String type;
  final bool isPast;
  final double? rating;
  final int? reviewCount;

  _EventItem({
    required this.name,
    required this.date,
    required this.location,
    required this.attendees,
    this.capacity,
    required this.type,
    this.isPast = false,
    this.rating,
    this.reviewCount,
  });
}

class _EventCard extends StatelessWidget {
  final _EventItem event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: event.isPast ? AppColors.lightGrey.withAlpha(128) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Event icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getEventColor(event.type).withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getEventIcon(event.type),
                  color: _getEventColor(event.type),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.mediumGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.mediumGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Join/View button
              if (!event.isPast)
                ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Joined!',
                      'You\'re going to ${event.name}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Join'),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    // View past event details
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mediumGrey,
                    side: BorderSide(color: AppColors.mediumGrey),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('View'),
                ),
            ],
          ),

          // Bottom row: capacity or rating info
          const SizedBox(height: 10),

          if (event.isPast && event.rating != null) ...[
            // Past event: Show rating and attendee count
            Row(
              children: [
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warmYellow.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.warmYellow.withAlpha(51)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.warmYellow),
                      const SizedBox(width: 4),
                      Text(
                        event.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.warmYellow,
                        ),
                      ),
                      if (event.reviewCount != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${event.reviewCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Attendee count
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendees} attended',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // View photos link
                GestureDetector(
                  onTap: () {
                    Nav.toBusinessPhotos();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_outlined,
                        size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Upcoming event: Show capacity
            EventCapacityIndicator(
              joinedCount: event.attendees,
              totalSlots: event.capacity,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    final colors = {
      'games': AppColors.friendlyPurple,
      'coffee': AppColors.warmYellow,
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

class _PhotosTab extends StatelessWidget {
  const _PhotosTab();

  @override
  Widget build(BuildContext context) {
    // Mock photo data
    final photoGroups = [
      ('Board Game Night - Jan 15', 6),
      ('Coffee & Conversations - Jan 10', 4),
      ('Hiking Meetup - Jan 5', 8),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: photoGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = photoGroups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.$1,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: group.$2,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withAlpha(77),
                        AppColors.friendlyPurple.withAlpha(179),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      color: Colors.white.withAlpha(128),
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final VoidCallback onWriteReview;

  const _ReviewsTab({required this.onWriteReview});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      _ReviewItem(
        userName: 'Sarah M.',
        rating: 5,
        date: '2 days ago',
        eventName: 'Board Game Night',
        comment: 'Amazing atmosphere! Met so many friendly people. Will definitely come back!',
      ),
      _ReviewItem(
        userName: 'Mike T.',
        rating: 5,
        date: '5 days ago',
        eventName: 'Coffee & Conversations',
        comment: 'Great venue and perfect for making new friends.',
      ),
      _ReviewItem(
        userName: 'Emma L.',
        rating: 4,
        date: '1 week ago',
        eventName: 'Hiking Meetup',
        comment: 'Fun experience overall. Would have loved more water breaks.',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Write review button
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warmYellow.withAlpha(26),
                AppColors.warmYellow.withAlpha(26),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.warmYellow.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.rate_review,
                color: AppColors.warmYellow,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Been to an event?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Share your experience with others',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onWriteReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Write Review'),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Rating summary
        const _RatingSummary(),

        const SizedBox(height: AppSpacing.lg),

        // Reviews list
        ...reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              '4.8',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.warmYellow,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < 4 ? Icons.star : Icons.star_half,
                  color: AppColors.warmYellow,
                  size: 18,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '47 reviews',
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            children: [
              _RatingBar(stars: 5, percentage: 0.81),
              _RatingBar(stars: 4, percentage: 0.13),
              _RatingBar(stars: 3, percentage: 0.04),
              _RatingBar(stars: 2, percentage: 0.02),
              _RatingBar(stars: 1, percentage: 0.00),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double percentage;

  const _RatingBar({
    required this.stars,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 10, color: AppColors.warmYellow),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.warmYellow,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String userName;
  final int rating;
  final String date;
  final String eventName;
  final String comment;

  _ReviewItem({
    required this.userName,
    required this.rating,
    required this.date,
    required this.eventName,
    required this.comment,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: AppColors.warmYellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event, size: 12, color: AppColors.primaryBlue),
                const SizedBox(width: 4),
                Text(
                  review.eventName,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String businessName;
  final Function(int rating, String comment) onSubmit;

  const _WriteReviewSheet({
    required this.businessName,
    required this.onSubmit,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  String? _selectedEvent;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Review ${widget.businessName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Event selector
            Text(
              'Which event did you attend?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedEvent,
                hint: const Text('Select an event...'),
                underline: const SizedBox(),
                items: [
                  'Board Game Night - Jan 15',
                  'Coffee & Conversations - Jan 10',
                  'Hiking Meetup - Jan 5',
                ].map((event) {
                  return DropdownMenuItem(
                    value: event,
                    child: Text(event),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedEvent = value);
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Star rating
            Text(
              'How was your experience?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      color: AppColors.warmYellow,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            if (_rating > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getRatingLabel(_rating),
                    style: TextStyle(
                      color: AppColors.warmYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Comment
            Text(
              'Tell us more (optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What did you enjoy? Any suggestions?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_rating > 0 && _selectedEvent != null)
                    ? () => widget.onSubmit(_rating, _commentController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmYellow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  disabledBackgroundColor: AppColors.lightGrey,
                ),
                child: const Text('Submit Review'),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    final labels = {
      1: 'Poor',
      2: 'Fair',
      3: 'Good',
      4: 'Great',
      5: 'Excellent!',
    };
    return labels[rating] ?? '';
  }
}
