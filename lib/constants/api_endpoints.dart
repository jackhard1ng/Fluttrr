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
  static String get updateLowProfile => '$apiBase/user/low-profile';
  static String get profileCompletion => '$apiBase/user/monitoring';

  // Profile photo endpoints
  static String get uploadProfilePhoto => '$apiBase/user/upload-profile-photo';
  static String get removeProfilePhoto => '$apiBase/user/remove-profile-photo';
  static String get deleteAccount => '$apiBase/user/delete-account';
  static String get notificationPreferences => '$apiBase/user/reminder-preferences';

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
  static String get activityImages => '$apiBase/activity/images';
  static String get upcomingActivities => '$apiBase/activity/upcoming';
  static String get trendingActivities => '$apiBase/activity/trending';
  static String get suggestedActivities => '$apiBase/activity/suggested';
  static String get createdActivitiesCount => '$apiBase/activity/created-activities-count';
  static String get joinedActivitiesCount => '$apiBase/activity/joined-activities-count';
  static String get userActivities => '$apiBase/activity/user-activities';

  // User search endpoints
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

  // Phone verification endpoints
  static String get sendPhoneOtp => '$apiBase/user/send-phone-otp';
  static String get verifyPhoneOtp => '$apiBase/user/verify-phone-otp';
  static String get phoneVerificationStatus => '$apiBase/user/phone-status';

  // Event feedback and ratings endpoints
  static String get submitEventFeedback => '$apiBase/activity/feedback';
  static String get getEventFeedback => '$apiBase/activity/feedback';
  static String get rateAttendee => '$apiBase/activity/rate-attendee';
  static String get getAttendeeRatings => '$apiBase/activity/attendee-ratings';
  static String get postEventSummary => '$apiBase/activity/post-event-summary';
  static String get sendThankYou => '$apiBase/activity/send-thank-you';

  // Guest/Bring-a-friend endpoints
  static String get inviteGuest => '$apiBase/activity/invite-guest';
  static String get getEventGuests => '$apiBase/activity/guests';
  static String get updateGuestStatus => '$apiBase/activity/guest-status';
  static String get cancelGuestInvite => '$apiBase/activity/cancel-guest';
  static String get guestRsvp => '$apiBase/activity/guest-rsvp';

  // Business rewards endpoints
  static String get businessRewardsSummary => '$apiBase/business/rewards/summary';
  static String get businessRewardsList => '$apiBase/business/rewards/list';
  static String get claimBusinessReward => '$apiBase/business/rewards/claim';
  static String get businessReferrals => '$apiBase/business/referrals';
  static String get businessReferralCode => '$apiBase/business/referral-code';

  // Event reminders endpoints
  static String get createReminder => '$apiBase/activity/reminder';
  static String get getReminders => '$apiBase/activity/reminders';
  static String get updateReminder => '$apiBase/activity/reminder';
  static String get deleteReminder => '$apiBase/activity/reminder';
  static String get reminderPreferences => '$apiBase/user/reminder-preferences';
  static String get upcomingReminders => '$apiBase/activity/upcoming-reminders';

  // Waitlist endpoints
  static String get joinWaitlist => '$apiBase/activity/waitlist/join';
  static String get leaveWaitlist => '$apiBase/activity/waitlist/leave';
  static String get getWaitlist => '$apiBase/activity/waitlist';
  static String get respondToWaitlistOffer => '$apiBase/activity/waitlist/respond';
  static String get waitlistPosition => '$apiBase/activity/waitlist/position';

  // Recurring events endpoints
  static String get createRecurringEvent => '$apiBase/activity/recurring/create';
  static String get getRecurringSeries => '$apiBase/activity/recurring/series';
  static String get updateRecurringSeries => '$apiBase/activity/recurring/update';
  static String get cancelRecurringInstance => '$apiBase/activity/recurring/cancel-instance';
  static String get deleteRecurringSeries => '$apiBase/activity/recurring/delete';
  static String get recurringEventInstances => '$apiBase/activity/recurring/instances';

  // Follow businesses endpoints
  static String get getFollowedBusinesses => '$apiBase/user/followed-businesses';
  static String get followBusinessNotifications => '$apiBase/user/follow-notifications';
  static String get followedBusinessEvents => '$apiBase/user/followed-business-events';

  // Groups endpoints
  static String get createGroup => '$apiBase/group/create';
  static String get getGroups => '$apiBase/group/list';
  static String get getGroupDetails => '$apiBase/group/details';
  static String get updateGroup => '$apiBase/group/update';
  static String get deleteGroup => '$apiBase/group/delete';
  static String get joinGroup => '$apiBase/group/join';
  static String get leaveGroup => '$apiBase/group/leave';
  static String get groupMembers => '$apiBase/group/members';
  static String get groupEvents => '$apiBase/group/events';
  static String get groupJoinRequests => '$apiBase/group/requests';
  static String get respondToJoinRequest => '$apiBase/group/respond-request';
  static String get searchGroups => '$apiBase/group/search';
  static String get suggestedGroups => '$apiBase/group/suggested';
  static String get myGroups => '$apiBase/group/my-groups';
  static String get interestGroups => '$apiBase/group/by-interest';

  // Icebreakers endpoints
  static String get getIcebreakers => '$apiBase/icebreaker/list';
  static String get getRandomIcebreaker => '$apiBase/icebreaker/random';
  static String get createCustomIcebreaker => '$apiBase/icebreaker/create';
  static String get icebreakerSession => '$apiBase/icebreaker/session';
  static String get startIcebreakerSession => '$apiBase/icebreaker/session/start';
  static String get submitIcebreakerResponse => '$apiBase/icebreaker/respond';
  static String get icebreakerResponses => '$apiBase/icebreaker/responses';
  static String get nextIcebreaker => '$apiBase/icebreaker/session/next';

  // Memories endpoints
  static String get memories => '$apiBase/memory';
  static String get memoryFeed => '$apiBase/memory/feed';
  static String get featuredMemories => '$apiBase/memory/featured';
  static String get eventMemories => '$apiBase/memory/event';
  static String get myMemories => '$apiBase/memory/my';
  static String get uploadMemory => '$apiBase/memory/upload';
  static String get memoryComments => '$apiBase/memory/comments';
  static String get memoryLike => '$apiBase/memory/like';
  static String get memoryTag => '$apiBase/memory/tag';
  static String get memoryReport => '$apiBase/memory/report';

  // Stories endpoints
  static String get stories => '$apiBase/story';
  static String get myStories => '$apiBase/story/me';
  static String get eventStories => '$apiBase/story/event';
  static String get userStories => '$apiBase/story/user';
  static String get storyView => '$apiBase/story/view';
  static String get storyReact => '$apiBase/story/react';

  // Socket URL
  static String get socketUrl => AppConfig.socketUrl;
}
