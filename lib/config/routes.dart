import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_screen_controller.dart';
import '../models/chat_model.dart';
import '../models/business_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/business_login_screen.dart';
import '../screens/business/business_register_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/discover/search_screen.dart';
import '../screens/discover/saved_events_screen.dart';
import '../screens/discover/create_event_screen.dart';
import '../screens/discover/quick_hangout_screen.dart';
import '../screens/discover/swipe_discover_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/privacy_settings_screen.dart';
import '../screens/profile/blocked_users_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_setup_screen.dart';
import '../screens/business/business_dashboard_screen.dart';
import '../screens/business/business_events_screen.dart';
import '../screens/business/business_reviews_screen.dart';
import '../screens/business/business_analytics_screen.dart';
import '../screens/business/quick_create_event_screen.dart';
import '../screens/business/event_photos_screen.dart';
import '../screens/business/business_welcome_screen.dart';
import '../screens/business/business_home_screen.dart';
import '../screens/business/business_create_profile_screen.dart';
import '../screens/business/business_event_details_screen.dart';
import '../screens/business/create_business_event_screen.dart';
import '../screens/business/subscription_screen.dart';
import '../screens/support/help_screen.dart';
import '../screens/support/report_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/group_chat_screen.dart';
import '../screens/activities/activity_details_screen.dart';
import '../screens/activities/create_activity_screen.dart';
import '../screens/memories/memories_screen.dart';
import '../screens/memories/event_memories_screen.dart';
import '../screens/memories/memory_detail_screen.dart';
import '../screens/memories/upload_memory_screen.dart';
import '../screens/memories/my_memories_screen.dart';
import '../screens/stories/story_viewer_screen.dart';
import '../screens/stories/create_story_screen.dart';
import '../models/memory_model.dart';
import '../models/story_model.dart';

/// App route names
class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const businessLogin = '/business-login';
  static const businessRegister = '/business-register';

  // Main
  static const home = '/home';
  static const notifications = '/notifications';

  // Discover
  static const search = '/search';
  static const savedEvents = '/saved-events';
  static const createEvent = '/create-event';
  static const quickHangout = '/quick-hangout';
  static const swipeDiscover = '/discover';


  // Profile
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const profileSetup = '/profile-setup';
  static const settings = '/settings';
  static const privacy = '/privacy';
  static const blockedUsers = '/blocked-users';

  // Chat
  static const chatList = '/chats';
  static const chat = '/chat';
  static const groupChat = '/group-chat';

  // Activities
  static const activityDetails = '/activity-details';
  static const createActivity = '/create-activity';

  // Support
  static const help = '/help';
  static const report = '/report';

  // Memories
  static const memories = '/memories';
  static const eventMemories = '/memories/event';
  static const memoryDetail = '/memories/detail';
  static const uploadMemory = '/memories/upload';
  static const myMemories = '/memories/my';

  // Stories
  static const stories = '/stories';
  static const createStory = '/stories/create';

  // Business
  static const businessWelcome = '/business/welcome';
  static const businessHome = '/business/home';
  static const businessDashboard = '/business/dashboard';
  static const businessCreateProfile = '/business/create-profile';
  static const businessEvents = '/business/events';
  static const businessEventDetails = '/business/event-details';
  static const businessReviews = '/business/reviews';
  static const businessAnalytics = '/business/analytics';
  static const businessCreateEvent = '/business/create-event';
  static const businessNewEvent = '/business/new-event';
  static const businessPhotos = '/business/photos';
  static const subscription = '/business/subscription';
}

/// App pages configuration
class AppPages {
  static final pages = [
    // Auth
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () {
        final isRegistration = Get.arguments as bool? ?? false;
        return OtpScreen(isRegistration: isRegistration);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => ResetPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessLogin,
      page: () => const BusinessLoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessRegister,
      page: () => const BusinessRegisterScreen(),
      transition: Transition.rightToLeft,
    ),

    // Main - Use MainScreen with bottom nav instead of HomeScreen
    GetPage(
      name: AppRoutes.home,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Discover
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.savedEvents,
      page: () => const SavedEventsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createEvent,
      page: () => const CreateEventScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.quickHangout,
      page: () => const QuickHangoutScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.swipeDiscover,
      page: () => const SwipeDiscoverScreen(),
      transition: Transition.fadeIn,
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacySettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.blockedUsers,
      page: () => const BlockedUsersScreen(),
      transition: Transition.rightToLeft,
    ),

    // Chat
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () {
        final args = Get.arguments;
        if (args is ChatConversation) {
          return ChatScreen(conversation: args);
        }
        if (args is Map<String, dynamic>) {
          final conversation = args['conversation'];
          if (conversation is ChatConversation) {
            return ChatScreen(
              conversation: conversation,
              isBusiness: args['isBusiness'] as bool? ?? false,
            );
          }
        }
        debugPrint('Invalid chat arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupChat,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          final groupId = args['groupId'];
          final groupName = args['groupName'];
          if (groupId is String && groupName is String) {
            return GroupChatScreen(
              groupId: groupId,
              groupName: groupName,
            );
          }
        }
        debugPrint('Invalid group chat arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.rightToLeft,
    ),

    // Activities
    GetPage(
      name: AppRoutes.activityDetails,
      page: () {
        final activityId = Get.arguments as int? ?? 0;
        return ActivityDetailsScreen(activityId: activityId);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createActivity,
      page: () => const CreateActivityScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),

    // Memories
    GetPage(
      name: AppRoutes.memories,
      page: () => const MemoriesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.eventMemories,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          final eventId = args['eventId'];
          final eventName = args['eventName'];
          if (eventId is String && eventName is String) {
            return EventMemoriesScreen(
              eventId: eventId,
              eventName: eventName,
              eventImage: args['eventImage'] as String?,
            );
          }
        }
        debugPrint('Invalid event memories arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.memoryDetail,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          final memory = args['memory'];
          if (memory is EventMemoryModel) {
            return MemoryDetailScreen(
              memory: memory,
              focusComments: args['focusComments'] as bool? ?? false,
            );
          }
        }
        debugPrint('Invalid memory detail arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.uploadMemory,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          final eventId = args['eventId'];
          final eventName = args['eventName'];
          if (eventId is String && eventName is String) {
            return UploadMemoryScreen(
              eventId: eventId,
              eventName: eventName,
            );
          }
        }
        debugPrint('Invalid upload memory arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.myMemories,
      page: () => const MyMemoriesScreen(),
      transition: Transition.rightToLeft,
    ),

    // Stories
    GetPage(
      name: AppRoutes.stories,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          final stories = args['stories'];
          if (stories is List<StoryModel>) {
            return StoryViewerScreen(
              stories: stories,
              initialIndex: args['initialIndex'] as int? ?? 0,
            );
          }
        }
        debugPrint('Invalid stories arguments: $args');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.createStory,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return CreateStoryScreen(
          eventId: args?['eventId'] as String?,
          eventName: args?['eventName'] as String?,
        );
      },
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),

    // Support
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () {
        final args = Get.arguments as Map<String, String?>?;
        return ReportScreen(
          userName: args?['userName'],
          eventName: args?['eventName'],
          businessName: args?['businessName'],
        );
      },
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),

    // Business
    GetPage(
      name: AppRoutes.businessWelcome,
      page: () => const BusinessWelcomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessHome,
      page: () => const BusinessHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.businessDashboard,
      page: () => const BusinessDashboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessCreateProfile,
      page: () => const BusinessCreateProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessEvents,
      page: () => const BusinessEventsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessEventDetails,
      page: () {
        final event = Get.arguments;
        if (event is BusinessEvent) {
          return BusinessEventDetailsScreen(event: event);
        }
        debugPrint('Invalid business event details arguments: $event');
        Get.back();
        return const SizedBox.shrink();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessReviews,
      page: () => const BusinessReviewsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessAnalytics,
      page: () => const BusinessAnalyticsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessCreateEvent,
      page: () => const QuickCreateEventScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.businessPhotos,
      page: () => const EventPhotosScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessNewEvent,
      page: () => const CreateBusinessEventScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

/// Navigation helper
class Nav {
  /// Switch to a tab in the MainScreen's bottom navigation.
  /// If we're on a pushed route on top of MainScreen, pop back first.
  static void _switchTab(int tabIndex) {
    if (Get.isRegistered<MainScreenController>()) {
      // Pop any routes on top of MainScreen (/home)
      Get.until((route) => route.settings.name == AppRoutes.home);
      Get.find<MainScreenController>().switchTab(tabIndex);
    } else {
      // Fallback: if MainScreen isn't alive yet, navigate to /home
      Get.offAllNamed(AppRoutes.home);
    }
  }

  // Auth
  static void toHome() => Get.offAllNamed(AppRoutes.home);
  static void toLogin() => Get.offAllNamed(AppRoutes.login);
  static void toRegister() => Get.toNamed(AppRoutes.register);
  static void toOnboarding() => Get.offAllNamed(AppRoutes.onboarding);
  static void toForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);
  static void toOtp({bool isRegistration = false}) => Get.toNamed(
        AppRoutes.otp,
        arguments: isRegistration,
      );
  static void toOtpClearStack({bool isRegistration = false}) => Get.offAllNamed(
        AppRoutes.otp,
        arguments: isRegistration,
      );
  static void toResetPassword() => Get.toNamed(AppRoutes.resetPassword);
  static void toBusinessLogin() => Get.toNamed(AppRoutes.businessLogin);
  static void toBusinessRegister() => Get.toNamed(AppRoutes.businessRegister);

  // Main
  static void toNotifications() => Get.toNamed(AppRoutes.notifications);
  static void toSearch() => Get.toNamed(AppRoutes.search);
  static void toSavedEvents() => Get.toNamed(AppRoutes.savedEvents);
  static void toCreateEvent() => Get.toNamed(AppRoutes.createEvent);
  static void toQuickHangout() => Get.toNamed(AppRoutes.quickHangout);
  static void toSwipeDiscover() => Get.toNamed(AppRoutes.swipeDiscover);

  // Profile
  static void toProfile() => _switchTab(MainScreenController.profileTab);
  static void toEditProfile() => Get.toNamed(AppRoutes.editProfile);
  static void toProfileSetup() => Get.toNamed(AppRoutes.profileSetup);
  static void toSettings() => Get.toNamed(AppRoutes.settings);
  static void toPrivacy() => Get.toNamed(AppRoutes.privacy);
  static void toBlockedUsers() => Get.toNamed(AppRoutes.blockedUsers);

  // Chat
  static void toChatList() => _switchTab(MainScreenController.messagesTab);
  static void toChat(ChatConversation conversation, {bool isBusiness = false}) =>
      Get.toNamed(
        AppRoutes.chat,
        arguments: isBusiness
            ? {'conversation': conversation, 'isBusiness': true}
            : conversation,
      );
  static void toGroupChat({required String groupId, required String groupName}) =>
      Get.toNamed(
        AppRoutes.groupChat,
        arguments: {'groupId': groupId, 'groupName': groupName},
      );

  // Activities
  static void toActivityDetails(int activityId) => Get.toNamed(
        AppRoutes.activityDetails,
        arguments: activityId,
      );
  static void toCreateActivity() => Get.toNamed(AppRoutes.createActivity);

  // Aliases for common navigation
  static void toActivities() => _switchTab(MainScreenController.exploreTab);
  static void toDiscover() => _switchTab(MainScreenController.exploreTab);
  static void toEventDetails({required String eventId}) => Get.toNamed(
        AppRoutes.activityDetails,
        arguments: int.tryParse(eventId) ?? 0,
      );
  static void toMessages() => _switchTab(MainScreenController.messagesTab);
  static void toSavedData() => Get.toNamed(AppRoutes.savedEvents);

  // Support
  static void toHelp() => Get.toNamed(AppRoutes.help);
  static void toReport({String? userName, String? eventName, String? businessName}) =>
      Get.toNamed(
        AppRoutes.report,
        arguments: {
          'userName': userName,
          'eventName': eventName,
          'businessName': businessName,
        },
      );

  // Business
  static void toBusinessWelcome() => Get.toNamed(AppRoutes.businessWelcome);
  static void toBusinessHome() => Get.offAllNamed(AppRoutes.businessHome);
  static void toBusinessDashboard() => Get.offAllNamed(AppRoutes.businessDashboard);
  static void toBusinessDashboardPush() => Get.toNamed(AppRoutes.businessDashboard);
  static void toBusinessCreateProfile() => Get.toNamed(AppRoutes.businessCreateProfile);
  static void toBusinessEvents() => Get.toNamed(AppRoutes.businessEvents);
  static void toBusinessEventDetails(BusinessEvent event) => Get.toNamed(
        AppRoutes.businessEventDetails,
        arguments: event,
      );
  static void toBusinessReviews() => Get.toNamed(AppRoutes.businessReviews);
  static void toBusinessAnalytics() => Get.toNamed(AppRoutes.businessAnalytics);
  static void toBusinessCreateEvent() => Get.toNamed(AppRoutes.businessCreateEvent);
  static void toBusinessNewEvent() => Get.toNamed(AppRoutes.businessNewEvent);
  static void toBusinessPhotos() => Get.toNamed(AppRoutes.businessPhotos);
  static void toSubscription() => Get.toNamed(AppRoutes.subscription);

  // Memories
  static void toMemories() => Get.toNamed(AppRoutes.memories);
  static void toEventMemories({
    required String eventId,
    required String eventName,
    String? eventImage,
  }) =>
      Get.toNamed(
        AppRoutes.eventMemories,
        arguments: {
          'eventId': eventId,
          'eventName': eventName,
          'eventImage': eventImage,
        },
      );
  static void toMemoryDetail(EventMemoryModel memory, {bool focusComments = false}) =>
      Get.toNamed(
        AppRoutes.memoryDetail,
        arguments: {
          'memory': memory,
          'focusComments': focusComments,
        },
      );
  static void toUploadMemory({
    required String eventId,
    required String eventName,
  }) =>
      Get.toNamed(
        AppRoutes.uploadMemory,
        arguments: {
          'eventId': eventId,
          'eventName': eventName,
        },
      );
  static void toMyMemories() => Get.toNamed(AppRoutes.myMemories);

  // Stories
  static void toStories(List<StoryModel> stories, {int initialIndex = 0}) =>
      Get.toNamed(
        AppRoutes.stories,
        arguments: {
          'stories': stories,
          'initialIndex': initialIndex,
        },
      );
  static void toCreateStory({String? eventId, String? eventName}) =>
      Get.toNamed(
        AppRoutes.createStory,
        arguments: eventId != null
            ? {
                'eventId': eventId,
                'eventName': eventName,
              }
            : null,
      );

  // User
  static void toUserProfile({required String userId, String? userName}) =>
      Get.toNamed(
        AppRoutes.profile,
        arguments: {
          'userId': userId,
          'userName': userName,
        },
      );

  // Common
  static void back() => Get.back();
  static void backUntilHome() => Get.offAllNamed(AppRoutes.home);
}
