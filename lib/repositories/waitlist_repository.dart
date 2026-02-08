import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/waitlist_model.dart';
import 'base_repository.dart';

/// Repository for event waitlist operations
class WaitlistRepository extends BaseRepository {
  /// Join an event waitlist
  Future<ApiResponse<WaitlistEntryModel>> joinWaitlist({
    required int eventId,
    String? note,
    int? guestsCount,
  }) async {
    return post<WaitlistEntryModel>(
      ApiEndpoints.joinWaitlist,
      body: {
        'event_id': eventId,
        'note': note,
        'guests_count': guestsCount,
      },
      fromJson: WaitlistEntryModel.fromJson,
    );
  }

  /// Leave an event waitlist
  Future<ApiResponse<dynamic>> leaveWaitlist({
    required int eventId,
  }) async {
    return delete(
      '${ApiEndpoints.leaveWaitlist}/$eventId',
    );
  }

  /// Get waitlist for an event
  Future<ApiResponse<EventWaitlistSummary>> getEventWaitlist({
    required int eventId,
  }) async {
    return get<EventWaitlistSummary>(
      '${ApiEndpoints.getWaitlist}/$eventId',
      fromJson: EventWaitlistSummary.fromJson,
    );
  }

  /// Respond to a waitlist offer
  Future<ApiResponse<WaitlistEntryModel>> respondToOffer({
    required String waitlistId,
    required bool accept,
  }) async {
    return post<WaitlistEntryModel>(
      ApiEndpoints.respondToWaitlistOffer,
      body: {
        'waitlist_id': waitlistId,
        'accept': accept,
      },
      fromJson: WaitlistEntryModel.fromJson,
    );
  }

  /// Get user's waitlist position for an event
  Future<ApiResponse<WaitlistEntryModel>> getWaitlistPosition({
    required int eventId,
  }) async {
    return get<WaitlistEntryModel>(
      '${ApiEndpoints.waitlistPosition}/$eventId',
      fromJson: WaitlistEntryModel.fromJson,
    );
  }

  /// Get all events user is waitlisted for
  Future<ApiResponse<List<WaitlistEntryModel>>> getUserWaitlists() async {
    final response = await get<dynamic>(
      ApiEndpoints.getWaitlist,
    );
    return parseListResponse(response, WaitlistEntryModel.fromJson);
  }

  /// Offer spot to next waitlisted user (for host)
  Future<ApiResponse<WaitlistEntryModel>> offerSpotToNextUser({
    required int eventId,
  }) async {
    return post<WaitlistEntryModel>(
      '${ApiEndpoints.getWaitlist}/$eventId/offer-spot',
      fromJson: WaitlistEntryModel.fromJson,
    );
  }

  /// Remove user from waitlist (for host)
  Future<ApiResponse<dynamic>> removeFromWaitlist({
    required String waitlistId,
    String? reason,
  }) async {
    return delete(
      '${ApiEndpoints.getWaitlist}/remove/$waitlistId',
    );
  }
}
