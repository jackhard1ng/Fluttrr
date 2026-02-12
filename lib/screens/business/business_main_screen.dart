import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/profile_controller.dart';
import 'business_dashboard_screen.dart';
import 'business_events_screen.dart';
import '../chat/chat_list_screen.dart';
import 'business_home_screen.dart';

/// Controller for business bottom navigation
class BusinessMainScreenController extends GetxController {
  static const int dashboardTab = 0;
  static const int eventsTab = 1;
  static const int messagesTab = 2;
  static const int profileTab = 3;

  final currentIndex = 0.obs;

  void switchTab(int index) {
    if (index >= 0 && index <= 3) {
      currentIndex.value = index;
    }
  }
}

/// Main screen for business accounts with bottom navigation
/// 4 tabs: Dashboard, Events, Messages, Profile
class BusinessMainScreen extends StatefulWidget {
  const BusinessMainScreen({super.key});

  @override
  State<BusinessMainScreen> createState() => _BusinessMainScreenState();
}

class _BusinessMainScreenState extends State<BusinessMainScreen>
    with WidgetsBindingObserver {
  late final BusinessMainScreenController _tabController;

  final List<Widget> _screens = [
    const BusinessDashboardScreen(),
    const BusinessEventsScreen(),
    const ChatListScreen(),
    const BusinessHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = Get.put(BusinessMainScreenController());
    _initControllers();
  }

  void _initControllers() {
    if (!Get.isRegistered<BusinessController>()) {
      Get.put(BusinessController());
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<ProfileController>()) return;
    final profileController = Get.find<ProfileController>();

    switch (state) {
      case AppLifecycleState.resumed:
        profileController.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        profileController.setOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = _tabController.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient divider
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryHorizontal,
                ),
              ),
              // Bottom navigation bar
              BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) => _tabController.switchTab(index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.grey,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.event_outlined),
                    activeIcon: Icon(Icons.event),
                    label: 'Events',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildChatIcon(false),
                    activeIcon: _buildChatIcon(true),
                    label: 'Messages',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.store_outlined),
                    activeIcon: Icon(Icons.store),
                    label: 'Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatIcon(bool isActive) {
    if (!Get.isRegistered<ChatController>()) {
      return Icon(
        isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
      );
    }

    return GetX<ChatController>(
      builder: (controller) {
        final unreadCount = controller.totalUnreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -8,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
