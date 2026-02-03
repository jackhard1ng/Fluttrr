import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/mates_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chat_screen.dart';

/// Mate profile view screen
class MateProfileScreen extends StatefulWidget {
  final int userId;

  const MateProfileScreen({super.key, required this.userId});

  @override
  State<MateProfileScreen> createState() => _MateProfileScreenState();
}

class _MateProfileScreenState extends State<MateProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final controller = Get.find<MatesController>();
    controller.viewMateProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return Scaffold(
      body: Obx(() {
        if (matesController.isLoadingProfile.value) {
          return const LoadingIndicator();
        }

        final user = matesController.viewedProfile.value;
        if (user == null) {
          return ErrorState(
            message: 'Failed to load profile',
            onRetry: _loadProfile,
          );
        }

        return CustomScrollView(
          slivers: [
            // Image header
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: user.profileImage != null
                    ? Image.network(
                        user.profileImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.person,
                          size: 100,
                          color: AppColors.grey,
                        ),
                      ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and status
                    Row(
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (user.profile?.age != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${user.profile!.age}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                        const Spacer(),
                        if (user.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.circular),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Online',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Location
                    if (user.profile?.location != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.profile!.location!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),

                    // Bio
                    if (user.profile?.bio != null &&
                        user.profile!.bio!.isNotEmpty) ...[
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        user.profile!.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Interests
                    if (user.profile?.interests != null &&
                        user.profile!.interests!.isNotEmpty) ...[
                      Text(
                        'Interests',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: user.profile!.interests!.map((interest) {
                          return TagChip(label: interest);
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Stats
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Created',
                            value:
                                '${user.activities?.created ?? 0}',
                            icon: Icons.add_circle_outline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            label: 'Joined',
                            value: '${user.activities?.joined ?? 0}',
                            icon: Icons.group_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl * 2),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Bottom buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: AppShadows.medium,
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final matesController = Get.find<MatesController>();
                    await matesController.likeMate(widget.userId);
                    Get.snackbar(
                      'Liked!',
                      'You liked this profile',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primaryBlue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Like'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GradientButton(
                  text: 'Message',
                  onPressed: () {
                    final matesController = Get.find<MatesController>();
                    final user = matesController.viewedProfile.value;
                    if (user != null) {
                      final conversation = ChatConversation(
                        otherUserId: user.userId,
                        otherUserName: user.userName,
                        otherUserImages: user.profile?.images ?? [],
                      );
                      Get.to(() => ChatScreen(conversation: conversation));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryBlue,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
