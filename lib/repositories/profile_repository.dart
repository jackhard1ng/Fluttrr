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

  /// Get profile completion percentage
  Future<ApiResponse<int>> getProfileCompletion() async {
    final response = await get<dynamic>(ApiEndpoints.profileCompletion);
    if (response.success && response.data != null) {
      final percentage = response.data['percentage'] ?? response.data['completionPercentage'] ?? 0;
      return ApiResponse.success(data: percentage as int);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get gallery images
  Future<ApiResponse<List<String>>> getGalleryImages() async {
    final response = await get<dynamic>(ApiEndpoints.galleryList);
    if (response.success && response.data != null) {
      final images = (response.data['images'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [];
      return ApiResponse.success(data: images);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Upload gallery image
  Future<ApiResponse<String>> uploadGalleryImage(File image) async {
    final response = await uploadFile<dynamic>(
      ApiEndpoints.galleryUpload,
      file: image,
      fieldName: 'image',
    );
    if (response.success && response.data != null) {
      final imageUrl = response.data['imageUrl'] ?? response.data['url'] ?? '';
      return ApiResponse.success(data: imageUrl as String);
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

  /// Get total activity count
  Future<ApiResponse<int>> getTotalActivityCount() async {
    final response = await get<dynamic>(ApiEndpoints.createdActivitiesCount);
    if (response.success && response.data != null) {
      final count = response.data['count'] ?? 0;
      return ApiResponse.success(data: count as int);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get total match count
  Future<ApiResponse<int>> getTotalMatchCount() async {
    final response = await get<dynamic>(ApiEndpoints.totalMates);
    if (response.success && response.data != null) {
      final count = response.data['count'] ?? response.data['total'] ?? 0;
      return ApiResponse.success(data: count as int);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get joined activities count
  Future<ApiResponse<int>> getJoinedActivitiesCount() async {
    final response = await get<dynamic>(ApiEndpoints.joinedActivitiesCount);
    if (response.success && response.data != null) {
      final count = response.data['count'] ?? 0;
      return ApiResponse.success(data: count as int);
    }
    return ApiResponse.failure(error: response.error);
  }
}
