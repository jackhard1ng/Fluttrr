/// Waitlist position status
enum WaitlistStatus {
  waiting,
  offered,
  accepted,
  declined,
  expired,
  removed,
  cancelled,
}

/// Waitlist entry model
class WaitlistEntryModel {
  final String? waitlistId;
  final int? eventId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final int position;
  final WaitlistStatus status;
  final DateTime? joinedAt;
  final DateTime? offeredAt;
  final DateTime? offerExpiresAt;
  final DateTime? respondedAt;
  final String? note;
  final int? guestsCount;

  const WaitlistEntryModel({
    this.waitlistId,
    this.eventId,
    this.userId,
    this.userName,
    this.userImage,
    this.position = 0,
    this.status = WaitlistStatus.waiting,
    this.joinedAt,
    this.offeredAt,
    this.offerExpiresAt,
    this.respondedAt,
    this.note,
    this.guestsCount,
  });

  factory WaitlistEntryModel.fromJson(Map<String, dynamic> json) {
    return WaitlistEntryModel(
      waitlistId: json['waitlist_id']?.toString(),
      eventId: json['event_id'] as int?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      position: json['position'] as int? ?? 0,
      status: _parseWaitlistStatus(json['status']),
      joinedAt: _parseDateTime(json['joined_at']),
      offeredAt: _parseDateTime(json['offered_at']),
      offerExpiresAt: _parseDateTime(json['offer_expires_at']),
      respondedAt: _parseDateTime(json['responded_at']),
      note: json['note'] as String?,
      guestsCount: json['guests_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waitlist_id': waitlistId,
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'position': position,
      'status': status.name,
      'joined_at': joinedAt?.toIso8601String(),
      'offered_at': offeredAt?.toIso8601String(),
      'offer_expires_at': offerExpiresAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'note': note,
      'guests_count': guestsCount,
    };
  }

  WaitlistEntryModel copyWith({
    String? waitlistId,
    int? eventId,
    int? userId,
    String? userName,
    String? userImage,
    int? position,
    WaitlistStatus? status,
    DateTime? joinedAt,
    DateTime? offeredAt,
    DateTime? offerExpiresAt,
    DateTime? respondedAt,
    String? note,
    int? guestsCount,
  }) {
    return WaitlistEntryModel(
      waitlistId: waitlistId ?? this.waitlistId,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      position: position ?? this.position,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      offeredAt: offeredAt ?? this.offeredAt,
      offerExpiresAt: offerExpiresAt ?? this.offerExpiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      note: note ?? this.note,
      guestsCount: guestsCount ?? this.guestsCount,
    );
  }

  bool get isWaiting => status == WaitlistStatus.waiting;
  bool get hasOffer => status == WaitlistStatus.offered;
  bool get offerExpired => offerExpiresAt?.isBefore(DateTime.now()) ?? false;

  Duration? get timeUntilOfferExpires {
    if (offerExpiresAt == null) return null;
    return offerExpiresAt!.difference(DateTime.now());
  }

  String get positionDisplay => '#$position';
}

/// Event waitlist summary
class EventWaitlistSummary {
  final int? eventId;
  final int totalWaiting;
  final int spotsAvailable;
  final int pendingOffers;
  final bool waitlistEnabled;
  final int maxWaitlistSize;
  final Duration offerExpireDuration;
  final List<WaitlistEntryModel> entries;
  final WaitlistEntryModel? userEntry;

  const EventWaitlistSummary({
    this.eventId,
    this.totalWaiting = 0,
    this.spotsAvailable = 0,
    this.pendingOffers = 0,
    this.waitlistEnabled = true,
    this.maxWaitlistSize = 50,
    this.offerExpireDuration = const Duration(hours: 24),
    this.entries = const [],
    this.userEntry,
  });

  factory EventWaitlistSummary.fromJson(Map<String, dynamic> json) {
    return EventWaitlistSummary(
      eventId: json['event_id'] as int?,
      totalWaiting: json['total_waiting'] as int? ?? 0,
      spotsAvailable: json['spots_available'] as int? ?? 0,
      pendingOffers: json['pending_offers'] as int? ?? 0,
      waitlistEnabled: json['waitlist_enabled'] != false,
      maxWaitlistSize: json['max_waitlist_size'] as int? ?? 50,
      offerExpireDuration: Duration(
        hours: json['offer_expire_hours'] as int? ?? 24,
      ),
      entries: _parseWaitlistEntries(json['entries']),
      userEntry: json['user_entry'] != null
          ? WaitlistEntryModel.fromJson(json['user_entry'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'total_waiting': totalWaiting,
      'spots_available': spotsAvailable,
      'pending_offers': pendingOffers,
      'waitlist_enabled': waitlistEnabled,
      'max_waitlist_size': maxWaitlistSize,
      'offer_expire_hours': offerExpireDuration.inHours,
      'entries': entries.map((e) => e.toJson()).toList(),
      'user_entry': userEntry?.toJson(),
    };
  }

  bool get isFull => entries.length >= maxWaitlistSize;
  bool get hasAvailableSpots => spotsAvailable > 0;
  bool get userIsOnWaitlist => userEntry != null;
}

/// Join waitlist request
class JoinWaitlistRequest {
  final int eventId;
  final String? note;
  final int? guestsCount;

  const JoinWaitlistRequest({
    required this.eventId,
    this.note,
    this.guestsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'note': note,
      'guests_count': guestsCount,
    };
  }
}

/// Waitlist offer response
class WaitlistOfferResponse {
  final String waitlistId;
  final bool accept;

  const WaitlistOfferResponse({
    required this.waitlistId,
    required this.accept,
  });

  Map<String, dynamic> toJson() {
    return {
      'waitlist_id': waitlistId,
      'accept': accept,
    };
  }
}

WaitlistStatus _parseWaitlistStatus(dynamic value) {
  if (value == null) return WaitlistStatus.waiting;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'offered':
        return WaitlistStatus.offered;
      case 'accepted':
        return WaitlistStatus.accepted;
      case 'declined':
        return WaitlistStatus.declined;
      case 'expired':
        return WaitlistStatus.expired;
      case 'removed':
        return WaitlistStatus.removed;
      case 'cancelled':
        return WaitlistStatus.cancelled;
      default:
        return WaitlistStatus.waiting;
    }
  }
  return WaitlistStatus.waiting;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<WaitlistEntryModel> _parseWaitlistEntries(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => WaitlistEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
