import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/story_model.dart';
import '../services/secure_http_client.dart';
import '../constants/api_endpoints.dart';

/// Repository for story-related API calls
class StoryRepository {
  final SecureHttpClient _client = SecureHttpClient.instance;

  /// Get all active stories (friends + events)
  Future<Map<String, dynamic>> getStories() async {
    try {
      final response = await _client.get(ApiEndpoints.stories);

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        // Backend wraps in { success, data: { userStories, eventStories } }
        final data = body['data'] as Map<String, dynamic>? ?? body;

        final userStories = ((data['userStories'] ?? data['user_stories']) as List<dynamic>?)
            ?.map((s) => UserStoryGroup.fromJson(s as Map<String, dynamic>))
            .toList() ?? [];

        final eventStories = ((data['eventStories'] ?? data['event_stories']) as List<dynamic>?)
            ?.map((s) => EventStoryGroup.fromJson(s as Map<String, dynamic>))
            .toList() ?? [];

        return {
          'userStories': userStories,
          'eventStories': eventStories,
        };
      }

      return {'userStories': [], 'eventStories': []};
    } catch (e) {
      debugPrint('Error fetching stories: $e');
      return {'userStories': [], 'eventStories': []};
    }
  }

  /// Get stories for a specific event
  Future<List<StoryModel>> getEventStories(String eventId) async {
    try {
      final response = await _client.get('${ApiEndpoints.stories}/event/$eventId');

      if (response.statusCode == 200 && response.data != null) {
        final stories = (response.data['stories'] as List<dynamic>?)
            ?.map((s) => StoryModel.fromJson(s))
            .toList() ?? [];
        return stories;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching event stories: $e');
      return [];
    }
  }

  /// Get stories for a specific user
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      final response = await _client.get('${ApiEndpoints.stories}/user/$userId');

      if (response.statusCode == 200 && response.data != null) {
        final stories = (response.data['stories'] as List<dynamic>?)
            ?.map((s) => StoryModel.fromJson(s))
            .toList() ?? [];
        return stories;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
      return [];
    }
  }

  /// Get my stories
  Future<List<StoryModel>> getMyStories() async {
    try {
      final response = await _client.get('${ApiEndpoints.stories}/me');

      if (response.statusCode == 200 && response.data != null) {
        final stories = (response.data['stories'] as List<dynamic>?)
            ?.map((s) => StoryModel.fromJson(s))
            .toList() ?? [];
        return stories;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching my stories: $e');
      return [];
    }
  }

  /// Create a new story
  Future<StoryModel?> createStory({
    required File media,
    required StoryType type,
    String? eventId,
    String? caption,
  }) async {
    try {
      final formData = {
        'type': type.name,
        if (eventId != null) 'event_id': eventId,
        if (caption != null) 'caption': caption,
      };

      final response = await _client.uploadFile(
        ApiEndpoints.stories,
        media,
        'media',
        additionalFields: formData,
      );

      if (response.statusCode == 201 && response.data != null) {
        return StoryModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error creating story: $e');
      return null;
    }
  }

  /// Create a text-only story (no file upload)
  Future<StoryModel?> createTextStory({
    String? eventId,
    String? caption,
  }) async {
    try {
      final body = {
        'type': 'text',
        if (eventId != null) 'event_id': eventId,
        if (caption != null) 'caption': caption,
      };

      final response = await _client.post(ApiEndpoints.stories, body);

      if (response.statusCode == 201 && response.data != null) {
        return StoryModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error creating text story: $e');
      return null;
    }
  }

  /// Mark story as viewed
  Future<bool> markStoryViewed(String storyId) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.stories}/$storyId/view',
        {},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking story viewed: $e');
      return false;
    }
  }

  /// Add reaction to story
  Future<bool> addReaction({
    required String storyId,
    required String emoji,
  }) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.stories}/$storyId/react',
        {'emoji': emoji},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding reaction: $e');
      return false;
    }
  }

  /// Delete my story
  Future<bool> deleteStory(String storyId) async {
    try {
      final response = await _client.delete(
        '${ApiEndpoints.stories}/$storyId',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting story: $e');
      return false;
    }
  }

  /// Get story viewers
  Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.stories}/$storyId/viewers',
      );

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(
          response.data['viewers'] ?? [],
        );
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching story viewers: $e');
      return [];
    }
  }
}
