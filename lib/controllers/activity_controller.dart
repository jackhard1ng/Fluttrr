import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';
import '../services/mock_data_service.dart';

/// Activity controller with mock data fallback
class ActivityController extends GetxController {
  final ActivityRepository _activityRepository = ActivityRepository();

  /// Flag to use mock data when API fails
  final RxBool useMockData = true.obs;

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

  /// Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadDailyActivities(),
      loadActivities(),
    ]);
  }

  /// Load daily activities (with mock data fallback)
  Future<void> loadDailyActivities() async {
    try {
      final response = await _activityRepository.getDailyActivities();
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        dailyActivities.value = response.data!;
        useMockData.value = false;
      } else {
        _loadMockDailyActivities();
      }
    } catch (e) {
      _loadMockDailyActivities();
    }
  }

  /// Load mock daily activities for demo
  void _loadMockDailyActivities() {
    useMockData.value = true;
    final mockData = MockDataService.generateMockActivities(5);
    dailyActivities.value = _convertMockToActivities(mockData);
  }

  /// Convert mock data to ActivityModel list
  List<ActivityModel> _convertMockToActivities(List<Map<String, dynamic>> mockData) {
    return mockData.map((data) {
      final host = MockDataService.generateMockUser();
      return ActivityModel(
        activityId: data['activityId'] as int,
        name: data['name'] as String,
        description: data['description'] as String,
        location: data['location'] as String,
        dateTime: DateTime.tryParse(data['date'] as String),
        eventType: data['eventType'] as String,
        images: [],
        totalSlots: data['maxAttendees'] as int,
        remainingSlots: (data['maxAttendees'] as int) - (data['attendeeCount'] as int),
        attendees: List.generate(
          data['attendeeCount'] as int,
          (i) {
            final attendee = MockDataService.generateMockUser();
            return Attendee(
              userId: attendee['userId'] as int,
              name: attendee['name'] as String,
              images: [attendee['profileImage'] as String],
            );
          },
        ),
        userJoined: data['userJoined'] as bool,
        userSaved: data['isSaved'] as bool,
        creatorId: host['userId'] as int,
        creatorName: host['name'] as String,
        creatorImages: [host['profileImage'] as String],
      );
    }).toList();
  }

  /// Load all activities (with mock data fallback)
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

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        if (refresh) {
          allActivities.value = response.data!;
        } else {
          allActivities.addAll(response.data!);
        }

        hasMorePages.value = response.data!.length >= pageSize;
        if (hasMorePages.value) {
          currentPage.value++;
        }
        useMockData.value = false;
      } else {
        _loadMockAllActivities();
      }
    } catch (e) {
      _loadMockAllActivities();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load mock all activities for demo
  void _loadMockAllActivities() {
    if (allActivities.isEmpty) {
      useMockData.value = true;
      final mockData = MockDataService.generateMockActivities(12);
      allActivities.value = _convertMockToActivities(mockData);
      hasMorePages.value = false;
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
      // Ignore errors
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
      // Ignore errors
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
      // Ignore errors
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
      // Ignore errors
    } finally {
      isLoading.value = false;
    }
  }

  /// Create activity
  Future<bool> createActivity() async {
    if (!_validateCreateForm()) return false;

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
        totalSlots: int.parse(slotsController.text),
        images: selectedImages.isNotEmpty ? selectedImages : null,
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
      errorMessage.value = 'Failed to create activity';
      return false;
    }
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
        totalSlots: slotsController.text.isNotEmpty ? int.parse(slotsController.text) : null,
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

  /// Delete activity
  Future<bool> deleteActivity(int activityId) async {
    try {
      final response = await _activityRepository.deleteActivity(activityId);

      if (response.success) {
        myActivities.removeWhere((a) => a.activityId == activityId);
        allActivities.removeWhere((a) => a.activityId == activityId);
        return true;
      }
      return false;
    } catch (e) {
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

  /// Update activity join status in lists
  void _updateActivityJoinStatus(int activityId, bool joined) {
    void updateList(RxList<ActivityModel> list) {
      final index = list.indexWhere((a) => a.activityId == activityId);
      if (index != -1) {
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

  /// Update activity save status in lists
  void _updateActivitySaveStatus(int activityId) {
    void updateList(RxList<ActivityModel> list) {
      final index = list.indexWhere((a) => a.activityId == activityId);
      if (index != -1) {
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
    if (slotsController.text.isEmpty || int.tryParse(slotsController.text) == null) {
      errorMessage.value = 'Please enter valid number of slots';
      return false;
    }
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
