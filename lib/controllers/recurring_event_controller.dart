import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/recurring_event_model.dart';
import '../repositories/recurring_event_repository.dart';

/// Controller for recurring events
class RecurringEventController extends GetxController {
  final RecurringEventRepository _repository = RecurringEventRepository();

  // State
  final RxList<RecurringEventModel> myRecurringSeries = <RecurringEventModel>[].obs;
  final Rx<RecurringEventModel?> currentSeries = Rx<RecurringEventModel?>(null);
  final RxList<RecurringEventInstance> upcomingInstances = <RecurringEventInstance>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();

  // Form state
  final RxString selectedEventType = ''.obs;
  final RxString startTime = ''.obs;
  final RxString endTime = ''.obs;
  final RxDouble selectedLatitude = 0.0.obs;
  final RxDouble selectedLongitude = 0.0.obs;
  final RxList<File> selectedImages = <File>[].obs;

  // Recurrence rule state
  final Rx<RecurrenceFrequency> frequency = RecurrenceFrequency.weekly.obs;
  final RxInt interval = 1.obs;
  final RxList<DayOfWeek> selectedDaysOfWeek = <DayOfWeek>[].obs;
  final RxInt dayOfMonth = 1.obs;
  final Rx<DateTime?> seriesStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> seriesEndDate = Rx<DateTime?>(null);
  final RxInt maxOccurrences = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyRecurringSeries();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    maxAttendeesController.dispose();
    super.onClose();
  }

  /// Load user's recurring event series
  Future<void> loadMyRecurringSeries() async {
    isLoading.value = true;
    try {
      final response = await _repository.getMyRecurringSeries();
      if (response.success && response.data != null) {
        myRecurringSeries.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading recurring series: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load a specific series
  Future<void> loadSeries(String seriesId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getRecurringSeries(seriesId: seriesId);
      if (response.success && response.data != null) {
        currentSeries.value = response.data;
        upcomingInstances.value = response.data!.upcomingInstances;
      } else {
        errorMessage.value = response.error ?? 'Failed to load series';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load series';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load instances for a series
  Future<void> loadInstances({
    required String seriesId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 10,
  }) async {
    try {
      final response = await _repository.getInstances(
        seriesId: seriesId,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
      );
      if (response.success && response.data != null) {
        upcomingInstances.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading instances: $e');
    }
  }

  /// Create a recurring event series
  Future<bool> createRecurringSeries() async {
    if (!_validateForm()) return false;

    isCreating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final recurrenceRule = RecurrenceRuleModel(
        frequency: frequency.value,
        interval: interval.value,
        daysOfWeek: selectedDaysOfWeek.toList(),
        dayOfMonth: frequency.value == RecurrenceFrequency.monthly ? dayOfMonth.value : null,
        startDate: seriesStartDate.value,
        endDate: seriesEndDate.value,
        maxOccurrences: maxOccurrences.value > 0 ? maxOccurrences.value : null,
      );

      final response = await _repository.createRecurringSeries(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        latitude: selectedLatitude.value != 0 ? selectedLatitude.value : null,
        longitude: selectedLongitude.value != 0 ? selectedLongitude.value : null,
        startTime: startTime.value,
        endTime: endTime.value.isNotEmpty ? endTime.value : null,
        maxAttendees: int.tryParse(maxAttendeesController.text) ?? 20,
        eventType: selectedEventType.value,
        recurrenceRule: recurrenceRule,
      );

      if (response.success && response.data != null) {
        myRecurringSeries.add(response.data!);
        successMessage.value = 'Recurring event series created!';
        _clearForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create series';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create series. Please try again.';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Update a recurring series
  Future<bool> updateSeries({
    required String seriesId,
    bool updateFutureOnly = true,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final recurrenceRule = RecurrenceRuleModel(
        frequency: frequency.value,
        interval: interval.value,
        daysOfWeek: selectedDaysOfWeek.toList(),
        dayOfMonth: frequency.value == RecurrenceFrequency.monthly ? dayOfMonth.value : null,
        startDate: seriesStartDate.value,
        endDate: seriesEndDate.value,
        maxOccurrences: maxOccurrences.value > 0 ? maxOccurrences.value : null,
      );

      final response = await _repository.updateRecurringSeries(
        seriesId: seriesId,
        name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        startTime: startTime.value.isNotEmpty ? startTime.value : null,
        endTime: endTime.value.isNotEmpty ? endTime.value : null,
        maxAttendees: maxAttendeesController.text.isNotEmpty
            ? int.tryParse(maxAttendeesController.text)
            : null,
        recurrenceRule: recurrenceRule,
        updateFutureOnly: updateFutureOnly,
      );

      if (response.success && response.data != null) {
        // Update in list
        final index = myRecurringSeries.indexWhere((s) => s.seriesId == seriesId);
        if (index != -1) {
          myRecurringSeries[index] = response.data!;
        }
        currentSeries.value = response.data;
        successMessage.value = 'Series updated!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to update series';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update series';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Cancel a specific instance
  Future<bool> cancelInstance({
    required String seriesId,
    required String instanceId,
    String? reason,
  }) async {
    try {
      final response = await _repository.cancelInstance(
        seriesId: seriesId,
        instanceId: instanceId,
        cancellationReason: reason,
      );

      if (response.success) {
        // Update in list
        final index = upcomingInstances.indexWhere((i) => i.instanceId == instanceId);
        if (index != -1) {
          upcomingInstances[index] = response.data!;
        }
        successMessage.value = 'Event cancelled';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to cancel event';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to cancel event';
      return false;
    }
  }

  /// Delete entire series
  Future<bool> deleteSeries(String seriesId) async {
    try {
      final response = await _repository.deleteRecurringSeries(seriesId: seriesId);

      if (response.success) {
        myRecurringSeries.removeWhere((s) => s.seriesId == seriesId);
        currentSeries.value = null;
        successMessage.value = 'Series deleted';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to delete series';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete series';
      return false;
    }
  }

  /// Pause a series
  Future<bool> pauseSeries(String seriesId) async {
    try {
      final response = await _repository.pauseSeries(seriesId: seriesId);

      if (response.success && response.data != null) {
        final index = myRecurringSeries.indexWhere((s) => s.seriesId == seriesId);
        if (index != -1) {
          myRecurringSeries[index] = response.data!;
        }
        successMessage.value = 'Series paused';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to pause series';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to pause series';
      return false;
    }
  }

  /// Resume a series
  Future<bool> resumeSeries(String seriesId) async {
    try {
      final response = await _repository.resumeSeries(seriesId: seriesId);

      if (response.success && response.data != null) {
        final index = myRecurringSeries.indexWhere((s) => s.seriesId == seriesId);
        if (index != -1) {
          myRecurringSeries[index] = response.data!;
        }
        successMessage.value = 'Series resumed';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to resume series';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to resume series';
      return false;
    }
  }

  /// Toggle day of week selection
  void toggleDayOfWeek(DayOfWeek day) {
    if (selectedDaysOfWeek.contains(day)) {
      selectedDaysOfWeek.remove(day);
    } else {
      selectedDaysOfWeek.add(day);
    }
  }

  /// Set frequency
  void setFrequency(RecurrenceFrequency freq) {
    frequency.value = freq;
    if (freq != RecurrenceFrequency.weekly) {
      selectedDaysOfWeek.clear();
    }
  }

  /// Set series for editing
  void setSeriesForEditing(RecurringEventModel series) {
    nameController.text = series.name ?? '';
    descriptionController.text = series.description ?? '';
    locationController.text = series.location ?? '';
    maxAttendeesController.text = series.maxAttendees?.toString() ?? '';
    selectedEventType.value = series.eventType ?? '';
    startTime.value = series.startTime ?? '';
    endTime.value = series.endTime ?? '';
    selectedLatitude.value = series.latitude ?? 0.0;
    selectedLongitude.value = series.longitude ?? 0.0;

    frequency.value = series.recurrenceRule.frequency;
    interval.value = series.recurrenceRule.interval;
    selectedDaysOfWeek.value = series.recurrenceRule.daysOfWeek;
    dayOfMonth.value = series.recurrenceRule.dayOfMonth ?? 1;
    seriesStartDate.value = series.recurrenceRule.startDate;
    seriesEndDate.value = series.recurrenceRule.endDate;
    maxOccurrences.value = series.recurrenceRule.maxOccurrences ?? 0;
  }

  /// Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter an event name';
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a location';
      return false;
    }
    if (startTime.value.isEmpty) {
      errorMessage.value = 'Please select a start time';
      return false;
    }
    if (frequency.value == RecurrenceFrequency.weekly && selectedDaysOfWeek.isEmpty) {
      errorMessage.value = 'Please select at least one day of the week';
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    maxAttendeesController.clear();
    selectedEventType.value = '';
    startTime.value = '';
    endTime.value = '';
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    selectedImages.clear();
    frequency.value = RecurrenceFrequency.weekly;
    interval.value = 1;
    selectedDaysOfWeek.clear();
    dayOfMonth.value = 1;
    seriesStartDate.value = null;
    seriesEndDate.value = null;
    maxOccurrences.value = 0;
  }

  /// Get recurrence display text
  String get recurrenceDisplayText {
    final rule = RecurrenceRuleModel(
      frequency: frequency.value,
      interval: interval.value,
      daysOfWeek: selectedDaysOfWeek.toList(),
    );
    var text = rule.frequencyDisplay;
    if (rule.daysOfWeekDisplay.isNotEmpty) {
      text += ' on ${rule.daysOfWeekDisplay}';
    }
    return text;
  }

  // Additional methods for screen compatibility

  /// Alias for frequency
  Rx<RecurrenceFrequency> get selectedFrequency => frequency;

  /// Selected days as indices (0=Monday, 6=Sunday)
  RxSet<int> get selectedDays {
    final set = <int>{};
    for (final day in selectedDaysOfWeek) {
      set.add(day.index);
    }
    return set.obs;
  }

  /// Alias for dayOfMonth
  RxInt get selectedDayOfMonth => dayOfMonth;

  /// End type selection (never, count, date)
  final RxString endType = 'never'.obs;

  /// Alias for maxOccurrences
  RxInt get occurrenceCount => maxOccurrences;

  /// Alias for seriesEndDate
  Rx<DateTime?> get endDate => seriesEndDate;

  /// Alias for upcomingInstances
  RxList<RecurringEventInstance> get instances => upcomingInstances;

  /// Get recurrence preview text
  String getRecurrencePreview() {
    return recurrenceDisplayText;
  }

  /// Get next occurrences based on current settings
  List<DateTime> getNextOccurrences(int count) {
    final rule = RecurrenceRuleModel(
      frequency: frequency.value,
      interval: interval.value,
      daysOfWeek: selectedDaysOfWeek.toList(),
      dayOfMonth: dayOfMonth.value,
      startDate: seriesStartDate.value ?? DateTime.now(),
      endDate: seriesEndDate.value,
      maxOccurrences: maxOccurrences.value > 0 ? maxOccurrences.value : null,
    );
    return rule.generateOccurrences(count: count);
  }

  /// Skip an instance
  Future<bool> skipInstance(String instanceId) async {
    final seriesId = currentSeries.value?.seriesId;
    if (seriesId == null) return false;
    return cancelInstance(seriesId: seriesId, instanceId: instanceId, reason: 'Skipped');
  }

  /// Alias for createRecurringSeries
  Future<bool> createSeries() => createRecurringSeries();

  /// Load series with int ID (converts to String)
  Future<void> loadSeriesById(int seriesId) => loadSeries(seriesId.toString());
}
