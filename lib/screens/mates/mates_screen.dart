import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../config/routes.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../widgets/common_widgets.dart';

/// Mates/friend discovery screen with list view - HelloTalk style
class MatesScreen extends StatelessWidget {
  const MatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                        ).createShader(bounds),
                        child: const Text(
                          'People Nearby',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '${matesController.nearbyMates.length} people near you',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: AppColors.darkGrey),
                          onPressed: () => _showFilters(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // My Connections button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.friendlyTeal.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.people, color: AppColors.friendlyTeal),
                          onPressed: Nav.toMatches,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Nav.toSearch();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withAlpha(128),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.mediumGrey),
                      const SizedBox(width: 12),
                      Text(
                        'Search by name or interests...',
                        style: TextStyle(color: AppColors.mediumGrey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Quick filters row
            Obx(() => SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _QuickFilterChip(
                    label: 'Online Now',
                    icon: Icons.circle,
                    iconColor: AppColors.success,
                    isSelected: matesController.quickFilter.value == 'online',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      matesController.toggleQuickFilter('online');
                    },
                  ),
                  _QuickFilterChip(
                    label: 'New Members',
                    icon: Icons.fiber_new,
                    isSelected: matesController.quickFilter.value == 'new',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      matesController.toggleQuickFilter('new');
                    },
                  ),
                  _QuickFilterChip(
                    label: 'Same Interests',
                    icon: Icons.favorite_border,
                    isSelected: matesController.quickFilter.value == 'interests',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      matesController.toggleQuickFilter('interests');
                    },
                  ),
                  _QuickFilterChip(
                    label: 'Nearby',
                    icon: Icons.near_me,
                    isSelected: matesController.quickFilter.value == 'nearby',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      matesController.toggleQuickFilter('nearby');
                    },
                  ),
                ],
              ),
            )),

            const SizedBox(height: AppSpacing.md),

            // People list
            Expanded(
              child: Obx(() {
                if (matesController.isLoading.value &&
                    matesController.nearbyMates.isEmpty) {
                  return const LoadingIndicator();
                }

                // Show error state with retry option
                if (matesController.errorMessage.value.isNotEmpty &&
                    matesController.nearbyMates.isEmpty) {
                  return _ErrorState(
                    message: matesController.errorMessage.value,
                    onRetry: matesController.loadNearbyMates,
                  );
                }

                if (matesController.nearbyMates.isEmpty) {
                  return _EmptyState(
                    onRefresh: matesController.loadNearbyMates,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => matesController.loadNearbyMates(refresh: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      // Load more when reaching 200px from the bottom
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        matesController.loadMoreMates();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      // Add 1 for loading indicator at the bottom
                      itemCount: matesController.nearbyMates.length +
                          (matesController.hasMorePages.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index >= matesController.nearbyMates.length) {
                          return Obx(() => matesController.isLoadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(AppSpacing.lg),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink());
                        }

                        final mate = matesController.nearbyMates[index];
                        return _PersonCard(
                          mate: mate,
                          isLiked: mate.isLiked,
                          onConnect: () async {
                            HapticFeedback.mediumImpact();
                            if (mate.userId != null) {
                              final success = await matesController.likeMate(mate.userId!);
                              if (success) {
                                Get.snackbar(
                                  'Connection Sent!',
                                  'We\'ll let you know if ${mate.displayName} connects back',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.success,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              } else {
                                Get.snackbar(
                                  'Oops!',
                                  'Could not send connection. Please try again.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.error,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          },
                          onViewProfile: () {
                            if (mate.userId != null) {
                              Nav.toMateProfile(mate.userId!);
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#64)
    if (!context.mounted) return;

    final matesController = Get.find<MatesController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _FilterSheet(controller: matesController),
    );
  }
}

/// Person card for list view - HelloTalk style
class _PersonCard extends StatelessWidget {
  final MateModel mate;
  final bool isLiked;
  final Future<void> Function() onConnect;
  final VoidCallback onViewProfile;

  const _PersonCard({
    required this.mate,
    required this.onConnect,
    required this.onViewProfile,
    this.isLiked = false,
  });

  void _showPersonOptions(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#87)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: AppColors.primaryBlue.withAlpha(26),
                    ),
                    child: Center(
                      child: Text(
                        // Safely access first character with fallback
                        mate.displayName.isNotEmpty
                            ? mate.displayName[0]
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                          mate.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (mate.distanceText.isNotEmpty)
                          Text(
                            mate.distanceText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primaryBlue),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                onViewProfile();
              },
            ),
            if (!isLiked)
              ListTile(
                leading: Icon(Icons.person_add, color: AppColors.success),
                title: const Text('Send Connection Request'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  onConnect();
                },
              ),
            ListTile(
              leading: Icon(Icons.message, color: AppColors.friendlyTeal),
              title: const Text('Say Hi'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  '👋 Hi sent!',
                  'You waved at ${mate.displayName}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.friendlyTeal,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.visibility_off, color: AppColors.mediumGrey),
              title: const Text('Hide This Person'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Person Hidden',
                  'You won\'t see ${mate.displayName} anymore',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.flag, color: AppColors.error),
              title: Text('Report', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                _showReportDialog(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting ${mate.displayName}?'),
            const SizedBox(height: 16),
            _ReportOption(
              label: 'Inappropriate profile',
              onTap: () {
                Navigator.pop(context);
                _confirmReport(context, 'Inappropriate profile');
              },
            ),
            _ReportOption(
              label: 'Spam or fake account',
              onTap: () {
                Navigator.pop(context);
                _confirmReport(context, 'Spam or fake account');
              },
            ),
            _ReportOption(
              label: 'Harassment',
              onTap: () {
                Navigator.pop(context);
                _confirmReport(context, 'Harassment');
              },
            ),
            _ReportOption(
              label: 'Other',
              onTap: () {
                Navigator.pop(context);
                _confirmReport(context, 'Other');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmReport(BuildContext context, String reason) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Report Submitted',
      'Thank you for keeping our community safe',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryBlue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return GestureDetector(
      onTap: onViewProfile,
      onLongPress: () => _showPersonOptions(context),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture with online indicator
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    image: hasValidImage
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: hasValidImage ? null : AppColors.primaryBlue.withAlpha(26),
                  ),
                  child: hasValidImage
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 35,
                          color: AppColors.primaryBlue,
                        ),
                ),
                if (mate.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mate.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (mate.age != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${mate.age}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (mate.location != null || mate.distanceText.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.mediumGrey,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            mate.location ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mediumGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mate.distanceText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(26),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              mate.distanceText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (mate.bio != null && mate.bio!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      mate.bio!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (mate.interests.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: mate.interests.take(3).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.friendlyTeal.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.friendlyTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Connect button
            Column(
              children: [
                GestureDetector(
                  onTap: isLiked ? null : onConnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isLiked
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                            ),
                      color: isLiked ? AppColors.success.withAlpha(26) : null,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isLiked
                          ? Border.all(color: AppColors.success)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.check : Icons.person_add,
                          size: 16,
                          color: isLiked ? AppColors.success : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLiked ? 'Sent' : 'Connect',
                          style: TextStyle(
                            color: isLiked ? AppColors.success : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick filter chip
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: isSelected
              ? null
              : Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (iconColor ?? AppColors.mediumGrey),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry option
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something Went Wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message.isNotEmpty ? message : 'Please check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: 'Try Again',
              width: 140,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 50,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No People Nearby Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filters or check back later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              text: 'Refresh',
              width: 140,
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterSheet extends StatelessWidget {
  final MatesController controller;

  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your People',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Adjust filters to find people who share your interests',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGrey,
                ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Age range
          Text(
            'Age Range',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => RangeSlider(
                values: RangeValues(
                  controller.minAge.value.toDouble(),
                  controller.maxAge.value.toDouble(),
                ),
                min: 18,
                max: 80,
                divisions: 62,
                labels: RangeLabels(
                  controller.minAge.value.toString(),
                  controller.maxAge.value.toString(),
                ),
                onChanged: (values) {
                  controller.minAge.value = values.start.round();
                  controller.maxAge.value = values.end.round();
                },
              )),

          const SizedBox(height: AppSpacing.md),

          // Gender
          Text(
            'Gender',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => Wrap(
                spacing: AppSpacing.sm,
                children: ['All', 'Male', 'Female', 'Other'].map((gender) {
                  final isSelected =
                      controller.selectedGender.value == (gender == 'All' ? '' : gender);
                  return ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.selectedGender.value = gender == 'All' ? '' : gender,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGrey,
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: AppSpacing.md),

          // Distance
          Text(
            'Maximum Distance',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => Slider(
                value: controller.maxDistance.value,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${controller.maxDistance.value.round()} km',
                onChanged: (value) => controller.maxDistance.value = value,
              )),

          const SizedBox(height: AppSpacing.lg),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GradientButton(
                  text: 'Apply',
                  onPressed: () {
                    controller.filterMates();
                    Get.back();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Report option for dialogs
class _ReportOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReportOption({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
