import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/event_reminder_model.dart';
import 'base_repository.dart';

/// Repository for event reminder operations
class EventReminderRepository extends BaseRepository {
  /// Create a reminder for an event
  Future<ApiResponse<EventReminderModel>> createReminder({
    required int eventId,
    required ReminderType type,
    List<ReminderDeliveryMethod> deliveryMethods = const [
      ReminderDeliveryMethod.push,
      ReminderDeliveryMethod.inApp,
    ],
    DateTime? customDateTime,
    String? customMessage,
  }) async {
    return post<EventReminderModel>(
      ApiEndpoints.createReminder,
      body: {
        'event_id': eventId,
        'type': type.name,
        'delivery_methods': deliveryMethods.map((m) => m.name).toList(),
        'custom_date_time': customDateTime?.toIso8601String(),
        'custom_message': customMessage,
      },
      fromJson: EventReminderModel.fromJson,
    );
  }

  /// Get reminders for an event
  Future<ApiResponse<List<EventReminderModel>>> getEventReminders({
    required int eventId,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.getReminders}/$eventId',
    );
    return parseListResponse(response, EventReminderModel.fromJson);
  }

  /// Get all user reminders
  Future<ApiResponse<List<EventReminderModel>>> getUserReminders() async {
    final response = await get<dynamic>(
      ApiEndpoints.getReminders,
    );
    return parseListResponse(response, EventReminderModel.fromJson);
  }

  /// Update a reminder
  Future<ApiResponse<EventReminderModel>> updateReminder({
    required String reminderId,
    ReminderType? type,
    List<ReminderDeliveryMethod>? deliveryMethods,
    bool? isEnabled,
    String? customMessage,
  }) async {
    final body = <String, dynamic>{
      'reminder_id': reminderId,
    };
    if (type != null) body['type'] = type.name;
    if (deliveryMethods != null) {
      body['delivery_methods'] = deliveryMethods.map((m) => m.name).toList();
    }
    if (isEnabled != null) body['is_enabled'] = isEnabled;
    if (customMessage != null) body['custom_message'] = customMessage;

    return put<EventReminderModel>(
      ApiEndpoints.updateReminder,
      body: body,
      fromJson: EventReminderModel.fromJson,
    );
  }

  /// Delete a reminder
  Future<ApiResponse<dynamic>> deleteReminder({
    required String reminderId,
  }) async {
    return delete(
      '${ApiEndpoints.deleteReminder}/$reminderId',
    );
  }

  /// Get reminder preferences
  Future<ApiResponse<ReminderPreferencesModel>> getReminderPreferences() async {
    return get<ReminderPreferencesModel>(
      ApiEndpoints.reminderPreferences,
      fromJson: ReminderPreferencesModel.fromJson,
    );
  }

  /// Update reminder preferences
  Future<ApiResponse<ReminderPreferencesModel>> updateReminderPreferences({
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
    final body = <String, dynamic>{};
    if (pushEnabled != null) body['push_enabled'] = pushEnabled;
    if (inAppEnabled != null) body['in_app_enabled'] = inAppEnabled;
    if (emailEnabled != null) body['email_enabled'] = emailEnabled;
    if (smsEnabled != null) body['sms_enabled'] = smsEnabled;
    if (defaultReminders != null) {
      body['default_reminders'] = defaultReminders.map((r) => r.name).toList();
    }
    if (reminderSoundEnabled != null) body['reminder_sound_enabled'] = reminderSoundEnabled;
    if (quietHoursEnabled != null) body['quiet_hours_enabled'] = quietHoursEnabled;
    if (quietHoursStart != null) body['quiet_hours_start'] = quietHoursStart;
    if (quietHoursEnd != null) body['quiet_hours_end'] = quietHoursEnd;

    return put<ReminderPreferencesModel>(
      ApiEndpoints.reminderPreferences,
      body: body,
      fromJson: ReminderPreferencesModel.fromJson,
    );
  }

  /// Get upcoming event reminders
  Future<ApiResponse<List<UpcomingEventNotification>>> getUpcomingReminders() async {
    final response = await get<dynamic>(
      ApiEndpoints.upcomingReminders,
    );
    return parseListResponse(response, UpcomingEventNotification.fromJson);
  }
}
