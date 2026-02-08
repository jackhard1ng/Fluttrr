import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/group_model.dart';
import '../models/activity_model.dart';
import 'base_repository.dart';

/// Repository for group operations
class GroupRepository extends BaseRepository {
  /// Create a new group
  Future<ApiResponse<GroupModel>> createGroup({
    required String name,
    required String description,
    required GroupType type,
    GroupPrivacy privacy = GroupPrivacy.public,
    String? image,
    String? coverImage,
    List<String> interests = const [],
    List<String> tags = const [],
    String? location,
    double? latitude,
    double? longitude,
    GroupSettings? settings,
  }) async {
    return post<GroupModel>(
      ApiEndpoints.createGroup,
      body: {
        'name': name,
        'description': description,
        'type': type.name,
        'privacy': privacy.name,
        'image': image,
        'cover_image': coverImage,
        'interests': interests,
        'tags': tags,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'settings': settings?.toJson(),
      },
      fromJson: GroupModel.fromJson,
    );
  }

  /// Get groups (with optional filters)
  Future<ApiResponse<List<GroupModel>>> getGroups({
    GroupType? type,
    String? interest,
    String? query,
    int page = 1,
    int limit = 20,
    double? latitude,
    double? longitude,
    double? radiusMiles,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) queryParams['type'] = type.name;
    if (interest != null) queryParams['interest'] = interest;
    if (query != null) queryParams['query'] = query;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radiusMiles != null) queryParams['radius'] = radiusMiles.toString();

    final response = await get<dynamic>(
      ApiEndpoints.getGroups,
      queryParams: queryParams,
    );
    return parseListResponse(response, GroupModel.fromJson);
  }

  /// Get group details
  Future<ApiResponse<GroupModel>> getGroupDetails({
    required String groupId,
  }) async {
    return get<GroupModel>(
      '${ApiEndpoints.getGroupDetails}/$groupId',
      fromJson: GroupModel.fromJson,
    );
  }

  /// Update a group
  Future<ApiResponse<GroupModel>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    GroupPrivacy? privacy,
    String? image,
    String? coverImage,
    List<String>? interests,
    List<String>? tags,
    GroupSettings? settings,
  }) async {
    final body = <String, dynamic>{
      'group_id': groupId,
    };
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (privacy != null) body['privacy'] = privacy.name;
    if (image != null) body['image'] = image;
    if (coverImage != null) body['cover_image'] = coverImage;
    if (interests != null) body['interests'] = interests;
    if (tags != null) body['tags'] = tags;
    if (settings != null) body['settings'] = settings.toJson();

    return put<GroupModel>(
      ApiEndpoints.updateGroup,
      body: body,
      fromJson: GroupModel.fromJson,
    );
  }

  /// Delete a group
  Future<ApiResponse<dynamic>> deleteGroup({
    required String groupId,
  }) async {
    return delete(
      '${ApiEndpoints.deleteGroup}/$groupId',
    );
  }

  /// Join a group
  Future<ApiResponse<GroupMemberModel>> joinGroup({
    required String groupId,
    String? message,
  }) async {
    return post<GroupMemberModel>(
      ApiEndpoints.joinGroup,
      body: {
        'group_id': groupId,
        'message': message,
      },
      fromJson: GroupMemberModel.fromJson,
    );
  }

  /// Leave a group
  Future<ApiResponse<dynamic>> leaveGroup({
    required String groupId,
  }) async {
    return post(
      ApiEndpoints.leaveGroup,
      body: {
        'group_id': groupId,
      },
    );
  }

  /// Get group members
  Future<ApiResponse<List<GroupMemberModel>>> getGroupMembers({
    required String groupId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.groupMembers}/$groupId',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, GroupMemberModel.fromJson);
  }

  /// Get group events
  Future<ApiResponse<List<ActivityModel>>> getGroupEvents({
    required String groupId,
    int page = 1,
    int limit = 20,
    bool upcomingOnly = true,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.groupEvents}/$groupId',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        'upcoming_only': upcomingOnly.toString(),
      },
    );
    return parseListResponse(response, ActivityModel.fromJson);
  }

  /// Get join requests for a group (admin only)
  Future<ApiResponse<List<GroupJoinRequest>>> getJoinRequests({
    required String groupId,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.groupJoinRequests}/$groupId',
    );
    return parseListResponse(response, GroupJoinRequest.fromJson);
  }

  /// Respond to a join request (admin only)
  Future<ApiResponse<GroupMemberModel>> respondToJoinRequest({
    required String requestId,
    required bool approve,
  }) async {
    return post<GroupMemberModel>(
      ApiEndpoints.respondToJoinRequest,
      body: {
        'request_id': requestId,
        'approve': approve,
      },
      fromJson: GroupMemberModel.fromJson,
    );
  }

  /// Search groups
  Future<ApiResponse<List<GroupModel>>> searchGroups({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.searchGroups,
      queryParams: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, GroupModel.fromJson);
  }

  /// Get suggested groups based on user interests
  Future<ApiResponse<List<GroupModel>>> getSuggestedGroups({
    int limit = 10,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.suggestedGroups,
      queryParams: {
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, GroupModel.fromJson);
  }

  /// Get groups the user is a member of
  Future<ApiResponse<List<GroupModel>>> getMyGroups({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.myGroups,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, GroupModel.fromJson);
  }

  /// Get groups by interest
  Future<ApiResponse<List<GroupModel>>> getGroupsByInterest({
    required String interest,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.interestGroups,
      queryParams: {
        'interest': interest,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, GroupModel.fromJson);
  }

  /// Update member role (admin only)
  Future<ApiResponse<GroupMemberModel>> updateMemberRole({
    required String groupId,
    required int userId,
    required GroupMemberRole role,
  }) async {
    return put<GroupMemberModel>(
      '${ApiEndpoints.groupMembers}/$groupId/role',
      body: {
        'user_id': userId,
        'role': role.name,
      },
      fromJson: GroupMemberModel.fromJson,
    );
  }

  /// Remove member from group (admin only)
  Future<ApiResponse<dynamic>> removeMember({
    required String groupId,
    required int userId,
  }) async {
    return delete(
      '${ApiEndpoints.groupMembers}/$groupId/$userId',
    );
  }
}
