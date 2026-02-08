import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

/// Activity controller for managing activities/events
class ActivityController extends GetxController {
  final ActivityRepository _activityRepository = ActivityRepository();

  // State
  final RxList<ActivityModel> dailyActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> allActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> myActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> joinedActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> upcomingActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> searchResults = <ActivityModel>[].obs;

  final Rx<ActivityModel?> selectedActivity = Rx<ActivityModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isJoining = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;
  static const int pageSize = 20;
  static const int maxPageSize = 100;

  // Concurrent request prevention
  bool _isCreatingActivity = false;
  String? _lastCreateRequestHash;

  // Create activity form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController slotsController = TextEditingController();

  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxString selectedEventType = ''.obs;
  final RxDouble selectedLatitude = 0.0.obs;
  final RxDouble selectedLongitude = 0.0.obs;
  final RxList<File> selectedImages = <File>[].obs;

  // Filter state
  final RxString filterEventType = ''.obs;
  final Rx<DateTime?> filterStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> filterEndDate = Rx<DateTime?>(null);
  final RxDouble filterRadius = 50.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    slotsController.dispose();
    super.onClose();
  }

  /// Load initial data with proper error handling (#88)
  Future<void> loadInitialData() async {
    // Use eagerError: false so all operations complete even if one fails
    await Future.wait(
      [
        loadDailyActivities(),
        loadActivities(),
      ],
      eagerError: false,
    );
  }

  /// Load daily activities
  Future<void> loadDailyActivities() async {
    try {
      final response = await _activityRepository.getDailyActivities();
      if (response.success && response.data != null) {
        dailyActivities.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading daily activities: $e');
    }
  }

  /// Load all activities with pagination
  Future<void> loadActivities({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      allActivities.clear();
    }

    if (!hasMorePages.value) return;

    isLoading.value = allActivities.isEmpty;
    isLoadingMore.value = allActivities.isNotEmpty;
    errorMessage.value = '';

    try {
      final response = await _activityRepository.getActivities(
        page: currentPage.value,
        limit: pageSize,
        eventType: filterEventType.value.isNotEmpty ? filterEventType.value : null,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          allActivities.value = response.data!;
        } else {
          allActivities.addAll(response.data!);
        }

        hasMorePages.value = response.data!.length >= pageSize;
        if (hasMorePages.value) {
          currentPage.value++;
        }
      } else {
        if (allActivities.isEmpty) {
          errorMessage.value = response.displayMessage;
        }
        hasMorePages.value = false;
      }
    } catch (e) {
      if (allActivities.isEmpty) {
        errorMessage.value = 'Failed to load activities. Please try again.';
      }
      debugPrint('Error loading activities: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more activities (pagination)
  Future<void> loadMoreActivities() async {
    if (isLoadingMore.value || !hasMorePages.value) return;
    await loadActivities();
  }

  /// Load my activities
  Future<void> loadMyActivities() async {
    try {
      final response = await _activityRepository.getMyActivities();
      if (response.success && response.data != null) {
        myActivities.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading my activities: $e');
    }
  }

  /// Load joined activities
  Future<void> loadJoinedActivities() async {
    try {
      final response = await _activityRepository.getJoinedActivities();
      if (response.success && response.data != null) {
        joinedActivities.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading joined activities: $e');
    }
  }

  /// Load upcoming activities
  Future<void> loadUpcomingActivities() async {
    try {
      final response = await _activityRepository.getUpcomingActivities();
      if (response.success && response.data != null) {
        upcomingActivities.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading upcoming activities: $e');
    }
  }

  /// Get activity details
  Future<void> loadActivityDetails(int activityId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _activityRepository.getActivityDetails(activityId);
      if (response.success && response.data != null) {
        selectedActivity.value = response.data;
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load activity details';
    } finally {
      isLoading.value = false;
    }
  }

  /// Search activities
  Future<void> searchActivities(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    try {
      final response = await _activityRepository.searchActivities(
        query: query,
        eventType: filterEventType.value.isNotEmpty ? filterEventType.value : null,
        startDate: filterStartDate.value,
        endDate: filterEndDate.value,
      );

      if (response.success && response.data != null) {
        searchResults.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error searching activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create activity with concurrent request prevention (#60)
  Future<bool> createActivity() async {
    if (!_validateCreateForm()) return false;

    // Generate hash from activity data to detect duplicate submissions
    final requestHash = _generateCreateRequestHash();

    // Prevent concurrent or duplicate requests
    if (_isCreatingActivity) {
      debugPrint('ActivityController: Create activity request already in progress');
      return false;
    }

    if (_lastCreateRequestHash == requestHash) {
      debugPrint('ActivityController: Duplicate create request detected');
      errorMessage.value = 'Activity already submitted. Please wait.';
      return false;
    }

    _isCreatingActivity = true;
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _activityRepository.createActivity(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        latitude: selectedLatitude.value,
        longitude: selectedLongitude.value,
        dateTime: selectedDateTime.value!,
        eventType: selectedEventType.value,
        totalSlots: int.tryParse(slotsController.text) ?? 0,
        images: selectedImages.isNotEmpty ? selectedImages : null,
      );

      if (response.success) {
        _lastCreateRequestHash = requestHash;
        _clearCreateForm();
        await loadMyActivities();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create activity';
      return false;
    } finally {
      _isCreatingActivity = false;
      isCreating.value = false;
    }
  }

  /// Generate hash from create activity form data for deduplication (#60)
  String _generateCreateRequestHash() {
    return '${nameController.text.trim()}_${selectedDateTime.value?.toIso8601String()}_${selectedLatitude.value}_${selectedLongitude.value}';
  }

  /// Update activity
  Future<bool> updateActivity(int activityId) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _activityRepository.updateActivity(
        activityId: activityId,
        name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        latitude: selectedLatitude.value != 0 ? selectedLatitude.value : null,
        longitude: selectedLongitude.value != 0 ? selectedLongitude.value : null,
        dateTime: selectedDateTime.value,
        eventType: selectedEventType.value.isNotEmpty ? selectedEventType.value : null,
        totalSlots: slotsController.text.isNotEmpty ? int.tryParse(slotsController.text) : null,
      );

      isCreating.value = false;

      if (response.success) {
        _clearCreateForm();
        await loadMyActivities();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Failed to update activity';
      return false;
    }
  }

  /// Delete activity with error message (#78)
  Future<bool> deleteActivity(int activityId) async {
    try {
      final response = await _activityRepository.deleteActivity(activityId);

      if (response.success) {
        myActivities.removeWhere((a) => a.activityId == activityId);
        allActivities.removeWhere((a) => a.activityId == activityId);
        return true;
      }
      errorMessage.value = response.displayMessage;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete activity. Please try again.';
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }

  /// Join activity
  Future<bool> joinActivity(int activityId) async {
    isJoining.value = true;

    try {
      final response = await _activityRepository.joinActivity(activityId);

      isJoining.value = false;

      if (response.success) {
        _updateActivityJoinStatus(activityId, true);
        return true;
      }
      return false;
    } catch (e) {
      isJoining.value = false;
      return false;
    }
  }

  /// Leave activity
  Future<bool> leaveActivity(int activityId) async {
    isJoining.value = true;

    try {
      final response = await _activityRepository.leaveActivity(activityId);

      isJoining.value = false;

      if (response.success) {
        _updateActivityJoinStatus(activityId, false);
        return true;
      }
      return false;
    } catch (e) {
      isJoining.value = false;
      return false;
    }
  }

  /// Toggle save activity
  Future<bool> toggleSaveActivity(int activityId) async {
    try {
      final response = await _activityRepository.toggleSaveActivity(activityId);

      if (response.success) {
        _updateActivitySaveStatus(activityId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update activity join status in lists with bounds checking
  void _updateActivityJoinStatus(int activityId, bool joined) {
    void updateList(RxList<ActivityModel> list) {
      final index = list.indexWhere((a) => a.activityId == activityId);
      // Double-check bounds to prevent race conditions with reactive lists
      if (index != -1 && index < list.length) {
        list[index] = list[index].copyWith(userJoined: joined);
      }
    }

    updateList(allActivities);
    updateList(dailyActivities);
    updateList(searchResults);

    if (selectedActivity.value?.activityId == activityId) {
      selectedActivity.value = selectedActivity.value?.copyWith(userJoined: joined);
    }

    if (joined) {
      loadJoinedActivities();
    } else {
      joinedActivities.removeWhere((a) => a.activityId == activityId);
    }
  }

  /// Update activity save status in lists with bounds checking
  void _updateActivitySaveStatus(int activityId) {
    void updateList(RxList<ActivityModel> list) {
      final index = list.indexWhere((a) => a.activityId == activityId);
      // Double-check bounds to prevent race conditions with reactive lists
      if (index != -1 && index < list.length) {
        final activity = list[index];
        list[index] = activity.copyWith(userSaved: !activity.userSaved);
      }
    }

    updateList(allActivities);
    updateList(dailyActivities);
    updateList(searchResults);

    if (selectedActivity.value?.activityId == activityId) {
      selectedActivity.value = selectedActivity.value?.copyWith(
        userSaved: !(selectedActivity.value?.userSaved ?? false),
      );
    }
  }

  /// Validate create form
  bool _validateCreateForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter an activity name';
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a description';
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a location';
      return false;
    }
    if (selectedDateTime.value == null) {
      errorMessage.value = 'Please select a date and time';
      return false;
    }
    if (selectedEventType.value.isEmpty) {
      errorMessage.value = 'Please select an event type';
      return false;
    }
    // Slots can be 0 for unlimited, or a positive number for limited
    final slots = int.tryParse(slotsController.text);
    if (slotsController.text.isNotEmpty && slots == null) {
      errorMessage.value = 'Please enter a valid number of slots';
      return false;
    }
    // If slots is provided and > 0, it's a limited event
    // If slots is 0 or empty, it's unlimited
    return true;
  }

  /// Clear create form
  void _clearCreateForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    slotsController.clear();
    selectedDateTime.value = null;
    selectedEventType.value = '';
    selectedLatitude.value = 0;
    selectedLongitude.value = 0;
    selectedImages.clear();
  }

  /// Set activity for editing
  void setActivityForEditing(ActivityModel activity) {
    nameController.text = activity.name ?? '';
    descriptionController.text = activity.description ?? '';
    locationController.text = activity.location ?? '';
    slotsController.text = activity.totalSlots?.toString() ?? '';
    selectedDateTime.value = activity.dateTime;
    selectedEventType.value = activity.eventType ?? '';
    selectedLatitude.value = activity.latitude ?? 0;
    selectedLongitude.value = activity.longitude ?? 0;
  }

  /// Apply filters
  void applyFilters({
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    double? radius,
  }) {
    if (eventType != null) filterEventType.value = eventType;
    if (startDate != null) filterStartDate.value = startDate;
    if (endDate != null) filterEndDate.value = endDate;
    if (radius != null) filterRadius.value = radius;

    loadActivities(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    filterEventType.value = '';
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterRadius.value = 50.0;

    loadActivities(refresh: true);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadInitialData();
  }
}
