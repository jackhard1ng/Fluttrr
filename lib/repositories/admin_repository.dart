import '../models/admin_model.dart';
import 'base_repository.dart';

/// Repository for admin operations
class AdminRepository extends BaseRepository {
  /// Check if current user is an admin
  Future<ApiResponse<AdminUserModel>> checkAdminStatus() async {
    return makeRequest(
      () => api.get('/admin/status'),
      (data) => AdminUserModel.fromJson(data),
    );
  }

  /// Get dashboard statistics
  Future<ApiResponse<AdminStatsModel>> getDashboardStats() async {
    return makeRequest(
      () => api.get('/admin/stats'),
      (data) => AdminStatsModel.fromJson(data),
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
    return makeRequest(
      () => api.get('/admin/logs', queryParameters: {
        'page': page,
        'limit': limit,
        if (adminId != null) 'admin_id': adminId,
        if (entityType != null) 'entity_type': entityType.name,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      }),
      (data) => (data as List)
          .map((e) => AdminActionLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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
    return makeRequest(
      () => api.get('/admin/businesses', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
        if (search != null && search.isNotEmpty) 'search': search,
        if (hasReports != null) 'has_reports': hasReports,
        if (sortBy != null) 'sort_by': sortBy,
        'descending': descending,
      }),
      (data) => (data as List)
          .map((e) => ManagedBusinessModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get business details
  Future<ApiResponse<ManagedBusinessModel>> getBusinessDetails(String businessId) async {
    return makeRequest(
      () => api.get('/admin/businesses/$businessId'),
      (data) => ManagedBusinessModel.fromJson(data),
    );
  }

  /// Verify a business
  Future<ApiResponse<ManagedBusinessModel>> verifyBusiness({
    required String businessId,
    bool approve = true,
    String? rejectionReason,
  }) async {
    return makeRequest(
      () => api.post('/admin/businesses/$businessId/verify', data: {
        'approved': approve,
        if (!approve && rejectionReason != null) 'reason': rejectionReason,
      }),
      (data) => ManagedBusinessModel.fromJson(data),
    );
  }

  /// Suspend a business
  Future<ApiResponse<ManagedBusinessModel>> suspendBusiness({
    required String businessId,
    required String reason,
    int? durationDays,
  }) async {
    return makeRequest(
      () => api.post('/admin/businesses/$businessId/suspend', data: {
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
      }),
      (data) => ManagedBusinessModel.fromJson(data),
    );
  }

  /// Unsuspend a business
  Future<ApiResponse<ManagedBusinessModel>> unsuspendBusiness(String businessId) async {
    return makeRequest(
      () => api.post('/admin/businesses/$businessId/unsuspend'),
      (data) => ManagedBusinessModel.fromJson(data),
    );
  }

  /// Delete a business
  Future<ApiResponse<bool>> deleteBusiness({
    required String businessId,
    required String reason,
  }) async {
    return makeRequest(
      () => api.delete('/admin/businesses/$businessId', data: {
        'reason': reason,
      }),
      (data) => true,
    );
  }

  /// Toggle business featured status
  Future<ApiResponse<ManagedBusinessModel>> toggleBusinessFeatured(String businessId) async {
    return makeRequest(
      () => api.post('/admin/businesses/$businessId/toggle-featured'),
      (data) => ManagedBusinessModel.fromJson(data),
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
    return makeRequest(
      () => api.post('/admin/businesses', data: {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (description != null) 'description': description,
        if (ownerId != null) 'owner_id': ownerId,
        'auto_verify': autoVerify,
      }),
      (data) => ManagedBusinessModel.fromJson(data),
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
    return makeRequest(
      () => api.get('/admin/events', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
        if (search != null && search.isNotEmpty) 'search': search,
        if (businessId != null) 'business_id': businessId,
        if (hasReports != null) 'has_reports': hasReports,
        if (isPast != null) 'is_past': isPast,
        if (sortBy != null) 'sort_by': sortBy,
        'descending': descending,
      }),
      (data) => (data as List)
          .map((e) => ManagedEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get event details
  Future<ApiResponse<ManagedEventModel>> getEventDetails(String eventId) async {
    return makeRequest(
      () => api.get('/admin/events/$eventId'),
      (data) => ManagedEventModel.fromJson(data),
    );
  }

  /// Approve an event
  Future<ApiResponse<ManagedEventModel>> approveEvent(String eventId) async {
    return makeRequest(
      () => api.post('/admin/events/$eventId/approve'),
      (data) => ManagedEventModel.fromJson(data),
    );
  }

  /// Reject an event
  Future<ApiResponse<ManagedEventModel>> rejectEvent({
    required String eventId,
    required String reason,
  }) async {
    return makeRequest(
      () => api.post('/admin/events/$eventId/reject', data: {
        'reason': reason,
      }),
      (data) => ManagedEventModel.fromJson(data),
    );
  }

  /// Remove an event
  Future<ApiResponse<bool>> removeEvent({
    required String eventId,
    required String reason,
    bool notifyAttendees = true,
  }) async {
    return makeRequest(
      () => api.delete('/admin/events/$eventId', data: {
        'reason': reason,
        'notify_attendees': notifyAttendees,
      }),
      (data) => true,
    );
  }

  /// Toggle event featured status
  Future<ApiResponse<ManagedEventModel>> toggleEventFeatured(String eventId) async {
    return makeRequest(
      () => api.post('/admin/events/$eventId/toggle-featured'),
      (data) => ManagedEventModel.fromJson(data),
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
    return makeRequest(
      () => api.post('/admin/events', data: {
        'title': title,
        'description': description,
        'location': location,
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (businessId != null) 'business_id': businessId,
        if (maxAttendees != null) 'max_attendees': maxAttendees,
      }),
      (data) => ManagedEventModel.fromJson(data),
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
    return makeRequest(
      () => api.get('/admin/users', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isBusinessOwner != null) 'is_business_owner': isBusinessOwner,
        if (hasReports != null) 'has_reports': hasReports,
        if (sortBy != null) 'sort_by': sortBy,
        'descending': descending,
      }),
      (data) => (data as List)
          .map((e) => ManagedUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get user details
  Future<ApiResponse<ManagedUserModel>> getUserDetails(String userId) async {
    return makeRequest(
      () => api.get('/admin/users/$userId'),
      (data) => ManagedUserModel.fromJson(data),
    );
  }

  /// Suspend a user
  Future<ApiResponse<ManagedUserModel>> suspendUser({
    required String userId,
    required String reason,
    int? durationDays,
  }) async {
    return makeRequest(
      () => api.post('/admin/users/$userId/suspend', data: {
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
      }),
      (data) => ManagedUserModel.fromJson(data),
    );
  }

  /// Unsuspend a user
  Future<ApiResponse<ManagedUserModel>> unsuspendUser(String userId) async {
    return makeRequest(
      () => api.post('/admin/users/$userId/unsuspend'),
      (data) => ManagedUserModel.fromJson(data),
    );
  }

  /// Ban a user
  Future<ApiResponse<ManagedUserModel>> banUser({
    required String userId,
    required String reason,
  }) async {
    return makeRequest(
      () => api.post('/admin/users/$userId/ban', data: {
        'reason': reason,
      }),
      (data) => ManagedUserModel.fromJson(data),
    );
  }

  /// Unban a user
  Future<ApiResponse<ManagedUserModel>> unbanUser(String userId) async {
    return makeRequest(
      () => api.post('/admin/users/$userId/unban'),
      (data) => ManagedUserModel.fromJson(data),
    );
  }

  /// Send warning to user
  Future<ApiResponse<bool>> sendWarning({
    required String userId,
    required String message,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    return makeRequest(
      () => api.post('/admin/users/$userId/warn', data: {
        'message': message,
        if (relatedEntityType != null) 'entity_type': relatedEntityType,
        if (relatedEntityId != null) 'entity_id': relatedEntityId,
      }),
      (data) => true,
    );
  }

  /// Delete a user account
  Future<ApiResponse<bool>> deleteUser({
    required String userId,
    required String reason,
  }) async {
    return makeRequest(
      () => api.delete('/admin/users/$userId', data: {
        'reason': reason,
      }),
      (data) => true,
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
    return makeRequest(
      () => api.get('/admin/reports', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
        if (type != null) 'type': type.name,
        if (entityType != null) 'entity_type': entityType.name,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (sortBy != null) 'sort_by': sortBy,
        'descending': descending,
      }),
      (data) => (data as List)
          .map((e) => ContentReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get report details
  Future<ApiResponse<ContentReportModel>> getReportDetails(String reportId) async {
    return makeRequest(
      () => api.get('/admin/reports/$reportId'),
      (data) => ContentReportModel.fromJson(data),
    );
  }

  /// Assign report to admin
  Future<ApiResponse<ContentReportModel>> assignReport({
    required String reportId,
    required String adminId,
  }) async {
    return makeRequest(
      () => api.post('/admin/reports/$reportId/assign', data: {
        'admin_id': adminId,
      }),
      (data) => ContentReportModel.fromJson(data),
    );
  }

  /// Resolve a report
  Future<ApiResponse<ContentReportModel>> resolveReport({
    required String reportId,
    required String resolution,
    String? actionTaken,
  }) async {
    return makeRequest(
      () => api.post('/admin/reports/$reportId/resolve', data: {
        'resolution': resolution,
        if (actionTaken != null) 'action_taken': actionTaken,
      }),
      (data) => ContentReportModel.fromJson(data),
    );
  }

  /// Dismiss a report
  Future<ApiResponse<ContentReportModel>> dismissReport({
    required String reportId,
    String? reason,
  }) async {
    return makeRequest(
      () => api.post('/admin/reports/$reportId/dismiss', data: {
        if (reason != null) 'reason': reason,
      }),
      (data) => ContentReportModel.fromJson(data),
    );
  }

  // ============ ADMIN MANAGEMENT ============

  /// Get all admins
  Future<ApiResponse<List<AdminUserModel>>> getAdmins() async {
    return makeRequest(
      () => api.get('/admin/admins'),
      (data) => (data as List)
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Add a new admin
  Future<ApiResponse<AdminUserModel>> addAdmin({
    required String userId,
    required AdminRole role,
    List<String>? permissions,
  }) async {
    return makeRequest(
      () => api.post('/admin/admins', data: {
        'user_id': userId,
        'role': role.name,
        if (permissions != null) 'permissions': permissions,
      }),
      (data) => AdminUserModel.fromJson(data),
    );
  }

  /// Update admin role
  Future<ApiResponse<AdminUserModel>> updateAdminRole({
    required String adminId,
    required AdminRole role,
    List<String>? permissions,
  }) async {
    return makeRequest(
      () => api.put('/admin/admins/$adminId', data: {
        'role': role.name,
        if (permissions != null) 'permissions': permissions,
      }),
      (data) => AdminUserModel.fromJson(data),
    );
  }

  /// Remove admin
  Future<ApiResponse<bool>> removeAdmin(String adminId) async {
    return makeRequest(
      () => api.delete('/admin/admins/$adminId'),
      (data) => true,
    );
  }

  // ============ SYSTEM SETTINGS ============

  /// Get system settings
  Future<ApiResponse<Map<String, dynamic>>> getSystemSettings() async {
    return makeRequest(
      () => api.get('/admin/settings'),
      (data) => data as Map<String, dynamic>,
    );
  }

  /// Update system settings
  Future<ApiResponse<Map<String, dynamic>>> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    return makeRequest(
      () => api.put('/admin/settings', data: settings),
      (data) => data as Map<String, dynamic>,
    );
  }
}
