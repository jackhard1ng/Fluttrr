import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';
import '../../config/routes.dart';
import '../../controllers/mates_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';

/// Beautiful mate profile view screen with photo gallery
class MateProfileScreen extends StatefulWidget {
  final int userId;

  const MateProfileScreen({super.key, required this.userId});

  @override
  State<MateProfileScreen> createState() => _MateProfileScreenState();
}

class _MateProfileScreenState extends State<MateProfileScreen> {
  final PageController _photoController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
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

        // Get all photos (profile image + gallery images)
        final photos = <String>[];
        if (user.profileImage != null && ApiEndpoints.isValidImageUrl(user.profileImage)) {
          photos.add(ApiEndpoints.getImageUrl(user.profileImage));
        }
        if (user.profile?.images != null) {
          for (final img in user.profile!.images!) {
            if (ApiEndpoints.isValidImageUrl(img)) {
              final url = ApiEndpoints.getImageUrl(img);
              if (!photos.contains(url)) photos.add(url);
            }
          }
        }

        return CustomScrollView(
          slivers: [
            // Photo gallery header
            SliverAppBar(
              expandedHeight: 420,
              pinned: true,
              backgroundColor: AppColors.primaryDark,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOptionsMenu(context),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo gallery
                    if (photos.isNotEmpty)
                      PageView.builder(
                        controller: _photoController,
                        itemCount: photos.length,
                        onPageChanged: (index) {
                          setState(() => _currentPhotoIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenPhoto(context, photos, index),
                            child: Image.network(
                              photos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.displayName),
                            ),
                          );
                        },
                      )
                    else
                      _buildDefaultAvatar(user.displayName),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(204),
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),

                    // Photo indicators
                    if (photos.length > 1)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 60,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(photos.length, (index) {
                            return Container(
                              width: _currentPhotoIndex == index ? 24 : 8,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _currentPhotoIndex == index
                                    ? Colors.white
                                    : Colors.white.withAlpha(128),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),

                    // Name and basic info overlay
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.profile?.age != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${user.profile!.age}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (user.isOnline)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 6, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Active now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (user.profile?.location != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.profile!.location!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.waving_hand,
                            label: 'Wave',
                            color: AppColors.friendlyTeal,
                            onTap: () async {
                              await matesController.likeMate(widget.userId);
                              Get.snackbar(
                                'Waved!',
                                'You waved at ${user.displayName}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.friendlyTeal,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Message',
                            color: AppColors.primaryBlue,
                            onTap: () {
                              final conversation = ChatConversation(
                                otherUserId: user.userId,
                                otherUserName: user.userName,
                                otherUserImages: user.profile?.images ?? [],
                              );
                              Nav.toChat(conversation);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _QuickActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          color: AppColors.friendlyPurple,
                          isCompact: true,
                          onTap: () {
                            // Share profile
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // About section
                    if (user.profile?.bio != null && user.profile!.bio!.isNotEmpty) ...[
                      _SectionHeader(title: 'About me', icon: Icons.person_outline),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          user.profile!.bio!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Interests section
                    if (user.profile?.interests != null &&
                        user.profile!.interests!.isNotEmpty) ...[
                      _SectionHeader(title: 'Interests', icon: Icons.favorite_border),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: user.profile!.interests!.map((interest) {
                          return _InterestChip(label: interest);
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Details section
                    _SectionHeader(title: 'Details', icon: Icons.info_outline),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          if (user.profile?.gender != null)
                            _DetailRow(
                              icon: Icons.person_outline,
                              label: 'Gender',
                              value: user.profile!.gender!,
                            ),
                          if (user.profile?.location != null)
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: user.profile!.location!,
                            ),
                          if (user.profile?.languages != null &&
                              user.profile!.languages!.isNotEmpty)
                            _DetailRow(
                              icon: Icons.language,
                              label: 'Languages',
                              value: user.profile!.languages!.join(', '),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Activity stats
                    _SectionHeader(title: 'Activity', icon: Icons.trending_up),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.event,
                            value: '${user.activities?.created ?? 0}',
                            label: 'Events Created',
                            color: AppColors.friendlyPurple,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.group,
                            value: '${user.activities?.joined ?? 0}',
                            label: 'Events Joined',
                            color: AppColors.friendlyTeal,
                          ),
                        ),
                      ],
                    ),

                    // Photo gallery thumbnails
                    if (photos.length > 1) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(title: 'Photos', icon: Icons.photo_library_outlined),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _photoController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                // Scroll to top
                              },
                              child: Container(
                                width: 100,
                                margin: EdgeInsets.only(
                                  right: index < photos.length - 1 ? AppSpacing.sm : 0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: _currentPhotoIndex == index
                                        ? AppColors.primaryBlue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(photos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Platonic friendship note
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.friendlyTeal.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.friendlyTeal.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            color: AppColors.friendlyTeal,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Looking for friends',
                                  style: TextStyle(
                                    color: AppColors.friendlyTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Wave to connect and start a friendship!',
                                  style: TextStyle(
                                    color: AppColors.friendlyTeal.withAlpha(179),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: AppColors.primaryDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No photo yet',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, List<String> photos, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Image.network(
                    photos[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block user'),
              onTap: () {
                Navigator.pop(context);
                // Block user
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report user'),
              onTap: () {
                Navigator.pop(context);
                // Report user
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isCompact;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: isCompact ? AppSpacing.md : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: isCompact
            ? Icon(icon, color: color, size: 24)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Interest chip with gradient
class _InterestChip extends StatelessWidget {
  final String label;

  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withAlpha(26),
            AppColors.friendlyTeal.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: AppColors.primaryBlue.withAlpha(51),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Detail row
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mediumGrey),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withAlpha(179),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
