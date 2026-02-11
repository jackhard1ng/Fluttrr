import 'dart:io';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart';
import 'base_repository.dart';

/// Profile repository
class ProfileRepository extends BaseRepository {
  /// Get current user profile
  Future<ApiResponse<UserModel>> getProfile() async {
    return get<UserModel>(
      ApiEndpoints.profile,
      fromJson: UserModel.fromJson,
    );
  }

  /// Create initial profile (after registration)
  Future<ApiResponse<dynamic>> createProfile({
    required int age,
    required String gender,
    required String bio,
    required List<String> interests,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    return post(
      ApiEndpoints.createProfile,
      body: {
        'age': age,
        'gender': gender,
        'bio': bio,
        'interests': interests,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? userName,
    int? age,
    String? gender,
    String? bio,
    List<String>? interests,
    String? location,
    List<String>? languages,
  }) async {
    final body = <String, dynamic>{};
    if (userName != null) body['userName'] = userName;
    if (age != null) body['age'] = age;
    if (gender != null) body['gender'] = gender;
    if (bio != null) body['bio'] = bio;
    if (interests != null) body['interests'] = interests;
    if (location != null) body['location'] = location;
    if (languages != null) body['Language'] = languages;

    return put<UserModel>(
      ApiEndpoints.updateProfile,
      body: body,
      fromJson: UserModel.fromJson,
    );
  }

  /// Update user location
  Future<ApiResponse<dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    return post(
      ApiEndpoints.updateLocation,
      body: {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'location': address,
      },
    );
  }

  /// Update FCM token
  Future<ApiResponse<dynamic>> updateFcmToken(String token) async {
    return post(
      ApiEndpoints.updateFcmToken,
      body: {'token': token},
    );
  }

  /// Set user online
  Future<ApiResponse<dynamic>> setOnline() async {
    return post(ApiEndpoints.setOnline);
  }

  /// Set user offline
  Future<ApiResponse<dynamic>> setOffline() async {
    return post(ApiEndpoints.setOffline);
  }

  /// Update Low Profile mode status
  /// When enabled, user is hidden from Discover but can still join events
  Future<ApiResponse<dynamic>> updateLowProfileStatus(bool isLowProfile) async {
    return post(
      ApiEndpoints.updateLowProfile,
      body: {'isLowProfile': isLowProfile},
    );
  }

  /// Get profile completion percentage with safe type conversion (#70)
  Future<ApiResponse<int>> getProfileCompletion() async {
    final response = await get<dynamic>(ApiEndpoints.profileCompletion);
    if (response.success && response.data != null) {
      final percentage = response.data['data'] ?? response.data['percentage'] ?? response.data['completionPercentage'] ?? 0;
      return ApiResponse.success(data: _safeToInt(percentage));
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Safely convert a value to int (#70)
  int _safeToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Safely convert a value to String (#70)
  String _safeToString(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  /// Get gallery images
  Future<ApiResponse<List<String>>> getGalleryImages() async {
    final response = await get<dynamic>(ApiEndpoints.galleryList);
    if (response.success && response.data != null) {
      final rawImages = response.data['data'] ?? response.data['images'];
      final images = (rawImages as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [];
      return ApiResponse.success(data: images);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Upload profile photo
  Future<ApiResponse<String>> uploadProfilePhoto(File image) async {
    final response = await uploadFile<dynamic>(
      ApiEndpoints.uploadProfilePhoto,
      file: image,
      fieldName: 'photo',
    );
    if (response.success && response.data != null) {
      final imageUrl = response.data['data'] ?? response.data['imageUrl'] ?? response.data['url'] ?? '';
      return ApiResponse.success(data: _safeToString(imageUrl));
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Remove profile photo
  Future<ApiResponse<dynamic>> removeProfilePhoto() async {
    return post(ApiEndpoints.removeProfilePhoto);
  }

  /// Delete user account (uses POST since body is needed for password)
  Future<ApiResponse<dynamic>> deleteAccount(String password) async {
    return post(
      ApiEndpoints.deleteAccount,
      body: {'password': password},
    );
  }

  /// Get notification preferences
  Future<ApiResponse<Map<String, dynamic>>> getNotificationPreferences() async {
    final response = await get<dynamic>(ApiEndpoints.notificationPreferences);
    if (response.success && response.data != null) {
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ApiResponse.success(data: data);
      }
      return ApiResponse.success(data: {
        'activityReminders': true,
        'messageNotifications': true,
        'promotionalEmails': false,
        'reminderTime': 30,
      });
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Update notification preferences
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationPreferences({
    bool? activityReminders,
    bool? messageNotifications,
    bool? promotionalEmails,
    int? reminderTime,
  }) async {
    final body = <String, dynamic>{};
    if (activityReminders != null) body['activityReminders'] = activityReminders;
    if (messageNotifications != null) body['messageNotifications'] = messageNotifications;
    if (promotionalEmails != null) body['promotionalEmails'] = promotionalEmails;
    if (reminderTime != null) body['reminderTime'] = reminderTime;

    final response = await put<dynamic>(
      ApiEndpoints.notificationPreferences,
      body: body,
    );
    if (response.success && response.data != null) {
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ApiResponse.success(data: data);
      }
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Upload gallery image with safe type conversion (#70)
  Future<ApiResponse<String>> uploadGalleryImage(File image) async {
    final response = await uploadFile<dynamic>(
      ApiEndpoints.galleryUpload,
      file: image,
      fieldName: 'image',
    );
    if (response.success && response.data != null) {
      final imageUrl = response.data['data'] ?? response.data['imageUrl'] ?? response.data['url'] ?? '';
      return ApiResponse.success(data: _safeToString(imageUrl));
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get user badges
  Future<ApiResponse<List<BadgeModel>>> getBadges() async {
    final response = await get<dynamic>(ApiEndpoints.badgesList);
    if (response.success && response.data != null) {
      final badges = (response.data['data'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse.success(data: badges);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Claim a badge
  Future<ApiResponse<dynamic>> claimBadge(int badgeId) async {
    return post(
      ApiEndpoints.claimBadge,
      body: {'badgeId': badgeId},
    );
  }

  /// Get leaderboard
  Future<ApiResponse<LeaderboardResponse>> getLeaderboard() async {
    return get<LeaderboardResponse>(
      ApiEndpoints.leaderboard,
      fromJson: LeaderboardResponse.fromJson,
    );
  }

  /// Get total activity count with safe type conversion (#70)
  Future<ApiResponse<int>> getTotalActivityCount() async {
    final response = await get<dynamic>(ApiEndpoints.createdActivitiesCount);
    if (response.success && response.data != null) {
      final count = response.data['data'] ?? response.data['count'] ?? 0;
      return ApiResponse.success(data: _safeToInt(count));
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get total connections count
  /// Note: Mates feature removed - returns 0 for backwards compatibility
  Future<ApiResponse<int>> getTotalMatchCount() async {
    return ApiResponse.success(data: 0);
  }

  /// Get joined activities count with safe type conversion (#70)
  Future<ApiResponse<int>> getJoinedActivitiesCount() async {
    final response = await get<dynamic>(ApiEndpoints.joinedActivitiesCount);
    if (response.success && response.data != null) {
      final count = response.data['data'] ?? response.data['count'] ?? 0;
      return ApiResponse.success(data: _safeToInt(count));
    }
    return ApiResponse.failure(error: response.error);
  }
}
