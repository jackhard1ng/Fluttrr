/// API endpoint configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL configuration
  static const String baseUrl = 'http://82.180.139.134';
  static const String apiBase = '$baseUrl/api';

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
  static const String login = '$apiBase/user/login';
  static const String verifyOtp = '$apiBase/user/verify-otp';
  static const String sendOtp = '$apiBase/user/send-otp';
  static const String googleLogin = '$apiBase/user/google-login';
  static const String changePassword = '$apiBase/user/change-password';
  static const String resetPassword = '$apiBase/user/reset-password';
  static const String requestOtp = '$apiBase/user/request-otp';
  static const String verifyResetOtp = '$apiBase/user/verify-reset-otp';

  // Profile endpoints
  static const String profile = '$apiBase/user/profile';
  static const String updateProfile = '$apiBase/user/update';
  static const String createProfile = '$apiBase/user/create-profile';
  static const String updateLocation = '$apiBase/user/update-location';
  static const String updateFcmToken = '$apiBase/user/token';
  static const String setOnline = '$apiBase/user/online';
  static const String setOffline = '$apiBase/user/offline';
  static const String profileCompletion = '$apiBase/user/monitoring';

  // Gallery endpoints
  static const String galleryList = '$apiBase/gallery/list';
  static const String galleryUpload = '$apiBase/gallery/upload';

  // Activity endpoints
  static const String dailyActivities = '$apiBase/activity/daily-activities';
  static const String activityList = '$apiBase/activity/list';
  static const String createActivity = '$apiBase/activity/create-activity';
  static const String activityDetails = '$apiBase/activity/activity-details';
  static const String myActivities = '$apiBase/activity/my-activity';
  static const String joinActivity = '$apiBase/activity/join';
  static const String leaveActivity = '$apiBase/activity/leave';
  static const String saveActivity = '$apiBase/activity/save';
  static const String searchActivities = '$apiBase/activity/search';
  static const String updateActivity = '$apiBase/activity/update';
  static const String deleteActivity = '$apiBase/activity/delete';
  static const String upcomingActivities = '$apiBase/activity/upcoming';
  static const String createdActivitiesCount = '$apiBase/activity/created-activities-count';
  static const String joinedActivitiesCount = '$apiBase/activity/joined-activities-count';
  static const String userActivities = '$apiBase/activity/user-activities';

  // Mates endpoints
  static const String filterMates = '$apiBase/mate/filter';
  static const String nearbyMates = '$apiBase/mate/nearby';
  static const String findNearbyMates = '$apiBase/mate/find-nearby-mates';
  static const String likeMate = '$apiBase/mate/like';
  static const String likedMates = '$apiBase/mate/liked-mates';
  static const String totalMates = '$apiBase/mate/total-mates';
  static const String matchList = '$apiBase/user/match';
  static const String searchUsers = '$apiBase/user/search';
  static const String userList = '$apiBase/user/List';

  // Privacy endpoints
  static const String privacyProfile = '$apiBase/privacy/profile';
  static const String updatePrivacy = '$apiBase/privacy/updatePrivacy';
  static const String getPrivacy = '$apiBase/privacy/getPrivacySettings';

  // Chat endpoints
  static const String sendMessage = '$apiBase/message/send';
  static const String chatList = '$apiBase/message/chatlist';
  static const String groupList = '$apiBase/message/grouplist';
  static const String markAsRead = '$apiBase/message/markAsRead';
  static const String businessChatList = '$apiBase/message/getChatList';
  static const String sendBusinessMessage = '$apiBase/message/sendB';

  // Business authentication endpoints
  static const String businessLogin = '$apiBase/business/login';
  static const String businessRegister = '$apiBase/business/register';
  static const String businessRequestOtp = '$apiBase/business/request-otp';
  static const String businessVerify = '$apiBase/business/verify';
  static const String businessProfile = '$apiBase/business/profile';
  static const String createBusinessProfile = '$apiBase/business/create-profile';
  static const String updateBusinessProfile = '$apiBase/business/update/';
  static const String businessStatus = '$apiBase/business/status';
  static const String businessProfileImage = '$apiBase/business/upload-profile-image';
  static const String businessCoverImage = '$apiBase/business/upload-cover-image';

  // Business events endpoints
  static const String businessEventList = '$apiBase/business/list';
  static const String createBusinessEvent = '$apiBase/business/create-event';
  static const String myBusinessEvents = '$apiBase/business/event-list';
  static const String updateBusinessEvent = '$apiBase/business/update-event/';
  static const String deleteBusinessEvent = '$apiBase/business/delete-event/';
  static const String businessEventDetails = '$apiBase/business/event/';
  static const String joinBusinessEvent = '$apiBase/business/join-event';
  static const String leaveBusinessEvent = '$apiBase/business/leave-event';
  static const String saveBusinessEvent = '$apiBase/business/save-event';
  static const String savedEventsList = '$apiBase/business/saved-list';
  static const String topEvents = '$apiBase/business/top-events';
  static const String eventClicks = '$apiBase/business/events/';
  static const String eventViews = '$apiBase/business/events/';

  // Business social endpoints
  static const String followBusiness = '$apiBase/business/follow';
  static const String unfollowBusiness = '$apiBase/business/unfollow';

  // Business subscription endpoints
  static const String createSubscription = '$apiBase/business/create';
  static const String cancelSubscription = '$apiBase/business/cancel';
  static const String subscriptionStatus = '$apiBase/business/subscription-status';
  static const String businessAnalytics = '$apiBase/business/analytics';

  // Badges & achievements endpoints
  static const String badgesList = '$apiBase/user/achievement-list';
  static const String claimBadge = '$apiBase/user/claimed';
  static const String leaderboard = '$apiBase/user/ranking';

  // Notifications endpoints
  static const String notifications = '$apiBase/mate/list_notifications';

  // Support endpoints
  static const String submitComplaint = '$apiBase/admin/complain';

  // Payment endpoints
  static const String createPaymentIntent = '$apiBase/payment/stripe/create-payment-intent';
  static const String verifyPayment = '$apiBase/payment/verify';
  static const String upgradeToPremium = '$apiBase/payment/upgrade-to-premium';

  // Device/FCM endpoints
  static const String registerDevice = '$apiBase/user/register-device';

  // Socket URL
  static const String socketUrl = baseUrl;
}
