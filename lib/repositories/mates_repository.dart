import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/mate_model.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Mates/matching repository
class MatesRepository extends BaseRepository {
  /// Get nearby mates
  Future<ApiResponse<List<MateModel>>> getNearbyMates({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final body = <String, dynamic>{};
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (radius != null) body['radius'] = radius;

    final response = await post<dynamic>(
      ApiEndpoints.nearbyMates,
      body: body.isNotEmpty ? body : null,
    );
    return _parseMatesList(response);
  }

  /// Filter mates
  Future<ApiResponse<List<MateModel>>> filterMates({
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? interests,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    final body = <String, dynamic>{};
    if (minAge != null) body['minAge'] = minAge;
    if (maxAge != null) body['maxAge'] = maxAge;
    if (gender != null) body['gender'] = gender;
    if (interests != null && interests.isNotEmpty) body['interests'] = interests;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (maxDistance != null) body['maxDistance'] = maxDistance;

    final response = await post<dynamic>(
      ApiEndpoints.filterMates,
      body: body,
    );
    return _parseMatesList(response);
  }

  /// Find nearby mates by distance
  Future<ApiResponse<List<MateModel>>> findNearbyMatesByDistance({
    required double latitude,
    required double longitude,
    double radius = 50,
  }) async {
    final response = await post<dynamic>(
      ApiEndpoints.findNearbyMates,
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );
    return _parseMatesList(response);
  }

  /// Search users
  Future<ApiResponse<List<MateModel>>> searchUsers(String query) async {
    final response = await post<dynamic>(
      ApiEndpoints.searchUsers,
      body: {'query': query},
    );
    return _parseMatesList(response);
  }

  /// Like a mate
  Future<ApiResponse<dynamic>> likeMate(int userId) async {
    return post(
      ApiEndpoints.likeMate,
      body: {'userId': userId},
    );
  }

  /// Get liked mates
  Future<ApiResponse<List<MateModel>>> getLikedMates() async {
    final response = await get<dynamic>(ApiEndpoints.likedMates);
    return _parseMatesList(response);
  }

  /// Get matches (mutual likes)
  Future<ApiResponse<List<MatchModel>>> getMatches() async {
    final response = await get<dynamic>(ApiEndpoints.matchList);
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> matches = [];

      if (data is Map<String, dynamic>) {
        matches = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        matches = data;
      }

      final matchList = matches
          .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: matchList);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get total mates count
  Future<ApiResponse<int>> getTotalMatesCount() async {
    final response = await get<dynamic>(ApiEndpoints.totalMates);
    if (response.success && response.data != null) {
      final count = response.data['count'] ?? response.data['total'] ?? 0;
      return ApiResponse.success(data: count as int);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// View mate profile
  Future<ApiResponse<UserModel>> viewMateProfile(int userId) async {
    return get<UserModel>(
      '${ApiEndpoints.privacyProfile}/$userId',
      fromJson: UserModel.fromJson,
    );
  }

  /// Helper method to parse mates list response
  ApiResponse<List<MateModel>> _parseMatesList(ApiResponse<dynamic> response) {
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> mates = [];

      if (data is Map<String, dynamic>) {
        mates = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        mates = data;
      }

      final matesList = mates
          .where((e) => e != null)
          .map((e) => MateModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: matesList);
    }
    return ApiResponse.failure(error: response.error);
  }
}
