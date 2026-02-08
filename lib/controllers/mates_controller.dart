import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/mate_model.dart';
import '../models/user_model.dart';
import '../repositories/mates_repository.dart';
import '../services/mock_data_service.dart';

/// Mates/matching controller with mock data fallback
class MatesController extends GetxController {
  final MatesRepository _matesRepository = MatesRepository();

  /// Flag to use mock data when API fails (disabled by default, enabled on API failure)
  final RxBool useMockData = false.obs;

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
  final RxBool isSwiping = false.obs;
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

  // Pagination state
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;
  final RxBool isLoadingMore = false.obs;
  static const int pageSize = 20;

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

  /// Load nearby mates (with pagination and mock data fallback)
  Future<void> loadNearbyMates({bool refresh = false}) async {
    // Reset pagination on refresh
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      nearbyMates.clear();
    }

    // Don't load if already loading or no more pages
    if (!hasMorePages.value) return;

    isLoading.value = nearbyMates.isEmpty;
    isLoadingMore.value = nearbyMates.isNotEmpty;
    errorMessage.value = '';

    try {
      final response = await _matesRepository.getNearbyMates(
        latitude: currentLatitude.value != 0 ? currentLatitude.value : null,
        longitude: currentLongitude.value != 0 ? currentLongitude.value : null,
        radius: maxDistance.value,
        page: currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        if (refresh || nearbyMates.isEmpty) {
          nearbyMates.value = response.data!;
        } else {
          nearbyMates.addAll(response.data!);
        }
        useMockData.value = false;

        // Check if there are more pages
        hasMorePages.value = response.data!.length >= pageSize;
        if (hasMorePages.value) {
          currentPage.value++;
        }
      } else if (nearbyMates.isEmpty) {
        // Use mock data as fallback only if list is empty
        _loadMockNearbyMates();
      } else {
        // No more data - end of list
        hasMorePages.value = false;
      }

      if (refresh) {
        currentSwipeIndex.value = 0;
      }
    } catch (e) {
      // Use mock data on error only if list is empty
      if (nearbyMates.isEmpty) {
        _loadMockNearbyMates();
      } else {
        errorMessage.value = 'Failed to load more people';
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more mates (for infinite scroll)
  Future<void> loadMoreMates() async {
    if (isLoadingMore.value || !hasMorePages.value) return;
    await loadNearbyMates();
  }

  /// Load mock nearby mates for demo
  void _loadMockNearbyMates() {
    useMockData.value = true;
    final mockData = MockDataService.generateMockUsers(15);
    nearbyMates.value = mockData.map((data) => MateModel(
      userId: data['userId'] as int,
      userName: data['name'] as String,
      age: data['age'] as int,
      gender: data['gender'] as String,
      bio: data['bio'] as String,
      location: data['location'] as String,
      onlineStatus: (data['isOnline'] as bool) ? 'online' : 'offline',
      images: [data['profileImage'] as String],
      interests: List<String>.from(data['interests'] as List),
      distance: double.tryParse(data['distance'] as String),
      isLiked: false,
      isMatched: false,
    )).toList();
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
      debugPrint('Error searching users: $e');
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
    if (isSwiping.value) return;
    if (currentSwipeIndex.value < nearbyMates.length - 1) {
      currentSwipeIndex.value++;
    }
  }

  /// Swipe right (like)
  Future<void> swipeRight() async {
    // Prevent concurrent swipes
    if (isSwiping.value) return;

    // Validate bounds before accessing the list
    final currentIndex = currentSwipeIndex.value;
    if (currentIndex >= nearbyMates.length) return;

    isSwiping.value = true;

    try {
      // Capture the mate data before any async operations
      final mate = nearbyMates[currentIndex];
      final mateUserId = mate.userId;

      // Increment index immediately to prevent double-swiping on the same user
      if (currentIndex < nearbyMates.length - 1) {
        currentSwipeIndex.value++;
      }

      // Like the user in the background
      if (mateUserId != null) {
        await likeMate(mateUserId);
      }
    } finally {
      isSwiping.value = false;
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
      debugPrint('Error loading liked mates: $e');
    }
  }

  /// Load matches (with mock data fallback)
  Future<void> loadMatches() async {
    try {
      final response = await _matesRepository.getMatches();
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        matches.value = response.data!;
      } else {
        _loadMockMatches();
      }
    } catch (e) {
      _loadMockMatches();
    }
  }

  /// Load mock matches for demo
  void _loadMockMatches() {
    final mockData = MockDataService.generateMockMatches(8);
    matches.value = mockData.map((data) => MatchModel(
      matchId: data['userId'] as int,
      userId: data['userId'] as int,
      userName: data['name'] as String,
      images: [data['profileImage'] as String],
      matchedAt: DateTime.tryParse(data['matchedAt'] as String),
    )).toList();
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
      debugPrint('Error viewing mate profile: $e');
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
