import 'package:get/get.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/discover/search_screen.dart';
import '../screens/discover/saved_events_screen.dart';
import '../screens/discover/create_event_screen.dart';
import '../screens/discover/quick_hangout_screen.dart';
import '../screens/discover/swipe_discover_screen.dart';
import '../screens/mates/friends_list_screen.dart';
import '../screens/mates/matches_screen.dart';
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
import '../screens/support/help_screen.dart';
import '../screens/support/report_screen.dart';

/// App route names
class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const forgotPassword = '/forgot-password';

  // Main
  static const home = '/home';
  static const notifications = '/notifications';

  // Discover
  static const search = '/search';
  static const savedEvents = '/saved-events';
  static const createEvent = '/create-event';
  static const quickHangout = '/quick-hangout';
  static const swipeDiscover = '/discover';

  // Mates
  static const friends = '/friends';
  static const matches = '/matches';

  // Profile
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const profileSetup = '/profile-setup';
  static const settings = '/settings';
  static const privacy = '/privacy';
  static const blockedUsers = '/blocked-users';

  // Support
  static const help = '/help';
  static const report = '/report';

  // Business
  static const businessWelcome = '/business/welcome';
  static const businessDashboard = '/business/dashboard';
  static const businessEvents = '/business/events';
  static const businessReviews = '/business/reviews';
  static const businessAnalytics = '/business/analytics';
  static const businessCreateEvent = '/business/create-event';
  static const businessPhotos = '/business/photos';
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
      page: () => const LoginScreen(),
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

    // Mates
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.matches,
      page: () => const MatchesScreen(),
      transition: Transition.rightToLeft,
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

    // Support
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportScreen(),
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
      name: AppRoutes.businessDashboard,
      page: () => const BusinessDashboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessEvents,
      page: () => const BusinessEventsScreen(),
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
  ];
}

/// Navigation helper
class Nav {
  // Auth
  static void toHome() => Get.offAllNamed(AppRoutes.home);
  static void toLogin() => Get.offAllNamed(AppRoutes.login);
  static void toOnboarding() => Get.offAllNamed(AppRoutes.onboarding);
  static void toForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);

  // Main
  static void toNotifications() => Get.toNamed(AppRoutes.notifications);
  static void toSearch() => Get.toNamed(AppRoutes.search);
  static void toSavedEvents() => Get.toNamed(AppRoutes.savedEvents);
  static void toCreateEvent() => Get.toNamed(AppRoutes.createEvent);
  static void toQuickHangout() => Get.toNamed(AppRoutes.quickHangout);
  static void toSwipeDiscover() => Get.toNamed(AppRoutes.swipeDiscover);

  // Mates
  static void toFriends() => Get.toNamed(AppRoutes.friends);
  static void toMatches() => Get.toNamed(AppRoutes.matches);

  // Profile
  static void toProfile() => Get.toNamed(AppRoutes.profile);
  static void toEditProfile() => Get.toNamed(AppRoutes.editProfile);
  static void toProfileSetup() => Get.toNamed(AppRoutes.profileSetup);
  static void toSettings() => Get.toNamed(AppRoutes.settings);
  static void toPrivacy() => Get.toNamed(AppRoutes.privacy);
  static void toBlockedUsers() => Get.toNamed(AppRoutes.blockedUsers);

  // Support
  static void toHelp() => Get.toNamed(AppRoutes.help);
  static void toReport() => Get.toNamed(AppRoutes.report);

  // Business
  static void toBusinessWelcome() => Get.toNamed(AppRoutes.businessWelcome);
  static void toBusinessDashboard() => Get.toNamed(AppRoutes.businessDashboard);
  static void toBusinessEvents() => Get.toNamed(AppRoutes.businessEvents);
  static void toBusinessReviews() => Get.toNamed(AppRoutes.businessReviews);
  static void toBusinessAnalytics() => Get.toNamed(AppRoutes.businessAnalytics);
  static void toBusinessCreateEvent() => Get.toNamed(AppRoutes.businessCreateEvent);
  static void toBusinessPhotos() => Get.toNamed(AppRoutes.businessPhotos);

  // Common
  static void back() => Get.back();
  static void backUntilHome() => Get.offAllNamed(AppRoutes.home);
}
