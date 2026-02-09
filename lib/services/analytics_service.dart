import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics service for tracking user behavior and app events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ USER PROPERTIES ============

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics setUserId error: $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics setUserProperty error: $e');
    }
  }

  /// Set user type (regular, business, premium)
  Future<void> setUserType(String userType) async {
    await setUserProperty(name: 'user_type', value: userType);
  }

  /// Set user age group
  Future<void> setAgeGroup(String ageGroup) async {
    await setUserProperty(name: 'age_group', value: ageGroup);
  }

  /// Set user location
  Future<void> setUserLocation(String location) async {
    await setUserProperty(name: 'location', value: location);
  }

  // ============ SCREEN TRACKING ============

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('Analytics logScreenView error: $e');
    }
  }

  // ============ AUTHENTICATION EVENTS ============

  /// Log sign up
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics logSignUp error: $e');
    }
  }

  /// Log login
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics logLogin error: $e');
    }
  }

  /// Log logout
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
    await setUserId(null);
  }

  // ============ ACTIVITY/EVENT EVENTS ============

  /// Log activity viewed
  Future<void> logActivityViewed({
    required String activityId,
    required String activityName,
    String? category,
    String? businessId,
  }) async {
    await logEvent(
      name: 'activity_viewed',
      parameters: {
        'activity_id': activityId,
        'activity_name': activityName,
        if (category != null) 'category': category,
        if (businessId != null) 'business_id': businessId,
      },
    );
  }

  /// Log RSVP to activity
  Future<void> logActivityRsvp({
    required String activityId,
    required String activityName,
    required int attendeeCount,
  }) async {
    await logEvent(
      name: 'activity_rsvp',
      parameters: {
        'activity_id': activityId,
        'activity_name': activityName,
        'attendee_count': attendeeCount,
      },
    );
  }

  /// Log activity check-in
  Future<void> logActivityCheckIn({
    required String activityId,
    required String activityName,
  }) async {
    await logEvent(
      name: 'activity_check_in',
      parameters: {
        'activity_id': activityId,
        'activity_name': activityName,
      },
    );
  }

  /// Log activity created
  Future<void> logActivityCreated({
    required String activityId,
    required String activityName,
    String? category,
    bool isRecurring = false,
  }) async {
    await logEvent(
      name: 'activity_created',
      parameters: {
        'activity_id': activityId,
        'activity_name': activityName,
        if (category != null) 'category': category,
        'is_recurring': isRecurring,
      },
    );
  }

  /// Log activity shared
  Future<void> logActivityShared({
    required String activityId,
    required String method,
  }) async {
    await logEvent(
      name: 'activity_shared',
      parameters: {
        'activity_id': activityId,
        'share_method': method,
      },
    );
  }

  // ============ SOCIAL EVENTS ============

  /// Log profile viewed
  Future<void> logProfileViewed({required String profileId}) async {
    await logEvent(
      name: 'profile_viewed',
      parameters: {'profile_id': profileId},
    );
  }

  /// Log match made
  Future<void> logMatchMade({required String matchId}) async {
    await logEvent(
      name: 'match_made',
      parameters: {'match_id': matchId},
    );
  }

  /// Log message sent
  Future<void> logMessageSent({
    required String chatId,
    bool isFirstMessage = false,
  }) async {
    await logEvent(
      name: 'message_sent',
      parameters: {
        'chat_id': chatId,
        'is_first_message': isFirstMessage,
      },
    );
  }

  /// Log friend request sent
  Future<void> logFriendRequestSent({required String toUserId}) async {
    await logEvent(
      name: 'friend_request_sent',
      parameters: {'to_user_id': toUserId},
    );
  }

  /// Log bring a friend invite sent
  Future<void> logBringFriendInvite({
    required String activityId,
    required String inviteMethod,
  }) async {
    await logEvent(
      name: 'bring_friend_invite',
      parameters: {
        'activity_id': activityId,
        'invite_method': inviteMethod,
      },
    );
  }

  // ============ BUSINESS EVENTS ============

  /// Log business viewed
  Future<void> logBusinessViewed({
    required String businessId,
    required String businessName,
  }) async {
    await logEvent(
      name: 'business_viewed',
      parameters: {
        'business_id': businessId,
        'business_name': businessName,
      },
    );
  }

  /// Log business followed
  Future<void> logBusinessFollowed({
    required String businessId,
    required String businessName,
  }) async {
    await logEvent(
      name: 'business_followed',
      parameters: {
        'business_id': businessId,
        'business_name': businessName,
      },
    );
  }

  /// Log reward redeemed
  Future<void> logRewardRedeemed({
    required String rewardId,
    required String businessId,
    required int pointsSpent,
  }) async {
    await logEvent(
      name: 'reward_redeemed',
      parameters: {
        'reward_id': rewardId,
        'business_id': businessId,
        'points_spent': pointsSpent,
      },
    );
  }

  // ============ GROUP EVENTS ============

  /// Log group created
  Future<void> logGroupCreated({
    required String groupId,
    required String groupName,
    required int initialMembers,
  }) async {
    await logEvent(
      name: 'group_created',
      parameters: {
        'group_id': groupId,
        'group_name': groupName,
        'initial_members': initialMembers,
      },
    );
  }

  /// Log group joined
  Future<void> logGroupJoined({
    required String groupId,
    required String groupName,
  }) async {
    await logEvent(
      name: 'group_joined',
      parameters: {
        'group_id': groupId,
        'group_name': groupName,
      },
    );
  }

  // ============ MEMORY EVENTS ============

  /// Log memory photo uploaded
  Future<void> logMemoryPhotoUploaded({
    required String activityId,
    required int photoCount,
  }) async {
    await logEvent(
      name: 'memory_photo_uploaded',
      parameters: {
        'activity_id': activityId,
        'photo_count': photoCount,
      },
    );
  }

  /// Log memory viewed
  Future<void> logMemoryViewed({
    required String activityId,
  }) async {
    await logEvent(
      name: 'memory_viewed',
      parameters: {'activity_id': activityId},
    );
  }

  // ============ SUBSCRIPTION EVENTS ============

  /// Log subscription started
  Future<void> logSubscriptionStarted({
    required String planId,
    required double price,
    required String currency,
  }) async {
    await logEvent(
      name: 'subscription_started',
      parameters: {
        'plan_id': planId,
        'price': price,
        'currency': currency,
      },
    );
  }

  /// Log subscription cancelled
  Future<void> logSubscriptionCancelled({
    required String planId,
    String? reason,
  }) async {
    await logEvent(
      name: 'subscription_cancelled',
      parameters: {
        'plan_id': planId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  // ============ ENGAGEMENT EVENTS ============

  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    String? category,
    int? resultsCount,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        numberOfResults: resultsCount,
      );
    } catch (e) {
      debugPrint('Analytics logSearch error: $e');
    }
  }

  /// Log notification received
  Future<void> logNotificationReceived({
    required String notificationType,
  }) async {
    await logEvent(
      name: 'notification_received',
      parameters: {'notification_type': notificationType},
    );
  }

  /// Log notification tapped
  Future<void> logNotificationTapped({
    required String notificationType,
  }) async {
    await logEvent(
      name: 'notification_tapped',
      parameters: {'notification_type': notificationType},
    );
  }

  /// Log feedback submitted
  Future<void> logFeedbackSubmitted({
    required String activityId,
    required int rating,
  }) async {
    await logEvent(
      name: 'feedback_submitted',
      parameters: {
        'activity_id': activityId,
        'rating': rating,
      },
    );
  }

  /// Log icebreaker used
  Future<void> logIcebreakerUsed({
    required String chatId,
    required String icebreakerId,
  }) async {
    await logEvent(
      name: 'icebreaker_used',
      parameters: {
        'chat_id': chatId,
        'icebreaker_id': icebreakerId,
      },
    );
  }

  // ============ MAP EVENTS ============

  /// Log map view opened
  Future<void> logMapViewOpened() async {
    await logEvent(name: 'map_view_opened');
  }

  /// Log map marker tapped
  Future<void> logMapMarkerTapped({
    required String activityId,
  }) async {
    await logEvent(
      name: 'map_marker_tapped',
      parameters: {'activity_id': activityId},
    );
  }

  // ============ ERROR EVENTS ============

  /// Log error occurred
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage.length > 100
            ? errorMessage.substring(0, 100)
            : errorMessage,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  // ============ GENERIC EVENT LOGGING ============

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (kDebugMode) {
        debugPrint('Analytics event: $name - $parameters');
      }
    } catch (e) {
      debugPrint('Analytics logEvent error: $e');
    }
  }

  // ============ CONVERSION TRACKING ============

  /// Log tutorial completed
  Future<void> logTutorialComplete() async {
    try {
      await _analytics.logTutorialComplete();
    } catch (e) {
      debugPrint('Analytics logTutorialComplete error: $e');
    }
  }

  /// Log app open
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics logAppOpen error: $e');
    }
  }

  /// Set analytics collection enabled/disabled
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics setAnalyticsCollectionEnabled error: $e');
    }
  }

  // ============ ALIASES FOR COMPATIBILITY ============

  /// Track event (alias for logEvent)
  Future<void> trackEvent(String name, {Map<String, Object>? parameters}) =>
      logEvent(name: name, parameters: parameters);
}
