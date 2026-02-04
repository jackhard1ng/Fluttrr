/// API endpoint configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL configuration
  static const String baseUrl = 'http://82.180.139.134:3001';
  static const String apiBase = '$baseUrl/api';

  // Authentication endpoints
  static const String login = '$apiBase/user/login';
  static const String verifyOtp = '$apiBase/user/verify-otp';
  static const String sendOtp = '$apiBase/user/send-otp';
  static const String googleLogin = '$apiBase/user/google-login';
  static const String changePassword = '$apiBase/user/change-password';
  static const String resetPassword = '$apiBase/user/reset-password';
  static const String requestOtp = '$apiBase/user/request-otp';
  static const String verifyResetOtp = '$apiBase/user/verifys-otp';

  // Profile endpoints
  static const String profile = '$apiBase/user/profile';
  static const String updateProfile = '$apiBase/user/update';
  static const String createProfile = '$apiBase/user/create-profile';
  static const String updateLocation = '$apiBase/user/update-location';
  static const String updateFcmToken = '$apiBase/user/token';
  static const String setOnline = '$apiBase/user/online';
  static const String setOffline = '$apiBase/user/offline';
  static const String profileCompletion = '$apiBase/user/monitring';

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
  static const String chatList = '$apiBase/message/cheatlist';
  static const String groupList = '$apiBase/message/grouplist';
  static const String markAsRead = '$apiBase/message/markAsRead';
  static const String businessChatList = '$apiBase/message/getChatList';
  static const String sendBusinessMessage = '$apiBase/message/sendB';

  // Business endpoints
  static const String businessRequestOtp = '$apiBase/bussness/request-otp';
  static const String businessVerify = '$apiBase/bussness/verify';
  static const String businessProfile = '$apiBase/bussness/busness';
  static const String createBusinessProfile = '$apiBase/bussness/create-profile';
  static const String updateBusinessProfile = '$apiBase/bussness/updates/';
  static const String businessStatus = '$apiBase/bussness/bussnesStatus';

  // Business events endpoints
  static const String businessEventList = '$apiBase/bussness/list';
  static const String createBusinessEvent = '$apiBase/bussness/createEvent';
  static const String myBusinessEvents = '$apiBase/bussness/eventList';
  static const String updateBusinessEvent = '$apiBase/bussness/updateEvent/';
  static const String deleteBusinessEvent = '$apiBase/bussness/deleteEvent/';
  static const String businessEventDetails = '$apiBase/bussness/eventById/';
  static const String joinBusinessEvent = '$apiBase/bussness/joinEvent';
  static const String leaveBusinessEvent = '$apiBase/bussness/leaveEvent';
  static const String saveBusinessEvent = '$apiBase/bussness/saveEvent';
  static const String savedEventsList = '$apiBase/bussness/saveList';
  static const String topEvents = '$apiBase/bussness/topEvent';
  static const String eventClicks = '$apiBase/bussness/events/';
  static const String eventViews = '$apiBase/bussness/events/';

  // Business social endpoints
  static const String followBusiness = '$apiBase/bussness/follow';
  static const String unfollowBusiness = '$apiBase/bussness/unfollow';

  // Business subscription endpoints
  static const String createSubscription = '$apiBase/bussness/create';
  static const String cancelSubscription = '$apiBase/bussness/cancel';
  static const String subscriptionStatus = '$apiBase/bussness/subscription-status';
  static const String businessAnalytics = '$apiBase/bussness/analytics';

  // Badges & achievements endpoints
  static const String badgesList = '$apiBase/user/achiveList';
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
