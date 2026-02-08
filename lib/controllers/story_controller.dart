import 'dart:io';

import 'package:get/get.dart';

import '../models/story_model.dart';
import '../repositories/story_repository.dart';
import '../services/analytics_service.dart';

/// Controller for managing stories
class StoryController extends GetxController {
  final StoryRepository _repository = StoryRepository();
  final AnalyticsService _analytics = AnalyticsService();

  // Observable state
  final RxList<UserStoryGroup> userStories = <UserStoryGroup>[].obs;
  final RxList<EventStoryGroup> eventStories = <EventStoryGroup>[].obs;
  final RxList<StoryModel> myStories = <StoryModel>[].obs;
  final RxList<StoryModel> currentStoryGroup = <StoryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  final RxInt currentStoryIndex = 0.obs;
  final Rx<StoryModel?> currentStory = Rx<StoryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadStories();
  }

  /// Load all stories (friends + events)
  Future<void> loadStories({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;

    try {
      final result = await _repository.getStories();

      userStories.value = result['userStories'] as List<UserStoryGroup>;
      eventStories.value = result['eventStories'] as List<EventStoryGroup>;

      // Sort: unviewed first, then by latest story time
      userStories.sort((a, b) {
        if (a.hasUnviewed && !b.hasUnviewed) return -1;
        if (!a.hasUnviewed && b.hasUnviewed) return 1;
        return (b.latestStory?.createdAt ?? DateTime.now())
            .compareTo(a.latestStory?.createdAt ?? DateTime.now());
      });

      eventStories.sort((a, b) {
        if (a.hasUnviewed && !b.hasUnviewed) return -1;
        if (!a.hasUnviewed && b.hasUnviewed) return 1;
        return (b.latestStory?.createdAt ?? DateTime.now())
            .compareTo(a.latestStory?.createdAt ?? DateTime.now());
      });
    } catch (e) {
      print('Error loading stories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load my stories
  Future<void> loadMyStories() async {
    try {
      myStories.value = await _repository.getMyStories();
    } catch (e) {
      print('Error loading my stories: $e');
    }
  }

  /// Create a new story
  Future<StoryModel?> createStory({
    required File media,
    required StoryType type,
    String? eventId,
    String? caption,
  }) async {
    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      // Simulate upload progress
      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        uploadProgress.value = (i + 1) / 10;
      }

      final story = await _repository.createStory(
        media: media,
        type: type,
        eventId: eventId,
        caption: caption,
      );

      if (story != null) {
        myStories.insert(0, story);
        _analytics.trackEvent('story_created', {
          'type': type.name,
          'has_event': eventId != null,
          'has_caption': caption != null && caption.isNotEmpty,
        });

        Get.snackbar(
          'Story Posted!',
          'Your story is now visible to friends',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return story;
    } catch (e) {
      print('Error creating story: $e');
      Get.snackbar(
        'Error',
        'Failed to post story. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// Open user story group
  void openUserStories(UserStoryGroup group) {
    currentStoryGroup.value = group.stories.where((s) => !s.isExpired).toList();
    currentStoryIndex.value = currentStoryGroup.indexWhere((s) => !s.isViewed);
    if (currentStoryIndex.value < 0) currentStoryIndex.value = 0;

    if (currentStoryGroup.isNotEmpty) {
      currentStory.value = currentStoryGroup[currentStoryIndex.value];
      _markCurrentStoryViewed();
    }
  }

  /// Open event story group
  void openEventStories(EventStoryGroup group) {
    currentStoryGroup.value = group.stories.where((s) => !s.isExpired).toList();
    currentStoryIndex.value = currentStoryGroup.indexWhere((s) => !s.isViewed);
    if (currentStoryIndex.value < 0) currentStoryIndex.value = 0;

    if (currentStoryGroup.isNotEmpty) {
      currentStory.value = currentStoryGroup[currentStoryIndex.value];
      _markCurrentStoryViewed();
    }
  }

  /// Go to next story
  bool nextStory() {
    if (currentStoryIndex.value < currentStoryGroup.length - 1) {
      currentStoryIndex.value++;
      currentStory.value = currentStoryGroup[currentStoryIndex.value];
      _markCurrentStoryViewed();
      return true;
    }
    return false;
  }

  /// Go to previous story
  bool previousStory() {
    if (currentStoryIndex.value > 0) {
      currentStoryIndex.value--;
      currentStory.value = currentStoryGroup[currentStoryIndex.value];
      return true;
    }
    return false;
  }

  /// Mark current story as viewed
  Future<void> _markCurrentStoryViewed() async {
    final story = currentStory.value;
    if (story == null || story.isViewed) return;

    await _repository.markStoryViewed(story.storyId);

    // Update local state
    final index = currentStoryGroup.indexWhere((s) => s.storyId == story.storyId);
    if (index >= 0) {
      currentStoryGroup[index] = StoryModel(
        storyId: story.storyId,
        userId: story.userId,
        userName: story.userName,
        userAvatar: story.userAvatar,
        eventId: story.eventId,
        eventName: story.eventName,
        type: story.type,
        mediaUrl: story.mediaUrl,
        thumbnailUrl: story.thumbnailUrl,
        caption: story.caption,
        createdAt: story.createdAt,
        expiresAt: story.expiresAt,
        viewCount: story.viewCount + 1,
        viewerIds: story.viewerIds,
        isViewed: true,
        reactions: story.reactions,
      );
    }

    _analytics.trackEvent('story_viewed', {'story_id': story.storyId});
  }

  /// Add reaction to current story
  Future<void> addReaction(String emoji) async {
    final story = currentStory.value;
    if (story == null) return;

    final success = await _repository.addReaction(
      storyId: story.storyId,
      emoji: emoji,
    );

    if (success) {
      Get.snackbar(
        emoji,
        'Reaction sent!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      _analytics.trackEvent('story_reaction', {
        'story_id': story.storyId,
        'emoji': emoji,
      });
    }
  }

  /// Delete my story
  Future<bool> deleteStory(String storyId) async {
    final success = await _repository.deleteStory(storyId);

    if (success) {
      myStories.removeWhere((s) => s.storyId == storyId);
      Get.snackbar(
        'Deleted',
        'Your story has been deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return success;
  }

  /// Get viewers for a story
  Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    return await _repository.getStoryViewers(storyId);
  }

  /// Check if user has any active stories
  bool get hasActiveStories => myStories.any((s) => !s.isExpired);

  /// Get total unviewed stories count
  int get totalUnviewedCount {
    int count = 0;
    for (final group in userStories) {
      count += group.unviewedCount;
    }
    for (final group in eventStories) {
      count += group.stories.where((s) => !s.isViewed).length;
    }
    return count;
  }
}
