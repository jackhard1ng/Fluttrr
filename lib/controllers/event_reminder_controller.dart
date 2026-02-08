import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event_reminder_model.dart';
import '../repositories/event_reminder_repository.dart';

/// Controller for event reminders
class EventReminderController extends GetxController {
  final EventReminderRepository _repository = EventReminderRepository();

  // State
  final RxList<EventReminderModel> eventReminders = <EventReminderModel>[].obs;
  final RxList<EventReminderModel> allReminders = <EventReminderModel>[].obs;
  final RxList<UpcomingEventNotification> upcomingReminders = <UpcomingEventNotification>[].obs;
  final Rx<ReminderPreferencesModel?> preferences = Rx<ReminderPreferencesModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Create reminder form state
  final Rx<ReminderType> selectedReminderType = ReminderType.oneDay.obs;
  final RxList<ReminderDeliveryMethod> selectedDeliveryMethods = <ReminderDeliveryMethod>[
    ReminderDeliveryMethod.push,
    ReminderDeliveryMethod.inApp,
  ].obs;
  final TextEditingController customMessageController = TextEditingController();
  final Rx<DateTime?> customDateTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
    loadUpcomingReminders();
  }

  @override
  void onClose() {
    customMessageController.dispose();
    super.onClose();
  }

  /// Load reminder preferences
  Future<void> loadPreferences() async {
    try {
      final response = await _repository.getReminderPreferences();
      final data = response.data;
      if (response.success && data != null) {
        preferences.value = data;
        // Apply default preferences
        selectedDeliveryMethods.value = [
          if (data.pushEnabled) ReminderDeliveryMethod.push,
          if (data.inAppEnabled) ReminderDeliveryMethod.inApp,
          if (data.emailEnabled) ReminderDeliveryMethod.email,
          if (data.smsEnabled) ReminderDeliveryMethod.sms,
        ];
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Load reminders for an event
  Future<void> loadEventReminders(int eventId) async {
    isLoading.value = true;
    try {
      final response = await _repository.getEventReminders(eventId: eventId);
      final data = response.data;
      if (response.success && data != null) {
        eventReminders.value = data;
      }
    } catch (e) {
      debugPrint('Error loading event reminders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all user reminders
  Future<void> loadAllReminders() async {
    isLoading.value = true;
    try {
      final response = await _repository.getUserReminders();
      final data = response.data;
      if (response.success && data != null) {
        allReminders.value = data;
      }
    } catch (e) {
      debugPrint('Error loading all reminders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load upcoming reminders
  Future<void> loadUpcomingReminders() async {
    try {
      final response = await _repository.getUpcomingReminders();
      final data = response.data;
      if (response.success && data != null) {
        upcomingReminders.value = data;
      }
    } catch (e) {
      debugPrint('Error loading upcoming reminders: $e');
    }
  }

  /// Create a reminder for an event
  Future<bool> createReminder({
    required int eventId,
  }) async {
    if (selectedDeliveryMethods.isEmpty) {
      errorMessage.value = 'Please select at least one notification method';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.createReminder(
        eventId: eventId,
        type: selectedReminderType.value,
        deliveryMethods: selectedDeliveryMethods.toList(),
        customDateTime: customDateTime.value,
        customMessage: customMessageController.text.trim().isNotEmpty
            ? customMessageController.text.trim()
            : null,
      );

      final data = response.data;
      if (response.success && data != null) {
        eventReminders.add(data);
        successMessage.value = 'Reminder set!';
        _clearForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create reminder';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create reminder. Please try again.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update a reminder
  Future<bool> updateReminder({
    required String reminderId,
    ReminderType? type,
    List<ReminderDeliveryMethod>? deliveryMethods,
    bool? isEnabled,
    String? customMessage,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.updateReminder(
        reminderId: reminderId,
        type: type,
        deliveryMethods: deliveryMethods,
        isEnabled: isEnabled,
        customMessage: customMessage,
      );

      final data = response.data;
      if (response.success && data != null) {
        final index = eventReminders.indexWhere((r) => r.reminderId == reminderId);
        if (index != -1) {
          eventReminders[index] = data;
        }
        successMessage.value = 'Reminder updated';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to update reminder';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update reminder';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Toggle reminder enabled/disabled
  Future<bool> toggleReminder(String reminderId, bool isEnabled) async {
    return updateReminder(reminderId: reminderId, isEnabled: isEnabled);
  }

  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final response = await _repository.deleteReminder(reminderId: reminderId);

      if (response.success) {
        eventReminders.removeWhere((r) => r.reminderId == reminderId);
        allReminders.removeWhere((r) => r.reminderId == reminderId);
        successMessage.value = 'Reminder deleted';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to delete reminder';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete reminder';
      return false;
    }
  }

  /// Update preferences
  Future<bool> updatePreferences({
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    List<ReminderType>? defaultReminders,
    bool? reminderSoundEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.updateReminderPreferences(
        pushEnabled: pushEnabled,
        inAppEnabled: inAppEnabled,
        emailEnabled: emailEnabled,
        smsEnabled: smsEnabled,
        defaultReminders: defaultReminders,
        reminderSoundEnabled: reminderSoundEnabled,
        quietHoursEnabled: quietHoursEnabled,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );

      if (response.success && response.data != null) {
        preferences.value = response.data;
        successMessage.value = 'Preferences updated';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to update preferences';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update preferences';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Set reminder type
  void setReminderType(ReminderType type) {
    selectedReminderType.value = type;
  }

  /// Toggle delivery method
  void toggleDeliveryMethod(ReminderDeliveryMethod method) {
    if (selectedDeliveryMethods.contains(method)) {
      selectedDeliveryMethods.remove(method);
    } else {
      selectedDeliveryMethods.add(method);
    }
  }

  /// Set custom date time
  void setCustomDateTime(DateTime dateTime) {
    customDateTime.value = dateTime;
    selectedReminderType.value = ReminderType.custom;
  }

  /// Clear form
  void _clearForm() {
    selectedReminderType.value = ReminderType.oneDay;
    customDateTime.value = null;
    customMessageController.clear();
  }

  /// Get reminders for display
  List<ReminderType> get availableReminderTypes => ReminderType.values;

  /// Check if has reminder for event
  bool hasReminderForEvent(int eventId) {
    return eventReminders.any((r) => r.eventId == eventId && r.isEnabled);
  }

  /// Get upcoming event count
  int get upcomingEventCount => upcomingReminders.length;

  // Additional methods for widget compatibility

  /// Push notifications enabled
  final RxBool pushEnabled = true.obs;

  /// Email notifications enabled
  final RxBool emailEnabled = false.obs;

  /// Get reminder for a specific event
  EventReminderModel? getReminder(int eventId) {
    try {
      return eventReminders.firstWhere((r) => r.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  /// Check if event has an active reminder
  bool hasActiveReminder(int eventId) {
    final reminder = getReminder(eventId);
    return reminder != null && reminder.isEnabled;
  }

  /// Cancel a reminder for an event
  Future<void> cancelReminder(int eventId) async {
    final reminder = getReminder(eventId);
    final reminderId = reminder?.reminderId;
    if (reminderId != null) {
      await deleteReminder(reminderId);
    }
  }

  /// Set reminder with specific types
  Future<void> setReminder({
    required int eventId,
    required List<ReminderType> types,
    bool? pushEnabled,
    bool? emailEnabled,
  }) async {
    for (final type in types) {
      selectedReminderType.value = type;
      selectedDeliveryMethods.value = [
        if (pushEnabled ?? this.pushEnabled.value) ReminderDeliveryMethod.push,
        ReminderDeliveryMethod.inApp,
        if (emailEnabled ?? this.emailEnabled.value) ReminderDeliveryMethod.email,
      ];
      await createReminder(eventId: eventId);
    }
  }
}
