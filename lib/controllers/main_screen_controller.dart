import 'package:get/get.dart';

/// Controller for managing the main bottom navigation tab state.
/// Allows any screen to switch tabs without pushing a new route.
class MainScreenController extends GetxController {
  static const int homeTab = 0;
  static const int exploreTab = 1;
  static const int messagesTab = 2;
  static const int profileTab = 3;

  final currentIndex = 0.obs;

  void switchTab(int index) {
    if (index >= 0 && index <= 3) {
      currentIndex.value = index;
    }
  }
}
