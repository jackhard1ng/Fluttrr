import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/admin_model.dart';
import '../repositories/admin_repository.dart';
import 'profile_controller.dart';

/// Owner/admin emails that have full admin access
/// Add your email here to get admin access without backend setup
const List<String> _ownerEmails = [
  // Add your email(s) here, for example:
  // 'your-email@example.com',
  // 'another-admin@example.com',
];

/// Controller for admin panel operations
class AdminController extends GetxController {
  final AdminRepository _repository = AdminRepository();

  // Current admin user
  final Rx<AdminUserModel?> currentAdmin = Rx<AdminUserModel?>(null);

  // Dashboard stats
  final Rx<AdminStatsModel?> stats = Rx<AdminStatsModel?>(null);

  // Lists
  final RxList<ManagedBusinessModel> businesses = <ManagedBusinessModel>[].obs;
  final RxList<ManagedEventModel> events = <ManagedEventModel>[].obs;
  final RxList<ManagedUserModel> users = <ManagedUserModel>[].obs;
  final RxList<ContentReportModel> reports = <ContentReportModel>[].obs;
  final RxList<AdminActionLogModel> actionLogs = <AdminActionLogModel>[].obs;
  final RxList<AdminUserModel> admins = <AdminUserModel>[].obs;

  // Selected items
  final Rx<ManagedBusinessModel?> selectedBusiness = Rx<ManagedBusinessModel?>(null);
  final Rx<ManagedEventModel?> selectedEvent = Rx<ManagedEventModel?>(null);
  final Rx<ManagedUserModel?> selectedUser = Rx<ManagedUserModel?>(null);
  final Rx<ContentReportModel?> selectedReport = Rx<ContentReportModel?>(null);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingBusinesses = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingReports = false.obs;
  final RxBool isProcessing = false.obs;

  // Pagination
  final RxInt businessPage = 1.obs;
  final RxInt eventPage = 1.obs;
  final RxInt userPage = 1.obs;
  final RxInt reportPage = 1.obs;
  final RxBool hasMoreBusinesses = true.obs;
  final RxBool hasMoreEvents = true.obs;
  final RxBool hasMoreUsers = true.obs;
  final RxBool hasMoreReports = true.obs;

  // Filters
  final Rx<BusinessVerificationStatus?> businessFilter = Rx<BusinessVerificationStatus?>(null);
  final Rx<ContentStatus?> eventFilter = Rx<ContentStatus?>(null);
  final Rx<UserAccountStatus?> userFilter = Rx<UserAccountStatus?>(null);
  final Rx<ReportStatus?> reportFilter = Rx<ReportStatus?>(null);
  final RxString searchQuery = ''.obs;

  // Messages
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAdminStatus();
  }

  /// Check if current user is an admin
  Future<bool> checkAdminStatus() async {
    isLoading.value = true;
    try {
      // First check if user's email is in the owner list (for quick setup without backend)
      if (_checkEmailBasedAccess()) {
        return true;
      }

      // Otherwise, check with the backend
      final response = await _repository.checkAdminStatus();
      if (response.success && response.data != null) {
        currentAdmin.value = response.data;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      // If backend fails, still allow email-based access
      return _checkEmailBasedAccess();
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current user's email is in the owner/admin list
  bool _checkEmailBasedAccess() {
    try {
      final profileController = Get.find<ProfileController>();
      final userEmail = profileController.currentUser.value?.email?.toLowerCase();

      if (userEmail != null && _ownerEmails.any((e) => e.toLowerCase() == userEmail)) {
        // Create an owner admin model for this user
        currentAdmin.value = AdminUserModel(
          adminId: 'local_owner',
          userId: profileController.currentUser.value?.id?.toString() ?? 'owner',
          name: profileController.currentUser.value?.userName ?? 'Owner',
          email: userEmail,
          role: AdminRole.owner,
          permissions: ['all'], // Full permissions
          isActive: true,
          createdAt: DateTime.now(),
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error checking email-based access: $e');
    }
    return false;
  }

  /// Check if user has admin access
  bool get isAdmin => currentAdmin.value != null;
  bool get isOwner => currentAdmin.value?.isOwner ?? false;
  bool get isSuperAdmin => currentAdmin.value?.isSuperAdmin ?? false;
  bool get canManageBusinesses => currentAdmin.value?.canManageBusinesses ?? false;
  bool get canManageUsers => currentAdmin.value?.canManageUsers ?? false;
  bool get canViewAnalytics => currentAdmin.value?.canViewAnalytics ?? false;

  /// Load dashboard stats
  Future<void> loadDashboardStats() async {
    isLoadingStats.value = true;
    try {
      final response = await _repository.getDashboardStats();
      if (response.success && response.data != null) {
        stats.value = response.data;
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Refresh all dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      loadDashboardStats(),
      loadReports(refresh: true),
    ]);
  }

  // ============ BUSINESS MANAGEMENT ============

  /// Load businesses
  Future<void> loadBusinesses({bool refresh = false}) async {
    if (refresh) {
      businessPage.value = 1;
      hasMoreBusinesses.value = true;
    }

    if (!hasMoreBusinesses.value && !refresh) return;

    isLoadingBusinesses.value = true;
    try {
      final response = await _repository.getBusinesses(
        page: businessPage.value,
        status: businessFilter.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          businesses.value = response.data!;
        } else {
          businesses.addAll(response.data!);
        }
        hasMoreBusinesses.value = response.data!.length >= 20;
        businessPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading businesses: $e');
    } finally {
      isLoadingBusinesses.value = false;
    }
  }

  /// Verify a business
  Future<bool> verifyBusiness(String businessId, {bool approve = true, String? reason}) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.verifyBusiness(
        businessId: businessId,
        approve: approve,
        rejectionReason: reason,
      );

      if (response.success && response.data != null) {
        final index = businesses.indexWhere((b) => b.businessId == businessId);
        if (index != -1) {
          businesses[index] = response.data!;
        }
        successMessage.value = approve ? 'Business verified' : 'Business verification rejected';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to verify business';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to verify business';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Suspend a business
  Future<bool> suspendBusiness(String businessId, {required String reason, int? durationDays}) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.suspendBusiness(
        businessId: businessId,
        reason: reason,
        durationDays: durationDays,
      );

      if (response.success && response.data != null) {
        final index = businesses.indexWhere((b) => b.businessId == businessId);
        if (index != -1) {
          businesses[index] = response.data!;
        }
        successMessage.value = 'Business suspended';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to suspend business';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to suspend business';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Unsuspend a business
  Future<bool> unsuspendBusiness(String businessId) async {
    isProcessing.value = true;
    try {
      final response = await _repository.unsuspendBusiness(businessId);
      if (response.success && response.data != null) {
        final index = businesses.indexWhere((b) => b.businessId == businessId);
        if (index != -1) {
          businesses[index] = response.data!;
        }
        successMessage.value = 'Business unsuspended';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to unsuspend business';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete a business
  Future<bool> deleteBusiness(String businessId, {required String reason}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.deleteBusiness(
        businessId: businessId,
        reason: reason,
      );
      if (response.success) {
        businesses.removeWhere((b) => b.businessId == businessId);
        successMessage.value = 'Business deleted';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete business';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Toggle business featured status
  Future<bool> toggleBusinessFeatured(String businessId) async {
    try {
      final response = await _repository.toggleBusinessFeatured(businessId);
      if (response.success && response.data != null) {
        final index = businesses.indexWhere((b) => b.businessId == businessId);
        if (index != -1) {
          businesses[index] = response.data!;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Create a new business
  Future<bool> createBusiness({
    required String name,
    required String email,
    String? phone,
    String? description,
    bool autoVerify = false,
  }) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.createBusiness(
        name: name,
        email: email,
        phone: phone,
        description: description,
        autoVerify: autoVerify,
      );

      if (response.success && response.data != null) {
        businesses.insert(0, response.data!);
        successMessage.value = 'Business created successfully';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create business';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create business';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============ EVENT MANAGEMENT ============

  /// Load events
  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh) {
      eventPage.value = 1;
      hasMoreEvents.value = true;
    }

    if (!hasMoreEvents.value && !refresh) return;

    isLoadingEvents.value = true;
    try {
      final response = await _repository.getEvents(
        page: eventPage.value,
        status: eventFilter.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          events.value = response.data!;
        } else {
          events.addAll(response.data!);
        }
        hasMoreEvents.value = response.data!.length >= 20;
        eventPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// Approve an event
  Future<bool> approveEvent(String eventId) async {
    isProcessing.value = true;
    try {
      final response = await _repository.approveEvent(eventId);
      if (response.success && response.data != null) {
        final index = events.indexWhere((e) => e.eventId == eventId);
        if (index != -1) {
          events[index] = response.data!;
        }
        successMessage.value = 'Event approved';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to approve event';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Reject an event
  Future<bool> rejectEvent(String eventId, {required String reason}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.rejectEvent(
        eventId: eventId,
        reason: reason,
      );
      if (response.success && response.data != null) {
        final index = events.indexWhere((e) => e.eventId == eventId);
        if (index != -1) {
          events[index] = response.data!;
        }
        successMessage.value = 'Event rejected';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to reject event';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Remove an event
  Future<bool> removeEvent(String eventId, {required String reason, bool notifyAttendees = true}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.removeEvent(
        eventId: eventId,
        reason: reason,
        notifyAttendees: notifyAttendees,
      );
      if (response.success) {
        events.removeWhere((e) => e.eventId == eventId);
        successMessage.value = 'Event removed';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to remove event';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Toggle event featured status
  Future<bool> toggleEventFeatured(String eventId) async {
    try {
      final response = await _repository.toggleEventFeatured(eventId);
      if (response.success && response.data != null) {
        final index = events.indexWhere((e) => e.eventId == eventId);
        if (index != -1) {
          events[index] = response.data!;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Create an event
  Future<bool> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    DateTime? endDate,
    String? businessId,
    int? maxAttendees,
  }) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.createEvent(
        title: title,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        businessId: businessId,
        maxAttendees: maxAttendees,
      );

      if (response.success && response.data != null) {
        events.insert(0, response.data!);
        successMessage.value = 'Event created successfully';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create event';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create event';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============ USER MANAGEMENT ============

  /// Load users
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      userPage.value = 1;
      hasMoreUsers.value = true;
    }

    if (!hasMoreUsers.value && !refresh) return;

    isLoadingUsers.value = true;
    try {
      final response = await _repository.getUsers(
        page: userPage.value,
        status: userFilter.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          users.value = response.data!;
        } else {
          users.addAll(response.data!);
        }
        hasMoreUsers.value = response.data!.length >= 20;
        userPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Suspend a user
  Future<bool> suspendUser(String userId, {required String reason, int? durationDays}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.suspendUser(
        userId: userId,
        reason: reason,
        durationDays: durationDays,
      );
      if (response.success && response.data != null) {
        final index = users.indexWhere((u) => u.userId == userId);
        if (index != -1) {
          users[index] = response.data!;
        }
        successMessage.value = 'User suspended';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to suspend user';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Unsuspend a user
  Future<bool> unsuspendUser(String userId) async {
    isProcessing.value = true;
    try {
      final response = await _repository.unsuspendUser(userId);
      if (response.success && response.data != null) {
        final index = users.indexWhere((u) => u.userId == userId);
        if (index != -1) {
          users[index] = response.data!;
        }
        successMessage.value = 'User unsuspended';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to unsuspend user';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Ban a user
  Future<bool> banUser(String userId, {required String reason}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.banUser(
        userId: userId,
        reason: reason,
      );
      if (response.success && response.data != null) {
        final index = users.indexWhere((u) => u.userId == userId);
        if (index != -1) {
          users[index] = response.data!;
        }
        successMessage.value = 'User banned';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to ban user';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Unban a user
  Future<bool> unbanUser(String userId) async {
    isProcessing.value = true;
    try {
      final response = await _repository.unbanUser(userId);
      if (response.success && response.data != null) {
        final index = users.indexWhere((u) => u.userId == userId);
        if (index != -1) {
          users[index] = response.data!;
        }
        successMessage.value = 'User unbanned';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to unban user';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Send warning to user
  Future<bool> warnUser(String userId, {required String message}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.sendWarning(
        userId: userId,
        message: message,
      );
      if (response.success) {
        successMessage.value = 'Warning sent to user';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to send warning';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String userId, {required String reason}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.deleteUser(
        userId: userId,
        reason: reason,
      );
      if (response.success) {
        users.removeWhere((u) => u.userId == userId);
        successMessage.value = 'User deleted';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete user';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============ REPORTS MANAGEMENT ============

  /// Load reports
  Future<void> loadReports({bool refresh = false}) async {
    if (refresh) {
      reportPage.value = 1;
      hasMoreReports.value = true;
    }

    if (!hasMoreReports.value && !refresh) return;

    isLoadingReports.value = true;
    try {
      final response = await _repository.getReports(
        page: reportPage.value,
        status: reportFilter.value,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          reports.value = response.data!;
        } else {
          reports.addAll(response.data!);
        }
        hasMoreReports.value = response.data!.length >= 20;
        reportPage.value++;
      }
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      isLoadingReports.value = false;
    }
  }

  /// Resolve a report
  Future<bool> resolveReport(String reportId, {required String resolution, String? actionTaken}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.resolveReport(
        reportId: reportId,
        resolution: resolution,
        actionTaken: actionTaken,
      );
      if (response.success && response.data != null) {
        final index = reports.indexWhere((r) => r.reportId == reportId);
        if (index != -1) {
          reports[index] = response.data!;
        }
        successMessage.value = 'Report resolved';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to resolve report';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Dismiss a report
  Future<bool> dismissReport(String reportId, {String? reason}) async {
    isProcessing.value = true;
    try {
      final response = await _repository.dismissReport(
        reportId: reportId,
        reason: reason,
      );
      if (response.success && response.data != null) {
        final index = reports.indexWhere((r) => r.reportId == reportId);
        if (index != -1) {
          reports[index] = response.data!;
        }
        successMessage.value = 'Report dismissed';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to dismiss report';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============ ADMIN MANAGEMENT ============

  /// Load admins
  Future<void> loadAdmins() async {
    if (!isSuperAdmin) return;

    try {
      final response = await _repository.getAdmins();
      if (response.success && response.data != null) {
        admins.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading admins: $e');
    }
  }

  /// Add a new admin
  Future<bool> addAdmin(String userId, AdminRole role, {List<String>? permissions}) async {
    if (!isSuperAdmin) return false;

    isProcessing.value = true;
    try {
      final response = await _repository.addAdmin(
        userId: userId,
        role: role,
        permissions: permissions,
      );
      if (response.success && response.data != null) {
        admins.add(response.data!);
        successMessage.value = 'Admin added';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to add admin';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Remove an admin
  Future<bool> removeAdmin(String adminId) async {
    if (!isSuperAdmin) return false;

    isProcessing.value = true;
    try {
      final response = await _repository.removeAdmin(adminId);
      if (response.success) {
        admins.removeWhere((a) => a.adminId == adminId);
        successMessage.value = 'Admin removed';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to remove admin';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============ HELPERS ============

  /// Search across entities
  void search(String query) {
    searchQuery.value = query;
  }

  /// Clear filters
  void clearFilters() {
    businessFilter.value = null;
    eventFilter.value = null;
    userFilter.value = null;
    reportFilter.value = null;
    searchQuery.value = '';
  }

  /// Get pending counts for badges
  int get pendingVerificationsCount =>
      businesses.where((b) => b.hasPendingVerification).length;

  int get pendingReportsCount =>
      reports.where((r) => r.isPending).length;

  int get flaggedEventsCount =>
      events.where((e) => e.isFlagged).length;

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
