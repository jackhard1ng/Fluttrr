import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/memory_model.dart';
import '../repositories/memory_repository.dart';
import '../services/analytics_service.dart';

/// Controller for event memories
class MemoryController extends GetxController {
  final MemoryRepository _repository = MemoryRepository();
  final AnalyticsService _analytics = AnalyticsService();

  // Feed
  final RxList<EventMemoryModel> feedMemories = <EventMemoryModel>[].obs;
  final RxList<EventMemoryModel> featuredMemories = <EventMemoryModel>[].obs;

  // Event-specific memories
  final RxList<EventMemoryModel> eventMemories = <EventMemoryModel>[].obs;
  final RxString currentEventId = ''.obs;

  // Events with memories
  final RxList<EventWithMemoriesModel> eventsWithMemories = <EventWithMemoriesModel>[].obs;

  // My memories
  final RxList<EventMemoryModel> myMemories = <EventMemoryModel>[].obs;

  // Selected memory details
  final Rx<EventMemoryModel?> selectedMemory = Rx<EventMemoryModel?>(null);
  final RxList<MemoryCommentModel> memoryComments = <MemoryCommentModel>[].obs;

  // Photos user is tagged in
  final RxList<MemoryPhotoModel> taggedPhotos = <MemoryPhotoModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFeed = false.obs;
  final RxBool isLoadingEvent = false.obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Pagination
  final RxInt feedPage = 1.obs;
  final RxInt eventPage = 1.obs;
  final RxInt eventsPage = 1.obs;
  final RxBool hasMoreFeed = true.obs;
  final RxBool hasMoreEventMemories = true.obs;
  final RxBool hasMoreEvents = true.obs;

  // Messages
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeaturedMemories();
  }

  // ============ FEED ============

  /// Load memories feed
  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      feedPage.value = 1;
      hasMoreFeed.value = true;
    }

    if (!hasMoreFeed.value && !refresh) return;

    isLoadingFeed.value = true;
    try {
      final response = await _repository.getMemoriesFeed(
        page: feedPage.value,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          feedMemories.value = response.data!;
        } else {
          feedMemories.addAll(response.data!);
        }
        hasMoreFeed.value = response.data!.length >= 20;
        feedPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading feed: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  /// Load featured/trending memories
  Future<void> loadFeaturedMemories() async {
    try {
      final response = await _repository.getFeaturedMemories();
      if (response.success && response.data != null) {
        featuredMemories.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading featured memories: $e');
    }
  }

  // ============ EVENT MEMORIES ============

  /// Load memories for a specific event
  Future<void> loadEventMemories({
    required String eventId,
    bool refresh = false,
  }) async {
    if (currentEventId.value != eventId) {
      eventMemories.clear();
      eventPage.value = 1;
      hasMoreEventMemories.value = true;
      currentEventId.value = eventId;
    }

    if (refresh) {
      eventPage.value = 1;
      hasMoreEventMemories.value = true;
    }

    if (!hasMoreEventMemories.value && !refresh) return;

    isLoadingEvent.value = true;
    try {
      final response = await _repository.getEventMemories(
        eventId: eventId,
        page: eventPage.value,
      );

      if (response.success && response.data != null) {
        if (refresh || eventPage.value == 1) {
          eventMemories.value = response.data!;
        } else {
          eventMemories.addAll(response.data!);
        }
        hasMoreEventMemories.value = response.data!.length >= 20;
        eventPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading event memories: $e');
    } finally {
      isLoadingEvent.value = false;
    }
  }

  /// Load events that have memories
  Future<void> loadEventsWithMemories({
    bool refresh = false,
    bool myEventsOnly = false,
  }) async {
    if (refresh) {
      eventsPage.value = 1;
      hasMoreEvents.value = true;
    }

    if (!hasMoreEvents.value && !refresh) return;

    isLoading.value = true;
    try {
      final response = await _repository.getEventsWithMemories(
        page: eventsPage.value,
        myEventsOnly: myEventsOnly,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          eventsWithMemories.value = response.data!;
        } else {
          eventsWithMemories.addAll(response.data!);
        }
        hasMoreEvents.value = response.data!.length >= 20;
        eventsPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading events with memories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load memory details
  Future<void> loadMemoryDetails(String memoryId) async {
    isLoading.value = true;
    try {
      final response = await _repository.getMemoryDetails(memoryId);
      if (response.success && response.data != null) {
        selectedMemory.value = response.data;
        await _analytics.logMemoryViewed(activityId: response.data!.eventId);
      }
    } catch (e) {
      debugPrint('Error loading memory details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ UPLOAD ============

  /// Upload new memory
  Future<EventMemoryModel?> uploadMemory({
    required String eventId,
    required List<File> photos,
    String? caption,
  }) async {
    if (photos.isEmpty) {
      errorMessage.value = 'Please select at least one photo';
      return null;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;
    errorMessage.value = '';

    try {
      final response = await _repository.uploadMemory(
        eventId: eventId,
        photos: photos,
        caption: caption,
      );

      if (response.success && response.data != null) {
        // Add to event memories if viewing that event
        if (currentEventId.value == eventId) {
          eventMemories.insert(0, response.data!);
        }

        // Add to my memories
        myMemories.insert(0, response.data!);

        // Track analytics
        await _analytics.logMemoryPhotoUploaded(
          activityId: eventId,
          photoCount: photos.length,
        );

        successMessage.value = 'Memory uploaded successfully!';
        return response.data;
      } else {
        errorMessage.value = response.error ?? 'Failed to upload memory';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload memory';
      debugPrint('Error uploading memory: $e');
      return null;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// Add photos to existing memory
  Future<bool> addPhotosToMemory({
    required String memoryId,
    required List<File> photos,
  }) async {
    isUploading.value = true;
    try {
      final response = await _repository.addPhotosToMemory(
        memoryId: memoryId,
        photos: photos,
      );

      if (response.success && response.data != null) {
        // Update in lists
        _updateMemoryInLists(response.data!);
        successMessage.value = 'Photos added!';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to add photos';
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete a memory
  Future<bool> deleteMemory(String memoryId) async {
    try {
      final response = await _repository.deleteMemory(memoryId);
      if (response.success) {
        feedMemories.removeWhere((m) => m.memoryId == memoryId);
        eventMemories.removeWhere((m) => m.memoryId == memoryId);
        myMemories.removeWhere((m) => m.memoryId == memoryId);
        if (selectedMemory.value?.memoryId == memoryId) {
          selectedMemory.value = null;
        }
        successMessage.value = 'Memory deleted';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete memory';
      return false;
    }
  }

  /// Delete a photo from memory
  Future<bool> deletePhoto({
    required String memoryId,
    required String photoId,
  }) async {
    try {
      final response = await _repository.deletePhoto(
        memoryId: memoryId,
        photoId: photoId,
      );

      if (response.success) {
        // Update memory in lists by removing the photo
        _removePhotoFromMemory(memoryId, photoId);
        successMessage.value = 'Photo deleted';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete photo';
      return false;
    }
  }

  // ============ INTERACTIONS ============

  /// Toggle like on a memory
  Future<void> toggleLike(String memoryId) async {
    final memory = _findMemory(memoryId);
    if (memory == null) return;

    // Optimistic update
    final newLikeState = !memory.isLikedByMe;
    final newLikeCount = memory.likeCount + (newLikeState ? 1 : -1);
    final updatedMemory = memory.copyWith(
      isLikedByMe: newLikeState,
      likeCount: newLikeCount,
    );
    _updateMemoryInLists(updatedMemory);

    try {
      final response = newLikeState
          ? await _repository.likeMemory(memoryId)
          : await _repository.unlikeMemory(memoryId);

      if (response.success && response.data != null) {
        _updateMemoryInLists(response.data!);
      } else {
        // Revert on failure
        _updateMemoryInLists(memory);
      }
    } catch (e) {
      // Revert on failure
      _updateMemoryInLists(memory);
    }
  }

  /// Load comments for a memory
  Future<void> loadComments(String memoryId) async {
    isLoadingComments.value = true;
    try {
      final response = await _repository.getMemoryComments(memoryId: memoryId);
      if (response.success && response.data != null) {
        memoryComments.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  /// Add comment to memory
  Future<bool> addComment({
    required String memoryId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    try {
      final response = await _repository.addComment(
        memoryId: memoryId,
        content: content.trim(),
      );

      if (response.success && response.data != null) {
        memoryComments.add(response.data!);

        // Update comment count in memory
        final memory = _findMemory(memoryId);
        if (memory != null) {
          _updateMemoryInLists(memory.copyWith(
            commentCount: memory.commentCount + 1,
          ));
        }
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to add comment';
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment({
    required String memoryId,
    required String commentId,
  }) async {
    try {
      final response = await _repository.deleteComment(
        memoryId: memoryId,
        commentId: commentId,
      );

      if (response.success) {
        memoryComments.removeWhere((c) => c.commentId == commentId);

        // Update comment count
        final memory = _findMemory(memoryId);
        if (memory != null) {
          _updateMemoryInLists(memory.copyWith(
            commentCount: (memory.commentCount - 1).clamp(0, memory.commentCount),
          ));
        }
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete comment';
      return false;
    }
  }

  /// Toggle like on a comment
  Future<void> toggleCommentLike({
    required String memoryId,
    required String commentId,
  }) async {
    final commentIndex = memoryComments.indexWhere((c) => c.commentId == commentId);
    if (commentIndex == -1) return;

    final comment = memoryComments[commentIndex];
    final newLikeState = !comment.isLikedByMe;

    // Optimistic update
    memoryComments[commentIndex] = comment.copyWith(
      isLikedByMe: newLikeState,
      likeCount: comment.likeCount + (newLikeState ? 1 : -1),
    );

    try {
      final response = await _repository.likeComment(
        memoryId: memoryId,
        commentId: commentId,
      );

      if (response.success && response.data != null) {
        memoryComments[commentIndex] = response.data!;
      }
    } catch (e) {
      // Revert on failure
      memoryComments[commentIndex] = comment;
    }
  }

  // ============ TAGGING ============

  /// Tag a user in a photo
  Future<bool> tagUser({
    required String memoryId,
    required String photoId,
    required String userId,
    required double xPosition,
    required double yPosition,
  }) async {
    try {
      final response = await _repository.tagUser(
        memoryId: memoryId,
        photoId: photoId,
        userId: userId,
        xPosition: xPosition,
        yPosition: yPosition,
      );

      if (response.success) {
        successMessage.value = 'User tagged!';
        // Reload memory to get updated tags
        await loadMemoryDetails(memoryId);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to tag user';
      return false;
    }
  }

  /// Remove a tag
  Future<bool> removeTag({
    required String memoryId,
    required String photoId,
    required String tagId,
  }) async {
    try {
      final response = await _repository.removeTag(
        memoryId: memoryId,
        photoId: photoId,
        tagId: tagId,
      );

      if (response.success) {
        await loadMemoryDetails(memoryId);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to remove tag';
      return false;
    }
  }

  /// Load photos user is tagged in
  Future<void> loadTaggedPhotos() async {
    isLoading.value = true;
    try {
      final response = await _repository.getPhotosTaggedIn();
      if (response.success && response.data != null) {
        taggedPhotos.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading tagged photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ MY MEMORIES ============

  /// Load my uploaded memories
  Future<void> loadMyMemories({bool refresh = false}) async {
    isLoading.value = true;
    try {
      final response = await _repository.getMyMemories();
      if (response.success && response.data != null) {
        myMemories.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading my memories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ REPORTING ============

  /// Report a memory
  Future<bool> reportMemory({
    required String memoryId,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await _repository.reportMemory(
        memoryId: memoryId,
        reason: reason,
        details: details,
      );

      if (response.success) {
        successMessage.value = 'Report submitted. Thank you!';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to submit report';
      return false;
    }
  }

  // ============ HELPERS ============

  /// Find memory in any list
  EventMemoryModel? _findMemory(String memoryId) {
    EventMemoryModel? memory;

    memory = feedMemories.firstWhereOrNull((m) => m.memoryId == memoryId);
    memory ??= eventMemories.firstWhereOrNull((m) => m.memoryId == memoryId);
    memory ??= myMemories.firstWhereOrNull((m) => m.memoryId == memoryId);
    memory ??= selectedMemory.value?.memoryId == memoryId ? selectedMemory.value : null;

    return memory;
  }

  /// Update memory in all lists
  void _updateMemoryInLists(EventMemoryModel memory) {
    final feedIndex = feedMemories.indexWhere((m) => m.memoryId == memory.memoryId);
    if (feedIndex != -1) feedMemories[feedIndex] = memory;

    final eventIndex = eventMemories.indexWhere((m) => m.memoryId == memory.memoryId);
    if (eventIndex != -1) eventMemories[eventIndex] = memory;

    final myIndex = myMemories.indexWhere((m) => m.memoryId == memory.memoryId);
    if (myIndex != -1) myMemories[myIndex] = memory;

    if (selectedMemory.value?.memoryId == memory.memoryId) {
      selectedMemory.value = memory;
    }
  }

  /// Remove photo from memory in lists
  void _removePhotoFromMemory(String memoryId, String photoId) {
    void updateMemory(EventMemoryModel memory, int index, RxList<EventMemoryModel> list) {
      final updatedPhotos = memory.photos.where((p) => p.photoId != photoId).toList();
      list[index] = memory.copyWith(photos: updatedPhotos);
    }

    final feedIndex = feedMemories.indexWhere((m) => m.memoryId == memoryId);
    if (feedIndex != -1) updateMemory(feedMemories[feedIndex], feedIndex, feedMemories);

    final eventIndex = eventMemories.indexWhere((m) => m.memoryId == memoryId);
    if (eventIndex != -1) updateMemory(eventMemories[eventIndex], eventIndex, eventMemories);

    final myIndex = myMemories.indexWhere((m) => m.memoryId == memoryId);
    if (myIndex != -1) updateMemory(myMemories[myIndex], myIndex, myMemories);

    if (selectedMemory.value?.memoryId == memoryId) {
      final memory = selectedMemory.value!;
      selectedMemory.value = memory.copyWith(
        photos: memory.photos.where((p) => p.photoId != photoId).toList(),
      );
    }
  }

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Reset all state
  void reset() {
    feedMemories.clear();
    featuredMemories.clear();
    eventMemories.clear();
    eventsWithMemories.clear();
    myMemories.clear();
    selectedMemory.value = null;
    memoryComments.clear();
    taggedPhotos.clear();
    currentEventId.value = '';
    feedPage.value = 1;
    eventPage.value = 1;
    eventsPage.value = 1;
    hasMoreFeed.value = true;
    hasMoreEventMemories.value = true;
    hasMoreEvents.value = true;
    clearMessages();
  }
}
