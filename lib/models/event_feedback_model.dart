/// Event feedback and rating model
class EventFeedbackModel {
  final String? feedbackId;
  final int? eventId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final bool isHost;

  const EventFeedbackModel({
    this.feedbackId,
    this.eventId,
    this.userId,
    this.userName,
    this.userImage,
    this.rating = 0,
    this.comment,
    this.createdAt,
    this.isHost = false,
  });

  factory EventFeedbackModel.fromJson(Map<String, dynamic> json) {
    return EventFeedbackModel(
      feedbackId: json['feedback_id']?.toString(),
      eventId: json['event_id'] as int?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      isHost: json['is_host'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedback_id': feedbackId,
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'is_host': isHost,
    };
  }
}

/// Attendee rating (rate other attendees)
class AttendeeRatingModel {
  final String? ratingId;
  final int? eventId;
  final int? raterId;
  final int? ratedUserId;
  final String? ratedUserName;
  final String? ratedUserImage;
  final int rating;
  final List<String> tags;
  final String? comment;
  final DateTime? createdAt;

  const AttendeeRatingModel({
    this.ratingId,
    this.eventId,
    this.raterId,
    this.ratedUserId,
    this.ratedUserName,
    this.ratedUserImage,
    this.rating = 0,
    this.tags = const [],
    this.comment,
    this.createdAt,
  });

  factory AttendeeRatingModel.fromJson(Map<String, dynamic> json) {
    return AttendeeRatingModel(
      ratingId: json['rating_id']?.toString(),
      eventId: json['event_id'] as int?,
      raterId: json['rater_id'] as int?,
      ratedUserId: json['rated_user_id'] as int?,
      ratedUserName: json['rated_user_name'] as String?,
      ratedUserImage: json['rated_user_image'] as String?,
      rating: json['rating'] as int? ?? 0,
      tags: _parseStringList(json['tags']),
      comment: json['comment'] as String?,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'event_id': eventId,
      'rater_id': raterId,
      'rated_user_id': ratedUserId,
      'rated_user_name': ratedUserName,
      'rated_user_image': ratedUserImage,
      'rating': rating,
      'tags': tags,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Post-event summary for hosts
class PostEventSummaryModel {
  final int? eventId;
  final String? eventName;
  final DateTime? eventDate;
  final int totalAttendees;
  final int checkedInCount;
  final double averageRating;
  final int totalRatings;
  final List<EventFeedbackModel> feedback;
  final bool thankYouSent;

  const PostEventSummaryModel({
    this.eventId,
    this.eventName,
    this.eventDate,
    this.totalAttendees = 0,
    this.checkedInCount = 0,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.feedback = const [],
    this.thankYouSent = false,
  });

  factory PostEventSummaryModel.fromJson(Map<String, dynamic> json) {
    return PostEventSummaryModel(
      eventId: json['event_id'] as int?,
      eventName: json['event_name'] as String?,
      eventDate: _parseDateTime(json['event_date']),
      totalAttendees: json['total_attendees'] as int? ?? 0,
      checkedInCount: json['checked_in_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      feedback: _parseFeedback(json['feedback']),
      thankYouSent: json['thank_you_sent'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_date': eventDate?.toIso8601String(),
      'total_attendees': totalAttendees,
      'checked_in_count': checkedInCount,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'feedback': feedback.map((f) => f.toJson()).toList(),
      'thank_you_sent': thankYouSent,
    };
  }
}

/// Rating tags for quick feedback
class RatingTag {
  static const List<String> positive = [
    'Great conversation',
    'Very friendly',
    'Fun to hang with',
    'Good listener',
    'Punctual',
    'Respectful',
    'Would meet again',
  ];

  static const List<String> neutral = [
    'Quiet',
    'Reserved',
    'Distracted',
  ];
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<EventFeedbackModel> _parseFeedback(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => EventFeedbackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
