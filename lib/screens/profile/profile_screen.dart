import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (profileController.isLoading.value &&
              profileController.currentUser.value == null) {
            return const LoadingIndicator();
          }

          return RefreshIndicator(
            onRefresh: profileController.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const GradientText(
                        text: 'Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: Nav.toEditProfile,
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: Nav.toSettings,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Profile header
                  _ProfileHeader(controller: profileController),

                  const SizedBox(height: AppSpacing.lg),

                  // Business Dashboard Card (for business accounts)
                  if (profileController.currentUser.value?.isBusinessAccount == true)
                    const _BusinessDashboardCard(),

                  if (profileController.currentUser.value?.isBusinessAccount == true)
                    const SizedBox(height: AppSpacing.lg),

                  // Profile completion
                  _ProfileCompletion(controller: profileController),

                  const SizedBox(height: AppSpacing.lg),

                  // Stats
                  _StatsSection(controller: profileController),

                  const SizedBox(height: AppSpacing.lg),

                  // Bio
                  if (profileController.bio != null &&
                      profileController.bio!.isNotEmpty)
                    _BioSection(bio: profileController.bio!),

                  const SizedBox(height: AppSpacing.lg),

                  // Interests
                  if (profileController.interests.isNotEmpty)
                    _InterestsSection(interests: profileController.interests),

                  const SizedBox(height: AppSpacing.lg),

                  // Gallery
                  if (profileController.galleryImages.isNotEmpty)
                    _GallerySection(images: profileController.galleryImages),

                  const SizedBox(height: AppSpacing.xl),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = Get.find<AuthController>();
              await authController.logout();
              Nav.toLogin();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile header widget
class _ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isBusinessAccount = controller.currentUser.value?.isBusinessAccount == true;

    return Column(
      children: [
        // Avatar with business badge
        Stack(
          children: [
            UserAvatar(
              imageUrl: controller.profileImage,
              size: 100,
              showOnlineIndicator: true,
              isOnline: controller.isOnline,
            ),
            if (isBusinessAccount)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const BusinessBadge(size: 20),
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Name with business badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.userName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (isBusinessAccount) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: const Text(
                  'Business',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // Location
        if (controller.location != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                controller.location!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
      ],
    );
  }
}

/// Profile completion widget
class _ProfileCompletion extends StatelessWidget {
  final ProfileController controller;

  const _ProfileCompletion({required this.controller});

  @override
  Widget build(BuildContext context) {
    final percentage = controller.profileCompletion.value / 100;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryHorizontal,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 30,
            lineWidth: 5,
            percent: percentage,
            center: Text(
              '${controller.profileCompletion.value}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            progressColor: Colors.white,
            backgroundColor: Colors.white30,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Completion',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  percentage < 1
                      ? 'Complete your profile to make more connections!'
                      : 'Your profile is complete!',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats section widget
class _StatsSection extends StatelessWidget {
  final ProfileController controller;

  const _StatsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Activities',
          value: controller.totalActivities.value.toString(),
          icon: Icons.event,
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          label: 'Connections',
          value: controller.totalMatches.value.toString(),
          icon: Icons.people,
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          label: 'Joined',
          value: controller.joinedActivities.value.toString(),
          icon: Icons.check_circle,
        ),
      ],
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bio section widget
class _BioSection extends StatelessWidget {
  final String bio;

  const _BioSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          bio,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Interests section widget
class _InterestsSection extends StatelessWidget {
  final List<String> interests;

  const _InterestsSection({required this.interests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: interests.map((interest) {
            return TagChip(label: interest);
          }).toList(),
        ),
      ],
    );
  }
}

/// Gallery section widget
class _GallerySection extends StatelessWidget {
  final List<String> images;

  const _GallerySection({required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                // View all photos
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.network(
                    images[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Business Dashboard Card - Prominent access to business features
class _BusinessDashboardCard extends StatelessWidget {
  const _BusinessDashboardCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Nav.toBusinessDashboardPush,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage events, reviews & photos',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
