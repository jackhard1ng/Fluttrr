import 'package:get/get.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/discover/search_screen.dart';
import '../screens/discover/event_details_screen.dart';
import '../screens/discover/saved_events_screen.dart';
import '../screens/discover/create_event_screen.dart';
import '../screens/discover/attendees_screen.dart';
import '../screens/mates/friends_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/privacy_settings_screen.dart';
import '../screens/profile/blocked_users_screen.dart';
import '../screens/support/help_screen.dart';
import '../screens/support/report_screen.dart';

/// App route names
class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';

  // Main
  static const home = '/home';
  static const notifications = '/notifications';

  // Discover
  static const search = '/search';
  static const eventDetails = '/event/:id';
  static const savedEvents = '/saved-events';
  static const createEvent = '/create-event';
  static const editEvent = '/edit-event/:id';
  static const attendees = '/event/:id/attendees';

  // Mates
  static const friends = '/friends';
  static const friendProfile = '/profile/:id';

  // Profile
  static const profile = '/profile';
  static const settings = '/settings';
  static const privacy = '/privacy';
  static const blockedUsers = '/blocked-users';

  // Support
  static const help = '/help';
  static const report = '/report';

  // Business
  static const businessDashboard = '/business/dashboard';
  static const businessEvents = '/business/events';
  static const businessAnalytics = '/business/analytics';
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

    // Main
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
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

    // Mates
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsListScreen(),
      transition: Transition.rightToLeft,
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
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
  ];
}

/// Navigation helper
class Nav {
  static void toHome() => Get.offAllNamed(AppRoutes.home);
  static void toLogin() => Get.offAllNamed(AppRoutes.login);
  static void toOnboarding() => Get.offAllNamed(AppRoutes.onboarding);

  static void toNotifications() => Get.toNamed(AppRoutes.notifications);
  static void toSearch() => Get.toNamed(AppRoutes.search);
  static void toSavedEvents() => Get.toNamed(AppRoutes.savedEvents);
  static void toCreateEvent() => Get.toNamed(AppRoutes.createEvent);

  static void toFriends() => Get.toNamed(AppRoutes.friends);
  static void toProfile() => Get.toNamed(AppRoutes.profile);
  static void toSettings() => Get.toNamed(AppRoutes.settings);
  static void toPrivacy() => Get.toNamed(AppRoutes.privacy);
  static void toBlockedUsers() => Get.toNamed(AppRoutes.blockedUsers);

  static void toHelp() => Get.toNamed(AppRoutes.help);
  static void toReport() => Get.toNamed(AppRoutes.report);

  static void back() => Get.back();
}
