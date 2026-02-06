import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Safety check-in reminder
class SafetyCheckIn extends StatelessWidget {
  final String eventName;
  final String meetingLocation;
  final VoidCallback? onShareLocation;
  final VoidCallback? onNotifyFriend;

  const SafetyCheckIn({
    super.key,
    required this.eventName,
    required this.meetingLocation,
    this.onShareLocation,
    this.onNotifyFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warmYellow.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warmYellow.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.warmYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Safety Check-in',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Meeting new people? Let someone know!',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SafetyAction(
                  icon: Icons.location_on,
                  label: 'Share Location',
                  onTap: onShareLocation,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SafetyAction(
                  icon: Icons.person,
                  label: 'Notify Friend',
                  onTap: onNotifyFriend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SafetyAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.warmYellow),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Meeting place suggestions for first hangouts
class SafeMeetingPlaces extends StatelessWidget {
  final Function(String)? onSelect;

  const SafeMeetingPlaces({
    super.key,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final places = [
      {'name': 'Coffee shop', 'icon': Icons.coffee, 'reason': 'Public & casual'},
      {'name': 'Park', 'icon': Icons.park, 'reason': 'Open & visible'},
      {'name': 'Library', 'icon': Icons.menu_book, 'reason': 'Quiet & safe'},
      {'name': 'Mall', 'icon': Icons.store, 'reason': 'Busy & secure'},
      {'name': 'Restaurant', 'icon': Icons.restaurant, 'reason': 'Staff present'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.verified_user,
              color: AppColors.friendlyTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Safe places to meet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Great spots for first-time hangouts',
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: places.map((place) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect?.call(place['name'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal.withAlpha(13),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.friendlyTeal.withAlpha(51)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      place['icon'] as IconData,
                      size: 18,
                      color: AppColors.friendlyTeal,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          place['reason'] as String,
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
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Comfort level indicator
class ComfortLevel extends StatelessWidget {
  final int level; // 1-5
  final Function(int)? onChanged;
  final bool readOnly;

  const ComfortLevel({
    super.key,
    required this.level,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['Anxious', 'Nervous', 'Okay', 'Good', 'Great'];
    final colors = [
      AppColors.error,
      AppColors.friendlyOrange,
      AppColors.warmYellow,
      AppColors.friendlyTeal,
      AppColors.success,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final isSelected = index + 1 == level;
            final isPast = index + 1 <= level;

            return GestureDetector(
              onTap: readOnly
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onChanged?.call(index + 1);
                    },
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPast
                          ? colors[index].withAlpha(isSelected ? 255 : 51)
                          : AppColors.lightGrey,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: colors[index], width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _getEmoji(index + 1),
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? colors[index] : AppColors.mediumGrey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getEmoji(int level) {
    switch (level) {
      case 1:
        return '😰';
      case 2:
        return '😬';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😊';
      default:
        return '😐';
    }
  }
}

/// Quick exit option
class QuickExitCard extends StatelessWidget {
  final VoidCallback? onExit;

  const QuickExitCard({
    super.key,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.exit_to_app,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need an exit?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "We'll send you a fake call in 5 minutes",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onExit?.call();
              Get.snackbar(
                'Exit call scheduled',
                "You'll get a call in 5 minutes",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.darkGrey,
                colorText: Colors.white,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: const Text(
                'Request',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verification badge info
class VerificationInfo extends StatelessWidget {
  final bool isVerified;
  final List<String> verifications;

  const VerificationInfo({
    super.key,
    required this.isVerified,
    this.verifications = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified && verifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.mediumGrey.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This user has not been verified',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Verified User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (verifications.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: verifications.map((v) {
                IconData icon;
                switch (v.toLowerCase()) {
                  case 'photo':
                    icon = Icons.camera_alt;
                    break;
                  case 'phone':
                    icon = Icons.phone;
                    break;
                  case 'email':
                    icon = Icons.email;
                    break;
                  case 'id':
                    icon = Icons.badge;
                    break;
                  default:
                    icon = Icons.check_circle;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        v,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mutual connections display
class MutualConnections extends StatelessWidget {
  final List<Map<String, String?>> mutualFriends;
  final VoidCallback? onTap;

  const MutualConnections({
    super.key,
    required this.mutualFriends,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mutualFriends.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // Stacked avatars
            SizedBox(
              width: 60,
              height: 32,
              child: Stack(
                children: List.generate(
                  mutualFriends.take(3).length,
                  (index) => Positioned(
                    left: index * 18.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(51),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: mutualFriends[index]['image'] != null
                            ? DecorationImage(
                                image: NetworkImage(mutualFriends[index]['image']!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: mutualFriends[index]['image'] == null
                          ? const Icon(
                              Icons.person,
                              size: 16,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mutualFriends.length} mutual friend${mutualFriends.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    mutualFriends.take(2).map((f) => f['name']).join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Report/Block action sheet
class SafetyActionSheet extends StatelessWidget {
  final String userName;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onHide;

  const SafetyActionSheet({
    super.key,
    required this.userName,
    this.onReport,
    this.onBlock,
    this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Safety Options',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SafetyOption(
            icon: Icons.visibility_off,
            iconColor: AppColors.mediumGrey,
            title: 'Hide this person',
            subtitle: "They won't appear in your suggestions",
            onTap: () {
              Get.back();
              onHide?.call();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _SafetyOption(
            icon: Icons.block,
            iconColor: AppColors.friendlyOrange,
            title: 'Block $userName',
            subtitle: "They can't contact or see you",
            onTap: () {
              Get.back();
              onBlock?.call();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _SafetyOption(
            icon: Icons.flag,
            iconColor: AppColors.error,
            title: 'Report $userName',
            subtitle: 'Report inappropriate behavior',
            onTap: () {
              Get.back();
              onReport?.call();
            },
          ),
          SizedBox(height: AppSpacing.lg + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SafetyOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SafetyOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// First meeting tips
class FirstMeetingTips extends StatelessWidget {
  const FirstMeetingTips({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {'icon': Icons.location_on, 'text': 'Meet in a public place'},
      {'icon': Icons.people, 'text': 'Tell a friend where you\'re going'},
      {'icon': Icons.phone, 'text': 'Keep your phone charged'},
      {'icon': Icons.directions_car, 'text': 'Have your own transportation'},
      {'icon': Icons.timer, 'text': 'Start with a short meetup'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'First Meeting Tips',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    tip['icon'] as IconData,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tip['text'] as String,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
