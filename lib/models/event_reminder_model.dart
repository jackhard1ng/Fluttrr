/// Reminder type
enum ReminderType {
  oneHour,
  oneHourBefore, // Alias for oneHour
  oneDay,
  oneDayBefore, // Alias for oneDay
  threeDays,
  oneWeek,
  oneWeekBefore, // Alias for oneWeek
  custom,
}

/// Reminder delivery method
enum ReminderDeliveryMethod {
  push,
  inApp,
  email,
  sms,
}

/// Event reminder model
class EventReminderModel {
  final String? reminderId;
  final int? eventId;
  final int? userId;
  final ReminderType type;
  final List<ReminderDeliveryMethod> deliveryMethods;
  final DateTime? scheduledFor;
  final bool isSent;
  final DateTime? sentAt;
  final bool isEnabled;
  final String? customMessage;

  const EventReminderModel({
    this.reminderId,
    this.eventId,
    this.userId,
    this.type = ReminderType.oneDay,
    this.deliveryMethods = const [ReminderDeliveryMethod.push, ReminderDeliveryMethod.inApp],
    this.scheduledFor,
    this.isSent = false,
    this.sentAt,
    this.isEnabled = true,
    this.customMessage,
  });

  factory EventReminderModel.fromJson(Map<String, dynamic> json) {
    return EventReminderModel(
      reminderId: json['reminder_id']?.toString(),
      eventId: json['event_id'] as int?,
      userId: json['user_id'] as int?,
      type: _parseReminderType(json['type']),
      deliveryMethods: _parseDeliveryMethods(json['delivery_methods']),
      scheduledFor: _parseDateTime(json['scheduled_for']),
      isSent: json['is_sent'] == true,
      sentAt: _parseDateTime(json['sent_at']),
      isEnabled: json['is_enabled'] != false,
      customMessage: json['custom_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminder_id': reminderId,
      'event_id': eventId,
      'user_id': userId,
      'type': type.name,
      'delivery_methods': deliveryMethods.map((m) => m.name).toList(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'is_sent': isSent,
      'sent_at': sentAt?.toIso8601String(),
      'is_enabled': isEnabled,
      'custom_message': customMessage,
    };
  }

  EventReminderModel copyWith({
    String? reminderId,
    int? eventId,
    int? userId,
    ReminderType? type,
    List<ReminderDeliveryMethod>? deliveryMethods,
    DateTime? scheduledFor,
    bool? isSent,
    DateTime? sentAt,
    bool? isEnabled,
    String? customMessage,
  }) {
    return EventReminderModel(
      reminderId: reminderId ?? this.reminderId,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      isEnabled: isEnabled ?? this.isEnabled,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case ReminderType.oneHour:
      case ReminderType.oneHourBefore:
        return '1 hour before';
      case ReminderType.oneDay:
      case ReminderType.oneDayBefore:
        return '1 day before';
      case ReminderType.threeDays:
        return '3 days before';
      case ReminderType.oneWeek:
      case ReminderType.oneWeekBefore:
        return '1 week before';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  Duration get reminderOffset {
    switch (type) {
      case ReminderType.oneHour:
      case ReminderType.oneHourBefore:
        return const Duration(hours: 1);
      case ReminderType.oneDay:
      case ReminderType.oneDayBefore:
        return const Duration(days: 1);
      case ReminderType.threeDays:
        return const Duration(days: 3);
      case ReminderType.oneWeek:
      case ReminderType.oneWeekBefore:
        return const Duration(days: 7);
      case ReminderType.custom:
        return Duration.zero;
    }
  }

  // Convenience getters for UI compatibility
  bool get isActive => isEnabled;
  bool get remindAt1Hour => type == ReminderType.oneHour || type == ReminderType.oneHourBefore;
  bool get remindAt1Day => type == ReminderType.oneDay || type == ReminderType.oneDayBefore;
  bool get remindAt1Week => type == ReminderType.oneWeek || type == ReminderType.oneWeekBefore;
  bool get remindAtAll1Hour => isEnabled && remindAt1Hour;
  bool get remindAtAll1Day => isEnabled && remindAt1Day;
  bool get remindAtAll1Week => isEnabled && remindAt1Week;
}

/// User reminder preferences
class ReminderPreferencesModel {
  final int? userId;
  final bool pushEnabled;
  final bool inAppEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final List<ReminderType> defaultReminders;
  final bool reminderSoundEnabled;
  final String? reminderSound;
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const ReminderPreferencesModel({
    this.userId,
    this.pushEnabled = true,
    this.inAppEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
    this.defaultReminders = const [ReminderType.oneDay, ReminderType.oneHour],
    this.reminderSoundEnabled = true,
    this.reminderSound,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory ReminderPreferencesModel.fromJson(Map<String, dynamic> json) {
    return ReminderPreferencesModel(
      userId: json['user_id'] as int?,
      pushEnabled: json['push_enabled'] != false,
      inAppEnabled: json['in_app_enabled'] != false,
      emailEnabled: json['email_enabled'] == true,
      smsEnabled: json['sms_enabled'] == true,
      defaultReminders: _parseReminderTypes(json['default_reminders']),
      reminderSoundEnabled: json['reminder_sound_enabled'] != false,
      reminderSound: json['reminder_sound'] as String?,
      quietHoursEnabled: json['quiet_hours_enabled'] == true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'push_enabled': pushEnabled,
      'in_app_enabled': inAppEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
      'default_reminders': defaultReminders.map((r) => r.name).toList(),
      'reminder_sound_enabled': reminderSoundEnabled,
      'reminder_sound': reminderSound,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  ReminderPreferencesModel copyWith({
    int? userId,
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    List<ReminderType>? defaultReminders,
    bool? reminderSoundEnabled,
    String? reminderSound,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return ReminderPreferencesModel(
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      defaultReminders: defaultReminders ?? this.defaultReminders,
      reminderSoundEnabled: reminderSoundEnabled ?? this.reminderSoundEnabled,
      reminderSound: reminderSound ?? this.reminderSound,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// Upcoming event reminder notification
class UpcomingEventNotification {
  final int? eventId;
  final String? eventName;
  final String? eventLocation;
  final DateTime? eventDateTime;
  final String? hostName;
  final String? eventImage;
  final Duration timeUntilEvent;
  final bool isCheckedIn;

  const UpcomingEventNotification({
    this.eventId,
    this.eventName,
    this.eventLocation,
    this.eventDateTime,
    this.hostName,
    this.eventImage,
    this.timeUntilEvent = Duration.zero,
    this.isCheckedIn = false,
  });

  factory UpcomingEventNotification.fromJson(Map<String, dynamic> json) {
    final eventDateTime = _parseDateTime(json['event_date_time']);
    return UpcomingEventNotification(
      eventId: json['event_id'] as int?,
      eventName: json['event_name'] as String?,
      eventLocation: json['event_location'] as String?,
      eventDateTime: eventDateTime,
      hostName: json['host_name'] as String?,
      eventImage: json['event_image'] as String?,
      timeUntilEvent: eventDateTime != null
          ? eventDateTime.difference(DateTime.now())
          : Duration.zero,
      isCheckedIn: json['is_checked_in'] == true,
    );
  }

  String get timeUntilDisplay {
    if (timeUntilEvent.isNegative) return 'Started';
    if (timeUntilEvent.inDays > 0) {
      return 'in ${timeUntilEvent.inDays} day${timeUntilEvent.inDays > 1 ? 's' : ''}';
    }
    if (timeUntilEvent.inHours > 0) {
      return 'in ${timeUntilEvent.inHours} hour${timeUntilEvent.inHours > 1 ? 's' : ''}';
    }
    if (timeUntilEvent.inMinutes > 0) {
      return 'in ${timeUntilEvent.inMinutes} minute${timeUntilEvent.inMinutes > 1 ? 's' : ''}';
    }
    return 'Starting now';
  }

  /// Convenience getter for next reminder time (alias for eventDateTime)
  DateTime? get nextReminderAt => eventDateTime;
}

ReminderType _parseReminderType(dynamic value) {
  if (value == null) return ReminderType.oneDay;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'one_hour':
      case 'onehour':
        return ReminderType.oneHour;
      case 'three_days':
      case 'threedays':
        return ReminderType.threeDays;
      case 'one_week':
      case 'oneweek':
        return ReminderType.oneWeek;
      case 'custom':
        return ReminderType.custom;
      default:
        return ReminderType.oneDay;
    }
  }
  return ReminderType.oneDay;
}

List<ReminderDeliveryMethod> _parseDeliveryMethods(dynamic value) {
  if (value == null) return [ReminderDeliveryMethod.push, ReminderDeliveryMethod.inApp];
  if (value is List) {
    return value.map((v) {
      if (v is String) {
        switch (v.toLowerCase()) {
          case 'push':
            return ReminderDeliveryMethod.push;
          case 'in_app':
          case 'inapp':
            return ReminderDeliveryMethod.inApp;
          case 'email':
            return ReminderDeliveryMethod.email;
          case 'sms':
            return ReminderDeliveryMethod.sms;
        }
      }
      return ReminderDeliveryMethod.push;
    }).toList();
  }
  return [ReminderDeliveryMethod.push, ReminderDeliveryMethod.inApp];
}

List<ReminderType> _parseReminderTypes(dynamic value) {
  if (value == null) return [ReminderType.oneDay, ReminderType.oneHour];
  if (value is List) {
    return value.map((v) => _parseReminderType(v)).toList();
  }
  return [ReminderType.oneDay, ReminderType.oneHour];
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
