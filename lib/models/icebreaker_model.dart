/// Icebreaker type
enum IcebreakerType {
  question,
  game,
  challenge,
  poll,
  wouldYouRather,
  twoTruthsOneLie,
  thisOrThat,
}

/// Icebreaker category
enum IcebreakerCategory {
  gettingToKnow,
  funAndSilly,
  deep,
  professional,
  creative,
  physical,
}

/// Icebreaker model
class IcebreakerModel {
  final String? icebreakerId;
  final String? question;
  final String? prompt;
  final IcebreakerType type;
  final IcebreakerCategory category;
  final List<String> options;
  final int? timeLimit;
  final bool isCustom;
  final int? creatorId;
  final int usageCount;
  final double rating;

  const IcebreakerModel({
    this.icebreakerId,
    this.question,
    this.prompt,
    this.type = IcebreakerType.question,
    this.category = IcebreakerCategory.gettingToKnow,
    this.options = const [],
    this.timeLimit,
    this.isCustom = false,
    this.creatorId,
    this.usageCount = 0,
    this.rating = 0.0,
  });

  factory IcebreakerModel.fromJson(Map<String, dynamic> json) {
    return IcebreakerModel(
      icebreakerId: json['icebreaker_id']?.toString(),
      question: json['question'] as String?,
      prompt: json['prompt'] as String?,
      type: _parseIcebreakerType(json['type']),
      category: _parseIcebreakerCategory(json['category']),
      options: _parseStringList(json['options']),
      timeLimit: json['time_limit'] as int?,
      isCustom: json['is_custom'] == true,
      creatorId: json['creator_id'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icebreaker_id': icebreakerId,
      'question': question,
      'prompt': prompt,
      'type': type.name,
      'category': category.name,
      'options': options,
      'time_limit': timeLimit,
      'is_custom': isCustom,
      'creator_id': creatorId,
      'usage_count': usageCount,
      'rating': rating,
    };
  }

  String get displayText => question ?? prompt ?? '';

  String get typeDisplay {
    switch (type) {
      case IcebreakerType.question:
        return 'Question';
      case IcebreakerType.game:
        return 'Game';
      case IcebreakerType.challenge:
        return 'Challenge';
      case IcebreakerType.poll:
        return 'Poll';
      case IcebreakerType.wouldYouRather:
        return 'Would You Rather';
      case IcebreakerType.twoTruthsOneLie:
        return 'Two Truths & A Lie';
      case IcebreakerType.thisOrThat:
        return 'This or That';
    }
  }

  String get categoryDisplay {
    switch (category) {
      case IcebreakerCategory.gettingToKnow:
        return 'Getting to Know';
      case IcebreakerCategory.funAndSilly:
        return 'Fun & Silly';
      case IcebreakerCategory.deep:
        return 'Deep & Meaningful';
      case IcebreakerCategory.professional:
        return 'Professional';
      case IcebreakerCategory.creative:
        return 'Creative';
      case IcebreakerCategory.physical:
        return 'Physical Activity';
    }
  }
}

/// Icebreaker response from a user
class IcebreakerResponseModel {
  final String? responseId;
  final String? icebreakerId;
  final int? eventId;
  final int? userId;
  final String? userName;
  final String? userImage;
  final String? answer;
  final int? selectedOptionIndex;
  final List<int> votes;
  final DateTime? respondedAt;
  final List<IcebreakerReaction> reactions;

  const IcebreakerResponseModel({
    this.responseId,
    this.icebreakerId,
    this.eventId,
    this.userId,
    this.userName,
    this.userImage,
    this.answer,
    this.selectedOptionIndex,
    this.votes = const [],
    this.respondedAt,
    this.reactions = const [],
  });

  factory IcebreakerResponseModel.fromJson(Map<String, dynamic> json) {
    return IcebreakerResponseModel(
      responseId: json['response_id']?.toString(),
      icebreakerId: json['icebreaker_id']?.toString(),
      eventId: json['event_id'] as int?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userImage: json['user_image'] as String?,
      answer: json['answer'] as String?,
      selectedOptionIndex: json['selected_option_index'] as int?,
      votes: _parseIntList(json['votes']),
      respondedAt: _parseDateTime(json['responded_at']),
      reactions: _parseReactions(json['reactions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_id': responseId,
      'icebreaker_id': icebreakerId,
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'answer': answer,
      'selected_option_index': selectedOptionIndex,
      'votes': votes,
      'responded_at': respondedAt?.toIso8601String(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
    };
  }
}

/// Reaction to an icebreaker response
class IcebreakerReaction {
  final int? userId;
  final String emoji;
  final DateTime? reactedAt;

  const IcebreakerReaction({
    this.userId,
    this.emoji = '',
    this.reactedAt,
  });

  factory IcebreakerReaction.fromJson(Map<String, dynamic> json) {
    return IcebreakerReaction(
      userId: json['user_id'] as int?,
      emoji: json['emoji'] as String? ?? '',
      reactedAt: _parseDateTime(json['reacted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'emoji': emoji,
      'reacted_at': reactedAt?.toIso8601String(),
    };
  }
}

/// Event icebreaker session
class EventIcebreakerSession {
  final String? sessionId;
  final int? eventId;
  final IcebreakerModel? currentIcebreaker;
  final List<IcebreakerModel> queue;
  final List<IcebreakerResponseModel> responses;
  final bool isActive;
  final DateTime? startedAt;
  final int participantCount;

  const EventIcebreakerSession({
    this.sessionId,
    this.eventId,
    this.currentIcebreaker,
    this.queue = const [],
    this.responses = const [],
    this.isActive = false,
    this.startedAt,
    this.participantCount = 0,
  });

  factory EventIcebreakerSession.fromJson(Map<String, dynamic> json) {
    return EventIcebreakerSession(
      sessionId: json['session_id']?.toString(),
      eventId: json['event_id'] as int?,
      currentIcebreaker: json['current_icebreaker'] != null
          ? IcebreakerModel.fromJson(json['current_icebreaker'] as Map<String, dynamic>)
          : null,
      queue: _parseIcebreakers(json['queue']),
      responses: _parseResponses(json['responses']),
      isActive: json['is_active'] == true,
      startedAt: _parseDateTime(json['started_at']),
      participantCount: json['participant_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'event_id': eventId,
      'current_icebreaker': currentIcebreaker?.toJson(),
      'queue': queue.map((i) => i.toJson()).toList(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'is_active': isActive,
      'started_at': startedAt?.toIso8601String(),
      'participant_count': participantCount,
    };
  }
}

/// Default icebreakers library
class IcebreakerLibrary {
  static const List<Map<String, dynamic>> gettingToKnow = [
    {
      'question': 'What\'s one thing you\'re passionate about that might surprise people?',
      'type': 'question',
      'category': 'gettingToKnow',
    },
    {
      'question': 'If you could have dinner with anyone, dead or alive, who would it be?',
      'type': 'question',
      'category': 'gettingToKnow',
    },
    {
      'question': 'What\'s your go-to karaoke song?',
      'type': 'question',
      'category': 'gettingToKnow',
    },
    {
      'question': 'What\'s the best trip you\'ve ever taken?',
      'type': 'question',
      'category': 'gettingToKnow',
    },
    {
      'question': 'What\'s your hidden talent?',
      'type': 'question',
      'category': 'gettingToKnow',
    },
  ];

  static const List<Map<String, dynamic>> wouldYouRather = [
    {
      'question': 'Would you rather travel back in time or into the future?',
      'type': 'wouldYouRather',
      'options': ['Back in time', 'Into the future'],
      'category': 'funAndSilly',
    },
    {
      'question': 'Would you rather have unlimited money or unlimited time?',
      'type': 'wouldYouRather',
      'options': ['Unlimited money', 'Unlimited time'],
      'category': 'deep',
    },
    {
      'question': 'Would you rather be able to fly or be invisible?',
      'type': 'wouldYouRather',
      'options': ['Fly', 'Be invisible'],
      'category': 'funAndSilly',
    },
  ];

  static const List<Map<String, dynamic>> thisOrThat = [
    {
      'question': 'Morning person or night owl?',
      'type': 'thisOrThat',
      'options': ['Morning person', 'Night owl'],
      'category': 'gettingToKnow',
    },
    {
      'question': 'Coffee or tea?',
      'type': 'thisOrThat',
      'options': ['Coffee', 'Tea'],
      'category': 'gettingToKnow',
    },
    {
      'question': 'Beach or mountains?',
      'type': 'thisOrThat',
      'options': ['Beach', 'Mountains'],
      'category': 'gettingToKnow',
    },
    {
      'question': 'Books or movies?',
      'type': 'thisOrThat',
      'options': ['Books', 'Movies'],
      'category': 'gettingToKnow',
    },
  ];

  static const List<Map<String, dynamic>> challenges = [
    {
      'prompt': 'Introduce yourself in exactly 10 words',
      'type': 'challenge',
      'category': 'creative',
      'time_limit': 60,
    },
    {
      'prompt': 'Share your best dad joke',
      'type': 'challenge',
      'category': 'funAndSilly',
    },
    {
      'prompt': 'Describe your ideal weekend in one sentence',
      'type': 'challenge',
      'category': 'gettingToKnow',
    },
  ];

  static List<IcebreakerModel> getRandomIcebreakers({int count = 5}) {
    final all = [
      ...gettingToKnow,
      ...wouldYouRather,
      ...thisOrThat,
      ...challenges,
    ];
    all.shuffle();
    return all.take(count).map((json) => IcebreakerModel.fromJson(json)).toList();
  }

  static List<IcebreakerModel> getByCategory(IcebreakerCategory category, {int count = 5}) {
    final all = [
      ...gettingToKnow,
      ...wouldYouRather,
      ...thisOrThat,
      ...challenges,
    ];
    final filtered = all.where((json) {
      final cat = _parseIcebreakerCategory(json['category']);
      return cat == category;
    }).toList();
    filtered.shuffle();
    return filtered.take(count).map((json) => IcebreakerModel.fromJson(json)).toList();
  }
}

IcebreakerType _parseIcebreakerType(dynamic value) {
  if (value == null) return IcebreakerType.question;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'game':
        return IcebreakerType.game;
      case 'challenge':
        return IcebreakerType.challenge;
      case 'poll':
        return IcebreakerType.poll;
      case 'wouldyourather':
      case 'would_you_rather':
        return IcebreakerType.wouldYouRather;
      case 'twotruthsonelie':
      case 'two_truths_one_lie':
        return IcebreakerType.twoTruthsOneLie;
      case 'thisorthat':
      case 'this_or_that':
        return IcebreakerType.thisOrThat;
      default:
        return IcebreakerType.question;
    }
  }
  return IcebreakerType.question;
}

IcebreakerCategory _parseIcebreakerCategory(dynamic value) {
  if (value == null) return IcebreakerCategory.gettingToKnow;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'funandsilly':
      case 'fun_and_silly':
        return IcebreakerCategory.funAndSilly;
      case 'deep':
        return IcebreakerCategory.deep;
      case 'professional':
        return IcebreakerCategory.professional;
      case 'creative':
        return IcebreakerCategory.creative;
      case 'physical':
        return IcebreakerCategory.physical;
      default:
        return IcebreakerCategory.gettingToKnow;
    }
  }
  return IcebreakerCategory.gettingToKnow;
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

List<int> _parseIntList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<int>().toList();
  }
  return [];
}

List<IcebreakerReaction> _parseReactions(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => IcebreakerReaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

List<IcebreakerModel> _parseIcebreakers(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => IcebreakerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

List<IcebreakerResponseModel> _parseResponses(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => IcebreakerResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
