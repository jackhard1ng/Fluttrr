import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../config/routes.dart';
import '../../controllers/activity_controller.dart';
import '../../models/activity_model.dart';
import '../../widgets/common_widgets.dart';

/// Swipeable activity discovery screen - Tinder-style for events
class SwipeDiscoverScreen extends StatefulWidget {
  const SwipeDiscoverScreen({super.key});

  @override
  State<SwipeDiscoverScreen> createState() => _SwipeDiscoverScreenState();
}

class _SwipeDiscoverScreenState extends State<SwipeDiscoverScreen>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late AnimationController _scaleController;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  int _currentIndex = 0;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    // Ensure ActivityController is available
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _scaleController.animateTo(0.95);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;

      // Determine swipe direction based on position
      if (_dragOffset.dx > 50) {
        _swipeDirection = SwipeDirection.right;
      } else if (_dragOffset.dx < -50) {
        _swipeDirection = SwipeDirection.left;
      } else if (_dragOffset.dy < -50) {
        _swipeDirection = SwipeDirection.up;
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details, int totalCards) {
    _scaleController.animateTo(1.0);

    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragOffset.dx.abs() > screenWidth * 0.4 || velocity.dx.abs() > 800) {
      // Swipe threshold reached
      final direction = _dragOffset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      _animateSwipe(direction, totalCards);
    } else if (_dragOffset.dy < -100 || velocity.dy < -800) {
      // Swipe up for super like / instant join
      _animateSwipe(SwipeDirection.up, totalCards);
    } else {
      // Spring back
      _resetCard();
    }
  }

  void _animateSwipe(SwipeDirection direction, int totalCards) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Offset endOffset;
    switch (direction) {
      case SwipeDirection.left:
        endOffset = Offset(-screenWidth * 1.5, _dragOffset.dy);
        break;
      case SwipeDirection.right:
        endOffset = Offset(screenWidth * 1.5, _dragOffset.dy);
        break;
      case SwipeDirection.up:
        endOffset = Offset(_dragOffset.dx, -screenHeight);
        break;
    }

    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _swipeController.forward().then((_) {
      // Guard against widget disposal during animation
      if (!mounted) return;
      _handleSwipeComplete(direction, totalCards);
    });
  }

  void _handleSwipeComplete(SwipeDirection direction, int totalCards) {
    final activityController = Get.find<ActivityController>();
    final activities = activityController.allActivities;

    if (_currentIndex < activities.length) {
      final activity = activities[_currentIndex];

      switch (direction) {
        case SwipeDirection.right:
          // Interested - save for later
          Get.snackbar(
            'Saved!',
            '${activity.displayName} added to your list',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            icon: const Icon(Icons.bookmark, color: Colors.white),
            duration: const Duration(seconds: 2),
          );
          break;
        case SwipeDirection.left:
          // Not interested - skip
          break;
        case SwipeDirection.up:
          // Super interested - join immediately
          Get.snackbar(
            'You\'re going!',
            'Joined ${activity.displayName}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.friendlyPurple,
            colorText: Colors.white,
            icon: const Icon(Icons.celebration, color: Colors.white),
            duration: const Duration(seconds: 2),
          );
          break;
      }
    }

    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
      _swipeDirection = null;
      _isDragging = false;
    });
    _swipeController.reset();

    // Check if we've gone through all cards
    if (_currentIndex >= totalCards) {
      _showNoMoreCards();
    }
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
      _swipeDirection = null;
      _isDragging = false;
    });
  }

  void _showNoMoreCards() {
    // Show refresh option
  }

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Obx(() {
        final activities = activityController.allActivities;

        if (activities.isEmpty) {
          return const _EmptyState();
        }

        if (_currentIndex >= activities.length) {
          return _AllCaughtUp(onRefresh: () {
            setState(() => _currentIndex = 0);
          });
        }

        return Stack(
          children: [
            // Instructions
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: const _SwipeInstructions(),
            ),

            // Card stack
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background cards - with bounds checking
                  if (activities.length > 1)
                    for (int i = min(_currentIndex + 2, activities.length - 1);
                         i > _currentIndex && i >= 0 && i < activities.length;
                         i--)
                      _buildBackgroundCard(activities[i], i - _currentIndex),

                  // Active card
                  if (_currentIndex < activities.length)
                    GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: (details) => _onPanEnd(details, activities.length),
                      child: AnimatedBuilder(
                        animation: _swipeController,
                        builder: (context, child) {
                          final offset = _swipeController.isAnimating
                              ? _swipeAnimation.value
                              : _dragOffset;

                          return Transform.translate(
                            offset: offset,
                            child: Transform.rotate(
                              angle: offset.dx * 0.001,
                              child: ScaleTransition(
                                scale: _scaleController,
                                child: _ActivityCard(
                                  activity: activities[_currentIndex],
                                  swipeDirection: _swipeDirection,
                                  dragProgress: _dragOffset.dx.abs() / 200,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _ActionButtons(
                onSkip: () => _animateSwipe(SwipeDirection.left, activities.length),
                onSave: () => _animateSwipe(SwipeDirection.right, activities.length),
                onJoin: () => _animateSwipe(SwipeDirection.up, activities.length),
                onInfo: () {
                  if (_currentIndex < activities.length) {
                    final activity = activities[_currentIndex];
                    if (activity.activityId != null) {
                      Nav.toActivityDetails(activity.activityId!);
                    }
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackgroundCard(ActivityModel activity, int stackIndex) {
    final scale = 1 - (stackIndex * 0.05);
    final yOffset = stackIndex * 10.0;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: 1 - (stackIndex * 0.2),
          child: _ActivityCard(
            activity: activity,
            isBackground: true,
          ),
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#83)
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersSheet(),
    );
  }
}

enum SwipeDirection { left, right, up }

class _SwipeInstructions extends StatelessWidget {
  const _SwipeInstructions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InstructionChip(
          icon: Icons.close,
          label: 'Skip',
          color: AppColors.error,
        ),
        const SizedBox(width: 16),
        _InstructionChip(
          icon: Icons.arrow_upward,
          label: 'Join',
          color: AppColors.friendlyPurple,
        ),
        const SizedBox(width: 16),
        _InstructionChip(
          icon: Icons.bookmark,
          label: 'Save',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _InstructionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InstructionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final SwipeDirection? swipeDirection;
  final double dragProgress;
  final bool isBackground;

  const _ActivityCard({
    required this.activity,
    this.swipeDirection,
    this.dragProgress = 0,
    this.isBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final cardHeight = cardWidth * 1.3;

    final imageUrl = ApiEndpoints.getImageUrl(activity.primaryImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(activity.primaryImage);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            if (hasValidImage)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.friendlyPurple,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getEventIcon(activity.eventType),
                    size: 80,
                    color: Colors.white.withAlpha(77),
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(179),
                    Colors.black.withAlpha(230),
                  ],
                  stops: const [0, 0.4, 0.75, 1],
                ),
              ),
            ),

            // Swipe indicators
            if (!isBackground && swipeDirection != null)
              _SwipeIndicator(
                direction: swipeDirection!,
                progress: dragProgress.clamp(0, 1),
              ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event type badge
                    if (activity.eventType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventColor(activity.eventType),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getEventIcon(activity.eventType),
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              activity.eventType!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      activity.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Location and time
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.location ?? 'Location TBD',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(activity.startTime),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Attendees and capacity
                    Row(
                      children: [
                        // Attendee avatars
                        if (activity.attendees.isNotEmpty)
                          AttendeeAvatars(
                            imageUrls: activity.attendees
                                .take(4)
                                .map((a) => a.profileImage)
                                .toList(),
                            totalCount: activity.attendeeCount,
                            avatarSize: 32,
                            maxVisible: 4,
                          ),

                        const SizedBox(width: 12),

                        // Capacity indicator
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.totalSlots != null && activity.totalSlots! > 0
                                    ? '${activity.attendeeCount} / ${activity.totalSlots} going'
                                    : '${activity.attendeeCount} going',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (activity.totalSlots != null && activity.totalSlots! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: activity.attendeeCount / activity.totalSlots!,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation(
                                        activity.isFull
                                            ? AppColors.error
                                            : AppColors.success,
                                      ),
                                      minHeight: 4,
                                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String? eventType) {
    final icons = {
      'Coffee': Icons.coffee,
      'Hiking': Icons.terrain,
      'Games': Icons.casino,
      'Sports': Icons.sports_basketball,
      'Food': Icons.restaurant,
      'Arts': Icons.palette,
      'Music': Icons.music_note,
      'Movies': Icons.movie,
      'Outdoors': Icons.park,
      'Fitness': Icons.fitness_center,
    };
    return icons[eventType] ?? Icons.event;
  }

  Color _getEventColor(String? eventType) {
    final colors = {
      'Coffee': AppColors.friendlyOrange,
      'Hiking': AppColors.friendlyTeal,
      'Games': AppColors.friendlyPurple,
      'Sports': AppColors.primaryBlue,
      'Food': AppColors.warmYellow,
      'Arts': const Color(0xFFE91E63),
      'Music': const Color(0xFF9C27B0),
      'Movies': const Color(0xFF795548),
      'Outdoors': const Color(0xFF4CAF50),
      'Fitness': const Color(0xFFFF5722),
    };
    return colors[eventType] ?? AppColors.primaryBlue;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Time TBD';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (eventDate == today) {
      dateStr = 'Today';
    } else if (eventDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dateStr = '${weekdays[dateTime.weekday - 1]}, ${dateTime.month}/${dateTime.day}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute $period';
  }
}

class _SwipeIndicator extends StatelessWidget {
  final SwipeDirection direction;
  final double progress;

  const _SwipeIndicator({
    required this.direction,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color color;
    Alignment alignment;

    switch (direction) {
      case SwipeDirection.left:
        icon = Icons.close;
        label = 'SKIP';
        color = AppColors.error;
        alignment = Alignment.topLeft;
        break;
      case SwipeDirection.right:
        icon = Icons.bookmark;
        label = 'SAVE';
        color = AppColors.success;
        alignment = Alignment.topRight;
        break;
      case SwipeDirection.up:
        icon = Icons.celebration;
        label = 'JOIN';
        color = AppColors.friendlyPurple;
        alignment = Alignment.topCenter;
        break;
    }

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Opacity(
            opacity: progress.clamp(0, 1),
            child: Transform.scale(
              scale: 0.8 + (progress * 0.4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(128),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onSave;
  final VoidCallback onJoin;
  final VoidCallback onInfo;

  const _ActionButtons({
    required this.onSkip,
    required this.onSave,
    required this.onJoin,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip button
        _CircleButton(
          icon: Icons.close,
          color: AppColors.error,
          size: 56,
          onTap: onSkip,
        ),
        const SizedBox(width: 16),
        // Info button
        _CircleButton(
          icon: Icons.info_outline,
          color: AppColors.primaryBlue,
          size: 44,
          onTap: onInfo,
        ),
        const SizedBox(width: 16),
        // Join button (larger)
        _CircleButton(
          icon: Icons.celebration,
          color: AppColors.friendlyPurple,
          size: 70,
          onTap: onJoin,
          isGradient: true,
        ),
        const SizedBox(width: 16),
        // Info button placeholder
        _CircleButton(
          icon: Icons.share,
          color: AppColors.friendlyTeal,
          size: 44,
          onTap: () {
            Get.snackbar(
              'Share',
              'Link copied!',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        const SizedBox(width: 16),
        // Save button
        _CircleButton(
          icon: Icons.bookmark,
          color: AppColors.success,
          size: 56,
          onTap: onSave,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool isGradient;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isGradient ? null : Colors.white,
          gradient: isGradient
              ? LinearGradient(
                  colors: [color, color.withAlpha(179)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (isGradient ? color : Colors.black).withAlpha(51),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isGradient ? Colors.white : color,
          size: size * 0.45,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_outlined,
            size: 80,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No activities to discover',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(color: AppColors.mediumGrey),
          ),
        ],
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  final VoidCallback onRefresh;

  const _AllCaughtUp({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve seen all available activities',
            style: TextStyle(color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Start Over'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  final Set<String> _selectedTypes = {};
  double _maxDistance = 25;
  bool _onlyAvailable = true;

  @override
  Widget build(BuildContext context) {
    final eventTypes = [
      'Coffee', 'Hiking', 'Games', 'Sports', 'Food',
      'Arts', 'Music', 'Movies', 'Outdoors', 'Fitness',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Activities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Event types
                Text(
                  'Event Types',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: eventTypes.map((type) {
                    final isSelected = _selectedTypes.contains(type);
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryBlue.withAlpha(26),
                      checkmarkColor: AppColors.primaryBlue,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Max Distance',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Text(
                      '${_maxDistance.round()} km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    setState(() => _maxDistance = value);
                  },
                ),

                const SizedBox(height: 12),

                // Only available toggle
                SwitchListTile(
                  title: const Text('Only show available spots'),
                  value: _onlyAvailable,
                  onChanged: (value) {
                    setState(() => _onlyAvailable = value);
                  },
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 20),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Apply filters
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
