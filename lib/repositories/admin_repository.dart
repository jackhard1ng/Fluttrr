import '../constants/api_endpoints.dart';
import '../models/admin_model.dart';
import '../models/api_response.dart';
import 'base_repository.dart';

/// Repository for admin operations
class AdminRepository extends BaseRepository {
  /// Check if current user is an admin
  Future<ApiResponse<AdminUserModel>> checkAdminStatus() async {
    return await get<AdminUserModel>(
      '${ApiEndpoints.apiBase}/admin/status',
      fromJson: (data) => AdminUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Get dashboard statistics
  Future<ApiResponse<AdminStatsModel>> getDashboardStats() async {
    return await get<AdminStatsModel>(
      '${ApiEndpoints.apiBase}/admin/stats',
      fromJson: (data) => AdminStatsModel.fromJson(data['data'] ?? data),
    );
  }

  /// Get action logs
  Future<ApiResponse<List<AdminActionLogModel>>> getActionLogs({
    int page = 1,
    int limit = 50,
    String? adminId,
    EntityType? entityType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (adminId != null) 'admin_id': adminId,
      if (entityType != null) 'entity_type': entityType.name,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/logs',
      queryParams: queryParams,
    );
    return parseListResponse(response, AdminActionLogModel.fromJson);
  }

  // ============ BUSINESS MANAGEMENT ============

  /// Get all businesses for admin management
  Future<ApiResponse<List<ManagedBusinessModel>>> getBusinesses({
    int page = 1,
    int limit = 20,
    BusinessVerificationStatus? status,
    String? search,
    bool? hasReports,
    String? sortBy,
    bool descending = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status.name,
      if (search != null && search.isNotEmpty) 'search': search,
      if (hasReports != null) 'has_reports': hasReports.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'descending': descending.toString(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/businesses',
      queryParams: queryParams,
    );
    return parseListResponse(response, ManagedBusinessModel.fromJson);
  }

  /// Get business details
  Future<ApiResponse<ManagedBusinessModel>> getBusinessDetails(String businessId) async {
    return await get<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId',
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  /// Verify a business
  Future<ApiResponse<ManagedBusinessModel>> verifyBusiness({
    required String businessId,
    bool approve = true,
    String? rejectionReason,
  }) async {
    return await post<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId/verify',
      body: {
        'approved': approve,
        if (!approve && rejectionReason != null) 'reason': rejectionReason,
      },
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  /// Suspend a business
  Future<ApiResponse<ManagedBusinessModel>> suspendBusiness({
    required String businessId,
    required String reason,
    int? durationDays,
  }) async {
    return await post<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId/suspend',
      body: {
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
      },
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  /// Unsuspend a business
  Future<ApiResponse<ManagedBusinessModel>> unsuspendBusiness(String businessId) async {
    return await post<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId/unsuspend',
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  /// Delete a business
  Future<ApiResponse<bool>> deleteBusiness({
    required String businessId,
    required String reason,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Toggle business featured status
  Future<ApiResponse<ManagedBusinessModel>> toggleBusinessFeatured(String businessId) async {
    return await post<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses/$businessId/toggle-featured',
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  /// Create a new business (admin-created)
  Future<ApiResponse<ManagedBusinessModel>> createBusiness({
    required String name,
    required String email,
    String? phone,
    String? description,
    String? ownerId,
    bool autoVerify = false,
  }) async {
    return await post<ManagedBusinessModel>(
      '${ApiEndpoints.apiBase}/admin/businesses',
      body: {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (description != null) 'description': description,
        if (ownerId != null) 'owner_id': ownerId,
        'auto_verify': autoVerify,
      },
      fromJson: (data) => ManagedBusinessModel.fromJson(data['data'] ?? data),
    );
  }

  // ============ EVENT MANAGEMENT ============

  /// Get all events for admin management
  Future<ApiResponse<List<ManagedEventModel>>> getEvents({
    int page = 1,
    int limit = 20,
    ContentStatus? status,
    String? search,
    String? businessId,
    bool? hasReports,
    bool? isPast,
    String? sortBy,
    bool descending = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status.name,
      if (search != null && search.isNotEmpty) 'search': search,
      if (businessId != null) 'business_id': businessId,
      if (hasReports != null) 'has_reports': hasReports.toString(),
      if (isPast != null) 'is_past': isPast.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'descending': descending.toString(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/events',
      queryParams: queryParams,
    );
    return parseListResponse(response, ManagedEventModel.fromJson);
  }

  /// Get event details
  Future<ApiResponse<ManagedEventModel>> getEventDetails(String eventId) async {
    return await get<ManagedEventModel>(
      '${ApiEndpoints.apiBase}/admin/events/$eventId',
      fromJson: (data) => ManagedEventModel.fromJson(data['data'] ?? data),
    );
  }

  /// Approve an event
  Future<ApiResponse<ManagedEventModel>> approveEvent(String eventId) async {
    return await post<ManagedEventModel>(
      '${ApiEndpoints.apiBase}/admin/events/$eventId/approve',
      fromJson: (data) => ManagedEventModel.fromJson(data['data'] ?? data),
    );
  }

  /// Reject an event
  Future<ApiResponse<ManagedEventModel>> rejectEvent({
    required String eventId,
    required String reason,
  }) async {
    return await post<ManagedEventModel>(
      '${ApiEndpoints.apiBase}/admin/events/$eventId/reject',
      body: {'reason': reason},
      fromJson: (data) => ManagedEventModel.fromJson(data['data'] ?? data),
    );
  }

  /// Remove an event
  Future<ApiResponse<bool>> removeEvent({
    required String eventId,
    required String reason,
    bool notifyAttendees = true,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/events/$eventId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Toggle event featured status
  Future<ApiResponse<ManagedEventModel>> toggleEventFeatured(String eventId) async {
    return await post<ManagedEventModel>(
      '${ApiEndpoints.apiBase}/admin/events/$eventId/toggle-featured',
      fromJson: (data) => ManagedEventModel.fromJson(data['data'] ?? data),
    );
  }

  /// Create an event (admin-created)
  Future<ApiResponse<ManagedEventModel>> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    DateTime? endDate,
    String? businessId,
    int? maxAttendees,
  }) async {
    return await post<ManagedEventModel>(
      '${ApiEndpoints.apiBase}/admin/events',
      body: {
        'title': title,
        'description': description,
        'location': location,
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (businessId != null) 'business_id': businessId,
        if (maxAttendees != null) 'max_attendees': maxAttendees,
      },
      fromJson: (data) => ManagedEventModel.fromJson(data['data'] ?? data),
    );
  }

  // ============ USER MANAGEMENT ============

  /// Get all users for admin management
  Future<ApiResponse<List<ManagedUserModel>>> getUsers({
    int page = 1,
    int limit = 20,
    UserAccountStatus? status,
    String? search,
    bool? isBusinessOwner,
    bool? hasReports,
    String? sortBy,
    bool descending = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status.name,
      if (search != null && search.isNotEmpty) 'search': search,
      if (isBusinessOwner != null) 'is_business_owner': isBusinessOwner.toString(),
      if (hasReports != null) 'has_reports': hasReports.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'descending': descending.toString(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/users',
      queryParams: queryParams,
    );
    return parseListResponse(response, ManagedUserModel.fromJson);
  }

  /// Get user details
  Future<ApiResponse<ManagedUserModel>> getUserDetails(String userId) async {
    return await get<ManagedUserModel>(
      '${ApiEndpoints.apiBase}/admin/users/$userId',
      fromJson: (data) => ManagedUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Suspend a user
  Future<ApiResponse<ManagedUserModel>> suspendUser({
    required String userId,
    required String reason,
    int? durationDays,
  }) async {
    return await post<ManagedUserModel>(
      '${ApiEndpoints.apiBase}/admin/users/$userId/suspend',
      body: {
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
      },
      fromJson: (data) => ManagedUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Unsuspend a user
  Future<ApiResponse<ManagedUserModel>> unsuspendUser(String userId) async {
    return await post<ManagedUserModel>(
      '${ApiEndpoints.apiBase}/admin/users/$userId/unsuspend',
      fromJson: (data) => ManagedUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Ban a user
  Future<ApiResponse<ManagedUserModel>> banUser({
    required String userId,
    required String reason,
  }) async {
    return await post<ManagedUserModel>(
      '${ApiEndpoints.apiBase}/admin/users/$userId/ban',
      body: {'reason': reason},
      fromJson: (data) => ManagedUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Unban a user
  Future<ApiResponse<ManagedUserModel>> unbanUser(String userId) async {
    return await post<ManagedUserModel>(
      '${ApiEndpoints.apiBase}/admin/users/$userId/unban',
      fromJson: (data) => ManagedUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Send warning to user
  Future<ApiResponse<bool>> sendWarning({
    required String userId,
    required String message,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    final response = await post<dynamic>(
      '${ApiEndpoints.apiBase}/admin/users/$userId/warn',
      body: {
        'message': message,
        if (relatedEntityType != null) 'entity_type': relatedEntityType,
        if (relatedEntityId != null) 'entity_id': relatedEntityId,
      },
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Delete a user account
  Future<ApiResponse<bool>> deleteUser({
    required String userId,
    required String reason,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/users/$userId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  // ============ REPORTS MANAGEMENT ============

  /// Get content reports
  Future<ApiResponse<List<ContentReportModel>>> getReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    ReportType? type,
    EntityType? entityType,
    String? assignedTo,
    String? sortBy,
    bool descending = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status.name,
      if (type != null) 'type': type.name,
      if (entityType != null) 'entity_type': entityType.name,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (sortBy != null) 'sort_by': sortBy,
      'descending': descending.toString(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/reports',
      queryParams: queryParams,
    );
    return parseListResponse(response, ContentReportModel.fromJson);
  }

  /// Get report details
  Future<ApiResponse<ContentReportModel>> getReportDetails(String reportId) async {
    return await get<ContentReportModel>(
      '${ApiEndpoints.apiBase}/admin/reports/$reportId',
      fromJson: (data) => ContentReportModel.fromJson(data['data'] ?? data),
    );
  }

  /// Assign report to admin
  Future<ApiResponse<ContentReportModel>> assignReport({
    required String reportId,
    required String adminId,
  }) async {
    return await post<ContentReportModel>(
      '${ApiEndpoints.apiBase}/admin/reports/$reportId/assign',
      body: {'admin_id': adminId},
      fromJson: (data) => ContentReportModel.fromJson(data['data'] ?? data),
    );
  }

  /// Resolve a report
  Future<ApiResponse<ContentReportModel>> resolveReport({
    required String reportId,
    required String resolution,
    String? actionTaken,
  }) async {
    return await post<ContentReportModel>(
      '${ApiEndpoints.apiBase}/admin/reports/$reportId/resolve',
      body: {
        'resolution': resolution,
        if (actionTaken != null) 'action_taken': actionTaken,
      },
      fromJson: (data) => ContentReportModel.fromJson(data['data'] ?? data),
    );
  }

  /// Dismiss a report
  Future<ApiResponse<ContentReportModel>> dismissReport({
    required String reportId,
    String? reason,
  }) async {
    return await post<ContentReportModel>(
      '${ApiEndpoints.apiBase}/admin/reports/$reportId/dismiss',
      body: {
        if (reason != null) 'reason': reason,
      },
      fromJson: (data) => ContentReportModel.fromJson(data['data'] ?? data),
    );
  }

  // ============ ADMIN MANAGEMENT ============

  /// Get all admins
  Future<ApiResponse<List<AdminUserModel>>> getAdmins() async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/admins',
    );
    return parseListResponse(response, AdminUserModel.fromJson);
  }

  /// Add a new admin
  Future<ApiResponse<AdminUserModel>> addAdmin({
    required String userId,
    required AdminRole role,
    List<String>? permissions,
  }) async {
    return await post<AdminUserModel>(
      '${ApiEndpoints.apiBase}/admin/admins',
      body: {
        'user_id': userId,
        'role': role.name,
        if (permissions != null) 'permissions': permissions,
      },
      fromJson: (data) => AdminUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Update admin role
  Future<ApiResponse<AdminUserModel>> updateAdminRole({
    required String adminId,
    required AdminRole role,
    List<String>? permissions,
  }) async {
    return await put<AdminUserModel>(
      '${ApiEndpoints.apiBase}/admin/admins/$adminId',
      body: {
        'role': role.name,
        if (permissions != null) 'permissions': permissions,
      },
      fromJson: (data) => AdminUserModel.fromJson(data['data'] ?? data),
    );
  }

  /// Remove admin
  Future<ApiResponse<bool>> removeAdmin(String adminId) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/admins/$adminId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  // ============ CHAT MODERATION ============

  /// Get chat conversations for moderation
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatsForModeration({
    int page = 1,
    int limit = 20,
    String? userId,
    String? search,
    bool? hasReports,
    String? sortBy,
    bool descending = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (userId != null) 'user_id': userId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (hasReports != null) 'has_reports': hasReports.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'descending': descending.toString(),
    };

    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats',
      queryParams: queryParams,
    );

    if (!response.success) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    final list = extractList(data);
    return ApiResponse<List<Map<String, dynamic>>>(
      success: true,
      data: list.cast<Map<String, dynamic>>(),
      statusCode: response.statusCode,
    );
  }

  /// Get messages in a specific chat
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats/$chatId/messages',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (!response.success) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    final list = extractList(data);
    return ApiResponse<List<Map<String, dynamic>>>(
      success: true,
      data: list.cast<Map<String, dynamic>>(),
      statusCode: response.statusCode,
    );
  }

  /// Delete a specific message
  Future<ApiResponse<bool>> deleteMessage({
    required String chatId,
    required String messageId,
    required String reason,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats/$chatId/messages/$messageId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Delete entire chat conversation
  Future<ApiResponse<bool>> deleteChat({
    required String chatId,
    required String reason,
    bool notifyParticipants = true,
  }) async {
    final response = await delete<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats/$chatId',
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Export chat log for investigation
  Future<ApiResponse<String>> exportChatLog({
    required String chatId,
    String format = 'json',
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats/$chatId/export',
      queryParams: {'format': format},
    );

    if (!response.success) {
      return ApiResponse<String>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    String? exportUrl;
    if (data is Map<String, dynamic>) {
      exportUrl = data['export_url'] as String?;
    }

    return ApiResponse<String>(
      success: true,
      data: exportUrl ?? '',
      statusCode: response.statusCode,
    );
  }

  /// Warn a user about their chat behavior
  Future<ApiResponse<bool>> sendChatWarning({
    required String userId,
    required String chatId,
    required String message,
    String? messageId,
  }) async {
    final response = await post<dynamic>(
      '${ApiEndpoints.apiBase}/admin/chats/$chatId/warn',
      body: {
        'user_id': userId,
        'message': message,
        if (messageId != null) 'message_id': messageId,
      },
    );
    return ApiResponse<bool>(
      success: response.success,
      data: response.success,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  // ============ SYSTEM SETTINGS ============

  /// Get system settings
  Future<ApiResponse<Map<String, dynamic>>> getSystemSettings() async {
    final response = await get<dynamic>(
      '${ApiEndpoints.apiBase}/admin/settings',
    );

    if (!response.success) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: data['data'] as Map<String, dynamic>? ?? data,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<Map<String, dynamic>>(
      success: true,
      data: <String, dynamic>{},
      statusCode: response.statusCode,
    );
  }

  /// Update system settings
  Future<ApiResponse<Map<String, dynamic>>> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await put<dynamic>(
      '${ApiEndpoints.apiBase}/admin/settings',
      body: settings,
    );

    if (!response.success) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: data['data'] as Map<String, dynamic>? ?? data,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<Map<String, dynamic>>(
      success: true,
      data: <String, dynamic>{},
      statusCode: response.statusCode,
    );
  }
}
