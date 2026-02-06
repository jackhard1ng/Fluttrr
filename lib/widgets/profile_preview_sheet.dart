import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';
import '../config/routes.dart';
import '../models/mate_model.dart';
import 'animated_widgets.dart';
import 'common_widgets.dart';

/// Shows a quick profile preview bottom sheet
class ProfilePreviewSheet {
  static void show(BuildContext context, MateModel mate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfilePreviewContent(mate: mate),
    );
  }
}

class _ProfilePreviewContent extends StatelessWidget {
  final MateModel mate;

  const _ProfilePreviewContent({required this.mate});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Profile header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightGrey,
                        image: hasValidImage
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: !hasValidImage
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: PulsingOnlineIndicator(
                        isOnline: mate.isOnline,
                        size: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppSpacing.md),

                // Name and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mate.displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (mate.age != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${mate.age}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (mate.location != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.mediumGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mate.location!,
                              style: TextStyle(
                                color: AppColors.mediumGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: mate.isOnline
                                  ? AppColors.success.withAlpha(26)
                                  : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(AppRadius.circular),
                            ),
                            child: Text(
                              mate.isOnline ? 'Online now' : 'Offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: mate.isOnline ? AppColors.success : AppColors.mediumGrey,
                              ),
                            ),
                          ),
                          if (mate.distance != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withAlpha(26),
                                borderRadius: BorderRadius.circular(AppRadius.circular),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.near_me,
                                    size: 10,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${mate.distance} km',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bio
          if (mate.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mate.bio!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // Interests
          if (mate.interests != null && mate.interests!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.interests,
                        size: 16,
                        color: AppColors.friendlyPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.friendlyPurple,
                        ),
                      ),
                      const Spacer(),
                      // TODO: Calculate actual match
                      InterestMatchIndicator(
                        matchCount: (mate.interests!.length * 0.6).round(),
                        totalInterests: mate.interests!.length,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mate.interests!.take(6).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.friendlyPurple.withAlpha(26),
                              AppColors.primaryBlue.withAlpha(26),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                          border: Border.all(
                            color: AppColors.friendlyPurple.withAlpha(51),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Message button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Nav.toChatList();
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
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
                const SizedBox(width: AppSpacing.md),
                // Wave button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryHorizontal,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Send wave
                        Get.snackbar(
                          'Wave Sent!',
                          'You waved at ${mate.displayName}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.friendlyTeal,
                          colorText: Colors.white,
                          icon: const Icon(Icons.waving_hand, color: Colors.white),
                        );
                      },
                      icon: const Icon(Icons.waving_hand),
                      label: const Text('Wave'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // View full profile
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mate.userId != null) {
                Nav.toMateProfile(mate.userId!);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Full Profile',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// Quick action bottom sheet for activities
class ActivityActionsSheet {
  static void show(BuildContext context, {
    required String activityName,
    required bool isJoined,
    required VoidCallback onJoin,
    required VoidCallback onShare,
    required VoidCallback onSave,
    required VoidCallback onReport,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                activityName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            _ActionTile(
              icon: isJoined ? Icons.event_busy : Icons.event_available,
              label: isJoined ? 'Leave Activity' : 'Join Activity',
              color: isJoined ? AppColors.error : AppColors.success,
              onTap: () {
                Navigator.pop(context);
                onJoin();
              },
            ),
            _ActionTile(
              icon: Icons.share_outlined,
              label: 'Share Activity',
              color: AppColors.primaryBlue,
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            _ActionTile(
              icon: Icons.bookmark_outline,
              label: 'Save for Later',
              color: AppColors.friendlyOrange,
              onTap: () {
                Navigator.pop(context);
                onSave();
              },
            ),
            _ActionTile(
              icon: Icons.flag_outlined,
              label: 'Report Activity',
              color: AppColors.mediumGrey,
              onTap: () {
                Navigator.pop(context);
                onReport();
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color == AppColors.mediumGrey ? AppColors.darkGrey : color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.mediumGrey,
      ),
      onTap: onTap,
    );
  }
}
