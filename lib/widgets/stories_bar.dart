import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/story_controller.dart';
import '../models/story_model.dart';
import '../constants/utils.dart';
import '../screens/stories/story_viewer_screen.dart';
import '../screens/stories/create_story_screen.dart';

/// Horizontal scrollable stories bar for home screen
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryController>(
      init: StoryController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  // Add story button
                  _AddStoryButton(
                    hasActiveStory: controller.hasActiveStories,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const CreateStoryScreen());
                    },
                  ),

                  // User stories
                  Obx(() {
                    return Row(
                      children: controller.userStories
                          .map((group) => _StoryAvatar(
                                imageUrl: group.userAvatar,
                                name: group.userName,
                                hasUnviewed: group.hasUnviewed,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  controller.openUserStories(group);
                                  Get.to(() => StoryViewerScreen(
                                        stories: group.stories,
                                        initialIndex: 0,
                                      ));
                                },
                              ))
                          .toList(),
                    );
                  }),

                  // Event stories
                  Obx(() {
                    return Row(
                      children: controller.eventStories
                          .map((group) => _EventStoryAvatar(
                                eventName: group.eventName,
                                eventImage: group.eventImage,
                                contributorCount: group.contributorCount,
                                hasUnviewed: group.hasUnviewed,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  controller.openEventStories(group);
                                  Get.to(() => StoryViewerScreen(
                                        stories: group.stories,
                                        initialIndex: 0,
                                      ));
                                },
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final bool hasActiveStory;
  final VoidCallback onTap;

  const _AddStoryButton({
    required this.hasActiveStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGrey,
                    border: hasActiveStory
                        ? Border.all(
                            color: AppColors.primaryBlue,
                            width: 3,
                          )
                        : null,
                  ),
                  child: hasActiveStory
                      ? ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.mediumGrey,
                          ),
                        )
                      : Icon(
                          Icons.add,
                          size: 28,
                          color: AppColors.primaryBlue,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool hasUnviewed;
  final VoidCallback onTap;

  const _StoryAvatar({
    this.imageUrl,
    required this.name,
    required this.hasUnviewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.friendlyPurple,
                        ],
                      )
                    : null,
                color: hasUnviewed ? null : AppColors.lightGrey,
              ),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name.split(' ').first,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryBlue.withAlpha(51),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _EventStoryAvatar extends StatelessWidget {
  final String eventName;
  final String? eventImage;
  final int contributorCount;
  final bool hasUnviewed;
  final VoidCallback onTap;

  const _EventStoryAvatar({
    required this.eventName,
    this.eventImage,
    required this.contributorCount,
    required this.hasUnviewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? LinearGradient(
                        colors: [
                          AppColors.friendlyOrange,
                          AppColors.warmYellow,
                        ],
                      )
                    : null,
                color: hasUnviewed ? null : AppColors.lightGrey,
              ),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      eventImage != null
                          ? Image.network(
                              eventImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                      if (contributorCount > 1)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            color: Colors.black.withAlpha(128),
                            child: Text(
                              '+$contributorCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              eventName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.friendlyOrange.withAlpha(51),
      child: const Center(
        child: Icon(
          Icons.event,
          color: AppColors.friendlyOrange,
          size: 24,
        ),
      ),
    );
  }
}
