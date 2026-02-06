import 'dart:math';

/// Service providing mock data for demo/testing purposes
class MockDataService {
  MockDataService._();

  static final Random _random = Random();

  /// List of sample first names
  static const List<String> _firstNames = [
    'Emma', 'Liam', 'Olivia', 'Noah', 'Ava', 'Ethan', 'Sophia', 'Mason',
    'Isabella', 'William', 'Mia', 'James', 'Charlotte', 'Oliver', 'Amelia',
    'Benjamin', 'Harper', 'Lucas', 'Evelyn', 'Henry', 'Luna', 'Alexander',
    'Chloe', 'Sebastian', 'Penelope', 'Jack', 'Layla', 'Aiden', 'Riley',
    'Owen', 'Zoey', 'Samuel', 'Nora', 'Ryan', 'Lily', 'Nathan', 'Eleanor',
    'Caleb', 'Hannah', 'Dylan', 'Lillian', 'Leo', 'Addison', 'Isaac',
  ];

  /// List of sample last names
  static const List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
    'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez',
    'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
    'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark',
    'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King',
  ];

  /// List of sample locations
  static const List<String> _locations = [
    'Downtown', 'Midtown', 'Brooklyn', 'Queens', 'Upper East Side',
    'West Village', 'SoHo', 'Chelsea', 'Williamsburg', 'Tribeca',
    'East Village', 'Harlem', 'Astoria', 'Park Slope', 'Bushwick',
  ];

  /// List of sample interests
  static const List<String> _interests = [
    'Hiking', 'Photography', 'Cooking', 'Reading', 'Yoga', 'Gaming',
    'Music', 'Art', 'Travel', 'Coffee', 'Movies', 'Fitness', 'Dancing',
    'Board Games', 'Volunteering', 'Cycling', 'Running', 'Meditation',
    'Crafts', 'Writing', 'Podcasts', 'Tech', 'Nature', 'Food',
    'Wine Tasting', 'Book Club', 'Camping', 'Concerts', 'Museums',
  ];

  /// List of sample bios
  static const List<String> _bios = [
    "Love exploring new coffee shops and hiking trails. Always looking for adventure buddies!",
    "Foodie at heart. Let's grab brunch and talk about life!",
    "New to the city and looking to make genuine connections. Book lover and amateur chef.",
    "Tech enthusiast by day, board game fanatic by night. Looking for game night friends!",
    "Yoga instructor who loves outdoor activities. Let's find inner peace together!",
    "Creative soul searching for like-minded friends. Art exhibitions and concerts are my thing.",
    "Work from home and miss social interactions. Coffee dates and walks in the park?",
    "Fitness junkie looking for workout buddies. No judgments, just good vibes!",
    "Recently relocated and building my friend circle. Love cooking and hosting dinner parties.",
    "Music lover and amateur photographer. Looking for concert buddies!",
    "Introvert trying to be more social. Love deep conversations and quiet cafes.",
    "Dog parent looking for puppy playdate friends. Also enjoy hiking and movies!",
    "Graduate student seeking study buddies and stress relief friends!",
    "Retired and young at heart. Love teaching and learning new things.",
    "Just moved here for work. Looking for friends to explore the city with!",
  ];

  /// List of sample activity names
  static const List<String> _activityNames = [
    'Morning Yoga in the Park',
    'Coffee & Conversation',
    'Weekend Hiking Adventure',
    'Board Game Night',
    'Photography Walk',
    'Cooking Class',
    'Book Club Meeting',
    'Running Group',
    'Art Gallery Visit',
    'Volunteer at Food Bank',
    'Movie Night',
    'Trivia Night',
    'Wine Tasting',
    'Meditation Session',
    'Language Exchange',
    'Potluck Dinner',
    'Museum Tour',
    'Beach Cleanup',
    'Karaoke Night',
    'Bike Ride',
    'Brunch Buddies',
    'Sunset Picnic',
    'Dance Class',
    'Open Mic Night',
  ];

  /// List of sample activity types
  static const List<String> _activityTypes = [
    'Outdoor', 'Social', 'Sports', 'Arts', 'Food', 'Wellness',
    'Learning', 'Volunteering', 'Entertainment', 'Adventure',
  ];

  /// List of sample venues
  static const List<String> _venues = [
    'Central Park', 'The Local Coffee House', 'Community Center',
    'Riverside Trail', 'Art Studio Downtown', 'The Wine Bar',
    'Public Library', 'Yoga Studio', 'The Game Cafe', 'Beach Park',
    'Museum of Art', 'Food Hall', 'The Jazz Club', 'Mountain Trail',
  ];

  /// List of sample avatar URLs (using UI Avatars API for consistent placeholders)
  static String getAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    final colors = ['0080FF', '2DD4BF', '8B5CF6', 'FF6B9D', 'FB923C'];
    final color = colors[_random.nextInt(colors.length)];
    return 'https://ui-avatars.com/api/?name=$encodedName&background=$color&color=fff&size=256&bold=true';
  }

  /// Generate a random mock user
  static Map<String, dynamic> generateMockUser({int? id}) {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];
    final fullName = '$firstName $lastName';
    final age = 18 + _random.nextInt(45);
    final userInterests = List.generate(
      3 + _random.nextInt(4),
      (_) => _interests[_random.nextInt(_interests.length)],
    ).toSet().toList();

    return {
      'userId': id ?? _random.nextInt(10000),
      'name': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}@email.com',
      'age': age,
      'gender': _random.nextBool() ? 'Male' : 'Female',
      'location': _locations[_random.nextInt(_locations.length)],
      'bio': _bios[_random.nextInt(_bios.length)],
      'interests': userInterests,
      'profileImage': getAvatarUrl(fullName),
      'isOnline': _random.nextDouble() > 0.6,
      'distance': (0.5 + _random.nextDouble() * 15).toStringAsFixed(1),
      'createdAt': DateTime.now().subtract(Duration(days: _random.nextInt(365))).toIso8601String(),
    };
  }

  /// Generate a list of mock users
  static List<Map<String, dynamic>> generateMockUsers(int count) {
    return List.generate(count, (index) => generateMockUser(id: 1000 + index));
  }

  /// Generate a random mock activity with proper attendee data
  static Map<String, dynamic> generateMockActivity({int? id, bool? hasLimit}) {
    final activityName = _activityNames[_random.nextInt(_activityNames.length)];
    final host = generateMockUser();
    final attendeeCount = 2 + _random.nextInt(12);

    // Some activities have no limit (null), some have limits
    final bool shouldHaveLimit = hasLimit ?? _random.nextDouble() > 0.4;
    final int? maxAttendees = shouldHaveLimit
        ? attendeeCount + _random.nextInt(10) + 3
        : null;

    final daysFromNow = _random.nextInt(14);
    final hour = 8 + _random.nextInt(12);

    // Generate actual attendee data with profile images
    final attendees = List.generate(
      attendeeCount,
      (index) {
        final user = generateMockUser(id: 6000 + (id ?? 0) * 100 + index);
        return {
          'userId': user['userId'],
          'name': user['name'],
          'profileImage': user['profileImage'],
        };
      },
    );

    // Some events are hosted by business accounts
    final isBusinessHost = _random.nextDouble() > 0.6;

    return {
      'activityId': id ?? _random.nextInt(10000),
      'name': activityName,
      'description': 'Join us for a fun $activityName! All skill levels welcome. '
          "Let's make new friends and have a great time together.",
      'eventType': _activityTypes[_random.nextInt(_activityTypes.length)],
      'location': _venues[_random.nextInt(_venues.length)],
      'date': DateTime.now().add(Duration(days: daysFromNow)).toIso8601String(),
      'time': '${hour.toString().padLeft(2, '0')}:00',
      'hostId': host['userId'],
      'hostName': isBusinessHost ? '${host['name']} Events' : host['name'],
      'hostImage': host['profileImage'],
      'isBusinessHost': isBusinessHost,
      'attendeeCount': attendeeCount,
      'maxAttendees': maxAttendees,
      'attendees': attendees,
      'primaryImage': null,
      'userJoined': _random.nextDouble() > 0.7,
      'isSaved': _random.nextDouble() > 0.8,
    };
  }

  /// Generate a list of mock activities
  static List<Map<String, dynamic>> generateMockActivities(int count) {
    return List.generate(count, (index) => generateMockActivity(id: 2000 + index));
  }

  /// Generate a mock chat conversation
  static Map<String, dynamic> generateMockChat({int? id, Map<String, dynamic>? otherUser}) {
    final user = otherUser ?? generateMockUser();
    final messages = generateMockMessages(user, 3 + _random.nextInt(8));
    final lastMessage = messages.isNotEmpty ? messages.last : null;

    return {
      'chatId': id ?? _random.nextInt(10000),
      'otherUserId': user['userId'],
      'otherUserName': user['name'],
      'otherUserImage': user['profileImage'],
      'isOnline': user['isOnline'],
      'lastMessage': lastMessage?['text'] ?? 'Say hello!',
      'lastMessageTime': lastMessage?['timestamp'] ?? DateTime.now().toIso8601String(),
      'unreadCount': _random.nextDouble() > 0.6 ? _random.nextInt(5) : 0,
      'messages': messages,
    };
  }

  /// Sample chat messages
  static const List<String> _sampleMessages = [
    "Hey! Nice to meet you!",
    "How's your day going?",
    "Would love to hang out sometime!",
    "That activity looks fun! Are you going?",
    "I saw we have similar interests!",
    "What's your favorite spot in the city?",
    "Have you tried that new coffee place?",
    "I'm thinking of joining the hiking group",
    "Do you want to grab coffee sometime?",
    "That sounds amazing!",
    "I'd love to!",
    "When works for you?",
    "How about this weekend?",
    "Perfect! Looking forward to it!",
    "See you then! 😊",
    "Thanks for reaching out!",
    "Let me know what you think!",
    "Have a great day!",
  ];

  /// Generate mock messages for a conversation
  static List<Map<String, dynamic>> generateMockMessages(Map<String, dynamic> otherUser, int count) {
    final messages = <Map<String, dynamic>>[];
    var currentTime = DateTime.now().subtract(Duration(hours: count * 2));

    for (int i = 0; i < count; i++) {
      final isFromMe = _random.nextBool();
      currentTime = currentTime.add(Duration(minutes: 5 + _random.nextInt(60)));

      messages.add({
        'messageId': _random.nextInt(100000),
        'text': _sampleMessages[_random.nextInt(_sampleMessages.length)],
        'senderId': isFromMe ? 'me' : otherUser['userId'],
        'senderName': isFromMe ? 'Me' : otherUser['name'],
        'timestamp': currentTime.toIso8601String(),
        'isRead': true,
      });
    }

    return messages;
  }

  /// Generate a list of mock chats
  static List<Map<String, dynamic>> generateMockChats(int count) {
    return List.generate(count, (index) => generateMockChat(id: 3000 + index));
  }

  /// Generate mock matches (mutual connections)
  static List<Map<String, dynamic>> generateMockMatches(int count) {
    return List.generate(count, (index) {
      final user = generateMockUser(id: 4000 + index);
      return {
        ...user,
        'matchedAt': DateTime.now().subtract(Duration(days: _random.nextInt(30))).toIso8601String(),
        'hasChat': _random.nextBool(),
      };
    });
  }

  /// Generate mock notifications
  static List<Map<String, dynamic>> generateMockNotifications(int count) {
    final types = ['match', 'message', 'activity', 'like'];
    final notifications = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      final type = types[_random.nextInt(types.length)];
      final user = generateMockUser();
      String title, body;

      switch (type) {
        case 'match':
          title = 'New Friend Connection!';
          body = '${user['name']} wants to be friends!';
          break;
        case 'message':
          title = 'New Message';
          body = '${user['name']}: ${_sampleMessages[_random.nextInt(_sampleMessages.length)]}';
          break;
        case 'activity':
          final activity = _activityNames[_random.nextInt(_activityNames.length)];
          title = 'Activity Reminder';
          body = '$activity is happening soon!';
          break;
        case 'like':
          title = 'Someone waved at you!';
          body = '${user['name']} wants to connect';
          break;
        default:
          title = 'Notification';
          body = 'You have a new notification';
      }

      notifications.add({
        'notificationId': 5000 + i,
        'type': type,
        'title': title,
        'body': body,
        'userId': user['userId'],
        'userImage': user['profileImage'],
        'isRead': _random.nextDouble() > 0.4,
        'createdAt': DateTime.now().subtract(Duration(hours: _random.nextInt(72))).toIso8601String(),
      });
    }

    return notifications;
  }

  /// Get demo profile data
  static Map<String, dynamic> getDemoProfile() {
    return {
      'userId': 1,
      'name': 'Demo User',
      'firstName': 'Demo',
      'lastName': 'User',
      'email': 'demo@fluttrr.app',
      'age': 28,
      'gender': 'Other',
      'location': 'Your City',
      'bio': 'Welcome to Fluttrr! Edit your profile to personalize your experience and start making new friends.',
      'interests': ['Making Friends', 'Exploring', 'Having Fun'],
      'profileImage': getAvatarUrl('Demo User'),
      'isOnline': true,
      'isPremium': false,
      'profileCompletion': 60,
    };
  }
}
