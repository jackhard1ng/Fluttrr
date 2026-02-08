import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/guest_model.dart';
import 'base_repository.dart';

/// Repository for guest/bring-a-friend operations
class GuestRepository extends BaseRepository {
  /// Invite a guest to an event
  Future<ApiResponse<GuestModel>> inviteGuest({
    required int eventId,
    required String guestName,
    String? guestPhone,
    String? guestEmail,
    bool sendSms = false,
    bool sendEmail = false,
    String? personalMessage,
  }) async {
    return post<GuestModel>(
      ApiEndpoints.inviteGuest,
      body: {
        'event_id': eventId,
        'guest_name': guestName,
        'guest_phone': guestPhone,
        'guest_email': guestEmail,
        'send_sms': sendSms,
        'send_email': sendEmail,
        'personal_message': personalMessage,
      },
      fromJson: GuestModel.fromJson,
    );
  }

  /// Get guests for an event
  Future<ApiResponse<EventGuestSummary>> getEventGuests({
    required int eventId,
  }) async {
    return get<EventGuestSummary>(
      '${ApiEndpoints.getEventGuests}/$eventId',
      fromJson: EventGuestSummary.fromJson,
    );
  }

  /// Update guest status
  Future<ApiResponse<GuestModel>> updateGuestStatus({
    required String guestId,
    required GuestStatus status,
  }) async {
    return put<GuestModel>(
      ApiEndpoints.updateGuestStatus,
      body: {
        'guest_id': guestId,
        'status': status.name,
      },
      fromJson: GuestModel.fromJson,
    );
  }

  /// Cancel a guest invitation
  Future<ApiResponse<dynamic>> cancelGuestInvite({
    required String guestId,
  }) async {
    return delete(
      '${ApiEndpoints.cancelGuestInvite}/$guestId',
    );
  }

  /// Guest RSVP (public endpoint for guests without account)
  Future<ApiResponse<GuestModel>> guestRsvp({
    required String inviteCode,
    required bool accept,
    String? guestName,
    String? guestEmail,
  }) async {
    return post<GuestModel>(
      ApiEndpoints.guestRsvp,
      body: {
        'invite_code': inviteCode,
        'accept': accept,
        'guest_name': guestName,
        'guest_email': guestEmail,
      },
      fromJson: GuestModel.fromJson,
      requiresAuth: false,
    );
  }

  /// Check-in a guest at the event
  Future<ApiResponse<GuestModel>> checkInGuest({
    required String guestId,
  }) async {
    return put<GuestModel>(
      ApiEndpoints.updateGuestStatus,
      body: {
        'guest_id': guestId,
        'status': GuestStatus.attended.name,
      },
      fromJson: GuestModel.fromJson,
    );
  }

  /// Resend invitation to guest
  Future<ApiResponse<dynamic>> resendInvitation({
    required String guestId,
    bool sendSms = false,
    bool sendEmail = false,
  }) async {
    return post(
      '${ApiEndpoints.inviteGuest}/resend',
      body: {
        'guest_id': guestId,
        'send_sms': sendSms,
        'send_email': sendEmail,
      },
    );
  }
}
