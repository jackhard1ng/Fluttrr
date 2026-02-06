import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Achievement badge system for gamification
class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requirement;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requirement,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => (currentProgress / requirement).clamp(0, 1);
}

/// Predefined achievements
class Achievements {
  static List<AchievementBadge> getAll({
    int eventsAttended = 0,
    int friendsMade = 0,
    int eventsHosted = 0,
    int reviewsLeft = 0,
    int consecutiveDays = 0,
    int differentEventTypes = 0,
  }) {
    return [
      // Attendance achievements
      AchievementBadge(
        id: 'first_event',
        name: 'First Flutter',
        description: 'Attend your first event',
        icon: Icons.celebration,
        color: AppColors.friendlyPurple,
        requirement: 1,
        currentProgress: eventsAttended,
        isUnlocked: eventsAttended >= 1,
      ),
      AchievementBadge(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Attend 10 events',
        icon: Icons.flutter_dash,
        color: AppColors.primaryBlue,
        requirement: 10,
        currentProgress: eventsAttended,
        isUnlocked: eventsAttended >= 10,
      ),
      AchievementBadge(
        id: 'event_enthusiast',
        name: 'Event Enthusiast',
        description: 'Attend 25 events',
        icon: Icons.emoji_events,
        color: AppColors.friendlyOrange,
        requirement: 25,
        currentProgress: eventsAttended,
        isUnlocked: eventsAttended >= 25,
      ),
      AchievementBadge(
        id: 'legendary_attendee',
        name: 'Legendary Attendee',
        description: 'Attend 100 events',
        icon: Icons.workspace_premium,
        color: const Color(0xFFFFD700),
        requirement: 100,
        currentProgress: eventsAttended,
        isUnlocked: eventsAttended >= 100,
      ),

      // Friend achievements
      AchievementBadge(
        id: 'first_friend',
        name: 'First Connection',
        description: 'Make your first friend',
        icon: Icons.person_add,
        color: AppColors.friendlyTeal,
        requirement: 1,
        currentProgress: friendsMade,
        isUnlocked: friendsMade >= 1,
      ),
      AchievementBadge(
        id: 'friend_collector',
        name: 'Friend Collector',
        description: 'Make 10 friends',
        icon: Icons.people,
        color: AppColors.success,
        requirement: 10,
        currentProgress: friendsMade,
        isUnlocked: friendsMade >= 10,
      ),
      AchievementBadge(
        id: 'community_pillar',
        name: 'Community Pillar',
        description: 'Make 50 friends',
        icon: Icons.groups,
        color: const Color(0xFF9C27B0),
        requirement: 50,
        currentProgress: friendsMade,
        isUnlocked: friendsMade >= 50,
      ),

      // Host achievements
      AchievementBadge(
        id: 'first_host',
        name: 'Event Creator',
        description: 'Host your first event',
        icon: Icons.add_circle,
        color: AppColors.warmYellow,
        requirement: 1,
        currentProgress: eventsHosted,
        isUnlocked: eventsHosted >= 1,
      ),
      AchievementBadge(
        id: 'super_host',
        name: 'Super Host',
        description: 'Host 10 events',
        icon: Icons.star,
        color: AppColors.friendlyOrange,
        requirement: 10,
        currentProgress: eventsHosted,
        isUnlocked: eventsHosted >= 10,
      ),

      // Streak achievements
      AchievementBadge(
        id: 'weekly_warrior',
        name: 'Weekly Warrior',
        description: 'Active for 7 consecutive days',
        icon: Icons.local_fire_department,
        color: AppColors.error,
        requirement: 7,
        currentProgress: consecutiveDays,
        isUnlocked: consecutiveDays >= 7,
      ),
      AchievementBadge(
        id: 'monthly_master',
        name: 'Monthly Master',
        description: 'Active for 30 consecutive days',
        icon: Icons.whatshot,
        color: const Color(0xFFFF5722),
        requirement: 30,
        currentProgress: consecutiveDays,
        isUnlocked: consecutiveDays >= 30,
      ),

      // Explorer achievements
      AchievementBadge(
        id: 'explorer',
        name: 'Explorer',
        description: 'Try 5 different event types',
        icon: Icons.explore,
        color: AppColors.primaryBlue,
        requirement: 5,
        currentProgress: differentEventTypes,
        isUnlocked: differentEventTypes >= 5,
      ),
      AchievementBadge(
        id: 'adventurer',
        name: 'Adventurer',
        description: 'Try all event types',
        icon: Icons.travel_explore,
        color: AppColors.friendlyTeal,
        requirement: 10,
        currentProgress: differentEventTypes,
        isUnlocked: differentEventTypes >= 10,
      ),

      // Review achievements
      AchievementBadge(
        id: 'reviewer',
        name: 'Helpful Reviewer',
        description: 'Leave 5 reviews',
        icon: Icons.rate_review,
        color: AppColors.friendlyPurple,
        requirement: 5,
        currentProgress: reviewsLeft,
        isUnlocked: reviewsLeft >= 5,
      ),
    ];
  }
}

/// Achievement badge display widget
class AchievementBadgeWidget extends StatelessWidget {
  final AchievementBadge badge;
  final double size;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    super.key,
    required this.badge,
    this.size = 60,
    this.showProgress = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showBadgeDetails(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: badge.isUnlocked
                  ? LinearGradient(
                      colors: [
                        badge.color,
                        badge.color.withAlpha(179),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: badge.isUnlocked ? null : AppColors.lightGrey,
              boxShadow: badge.isUnlocked
                  ? [
                      BoxShadow(
                        color: badge.color.withAlpha(77),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  badge.icon,
                  size: size * 0.5,
                  color: badge.isUnlocked ? Colors.white : AppColors.mediumGrey,
                ),
                if (!badge.isUnlocked)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(77),
                    ),
                    child: Icon(
                      Icons.lock,
                      size: size * 0.3,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Badge name
          SizedBox(
            width: size + 20,
            child: Text(
              badge.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badge.isUnlocked ? AppColors.darkGrey : AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Progress indicator
          if (showProgress && !badge.isUnlocked) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: badge.progress,
                  backgroundColor: AppColors.lightGrey,
                  valueColor: AlwaysStoppedAnimation(badge.color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${badge.currentProgress}/${badge.requirement}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => _BadgeDetailsDialog(badge: badge),
    );
  }
}

class _BadgeDetailsDialog extends StatelessWidget {
  final AchievementBadge badge;

  const _BadgeDetailsDialog({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon (large)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: badge.isUnlocked
                    ? LinearGradient(
                        colors: [badge.color, badge.color.withAlpha(179)],
                      )
                    : null,
                color: badge.isUnlocked ? null : AppColors.lightGrey,
                boxShadow: badge.isUnlocked
                    ? [
                        BoxShadow(
                          color: badge.color.withAlpha(77),
                          blurRadius: 20,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                badge.icon,
                size: 50,
                color: badge.isUnlocked ? Colors.white : AppColors.mediumGrey,
              ),
            ),

            const SizedBox(height: 20),

            // Badge name
            Text(
              badge.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              badge.description,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Progress or unlock date
            if (badge.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Unlocked!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: AlwaysStoppedAnimation(badge.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${badge.currentProgress} / ${badge.requirement}',
                    style: TextStyle(
                      color: badge.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Achievement showcase section
class AchievementsShowcase extends StatelessWidget {
  final int eventsAttended;
  final int friendsMade;
  final int eventsHosted;

  const AchievementsShowcase({
    super.key,
    this.eventsAttended = 0,
    this.friendsMade = 0,
    this.eventsHosted = 0,
  });

  @override
  Widget build(BuildContext context) {
    final badges = Achievements.getAll(
      eventsAttended: eventsAttended,
      friendsMade: friendsMade,
      eventsHosted: eventsHosted,
    );

    final unlockedBadges = badges.where((b) => b.isUnlocked).toList();
    final lockedBadges = badges.where((b) => !b.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech, color: AppColors.warmYellow),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${unlockedBadges.length}/${badges.length}',
                style: TextStyle(
                  color: AppColors.warmYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Unlocked badges
        if (unlockedBadges.isNotEmpty) ...[
          Text(
            'Earned',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AchievementBadgeWidget(
                    badge: unlockedBadges[index],
                    size: 60,
                  ),
                );
              },
            ),
          ),
        ],

        // Next achievements to unlock
        if (lockedBadges.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Next Goals',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lockedBadges.take(5).length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AchievementBadgeWidget(
                    badge: lockedBadges[index],
                    size: 60,
                    showProgress: true,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Achievement unlock celebration
class AchievementUnlockCelebration extends StatefulWidget {
  final AchievementBadge badge;
  final VoidCallback onDismiss;

  const AchievementUnlockCelebration({
    super.key,
    required this.badge,
    required this.onDismiss,
  });

  @override
  State<AchievementUnlockCelebration> createState() =>
      _AchievementUnlockCelebrationState();
}

class _AchievementUnlockCelebrationState
    extends State<AchievementUnlockCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1).animate(_glowController);

    _scaleController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.badge.color.withAlpha(
                          (128 * _glowAnimation.value).round(),
                        ),
                        blurRadius: 30 * _glowAnimation.value,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ACHIEVEMENT UNLOCKED!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              widget.badge.color,
                              widget.badge.color.withAlpha(179),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.badge.color.withAlpha(128),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.badge.icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.badge.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.badge.description,
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tap to dismiss',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
