import 'dart:io';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/activity_model.dart';
import 'base_repository.dart';

/// Activity repository
class ActivityRepository extends BaseRepository {
  /// Maximum allowed page size to prevent DOS (#57)
  static const int _maxPageSize = 100;

  /// Validate and sanitize pagination parameters (#57)
  Map<String, int> _validatePagination(int? page, int? limit) {
    final validPage = (page != null && page >= 1) ? page : 1;
    final validLimit = (limit != null && limit >= 1 && limit <= _maxPageSize)
        ? limit
        : 20;
    return {'page': validPage, 'limit': validLimit};
  }

  /// Get daily activities
  Future<ApiResponse<List<ActivityModel>>> getDailyActivities() async {
    final response = await get<dynamic>(ApiEndpoints.dailyActivities);
    return _parseActivityList(response);
  }

  /// Get all activities with validated pagination (#57)
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int? page,
    int? limit,
    String? eventType,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    // Validate pagination parameters (#57)
    final pagination = _validatePagination(page, limit);

    final queryParams = <String, String>{
      'page': pagination['page'].toString(),
      'limit': pagination['limit'].toString(),
    };
    if (eventType != null) queryParams['eventType'] = eventType;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();

    final response = await get<dynamic>(
      ApiEndpoints.activityList,
      queryParams: queryParams,
    );
    return _parseActivityList(response);
  }

  /// Get activity details
  Future<ApiResponse<ActivityModel>> getActivityDetails(int activityId) async {
    return get<ActivityModel>(
      '${ApiEndpoints.activityDetails}/$activityId',
      fromJson: ActivityModel.fromJson,
    );
  }

  /// Get my activities
  Future<ApiResponse<List<ActivityModel>>> getMyActivities() async {
    final response = await get<dynamic>(ApiEndpoints.myActivities);
    return _parseActivityList(response);
  }

  /// Get user's joined activities
  Future<ApiResponse<List<ActivityModel>>> getJoinedActivities() async {
    final response = await get<dynamic>(ApiEndpoints.userActivities);
    return _parseActivityList(response);
  }

  /// Get upcoming activities
  Future<ApiResponse<List<ActivityModel>>> getUpcomingActivities() async {
    final response = await get<dynamic>(ApiEndpoints.upcomingActivities);
    return _parseActivityList(response);
  }

  /// Get trending activities (most popular upcoming)
  Future<ApiResponse<List<ActivityModel>>> getTrendingActivities({int limit = 10}) async {
    final response = await get<dynamic>(
      ApiEndpoints.trendingActivities,
      queryParams: {'limit': limit.toString()},
    );
    return _parseActivityList(response);
  }

  /// Get suggested activities (based on user interests)
  Future<ApiResponse<List<ActivityModel>>> getSuggestedActivities({int limit = 10}) async {
    final response = await get<dynamic>(
      ApiEndpoints.suggestedActivities,
      queryParams: {'limit': limit.toString()},
    );
    return _parseActivityList(response);
  }

  /// Search/filter activities
  Future<ApiResponse<List<ActivityModel>>> searchActivities({
    String? query,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final body = <String, dynamic>{};
    if (query != null) body['query'] = query;
    if (eventType != null) body['eventType'] = eventType;
    if (startDate != null) body['startDate'] = startDate.toIso8601String();
    if (endDate != null) body['endDate'] = endDate.toIso8601String();
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (radius != null) body['radius'] = radius;

    final response = await post<dynamic>(
      ApiEndpoints.searchActivities,
      body: body,
    );
    return _parseActivityList(response);
  }

  /// Create activity
  Future<ApiResponse<ActivityModel>> createActivity({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required DateTime dateTime,
    required String eventType,
    required int totalSlots,
    List<File>? images,
  }) async {
    // First create the activity without images
    final response = await post<ActivityModel>(
      ApiEndpoints.createActivity,
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'date_time': dateTime.toIso8601String(),
        'event_type': eventType,
        'total_slots': totalSlots,
      },
      fromJson: ActivityModel.fromJson,
    );

    // Upload images if activity was created successfully and images provided
    if (response.success && response.data != null && images != null && images.isNotEmpty) {
      final activityId = response.data?.activityId;
      if (activityId != null) {
        await _uploadActivityImages(activityId, images);
      }
    }

    return response;
  }

  /// Create recurring activity series
  Future<ApiResponse<dynamic>> createRecurringActivity({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required String eventType,
    required int totalSlots,
    required String recurrenceType,
    required int interval,
    required DateTime startDate,
    required String timeOfDay,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? maxOccurrences,
  }) async {
    return post<dynamic>(
      ApiEndpoints.createRecurringEvent,
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'event_type': eventType,
        'total_slots': totalSlots,
        'recurrence_type': recurrenceType,
        'interval': interval,
        'start_date': startDate.toIso8601String(),
        'time_of_day': timeOfDay,
        if (daysOfWeek != null) 'days_of_week': daysOfWeek,
        if (dayOfMonth != null) 'day_of_month': dayOfMonth,
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (maxOccurrences != null) 'max_occurrences': maxOccurrences,
      },
    );
  }

  /// Upload images for an activity
  Future<ApiResponse<dynamic>> _uploadActivityImages(int activityId, List<File> images) async {
    final files = <String, File>{};
    for (var i = 0; i < images.length; i++) {
      files['image_$i'] = images[i];
    }

    return uploadMultipleFiles<dynamic>(
      '${ApiEndpoints.activityImages}/$activityId',
      files: files,
    );
  }

  /// Update activity
  Future<ApiResponse<ActivityModel>> updateActivity({
    required int activityId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    String? eventType,
    int? totalSlots,
    List<File>? images,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (dateTime != null) body['date_time'] = dateTime.toIso8601String();
    if (eventType != null) body['event_type'] = eventType;
    if (totalSlots != null) body['total_slots'] = totalSlots;

    final response = await put<ActivityModel>(
      '${ApiEndpoints.updateActivity}/$activityId',
      body: body,
      fromJson: ActivityModel.fromJson,
    );

    // Upload new images if provided
    if (response.success && images != null && images.isNotEmpty) {
      await _uploadActivityImages(activityId, images);
    }

    return response;
  }

  /// Delete activity
  Future<ApiResponse<dynamic>> deleteActivity(int activityId) async {
    return delete('${ApiEndpoints.deleteActivity}/$activityId');
  }

  /// Join activity
  Future<ApiResponse<dynamic>> joinActivity(int activityId) async {
    return post(
      ApiEndpoints.joinActivity,
      body: {'activityId': activityId},
    );
  }

  /// Leave activity
  Future<ApiResponse<dynamic>> leaveActivity(int activityId) async {
    return post(
      ApiEndpoints.leaveActivity,
      body: {'activityId': activityId},
    );
  }

  /// Save/unsave activity
  Future<ApiResponse<dynamic>> toggleSaveActivity(int activityId) async {
    return post(
      ApiEndpoints.saveActivity,
      body: {'activityId': activityId},
    );
  }

  /// Helper method to parse activity list response (uses safe parsing from BaseRepository)
  ApiResponse<List<ActivityModel>> _parseActivityList(ApiResponse<dynamic> response) {
    return parseListResponse(response, ActivityModel.fromJson);
  }
}
