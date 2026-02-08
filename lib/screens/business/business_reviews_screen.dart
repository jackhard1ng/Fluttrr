import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';

/// Screen for businesses to view and manage their reviews
class BusinessReviewsScreen extends StatefulWidget {
  const BusinessReviewsScreen({super.key});

  @override
  State<BusinessReviewsScreen> createState() => _BusinessReviewsScreenState();
}

class _BusinessReviewsScreenState extends State<BusinessReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

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
        title: const Text('Reviews'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.mediumGrey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'All Reviews'),
            Tab(text: 'Awaiting Reply'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats summary
          const _ReviewStatsSummary(),

          // Filter chips
          _FilterChips(
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),

          // Reviews list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReviewsList(filter: _selectedFilter),
                _ReviewsList(filter: _selectedFilter, awaitingReplyOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStatsSummary extends StatelessWidget {
  const _ReviewStatsSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
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
          color: AppColors.warmYellow.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          // Overall rating
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
                    size: 16,
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
          // Rating breakdown
          Expanded(
            child: Column(
              children: [
                _RatingBar(stars: 5, count: 38, total: 47),
                _RatingBar(stars: 4, count: 6, total: 47),
                _RatingBar(stars: 3, count: 2, total: 47),
                _RatingBar(stars: 2, count: 1, total: 47),
                _RatingBar(stars: 1, count: 0, total: 47),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

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
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'All'),
      ('5', '5 Stars'),
      ('4', '4 Stars'),
      ('3', '3 Stars'),
      ('low', '1-2 Stars'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selected == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.$2),
              selected: isSelected,
              onSelected: (_) => onSelected(filter.$1),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryBlue.withAlpha(26),
              checkmarkColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final String filter;
  final bool awaitingReplyOnly;

  const _ReviewsList({
    required this.filter,
    this.awaitingReplyOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // Mock reviews data
    final reviews = [
      _ReviewData(
        userName: 'Sarah M.',
        userImage: null,
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 2)),
        eventName: 'Board Game Night',
        comment: 'Amazing atmosphere! Met so many friendly people. The organizers were super welcoming and made sure everyone was included. Will definitely come back!',
        hasReply: true,
        reply: 'Thank you so much Sarah! We loved having you. See you at the next event!',
      ),
      _ReviewData(
        userName: 'Mike T.',
        userImage: null,
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 5)),
        eventName: 'Coffee & Conversations',
        comment: 'Great venue and perfect for making new friends. The host was really good at introducing people to each other.',
        hasReply: false,
      ),
      _ReviewData(
        userName: 'Emma L.',
        userImage: null,
        rating: 4,
        date: DateTime.now().subtract(const Duration(days: 8)),
        eventName: 'Hiking Meetup',
        comment: 'Fun experience overall. Would have loved if there were more water breaks, but the trail was beautiful and the group was friendly.',
        hasReply: true,
        reply: 'Thanks for the feedback Emma! We\'ll make sure to schedule more breaks in our next hike. Happy you enjoyed it!',
      ),
      _ReviewData(
        userName: 'James K.',
        userImage: null,
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 12)),
        eventName: 'Photography Walk',
        comment: 'Perfect event for photography enthusiasts. Got some amazing shots and made friends who share my passion!',
        hasReply: false,
      ),
      _ReviewData(
        userName: 'Lisa R.',
        userImage: null,
        rating: 3,
        date: DateTime.now().subtract(const Duration(days: 15)),
        eventName: 'Cooking Class',
        comment: 'Good event but it was a bit crowded. Could use a smaller group size for a more intimate experience.',
        hasReply: false,
      ),
    ];

    // Filter reviews
    var filteredReviews = reviews.where((r) {
      if (awaitingReplyOnly && r.hasReply) return false;
      if (filter == 'all') return true;
      if (filter == '5') return r.rating == 5;
      if (filter == '4') return r.rating == 4;
      if (filter == '3') return r.rating == 3;
      if (filter == 'low') return r.rating <= 2;
      return true;
    }).toList();

    if (filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              awaitingReplyOnly ? Icons.check_circle_outline : Icons.rate_review_outlined,
              size: 64,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              awaitingReplyOnly
                  ? 'All caught up!'
                  : 'No reviews match this filter',
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 16,
              ),
            ),
            if (awaitingReplyOnly) ...[
              const SizedBox(height: 8),
              Text(
                'You\'ve replied to all reviews',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filteredReviews.length,
      itemBuilder: (context, index) {
        return _ReviewCard(review: filteredReviews[index]);
      },
    );
  }
}

class _ReviewData {
  final String userName;
  final String? userImage;
  final int rating;
  final DateTime date;
  final String eventName;
  final String comment;
  final bool hasReply;
  final String? reply;

  _ReviewData({
    required this.userName,
    this.userImage,
    required this.rating,
    required this.date,
    required this.eventName,
    required this.comment,
    required this.hasReply,
    this.reply,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;

  const _ReviewCard({required this.review});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

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
          // Header with user info and rating
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGrey,
                  image: review.userImage != null
                      ? DecorationImage(
                          image: NetworkImage(
                            ApiEndpoints.getImageUrl(review.userImage),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: review.userImage == null
                    ? Center(
                        child: Text(
                          review.userName[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(review.rating).withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _getRatingColor(review.rating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(review.rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Event name badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  review.eventName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Review comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Reply section
          if (review.hasReply && review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border(
                  left: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Your reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.reply!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              if (!review.hasReply)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReplyDialog(context),
                    icon: const Icon(Icons.reply, size: 18),
                    label: const Text('Reply'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReplyDialog(context, editMode: true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Reply'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mediumGrey,
                      side: const BorderSide(color: AppColors.lightGrey),
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
                  // Report inappropriate review
                  Get.snackbar(
                    'Report Submitted',
                    'We\'ll review this feedback',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icon(
                  Icons.flag_outlined,
                  color: AppColors.mediumGrey,
                ),
                tooltip: 'Report',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warmYellow;
    return AppColors.error;
  }

  void _showReplyDialog(BuildContext context, {bool editMode = false}) {
    // Check if context is still mounted before showing bottom sheet (#104)
    if (!context.mounted) return;

    final controller = TextEditingController(
      text: editMode ? review.reply : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
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
                editMode ? 'Edit Your Reply' : 'Reply to ${review.userName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Original review preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '"${review.comment}"',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 16),

              // Reply input
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a thoughtful reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      editMode ? 'Reply Updated' : 'Reply Posted',
                      editMode
                          ? 'Your reply has been updated'
                          : 'Thank you for responding to ${review.userName}!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(editMode ? 'Update Reply' : 'Post Reply'),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}
