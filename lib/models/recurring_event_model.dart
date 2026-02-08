/// Recurrence frequency
enum RecurrenceFrequency {
  once,
  daily,
  weekly,
  biweekly,
  monthly,
  yearly,
  custom,
}

/// Days of week for weekly recurrence
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Recurrence rule model
class RecurrenceRuleModel {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<DayOfWeek> daysOfWeek;
  final int? dayOfMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxOccurrences;
  final List<DateTime> exceptions;

  const RecurrenceRuleModel({
    this.frequency = RecurrenceFrequency.weekly,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    this.startDate,
    this.endDate,
    this.maxOccurrences,
    this.exceptions = const [],
  });

  factory RecurrenceRuleModel.fromJson(Map<String, dynamic> json) {
    return RecurrenceRuleModel(
      frequency: _parseFrequency(json['frequency']),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: _parseDaysOfWeek(json['days_of_week']),
      dayOfMonth: json['day_of_month'] as int?,
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      maxOccurrences: json['max_occurrences'] as int?,
      exceptions: _parseDateList(json['exceptions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      'days_of_week': daysOfWeek.map((d) => d.name).toList(),
      'day_of_month': dayOfMonth,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'max_occurrences': maxOccurrences,
      'exceptions': exceptions.map((d) => d.toIso8601String()).toList(),
    };
  }

  RecurrenceRuleModel copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<DayOfWeek>? daysOfWeek,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    int? maxOccurrences,
    List<DateTime>? exceptions,
  }) {
    return RecurrenceRuleModel(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      exceptions: exceptions ?? this.exceptions,
    );
  }

  String get frequencyDisplay {
    switch (frequency) {
      case RecurrenceFrequency.once:
        return 'One Time';
      case RecurrenceFrequency.daily:
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case RecurrenceFrequency.weekly:
        return interval == 1 ? 'Weekly' : 'Every $interval weeks';
      case RecurrenceFrequency.biweekly:
        return 'Every 2 weeks';
      case RecurrenceFrequency.monthly:
        return interval == 1 ? 'Monthly' : 'Every $interval months';
      case RecurrenceFrequency.yearly:
        return interval == 1 ? 'Yearly' : 'Every $interval years';
      case RecurrenceFrequency.custom:
        return 'Custom';
    }
  }

  String get daysOfWeekDisplay {
    if (daysOfWeek.isEmpty) return '';
    return daysOfWeek.map((d) => d.name.substring(0, 3).toUpperCase()).join(', ');
  }

  /// Generate upcoming occurrences
  List<DateTime> generateOccurrences({int count = 10}) {
    final occurrences = <DateTime>[];
    var current = startDate ?? DateTime.now();
    final end = endDate ?? DateTime.now().add(const Duration(days: 365));
    final max = maxOccurrences ?? count;

    while (occurrences.length < max && current.isBefore(end)) {
      if (!exceptions.any((e) => _isSameDay(e, current))) {
        if (_matchesRule(current)) {
          occurrences.add(current);
        }
      }
      current = _nextDate(current);
    }

    return occurrences.take(count).toList();
  }

  bool _matchesRule(DateTime date) {
    if (frequency == RecurrenceFrequency.weekly && daysOfWeek.isNotEmpty) {
      final dayIndex = date.weekday - 1;
      return daysOfWeek.any((d) => d.index == dayIndex);
    }
    if (frequency == RecurrenceFrequency.monthly && dayOfMonth != null) {
      return date.day == dayOfMonth;
    }
    return true;
  }

  DateTime _nextDate(DateTime current) {
    switch (frequency) {
      case RecurrenceFrequency.once:
        return current.add(const Duration(days: 365 * 10)); // Far future to stop iteration
      case RecurrenceFrequency.daily:
        return current.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return current.add(const Duration(days: 1));
      case RecurrenceFrequency.biweekly:
        return current.add(Duration(days: 14 * interval));
      case RecurrenceFrequency.monthly:
        return DateTime(current.year, current.month + interval, current.day);
      case RecurrenceFrequency.yearly:
        return DateTime(current.year + interval, current.month, current.day);
      case RecurrenceFrequency.custom:
        return current.add(Duration(days: interval));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Recurring event model
class RecurringEventModel {
  final String? seriesId;
  final int? templateEventId;
  final String? name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final int? maxAttendees;
  final String? eventType;
  final List<String> images;
  final int? creatorId;
  final String? creatorName;
  final RecurrenceRuleModel recurrenceRule;
  final bool isActive;
  final DateTime? createdAt;
  final List<RecurringEventInstance> upcomingInstances;

  const RecurringEventModel({
    this.seriesId,
    this.templateEventId,
    this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.maxAttendees,
    this.eventType,
    this.images = const [],
    this.creatorId,
    this.creatorName,
    this.recurrenceRule = const RecurrenceRuleModel(),
    this.isActive = true,
    this.createdAt,
    this.upcomingInstances = const [],
  });

  factory RecurringEventModel.fromJson(Map<String, dynamic> json) {
    return RecurringEventModel(
      seriesId: json['series_id']?.toString(),
      templateEventId: json['template_event_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      maxAttendees: json['max_attendees'] as int?,
      eventType: json['event_type'] as String?,
      images: _parseStringList(json['images']),
      creatorId: json['creator_id'] as int?,
      creatorName: json['creator_name'] as String?,
      recurrenceRule: json['recurrence_rule'] != null
          ? RecurrenceRuleModel.fromJson(json['recurrence_rule'] as Map<String, dynamic>)
          : const RecurrenceRuleModel(),
      isActive: json['is_active'] != false,
      createdAt: _parseDateTime(json['created_at']),
      upcomingInstances: _parseInstances(json['upcoming_instances']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'series_id': seriesId,
      'template_event_id': templateEventId,
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
      'creator_id': creatorId,
      'creator_name': creatorName,
      'recurrence_rule': recurrenceRule.toJson(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'upcoming_instances': upcomingInstances.map((i) => i.toJson()).toList(),
    };
  }

  RecurringEventModel copyWith({
    String? seriesId,
    int? templateEventId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    int? maxAttendees,
    String? eventType,
    List<String>? images,
    int? creatorId,
    String? creatorName,
    RecurrenceRuleModel? recurrenceRule,
    bool? isActive,
    DateTime? createdAt,
    List<RecurringEventInstance>? upcomingInstances,
  }) {
    return RecurringEventModel(
      seriesId: seriesId ?? this.seriesId,
      templateEventId: templateEventId ?? this.templateEventId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      eventType: eventType ?? this.eventType,
      images: images ?? this.images,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      upcomingInstances: upcomingInstances ?? this.upcomingInstances,
    );
  }
}

/// Individual instance of a recurring event
class RecurringEventInstance {
  final String? instanceId;
  final String? seriesId;
  final int? eventId;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final bool isCancelled;
  final bool isModified;
  final String? cancellationReason;
  final int? attendeeCount;
  final int? remainingSlots;
  final bool userJoined;

  const RecurringEventInstance({
    this.instanceId,
    this.seriesId,
    this.eventId,
    this.date,
    this.startTime,
    this.endTime,
    this.isCancelled = false,
    this.isModified = false,
    this.cancellationReason,
    this.attendeeCount,
    this.remainingSlots,
    this.userJoined = false,
  });

  factory RecurringEventInstance.fromJson(Map<String, dynamic> json) {
    return RecurringEventInstance(
      instanceId: json['instance_id']?.toString(),
      seriesId: json['series_id']?.toString(),
      eventId: json['event_id'] as int?,
      date: _parseDateTime(json['date']),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isCancelled: json['is_cancelled'] == true,
      isModified: json['is_modified'] == true,
      cancellationReason: json['cancellation_reason'] as String?,
      attendeeCount: json['attendee_count'] as int?,
      remainingSlots: json['remaining_slots'] as int?,
      userJoined: json['user_joined'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance_id': instanceId,
      'series_id': seriesId,
      'event_id': eventId,
      'date': date?.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'is_cancelled': isCancelled,
      'is_modified': isModified,
      'cancellation_reason': cancellationReason,
      'attendee_count': attendeeCount,
      'remaining_slots': remainingSlots,
      'user_joined': userJoined,
    };
  }
}

RecurrenceFrequency _parseFrequency(dynamic value) {
  if (value == null) return RecurrenceFrequency.weekly;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'once':
        return RecurrenceFrequency.once;
      case 'daily':
        return RecurrenceFrequency.daily;
      case 'biweekly':
        return RecurrenceFrequency.biweekly;
      case 'monthly':
        return RecurrenceFrequency.monthly;
      case 'yearly':
        return RecurrenceFrequency.yearly;
      case 'custom':
        return RecurrenceFrequency.custom;
      default:
        return RecurrenceFrequency.weekly;
    }
  }
  return RecurrenceFrequency.weekly;
}

List<DayOfWeek> _parseDaysOfWeek(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((v) {
      if (v is String) {
        switch (v.toLowerCase()) {
          case 'monday':
            return DayOfWeek.monday;
          case 'tuesday':
            return DayOfWeek.tuesday;
          case 'wednesday':
            return DayOfWeek.wednesday;
          case 'thursday':
            return DayOfWeek.thursday;
          case 'friday':
            return DayOfWeek.friday;
          case 'saturday':
            return DayOfWeek.saturday;
          case 'sunday':
            return DayOfWeek.sunday;
        }
      }
      return DayOfWeek.monday;
    }).toList();
  }
  return [];
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<DateTime> _parseDateList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .map((v) => v is String ? DateTime.tryParse(v) : null)
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }
  return [];
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

List<RecurringEventInstance> _parseInstances(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => RecurringEventInstance.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
