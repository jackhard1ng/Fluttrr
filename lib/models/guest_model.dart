/// Guest status for bring-a-friend feature
enum GuestStatus {
  invited,
  pending,  // Alias for invited - for UI compatibility
  confirmed,
  declined,
  attended,
  checkedIn,  // Alias for attended - for UI compatibility
  noShow,
}

/// Guest model for bring-a-friend feature
class GuestModel {
  final String? guestId;
  final int? eventId;
  final int? invitedByUserId;
  final String? invitedByUserName;
  final String? guestName;
  final String? guestPhone;
  final String? guestEmail;
  final GuestStatus status;
  final DateTime? invitedAt;
  final DateTime? respondedAt;
  final bool isAppUser;
  final int? appUserId;
  final String? inviteCode;
  final String? inviteLink;

  const GuestModel({
    this.guestId,
    this.eventId,
    this.invitedByUserId,
    this.invitedByUserName,
    this.guestName,
    this.guestPhone,
    this.guestEmail,
    this.status = GuestStatus.invited,
    this.invitedAt,
    this.respondedAt,
    this.isAppUser = false,
    this.appUserId,
    this.inviteCode,
    this.inviteLink,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      guestId: json['guest_id']?.toString(),
      eventId: json['event_id'] as int?,
      invitedByUserId: json['invited_by_user_id'] as int?,
      invitedByUserName: json['invited_by_user_name'] as String?,
      guestName: json['guest_name'] as String?,
      guestPhone: json['guest_phone'] as String?,
      guestEmail: json['guest_email'] as String?,
      status: _parseGuestStatus(json['status']),
      invitedAt: _parseDateTime(json['invited_at']),
      respondedAt: _parseDateTime(json['responded_at']),
      isAppUser: json['is_app_user'] == true,
      appUserId: json['app_user_id'] as int?,
      inviteCode: json['invite_code'] as String?,
      inviteLink: json['invite_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guest_id': guestId,
      'event_id': eventId,
      'invited_by_user_id': invitedByUserId,
      'invited_by_user_name': invitedByUserName,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'guest_email': guestEmail,
      'status': status.name,
      'invited_at': invitedAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'is_app_user': isAppUser,
      'app_user_id': appUserId,
      'invite_code': inviteCode,
      'invite_link': inviteLink,
    };
  }

  GuestModel copyWith({
    String? guestId,
    int? eventId,
    int? invitedByUserId,
    String? invitedByUserName,
    String? guestName,
    String? guestPhone,
    String? guestEmail,
    GuestStatus? status,
    DateTime? invitedAt,
    DateTime? respondedAt,
    bool? isAppUser,
    int? appUserId,
    String? inviteCode,
    String? inviteLink,
  }) {
    return GuestModel(
      guestId: guestId ?? this.guestId,
      eventId: eventId ?? this.eventId,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      invitedByUserName: invitedByUserName ?? this.invitedByUserName,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      guestEmail: guestEmail ?? this.guestEmail,
      status: status ?? this.status,
      invitedAt: invitedAt ?? this.invitedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      isAppUser: isAppUser ?? this.isAppUser,
      appUserId: appUserId ?? this.appUserId,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteLink: inviteLink ?? this.inviteLink,
    );
  }

  bool get isPending => status == GuestStatus.invited || status == GuestStatus.pending;
  bool get isConfirmed => status == GuestStatus.confirmed;
  bool get hasResponded => status != GuestStatus.invited && status != GuestStatus.pending;

  /// Convenience getters for UI compatibility
  String? get name => guestName;
  String? get phone => guestPhone;
  String? get email => guestEmail;
}

/// Guest invite request
class GuestInviteRequest {
  final int eventId;
  final String guestName;
  final String? guestPhone;
  final String? guestEmail;
  final bool sendSms;
  final bool sendEmail;
  final String? personalMessage;

  const GuestInviteRequest({
    required this.eventId,
    required this.guestName,
    this.guestPhone,
    this.guestEmail,
    this.sendSms = false,
    this.sendEmail = false,
    this.personalMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'guest_email': guestEmail,
      'send_sms': sendSms,
      'send_email': sendEmail,
      'personal_message': personalMessage,
    };
  }
}

/// Event guest list summary
class EventGuestSummary {
  final int eventId;
  final int maxGuests;
  final int totalInvited;
  final int confirmed;
  final int declined;
  final int pending;
  final List<GuestModel> guests;

  const EventGuestSummary({
    required this.eventId,
    this.maxGuests = 5,
    this.totalInvited = 0,
    this.confirmed = 0,
    this.declined = 0,
    this.pending = 0,
    this.guests = const [],
  });

  factory EventGuestSummary.fromJson(Map<String, dynamic> json) {
    return EventGuestSummary(
      eventId: json['event_id'] as int? ?? 0,
      maxGuests: json['max_guests'] as int? ?? 5,
      totalInvited: json['total_invited'] as int? ?? 0,
      confirmed: json['confirmed'] as int? ?? 0,
      declined: json['declined'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      guests: _parseGuests(json['guests']),
    );
  }

  int get availableSlots => maxGuests - totalInvited;
  bool get canInviteMore => availableSlots > 0;
}

GuestStatus _parseGuestStatus(dynamic value) {
  if (value == null) return GuestStatus.invited;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return GuestStatus.confirmed;
      case 'declined':
        return GuestStatus.declined;
      case 'attended':
        return GuestStatus.attended;
      case 'no_show':
      case 'noshow':
        return GuestStatus.noShow;
      default:
        return GuestStatus.invited;
    }
  }
  return GuestStatus.invited;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<GuestModel> _parseGuests(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => GuestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
