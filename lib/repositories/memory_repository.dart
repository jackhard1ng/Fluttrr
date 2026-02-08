import 'dart:io';

import '../models/memory_model.dart';
import 'base_repository.dart';

/// Repository for event memory operations
class MemoryRepository extends BaseRepository {
  // ============ FEED ============

  /// Get memories feed (all memories from events user attended)
  Future<ApiResponse<List<EventMemoryModel>>> getMemoriesFeed({
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/memories/feed', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get featured/trending memories
  Future<ApiResponse<List<EventMemoryModel>>> getFeaturedMemories({
    int limit = 10,
  }) async {
    return makeRequest(
      () => api.get('/memories/featured', queryParameters: {
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============ EVENT MEMORIES ============

  /// Get all memories for a specific event
  Future<ApiResponse<List<EventMemoryModel>>> getEventMemories({
    required String eventId,
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/events/$eventId/memories', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get memory details
  Future<ApiResponse<EventMemoryModel>> getMemoryDetails(String memoryId) async {
    return makeRequest(
      () => api.get('/memories/$memoryId'),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  /// Get events that have memories (for browsing)
  Future<ApiResponse<List<EventWithMemoriesModel>>> getEventsWithMemories({
    int page = 1,
    int limit = 20,
    bool myEventsOnly = false,
  }) async {
    return makeRequest(
      () => api.get('/memories/events', queryParameters: {
        'page': page,
        'limit': limit,
        'my_events_only': myEventsOnly,
      }),
      (data) => (data as List)
          .map((e) => EventWithMemoriesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============ UPLOAD ============

  /// Upload memory photos for an event
  Future<ApiResponse<EventMemoryModel>> uploadMemory({
    required String eventId,
    required List<File> photos,
    String? caption,
    List<Map<String, dynamic>>? photoDescriptions,
  }) async {
    final formData = <String, dynamic>{
      'event_id': eventId,
      if (caption != null) 'caption': caption,
      if (photoDescriptions != null) 'photo_descriptions': photoDescriptions,
    };

    // Add photos to form data
    final photoFiles = <MapEntry<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      photoFiles.add(MapEntry('photos[$i]', photos[i]));
    }

    return makeRequest(
      () => api.postMultipart('/memories', formData, files: photoFiles),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  /// Add photos to existing memory
  Future<ApiResponse<EventMemoryModel>> addPhotosToMemory({
    required String memoryId,
    required List<File> photos,
  }) async {
    final photoFiles = <MapEntry<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      photoFiles.add(MapEntry('photos[$i]', photos[i]));
    }

    return makeRequest(
      () => api.postMultipart('/memories/$memoryId/photos', {}, files: photoFiles),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  /// Delete a photo from memory
  Future<ApiResponse<bool>> deletePhoto({
    required String memoryId,
    required String photoId,
  }) async {
    return makeRequest(
      () => api.delete('/memories/$memoryId/photos/$photoId'),
      (data) => true,
    );
  }

  /// Delete entire memory
  Future<ApiResponse<bool>> deleteMemory(String memoryId) async {
    return makeRequest(
      () => api.delete('/memories/$memoryId'),
      (data) => true,
    );
  }

  /// Update memory caption
  Future<ApiResponse<EventMemoryModel>> updateMemory({
    required String memoryId,
    String? caption,
  }) async {
    return makeRequest(
      () => api.put('/memories/$memoryId', data: {
        if (caption != null) 'caption': caption,
      }),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  // ============ INTERACTIONS ============

  /// Like a memory
  Future<ApiResponse<EventMemoryModel>> likeMemory(String memoryId) async {
    return makeRequest(
      () => api.post('/memories/$memoryId/like'),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  /// Unlike a memory
  Future<ApiResponse<EventMemoryModel>> unlikeMemory(String memoryId) async {
    return makeRequest(
      () => api.delete('/memories/$memoryId/like'),
      (data) => EventMemoryModel.fromJson(data),
    );
  }

  /// Get comments for a memory
  Future<ApiResponse<List<MemoryCommentModel>>> getMemoryComments({
    required String memoryId,
    int page = 1,
    int limit = 50,
  }) async {
    return makeRequest(
      () => api.get('/memories/$memoryId/comments', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => MemoryCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Add comment to memory
  Future<ApiResponse<MemoryCommentModel>> addComment({
    required String memoryId,
    required String content,
  }) async {
    return makeRequest(
      () => api.post('/memories/$memoryId/comments', data: {
        'content': content,
      }),
      (data) => MemoryCommentModel.fromJson(data),
    );
  }

  /// Delete comment
  Future<ApiResponse<bool>> deleteComment({
    required String memoryId,
    required String commentId,
  }) async {
    return makeRequest(
      () => api.delete('/memories/$memoryId/comments/$commentId'),
      (data) => true,
    );
  }

  /// Like a comment
  Future<ApiResponse<MemoryCommentModel>> likeComment({
    required String memoryId,
    required String commentId,
  }) async {
    return makeRequest(
      () => api.post('/memories/$memoryId/comments/$commentId/like'),
      (data) => MemoryCommentModel.fromJson(data),
    );
  }

  // ============ TAGGING ============

  /// Tag a user in a photo
  Future<ApiResponse<PhotoTagModel>> tagUser({
    required String memoryId,
    required String photoId,
    required String userId,
    required double xPosition,
    required double yPosition,
  }) async {
    return makeRequest(
      () => api.post('/memories/$memoryId/photos/$photoId/tags', data: {
        'user_id': userId,
        'x_position': xPosition,
        'y_position': yPosition,
      }),
      (data) => PhotoTagModel.fromJson(data),
    );
  }

  /// Remove tag from photo
  Future<ApiResponse<bool>> removeTag({
    required String memoryId,
    required String photoId,
    required String tagId,
  }) async {
    return makeRequest(
      () => api.delete('/memories/$memoryId/photos/$photoId/tags/$tagId'),
      (data) => true,
    );
  }

  /// Get photos user is tagged in
  Future<ApiResponse<List<MemoryPhotoModel>>> getPhotosTaggedIn({
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/memories/tagged', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => MemoryPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============ REPORTING ============

  /// Report a memory
  Future<ApiResponse<bool>> reportMemory({
    required String memoryId,
    required String reason,
    String? details,
  }) async {
    return makeRequest(
      () => api.post('/memories/$memoryId/report', data: {
        'reason': reason,
        if (details != null) 'details': details,
      }),
      (data) => true,
    );
  }

  // ============ USER MEMORIES ============

  /// Get memories uploaded by a user
  Future<ApiResponse<List<EventMemoryModel>>> getUserMemories({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/users/$userId/memories', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get my uploaded memories
  Future<ApiResponse<List<EventMemoryModel>>> getMyMemories({
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/memories/mine', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get memories where user is tagged
  Future<ApiResponse<List<EventMemoryModel>>> getTaggedMemories({
    int page = 1,
    int limit = 20,
  }) async {
    return makeRequest(
      () => api.get('/memories/tagged-in', queryParameters: {
        'page': page,
        'limit': limit,
      }),
      (data) => (data as List)
          .map((e) => EventMemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
