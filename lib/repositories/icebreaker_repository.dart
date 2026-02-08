import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/icebreaker_model.dart';
import 'base_repository.dart';

/// Repository for icebreaker operations
class IcebreakerRepository extends BaseRepository {
  /// Get list of icebreakers
  Future<ApiResponse<List<IcebreakerModel>>> getIcebreakers({
    IcebreakerType? type,
    IcebreakerCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) queryParams['type'] = type.name;
    if (category != null) queryParams['category'] = category.name;

    final response = await get<dynamic>(
      ApiEndpoints.getIcebreakers,
      queryParams: queryParams,
    );
    return parseListResponse(response, IcebreakerModel.fromJson);
  }

  /// Get random icebreaker
  Future<ApiResponse<IcebreakerModel>> getRandomIcebreaker({
    IcebreakerType? type,
    IcebreakerCategory? category,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type.name;
    if (category != null) queryParams['category'] = category.name;

    return get<IcebreakerModel>(
      ApiEndpoints.getRandomIcebreaker,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: IcebreakerModel.fromJson,
    );
  }

  /// Create a custom icebreaker
  Future<ApiResponse<IcebreakerModel>> createCustomIcebreaker({
    required String question,
    String? prompt,
    required IcebreakerType type,
    required IcebreakerCategory category,
    List<String> options = const [],
    int? timeLimit,
  }) async {
    return post<IcebreakerModel>(
      ApiEndpoints.createCustomIcebreaker,
      body: {
        'question': question,
        'prompt': prompt,
        'type': type.name,
        'category': category.name,
        'options': options,
        'time_limit': timeLimit,
      },
      fromJson: IcebreakerModel.fromJson,
    );
  }

  /// Get icebreaker session for an event
  Future<ApiResponse<EventIcebreakerSession>> getIcebreakerSession({
    required int eventId,
  }) async {
    return get<EventIcebreakerSession>(
      '${ApiEndpoints.icebreakerSession}/$eventId',
      fromJson: EventIcebreakerSession.fromJson,
    );
  }

  /// Start an icebreaker session for an event (host only)
  Future<ApiResponse<EventIcebreakerSession>> startIcebreakerSession({
    required int eventId,
    List<String>? icebreakerIds,
    IcebreakerCategory? category,
    int? count,
  }) async {
    return post<EventIcebreakerSession>(
      ApiEndpoints.startIcebreakerSession,
      body: {
        'event_id': eventId,
        'icebreaker_ids': icebreakerIds,
        'category': category?.name,
        'count': count ?? 5,
      },
      fromJson: EventIcebreakerSession.fromJson,
    );
  }

  /// Submit response to an icebreaker
  Future<ApiResponse<IcebreakerResponseModel>> submitResponse({
    required String icebreakerId,
    required int eventId,
    String? answer,
    int? selectedOptionIndex,
  }) async {
    return post<IcebreakerResponseModel>(
      ApiEndpoints.submitIcebreakerResponse,
      body: {
        'icebreaker_id': icebreakerId,
        'event_id': eventId,
        'answer': answer,
        'selected_option_index': selectedOptionIndex,
      },
      fromJson: IcebreakerResponseModel.fromJson,
    );
  }

  /// Get responses for an icebreaker
  Future<ApiResponse<List<IcebreakerResponseModel>>> getResponses({
    required String icebreakerId,
    required int eventId,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.icebreakerResponses,
      queryParams: {
        'icebreaker_id': icebreakerId,
        'event_id': eventId.toString(),
      },
    );
    return parseListResponse(response, IcebreakerResponseModel.fromJson);
  }

  /// Move to next icebreaker in session (host only)
  Future<ApiResponse<EventIcebreakerSession>> nextIcebreaker({
    required int eventId,
  }) async {
    return post<EventIcebreakerSession>(
      ApiEndpoints.nextIcebreaker,
      body: {
        'event_id': eventId,
      },
      fromJson: EventIcebreakerSession.fromJson,
    );
  }

  /// Add reaction to a response
  Future<ApiResponse<IcebreakerResponseModel>> addReaction({
    required String responseId,
    required String emoji,
  }) async {
    return post<IcebreakerResponseModel>(
      '${ApiEndpoints.icebreakerResponses}/$responseId/react',
      body: {
        'emoji': emoji,
      },
      fromJson: IcebreakerResponseModel.fromJson,
    );
  }

  /// End icebreaker session (host only)
  Future<ApiResponse<dynamic>> endSession({
    required int eventId,
  }) async {
    return post(
      '${ApiEndpoints.icebreakerSession}/$eventId/end',
    );
  }

  /// Get popular icebreakers
  Future<ApiResponse<List<IcebreakerModel>>> getPopularIcebreakers({
    int limit = 10,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.getIcebreakers,
      queryParams: {
        'sort': 'popular',
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, IcebreakerModel.fromJson);
  }
}
