import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/follow_controller.dart';

/// Button widget for following/unfollowing a business
class FollowBusinessButton extends StatelessWidget {
  final int businessId;
  final bool isFollowing;
  final bool showIcon;
  final bool compact;
  final VoidCallback? onToggle;

  const FollowBusinessButton({
    super.key,
    required this.businessId,
    this.isFollowing = false,
    this.showIcon = true,
    this.compact = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowController>();

    return Obx(() {
      final following = controller.isFollowingBusiness(businessId);
      final isLoading = controller.isFollowing.value &&
          controller.loggingBusinessId == businessId;

      if (compact) {
        return _buildCompactButton(following, isLoading, controller);
      }

      return _buildFullButton(following, isLoading, controller);
    });
  }

  Widget _buildFullButton(
    bool following,
    bool isLoading,
    FollowController controller,
  ) {
    if (following) {
      return OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                controller.toggleFollow(businessId);
                onToggle?.call();
              },
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : showIcon
                ? const Icon(Icons.check)
                : const SizedBox.shrink(),
        label: const Text('Following'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () {
              controller.toggleFollow(businessId);
              onToggle?.call();
            },
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : showIcon
              ? const Icon(Icons.add)
              : const SizedBox.shrink(),
      label: const Text('Follow'),
    );
  }

  Widget _buildCompactButton(
    bool following,
    bool isLoading,
    FollowController controller,
  ) {
    return IconButton(
      onPressed: isLoading
          ? null
          : () {
              controller.toggleFollow(businessId);
              onToggle?.call();
            },
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              following ? Icons.favorite : Icons.favorite_border,
              color: following ? Colors.red : Colors.grey,
            ),
    );
  }
}

/// A card showing followed business with their upcoming events
class FollowedBusinessCard extends StatelessWidget {
  final int businessId;
  final String businessName;
  final String? businessImage;
  final int upcomingEventsCount;
  final VoidCallback? onTap;

  const FollowedBusinessCard({
    super.key,
    required this.businessId,
    required this.businessName,
    this.businessImage,
    this.upcomingEventsCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Business image
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    businessImage != null ? NetworkImage(businessImage!) : null,
                backgroundColor: Colors.grey[200],
                child: businessImage == null
                    ? Icon(Icons.business, color: Colors.grey[400])
                    : null,
              ),
              const SizedBox(width: 12),

              // Business info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (upcomingEventsCount > 0)
                      Text(
                        '$upcomingEventsCount upcoming events',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),

              // Follow button
              FollowBusinessButton(
                businessId: businessId,
                isFollowing: true,
                compact: true,
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to show followed businesses section on home screen
class FollowedBusinessesSection extends StatelessWidget {
  const FollowedBusinessesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowController>();

    return Obx(() {
      if (controller.followedBusinesses.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Businesses You Follow',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full list
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.followedBusinesses.length,
              itemBuilder: (context, index) {
                final follow = controller.followedBusinesses[index];
                return _buildBusinessChip(follow);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBusinessChip(dynamic follow) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: follow.businessImage != null
                ? NetworkImage(follow.businessImage!)
                : null,
            backgroundColor: Colors.grey[200],
            child: follow.businessImage == null
                ? Icon(Icons.business, color: Colors.grey[400], size: 32)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            follow.businessName ?? 'Business',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
