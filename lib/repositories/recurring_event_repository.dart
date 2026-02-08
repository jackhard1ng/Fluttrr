import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/recurring_event_model.dart';
import 'base_repository.dart';

/// Repository for recurring event operations
class RecurringEventRepository extends BaseRepository {
  /// Create a recurring event series
  Future<ApiResponse<RecurringEventModel>> createRecurringSeries({
    required String name,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
    required String startTime,
    String? endTime,
    int? durationMinutes,
    required int maxAttendees,
    required String eventType,
    List<String> images = const [],
    required RecurrenceRuleModel recurrenceRule,
  }) async {
    return post<RecurringEventModel>(
      ApiEndpoints.createRecurringEvent,
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'start_time': startTime,
        'end_time': endTime,
        'duration_minutes': durationMinutes,
        'max_attendees': maxAttendees,
        'event_type': eventType,
        'images': images,
        'recurrence_rule': recurrenceRule.toJson(),
      },
      fromJson: RecurringEventModel.fromJson,
    );
  }

  /// Get a recurring event series
  Future<ApiResponse<RecurringEventModel>> getRecurringSeries({
    required String seriesId,
  }) async {
    return get<RecurringEventModel>(
      '${ApiEndpoints.getRecurringSeries}/$seriesId',
      fromJson: RecurringEventModel.fromJson,
    );
  }

  /// Get all recurring series for the current user
  Future<ApiResponse<List<RecurringEventModel>>> getMyRecurringSeries() async {
    final response = await get<dynamic>(
      ApiEndpoints.getRecurringSeries,
    );
    return parseListResponse(response, RecurringEventModel.fromJson);
  }

  /// Update a recurring event series
  Future<ApiResponse<RecurringEventModel>> updateRecurringSeries({
    required String seriesId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? startTime,
    String? endTime,
    int? maxAttendees,
    RecurrenceRuleModel? recurrenceRule,
    bool? isActive,
    bool updateFutureOnly = true,
  }) async {
    final body = <String, dynamic>{
      'series_id': seriesId,
      'update_future_only': updateFutureOnly,
    };
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (startTime != null) body['start_time'] = startTime;
    if (endTime != null) body['end_time'] = endTime;
    if (maxAttendees != null) body['max_attendees'] = maxAttendees;
    if (recurrenceRule != null) body['recurrence_rule'] = recurrenceRule.toJson();
    if (isActive != null) body['is_active'] = isActive;

    return put<RecurringEventModel>(
      ApiEndpoints.updateRecurringSeries,
      body: body,
      fromJson: RecurringEventModel.fromJson,
    );
  }

  /// Cancel a specific instance of a recurring event
  Future<ApiResponse<RecurringEventInstance>> cancelInstance({
    required String seriesId,
    required String instanceId,
    String? cancellationReason,
    bool notifyAttendees = true,
  }) async {
    return post<RecurringEventInstance>(
      ApiEndpoints.cancelRecurringInstance,
      body: {
        'series_id': seriesId,
        'instance_id': instanceId,
        'cancellation_reason': cancellationReason,
        'notify_attendees': notifyAttendees,
      },
      fromJson: RecurringEventInstance.fromJson,
    );
  }

  /// Delete entire recurring event series
  Future<ApiResponse<dynamic>> deleteRecurringSeries({
    required String seriesId,
    bool notifyAttendees = true,
  }) async {
    return delete(
      '${ApiEndpoints.deleteRecurringSeries}/$seriesId',
    );
  }

  /// Get instances of a recurring event
  Future<ApiResponse<List<RecurringEventInstance>>> getInstances({
    required String seriesId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['to_date'] = toDate.toIso8601String();
    }

    final response = await get<dynamic>(
      '${ApiEndpoints.recurringEventInstances}/$seriesId',
      queryParams: queryParams,
    );
    return parseListResponse(response, RecurringEventInstance.fromJson);
  }

  /// Pause a recurring event series
  Future<ApiResponse<RecurringEventModel>> pauseSeries({
    required String seriesId,
  }) async {
    return updateRecurringSeries(
      seriesId: seriesId,
      isActive: false,
    );
  }

  /// Resume a paused recurring event series
  Future<ApiResponse<RecurringEventModel>> resumeSeries({
    required String seriesId,
  }) async {
    return updateRecurringSeries(
      seriesId: seriesId,
      isActive: true,
    );
  }

  /// Add exception date to recurring series
  Future<ApiResponse<RecurringEventModel>> addExceptionDate({
    required String seriesId,
    required DateTime exceptionDate,
  }) async {
    return post<RecurringEventModel>(
      '${ApiEndpoints.getRecurringSeries}/$seriesId/exception',
      body: {
        'exception_date': exceptionDate.toIso8601String(),
      },
      fromJson: RecurringEventModel.fromJson,
    );
  }
}
