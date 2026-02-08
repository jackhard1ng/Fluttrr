import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/event_feedback_model.dart';
import 'base_repository.dart';

/// Repository for event feedback and rating operations
class EventFeedbackRepository extends BaseRepository {
  /// Submit feedback for an event
  Future<ApiResponse<EventFeedbackModel>> submitEventFeedback({
    required int eventId,
    required int rating,
    String? comment,
  }) async {
    return post<EventFeedbackModel>(
      ApiEndpoints.submitEventFeedback,
      body: {
        'event_id': eventId,
        'rating': rating,
        'comment': comment,
      },
      fromJson: EventFeedbackModel.fromJson,
    );
  }

  /// Get feedback for an event
  Future<ApiResponse<List<EventFeedbackModel>>> getEventFeedback({
    required int eventId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.getEventFeedback}/$eventId',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, EventFeedbackModel.fromJson);
  }

  /// Rate an attendee
  Future<ApiResponse<AttendeeRatingModel>> rateAttendee({
    required int eventId,
    required int ratedUserId,
    required int rating,
    List<String> tags = const [],
    String? comment,
  }) async {
    return post<AttendeeRatingModel>(
      ApiEndpoints.rateAttendee,
      body: {
        'event_id': eventId,
        'rated_user_id': ratedUserId,
        'rating': rating,
        'tags': tags,
        'comment': comment,
      },
      fromJson: AttendeeRatingModel.fromJson,
    );
  }

  /// Get attendee ratings for an event
  Future<ApiResponse<List<AttendeeRatingModel>>> getAttendeeRatings({
    required int eventId,
  }) async {
    final response = await get<dynamic>(
      '${ApiEndpoints.getAttendeeRatings}/$eventId',
    );
    return parseListResponse(response, AttendeeRatingModel.fromJson);
  }

  /// Get post-event summary for host
  Future<ApiResponse<PostEventSummaryModel>> getPostEventSummary({
    required int eventId,
  }) async {
    return get<PostEventSummaryModel>(
      '${ApiEndpoints.postEventSummary}/$eventId',
      fromJson: PostEventSummaryModel.fromJson,
    );
  }

  /// Send thank you message to attendees
  Future<ApiResponse<dynamic>> sendThankYouMessage({
    required int eventId,
    String? customMessage,
    bool includeRatingRequest = true,
  }) async {
    return post(
      ApiEndpoints.sendThankYou,
      body: {
        'event_id': eventId,
        'custom_message': customMessage,
        'include_rating_request': includeRatingRequest,
      },
    );
  }

  /// Get events pending feedback (for user to provide feedback)
  Future<ApiResponse<List<PostEventSummaryModel>>> getEventsPendingFeedback() async {
    final response = await get<dynamic>(
      '${ApiEndpoints.postEventSummary}/pending',
    );
    return parseListResponse(response, PostEventSummaryModel.fromJson);
  }
}
