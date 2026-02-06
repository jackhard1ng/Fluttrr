import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';
import '../models/mate_model.dart';

/// "I'm Free Now" feature for spontaneous meetups
class FreeNowButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const FreeNowButton({
    super.key,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFreeNowSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.success, AppColors.friendlyTeal],
                )
              : null,
          color: isActive ? null : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.circular),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.success.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.emoji_people : Icons.add,
              size: 20,
              color: isActive ? Colors.white : AppColors.mediumGrey,
            ),
            const SizedBox(width: 8),
            Text(
              isActive ? "I'm Free Now!" : "I'm Free",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreeNowSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FreeNowSheet(),
    );
  }
}

/// Bottom sheet for setting "I'm Free Now" status
class FreeNowSheet extends StatefulWidget {
  const FreeNowSheet({super.key});

  @override
  State<FreeNowSheet> createState() => _FreeNowSheetState();
}

class _FreeNowSheetState extends State<FreeNowSheet> {
  String? _selectedActivity;
  Duration _duration = const Duration(hours: 2);

  final _activities = [
    ('coffee', 'Coffee', Icons.coffee),
    ('walk', 'Walk', Icons.directions_walk),
    ('food', 'Grab Food', Icons.restaurant),
    ('hangout', 'Just Hangout', Icons.weekend),
    ('games', 'Play Games', Icons.sports_esports),
    ('anything', 'Anything!', Icons.all_inclusive),
  ];

  @override
  Widget build(BuildContext context) {
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.success, AppColors.friendlyTeal],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.emoji_people,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "I'm Free Right Now!",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Let nearby friends know you want to hang',
                            style: TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // What do you want to do?
                Text(
                  "What do you feel like doing?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _activities.map((activity) {
                    final isSelected = _selectedActivity == activity.$1;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedActivity = activity.$1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.success.withAlpha(26)
                              : AppColors.lightGrey.withAlpha(128),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                          border: Border.all(
                            color: isSelected ? AppColors.success : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activity.$3,
                              size: 18,
                              color: isSelected ? AppColors.success : AppColors.mediumGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              activity.$2,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.success : AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Duration
                Text(
                  "How long are you free?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _DurationOption(
                      label: '1 hour',
                      duration: const Duration(hours: 1),
                      isSelected: _duration == const Duration(hours: 1),
                      onTap: () => setState(() => _duration = const Duration(hours: 1)),
                    ),
                    const SizedBox(width: 8),
                    _DurationOption(
                      label: '2 hours',
                      duration: const Duration(hours: 2),
                      isSelected: _duration == const Duration(hours: 2),
                      onTap: () => setState(() => _duration = const Duration(hours: 2)),
                    ),
                    const SizedBox(width: 8),
                    _DurationOption(
                      label: '3+ hours',
                      duration: const Duration(hours: 3),
                      isSelected: _duration == const Duration(hours: 3),
                      onTap: () => setState(() => _duration = const Duration(hours: 3)),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Broadcast button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedActivity != null
                        ? () {
                            Navigator.pop(context);
                            _showSuccessAndMatches(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      disabledBackgroundColor: AppColors.lightGrey,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broadcast_on_personal),
                        SizedBox(width: 8),
                        Text(
                          'Broadcast to Friends',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Only your friends will see this',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
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

  void _showSuccessAndMatches(BuildContext context) {
    Get.snackbar(
      "You're Live!",
      'Friends nearby will be notified',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // Show people who are also free
    Future.delayed(const Duration(seconds: 1), () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const FreeNowMatches(),
      );
    });
  }
}

class _DurationOption extends StatelessWidget {
  final String label;
  final Duration duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.label,
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.success : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.success : AppColors.lightGrey,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.darkGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows people who are also free right now
class FreeNowMatches extends StatelessWidget {
  const FreeNowMatches({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final freeNowPeople = [
      _FreeNowPerson(
        name: 'Alex',
        avatar: null,
        activity: 'Coffee',
        activityIcon: Icons.coffee,
        distance: '0.3 mi away',
        expiresIn: '45 min',
      ),
      _FreeNowPerson(
        name: 'Jordan',
        avatar: null,
        activity: 'Grab Food',
        activityIcon: Icons.restaurant,
        distance: '0.8 mi away',
        expiresIn: '1h 20min',
      ),
      _FreeNowPerson(
        name: 'Sam',
        avatar: null,
        activity: 'Anything!',
        activityIcon: Icons.all_inclusive,
        distance: '1.2 mi away',
        expiresIn: '2h',
      ),
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
                Row(
                  children: [
                    Icon(Icons.people, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Friends Free Right Now',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '${freeNowPeople.length} friends are looking to hang out nearby',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                  ),
                ),

                const SizedBox(height: 20),

                // Free now people list
                ...freeNowPeople.map((person) => _FreeNowPersonCard(person: person)),

                const SizedBox(height: 16),

                // Tip
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyTeal.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.friendlyTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap someone to send a quick invite!',
                          style: TextStyle(
                            color: AppColors.friendlyTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _FreeNowPerson {
  final String name;
  final String? avatar;
  final String activity;
  final IconData activityIcon;
  final String distance;
  final String expiresIn;

  _FreeNowPerson({
    required this.name,
    this.avatar,
    required this.activity,
    required this.activityIcon,
    required this.distance,
    required this.expiresIn,
  });
}

class _FreeNowPersonCard extends StatelessWidget {
  final _FreeNowPerson person;

  const _FreeNowPersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _sendQuickInvite(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with activity icon
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withAlpha(26),
                    image: person.avatar != null && ApiEndpoints.isValidImageUrl(person.avatar)
                        ? DecorationImage(
                            image: NetworkImage(ApiEndpoints.getImageUrl(person.avatar)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: person.avatar == null
                      ? Center(
                          child: Text(
                            person.name[0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      person.activityIcon,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Free now',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        person.activityIcon,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Wants to: ${person.activity}',
                        style: TextStyle(
                          fontSize: 13,
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
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        person.distance,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Free for ${person.expiresIn}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Invite button
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waving_hand,
                color: AppColors.success,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickInvite(BuildContext context) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Invite Sent!',
      '${person.name} will be notified',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
    Navigator.pop(context);
  }
}

/// Compact indicator showing how many friends are free
class FreeNowIndicator extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const FreeNowIndicator({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, AppColors.friendlyTeal],
          ),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_people,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              '$count free now',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
