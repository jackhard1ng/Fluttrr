import 'package:get/get.dart';

import '../models/mate_model.dart';
import '../models/user_model.dart';
import '../repositories/mates_repository.dart';

/// Mates/matching controller
class MatesController extends GetxController {
  final MatesRepository _matesRepository = MatesRepository();

  // State
  final RxList<MateModel> nearbyMates = <MateModel>[].obs;
  final RxList<MateModel> filteredMates = <MateModel>[].obs;
  final RxList<MateModel> likedMates = <MateModel>[].obs;
  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxList<MateModel> searchResults = <MateModel>[].obs;

  final Rx<UserModel?> viewedProfile = Rx<UserModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isLiking = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter state
  final RxInt minAge = 18.obs;
  final RxInt maxAge = 60.obs;
  final RxString selectedGender = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;
  final RxDouble maxDistance = 50.0.obs;

  // Location
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;

  // Current swipe index
  final RxInt currentSwipeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadNearbyMates(),
      loadMatches(),
    ]);
  }

  /// Set current location
  void setLocation(double latitude, double longitude) {
    currentLatitude.value = latitude;
    currentLongitude.value = longitude;
    // Reload nearby mates with new location
    loadNearbyMates();
  }

  /// Load nearby mates
  Future<void> loadNearbyMates() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _matesRepository.getNearbyMates(
        latitude: currentLatitude.value != 0 ? currentLatitude.value : null,
        longitude: currentLongitude.value != 0 ? currentLongitude.value : null,
        radius: maxDistance.value,
      );

      if (response.success && response.data != null) {
        nearbyMates.value = response.data!;
        currentSwipeIndex.value = 0;
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load nearby mates';
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter mates
  Future<void> filterMates() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _matesRepository.filterMates(
        minAge: minAge.value,
        maxAge: maxAge.value,
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : null,
        interests: selectedInterests.isNotEmpty ? selectedInterests : null,
        latitude: currentLatitude.value != 0 ? currentLatitude.value : null,
        longitude: currentLongitude.value != 0 ? currentLongitude.value : null,
        maxDistance: maxDistance.value,
      );

      if (response.success && response.data != null) {
        filteredMates.value = response.data!;
        nearbyMates.value = response.data!;
        currentSwipeIndex.value = 0;
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to filter mates';
    } finally {
      isLoading.value = false;
    }
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final response = await _matesRepository.searchUsers(query);
      if (response.success && response.data != null) {
        searchResults.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Like a mate
  Future<bool> likeMate(int userId) async {
    isLiking.value = true;

    try {
      final response = await _matesRepository.likeMate(userId);

      isLiking.value = false;

      if (response.success) {
        // Update mate in list
        _updateMateLikeStatus(userId, true);

        // Check if it's a match (response might contain match info)
        final isMatch = response.data?['isMatch'] == true;
        if (isMatch) {
          await loadMatches();
        }

        return true;
      }
      return false;
    } catch (e) {
      isLiking.value = false;
      return false;
    }
  }

  /// Swipe left (skip)
  void swipeLeft() {
    if (currentSwipeIndex.value < nearbyMates.length - 1) {
      currentSwipeIndex.value++;
    }
  }

  /// Swipe right (like)
  Future<void> swipeRight() async {
    if (currentSwipeIndex.value < nearbyMates.length) {
      final mate = nearbyMates[currentSwipeIndex.value];
      if (mate.userId != null) {
        await likeMate(mate.userId!);
      }
      if (currentSwipeIndex.value < nearbyMates.length - 1) {
        currentSwipeIndex.value++;
      }
    }
  }

  /// Load liked mates
  Future<void> loadLikedMates() async {
    try {
      final response = await _matesRepository.getLikedMates();
      if (response.success && response.data != null) {
        likedMates.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Load matches
  Future<void> loadMatches() async {
    try {
      final response = await _matesRepository.getMatches();
      if (response.success && response.data != null) {
        matches.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// View mate profile
  Future<void> viewMateProfile(int userId) async {
    isLoadingProfile.value = true;
    viewedProfile.value = null;

    try {
      final response = await _matesRepository.viewMateProfile(userId);
      if (response.success && response.data != null) {
        viewedProfile.value = response.data;
      }
    } catch (e) {
      // Ignore errors
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Update mate like status in lists
  void _updateMateLikeStatus(int userId, bool liked) {
    void updateList(RxList<MateModel> list) {
      final index = list.indexWhere((m) => m.userId == userId);
      if (index != -1) {
        list[index] = list[index].copyWith(isLiked: liked);
      }
    }

    updateList(nearbyMates);
    updateList(filteredMates);
    updateList(searchResults);
  }

  /// Apply filters
  void applyFilters({
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? interests,
    double? maxDistance,
  }) {
    if (minAge != null) this.minAge.value = minAge;
    if (maxAge != null) this.maxAge.value = maxAge;
    if (gender != null) selectedGender.value = gender;
    if (interests != null) selectedInterests.value = interests;
    if (maxDistance != null) this.maxDistance.value = maxDistance;

    filterMates();
  }

  /// Clear filters
  void clearFilters() {
    minAge.value = 18;
    maxAge.value = 60;
    selectedGender.value = '';
    selectedInterests.clear();
    maxDistance.value = 50.0;

    loadNearbyMates();
  }

  /// Toggle interest filter
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadInitialData();
  }

  // Getters
  MateModel? get currentMate =>
      nearbyMates.isNotEmpty && currentSwipeIndex.value < nearbyMates.length
          ? nearbyMates[currentSwipeIndex.value]
          : null;

  bool get hasMoreMates => currentSwipeIndex.value < nearbyMates.length;

  int get remainingMates => nearbyMates.length - currentSwipeIndex.value;
}
