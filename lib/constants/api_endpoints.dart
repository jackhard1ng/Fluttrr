import '../config/environment.dart';

/// API endpoint configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL from environment configuration
  static String get baseUrl => AppConfig.baseUrl;
  static String get apiBase => '$baseUrl/api';

  /// Get the full URL for an image path
  /// Handles relative paths and ensures the URL is valid
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    // Already a full URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Relative path starting with /
    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    }
    // Relative path without leading /
    return '$baseUrl/$imagePath';
  }

  /// Check if an image URL is valid
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final fullUrl = getImageUrl(url);
    return fullUrl.startsWith('http://') || fullUrl.startsWith('https://');
  }

  // Authentication endpoints
  static String get login => '$apiBase/user/login';
  static String get verifyOtp => '$apiBase/user/verify-otp';
  static String get sendOtp => '$apiBase/user/send-otp';
  static String get googleLogin => '$apiBase/user/google-login';
  static String get changePassword => '$apiBase/user/change-password';
  static String get resetPassword => '$apiBase/user/reset-password';
  static String get requestOtp => '$apiBase/user/request-otp';
  static String get verifyResetOtp => '$apiBase/user/verify-reset-otp';
  static String get refreshToken => '$apiBase/user/refresh-token';

  // Profile endpoints
  static String get profile => '$apiBase/user/profile';
  static String get updateProfile => '$apiBase/user/update';
  static String get createProfile => '$apiBase/user/create-profile';
  static String get updateLocation => '$apiBase/user/update-location';
  static String get updateFcmToken => '$apiBase/user/token';
  static String get setOnline => '$apiBase/user/online';
  static String get setOffline => '$apiBase/user/offline';
  static String get profileCompletion => '$apiBase/user/monitoring';

  // Gallery endpoints
  static String get galleryList => '$apiBase/gallery/list';
  static String get galleryUpload => '$apiBase/gallery/upload';

  // Activity endpoints
  static String get dailyActivities => '$apiBase/activity/daily-activities';
  static String get activityList => '$apiBase/activity/list';
  static String get createActivity => '$apiBase/activity/create-activity';
  static String get activityDetails => '$apiBase/activity/activity-details';
  static String get myActivities => '$apiBase/activity/my-activity';
  static String get joinActivity => '$apiBase/activity/join';
  static String get leaveActivity => '$apiBase/activity/leave';
  static String get saveActivity => '$apiBase/activity/save';
  static String get searchActivities => '$apiBase/activity/search';
  static String get updateActivity => '$apiBase/activity/update';
  static String get deleteActivity => '$apiBase/activity/delete';
  static String get upcomingActivities => '$apiBase/activity/upcoming';
  static String get createdActivitiesCount => '$apiBase/activity/created-activities-count';
  static String get joinedActivitiesCount => '$apiBase/activity/joined-activities-count';
  static String get userActivities => '$apiBase/activity/user-activities';

  // Mates endpoints
  static String get filterMates => '$apiBase/mate/filter';
  static String get nearbyMates => '$apiBase/mate/nearby';
  static String get findNearbyMates => '$apiBase/mate/find-nearby-mates';
  static String get likeMate => '$apiBase/mate/like';
  static String get likedMates => '$apiBase/mate/liked-mates';
  static String get totalMates => '$apiBase/mate/total-mates';
  static String get matchList => '$apiBase/user/match';
  static String get searchUsers => '$apiBase/user/search';
  static String get userList => '$apiBase/user/List';

  // Privacy endpoints
  static String get privacyProfile => '$apiBase/privacy/profile';
  static String get updatePrivacy => '$apiBase/privacy/updatePrivacy';
  static String get getPrivacy => '$apiBase/privacy/getPrivacySettings';

  // Chat endpoints
  static String get sendMessage => '$apiBase/message/send';
  static String get chatList => '$apiBase/message/chatlist';
  static String get groupList => '$apiBase/message/grouplist';
  static String get markAsRead => '$apiBase/message/markAsRead';
  static String get businessChatList => '$apiBase/message/getChatList';
  static String get sendBusinessMessage => '$apiBase/message/sendB';

  // Business authentication endpoints
  static String get businessLogin => '$apiBase/business/login';
  static String get businessRegister => '$apiBase/business/register';
  static String get businessRequestOtp => '$apiBase/business/request-otp';
  static String get businessVerify => '$apiBase/business/verify';
  static String get businessProfile => '$apiBase/business/profile';
  static String get createBusinessProfile => '$apiBase/business/create-profile';
  static String get updateBusinessProfile => '$apiBase/business/update/';
  static String get businessStatus => '$apiBase/business/status';
  static String get businessProfileImage => '$apiBase/business/upload-profile-image';
  static String get businessCoverImage => '$apiBase/business/upload-cover-image';

  // Business events endpoints
  static String get businessEventList => '$apiBase/business/list';
  static String get createBusinessEvent => '$apiBase/business/create-event';
  static String get myBusinessEvents => '$apiBase/business/event-list';
  static String get updateBusinessEvent => '$apiBase/business/update-event/';
  static String get deleteBusinessEvent => '$apiBase/business/delete-event/';
  static String get businessEventDetails => '$apiBase/business/event/';
  static String get joinBusinessEvent => '$apiBase/business/join-event';
  static String get leaveBusinessEvent => '$apiBase/business/leave-event';
  static String get saveBusinessEvent => '$apiBase/business/save-event';
  static String get savedEventsList => '$apiBase/business/saved-list';
  static String get topEvents => '$apiBase/business/top-events';
  static String get eventClicks => '$apiBase/business/events/';
  static String get eventViews => '$apiBase/business/events/';

  // Business social endpoints
  static String get followBusiness => '$apiBase/business/follow';
  static String get unfollowBusiness => '$apiBase/business/unfollow';

  // Business subscription endpoints
  static String get createSubscription => '$apiBase/business/create';
  static String get cancelSubscription => '$apiBase/business/cancel';
  static String get subscriptionStatus => '$apiBase/business/subscription-status';
  static String get businessAnalytics => '$apiBase/business/analytics';

  // Badges & achievements endpoints
  static String get badgesList => '$apiBase/user/achievement-list';
  static String get claimBadge => '$apiBase/user/claimed';
  static String get leaderboard => '$apiBase/user/ranking';

  // Notifications endpoints
  static String get notifications => '$apiBase/mate/list_notifications';

  // Support endpoints
  static String get submitComplaint => '$apiBase/admin/complain';

  // Payment endpoints
  static String get createPaymentIntent => '$apiBase/payment/stripe/create-payment-intent';
  static String get verifyPayment => '$apiBase/payment/verify';
  static String get upgradeToPremium => '$apiBase/payment/upgrade-to-premium';

  // Device/FCM endpoints
  static String get registerDevice => '$apiBase/user/register-device';

  // Socket URL
  static String get socketUrl => AppConfig.socketUrl;
}
