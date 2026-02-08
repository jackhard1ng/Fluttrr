import 'dart:io';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
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
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/feed',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }

  /// Get featured/trending memories
  Future<ApiResponse<List<EventMemoryModel>>> getFeaturedMemories({
    int limit = 10,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/featured',
      queryParams: {'limit': limit.toString()},
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }

  // ============ EVENT MEMORIES ============

  /// Get all memories for a specific event
  Future<ApiResponse<List<EventMemoryModel>>> getEventMemories({
    required String eventId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/events/$eventId/memories',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }

  /// Get memory details
  Future<ApiResponse<EventMemoryModel>> getMemoryDetails(String memoryId) async {
    return await get<EventMemoryModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId',
      fromJson: (data) => EventMemoryModel.fromJson(data['data'] ?? data),
    );
  }

  /// Get events that have memories (for browsing)
  Future<ApiResponse<List<EventWithMemoriesModel>>> getEventsWithMemories({
    int page = 1,
    int limit = 20,
    bool myEventsOnly = false,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/events',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        'my_events_only': myEventsOnly.toString(),
      },
    );
    return parseListResponse(response, EventWithMemoriesModel.fromJson);
  }

  // ============ UPLOAD ============

  /// Upload memory photos for an event
  Future<ApiResponse<EventMemoryModel>> uploadMemory({
    required String eventId,
    required List<File> photos,
    String? caption,
    List<Map<String, dynamic>>? photoDescriptions,
  }) async {
    final fields = <String, String>{
      'event_id': eventId,
      if (caption != null) 'caption': caption,
    };

    return await uploadMultipleFiles<EventMemoryModel>(
      '${ApiEndpoints.apiBase}/memories',
      fileList: photos,
      fileListFieldName: 'photos',
      fields: fields,
      fromJson: (data) => EventMemoryModel.fromJson(data['data'] ?? data),
    );
  }

  /// Add photos to existing memory
  Future<ApiResponse<EventMemoryModel>> addPhotosToMemory({
    required String memoryId,
    required List<File> photos,
  }) async {
    return await uploadMultipleFiles<EventMemoryModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/photos',
      fileList: photos,
      fileListFieldName: 'photos',
      fromJson: (data) => EventMemoryModel.fromJson(data['data'] ?? data),
    );
  }

  /// Delete a photo from memory
  Future<ApiResponse<bool>> deletePhoto({
    required String memoryId,
    required String photoId,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/photos/$photoId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Delete entire memory
  Future<ApiResponse<bool>> deleteMemory(String memoryId) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Update memory caption
  Future<ApiResponse<EventMemoryModel>> updateMemory({
    required String memoryId,
    String? caption,
  }) async {
    return await put<EventMemoryModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId',
      body: {
        if (caption != null) 'caption': caption,
      },
      fromJson: (data) => EventMemoryModel.fromJson(data['data'] ?? data),
    );
  }

  // ============ INTERACTIONS ============

  /// Like a memory
  Future<ApiResponse<EventMemoryModel>> likeMemory(String memoryId) async {
    return await post<EventMemoryModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/like',
      fromJson: (data) => EventMemoryModel.fromJson(data['data'] ?? data),
    );
  }

  /// Unlike a memory
  Future<ApiResponse<EventMemoryModel>> unlikeMemory(String memoryId) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/like',
    );
    if (!response.success) {
      return ApiResponse<EventMemoryModel>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }
    // Parse the response data if available
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse<EventMemoryModel>(
        success: true,
        data: EventMemoryModel.fromJson(data['data'] ?? data),
        statusCode: response.statusCode,
      );
    }
    return ApiResponse<EventMemoryModel>(
      success: true,
      statusCode: response.statusCode,
    );
  }

  /// Get comments for a memory
  Future<ApiResponse<List<MemoryCommentModel>>> getMemoryComments({
    required String memoryId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/comments',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, MemoryCommentModel.fromJson);
  }

  /// Add comment to memory
  Future<ApiResponse<MemoryCommentModel>> addComment({
    required String memoryId,
    required String content,
  }) async {
    return await post<MemoryCommentModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/comments',
      body: {'content': content},
      fromJson: (data) => MemoryCommentModel.fromJson(data['data'] ?? data),
    );
  }

  /// Delete comment
  Future<ApiResponse<bool>> deleteComment({
    required String memoryId,
    required String commentId,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/comments/$commentId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Like a comment
  Future<ApiResponse<MemoryCommentModel>> likeComment({
    required String memoryId,
    required String commentId,
  }) async {
    return await post<MemoryCommentModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/comments/$commentId/like',
      fromJson: (data) => MemoryCommentModel.fromJson(data['data'] ?? data),
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
    return await post<PhotoTagModel>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/photos/$photoId/tags',
      body: {
        'user_id': userId,
        'x_position': xPosition,
        'y_position': yPosition,
      },
      fromJson: (data) => PhotoTagModel.fromJson(data['data'] ?? data),
    );
  }

  /// Remove tag from photo
  Future<ApiResponse<bool>> removeTag({
    required String memoryId,
    required String photoId,
    required String tagId,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/photos/$photoId/tags/$tagId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Get photos user is tagged in
  Future<ApiResponse<List<MemoryPhotoModel>>> getPhotosTaggedIn({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/tagged',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, MemoryPhotoModel.fromJson);
  }

  // ============ REPORTING ============

  /// Report a memory
  Future<ApiResponse<bool>> reportMemory({
    required String memoryId,
    required String reason,
    String? details,
  }) async {
    final response = await post<dynamic>(
      '${ApiEndpoints.apiBase}/memories/$memoryId/report',
      body: {
        'reason': reason,
        if (details != null) 'details': details,
      },
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  // ============ USER MEMORIES ============

  /// Get memories uploaded by a user
  Future<ApiResponse<List<EventMemoryModel>>> getUserMemories({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/users/$userId/memories',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }

  /// Get my uploaded memories
  Future<ApiResponse<List<EventMemoryModel>>> getMyMemories({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/mine',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }

  /// Get memories where user is tagged
  Future<ApiResponse<List<EventMemoryModel>>> getTaggedMemories({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/memories/tagged-in',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventMemoryModel.fromJson);
  }
}
