import 'package:get/get.dart';

import '../controllers/controllers.dart';

/// Initial bindings - loaded at app start
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core controllers - always available
    Get.put(AuthController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}

/// Home bindings - loaded when entering home
class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => DiscoverController());
    Get.lazyPut(() => MatesController());
    Get.lazyPut(() => ActivityController());
    Get.lazyPut(() => NotificationsController());
  }
}

/// Chat bindings - loaded when entering chat
class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
  }
}

/// Business bindings - loaded for business users
class BusinessBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BusinessController());
  }
}

/// Helper to initialize all controllers
class AppBindings {
  static void init() {
    // Initialize core services
    Get.put(AuthController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }

  static void initHome() {
    // Initialize home-related controllers
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    if (!Get.isRegistered<DiscoverController>()) {
      Get.put(DiscoverController());
    }
    if (!Get.isRegistered<MatesController>()) {
      Get.put(MatesController());
    }
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }
  }

  static void disposeHome() {
    // Clean up when leaving home
    Get.delete<ProfileController>();
    Get.delete<DiscoverController>();
    Get.delete<MatesController>();
    Get.delete<NotificationsController>();
  }
}
