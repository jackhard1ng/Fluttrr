import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/follow_model.dart';
import '../models/business_model.dart';
import 'base_repository.dart';

/// Repository for business follow operations
class FollowRepository extends BaseRepository {
  /// Follow a business
  Future<ApiResponse<BusinessFollowModel>> followBusiness({
    required int businessId,
    bool enableNotifications = true,
  }) async {
    return post<BusinessFollowModel>(
      ApiEndpoints.followBusiness,
      body: {
        'business_id': businessId,
        'enable_notifications': enableNotifications,
      },
      fromJson: BusinessFollowModel.fromJson,
    );
  }

  /// Unfollow a business
  Future<ApiResponse<dynamic>> unfollowBusiness({
    required int businessId,
  }) async {
    return post(
      ApiEndpoints.unfollowBusiness,
      body: {
        'business_id': businessId,
      },
    );
  }

  /// Get followed businesses
  Future<ApiResponse<FollowedBusinessesResponse>> getFollowedBusinesses({
    int page = 1,
    int limit = 20,
  }) async {
    return get<FollowedBusinessesResponse>(
      ApiEndpoints.getFollowedBusinesses,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: FollowedBusinessesResponse.fromJson,
    );
  }

  /// Update follow notification settings
  Future<ApiResponse<FollowNotificationSettings>> updateFollowNotifications({
    required int businessId,
    bool? newEvents,
    bool? eventReminders,
    bool? promotions,
    bool? updates,
  }) async {
    final body = <String, dynamic>{
      'business_id': businessId,
    };
    if (newEvents != null) body['new_events'] = newEvents;
    if (eventReminders != null) body['event_reminders'] = eventReminders;
    if (promotions != null) body['promotions'] = promotions;
    if (updates != null) body['updates'] = updates;

    return put<FollowNotificationSettings>(
      ApiEndpoints.followBusinessNotifications,
      body: body,
      fromJson: FollowNotificationSettings.fromJson,
    );
  }

  /// Get events from followed businesses
  Future<ApiResponse<List<BusinessEvent>>> getFollowedBusinessEvents({
    int page = 1,
    int limit = 20,
    DateTime? fromDate,
    String? category,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String();
    }
    if (category != null) {
      queryParams['category'] = category;
    }

    final response = await get<dynamic>(
      ApiEndpoints.followedBusinessEvents,
      queryParams: queryParams,
    );
    return parseListResponse(response, BusinessEvent.fromJson);
  }

  /// Check if user is following a business
  Future<ApiResponse<bool>> isFollowingBusiness({
    required int businessId,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.followBusiness}/$businessId/check',
    );
    if (response.success) {
      final data = response.data as Map<String, dynamic>?;
      return ApiResponse.success(data: data?['is_following'] == true);
    }
    return ApiResponse.failure(error: response.error ?? 'Failed to check follow status');
  }

  /// Get follow notification settings for a business
  Future<ApiResponse<FollowNotificationSettings>> getFollowNotificationSettings({
    required int businessId,
  }) async {
    return get<FollowNotificationSettings>(
      '${ApiEndpoints.followBusinessNotifications}/$businessId',
      fromJson: FollowNotificationSettings.fromJson,
    );
  }
}
