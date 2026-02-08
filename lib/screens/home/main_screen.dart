import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/chat_controller.dart';
import 'home_screen.dart';
import '../activities/activities_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

/// Main screen with bottom navigation
/// 4 tabs: Home (event feed), Explore (browse events), Chat, Profile
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ActivitiesScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initControllers();
  }

  void _initControllers() {
    // Initialize all required controllers
    Get.put(ActivityController());
    Get.put(ChatController());

    // Set user online
    final profileController = Get.find<ProfileController>();
    profileController.setOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
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
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.grey,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Mates',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event),
                  label: 'Activities',
                ),
                BottomNavigationBarItem(
                  icon: _buildChatIcon(false),
                  activeIcon: _buildChatIcon(true),
                  label: 'Chat',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatIcon(bool isActive) {
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
