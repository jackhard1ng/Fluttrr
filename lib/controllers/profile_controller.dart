import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../models/badge_model.dart';
import '../repositories/profile_repository.dart';
import '../services/mock_data_service.dart';

/// Profile controller with mock data fallback for demo
class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

  /// Flag to use mock data when API fails
  final RxBool useMockData = true.obs;

  // State
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<String> galleryImages = <String>[].obs;
  final RxList<BadgeModel> badges = <BadgeModel>[].obs;
  final RxList<LeaderboardEntry> leaderboard = <LeaderboardEntry>[].obs;
  final Rx<LeaderboardEntry?> currentUserRank = Rx<LeaderboardEntry?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt profileCompletion = 0.obs;
  final RxInt totalActivities = 0.obs;
  final RxInt totalMatches = 0.obs;
  final RxInt joinedActivities = 0.obs;

  // Text controllers for editing
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;

  /// Browse location for finding events in different cities (travel mode)
  final RxString browseLocation = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    userNameController.dispose();
    bioController.dispose();
    ageController.dispose();
    locationController.dispose();
    super.onClose();
  }

  /// Load user profile (with mock data fallback)
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        useMockData.value = false;
        _populateEditControllers();
        await _loadAdditionalData();
      } else {
        // Use mock data when API fails
        _loadMockProfile();
      }
    } catch (e) {
      // Use mock data on error
      _loadMockProfile();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load mock profile for demo
  void _loadMockProfile() {
    useMockData.value = true;
    final mockData = MockDataService.getDemoProfile();

    currentUser.value = UserModel(
      userId: mockData['userId'] as int,
      userName: mockData['name'] as String,
      email: mockData['email'] as String,
      onlineStatus: (mockData['isOnline'] as bool) ? 'online' : 'offline',
      accountType: AccountType.regular, // Regular account for demo
      profile: Profile(
        age: mockData['age'] as int,
        gender: mockData['gender'] as String,
        bio: mockData['bio'] as String,
        location: mockData['location'] as String,
        interests: List<String>.from(mockData['interests'] as List),
        images: [mockData['profileImage'] as String],
      ),
    );

    profileCompletion.value = mockData['profileCompletion'] as int;
    totalActivities.value = 3;
    totalMatches.value = 8;
    joinedActivities.value = 5;

    _populateEditControllers();
  }

  /// Populate edit controllers with current data
  void _populateEditControllers() {
    final user = currentUser.value;
    if (user != null) {
      userNameController.text = user.userName ?? '';
      bioController.text = user.profile?.bio ?? '';
      ageController.text = user.profile?.age?.toString() ?? '';
      locationController.text = user.profile?.location ?? '';
      selectedGender.value = user.profile?.gender ?? '';
      selectedInterests.value = user.profile?.interests ?? [];
      selectedLanguages.value = user.profile?.languages ?? [];
    }
  }

  /// Load additional profile data
  Future<void> _loadAdditionalData() async {
    try {
      // Load in parallel
      await Future.wait([
        _loadProfileCompletion(),
        _loadStatistics(),
        _loadGallery(),
      ]);
    } catch (e) {
      debugPrint('Error loading additional profile data: $e');
    }
  }

  Future<void> _loadProfileCompletion() async {
    final response = await _profileRepository.getProfileCompletion();
    if (response.success && response.data != null) {
      profileCompletion.value = response.data!;
    }
  }

  Future<void> _loadStatistics() async {
    final results = await Future.wait([
      _profileRepository.getTotalActivityCount(),
      _profileRepository.getTotalMatchCount(),
      _profileRepository.getJoinedActivitiesCount(),
    ]);

    if (results[0].success) totalActivities.value = results[0].data ?? 0;
    if (results[1].success) totalMatches.value = results[1].data ?? 0;
    if (results[2].success) joinedActivities.value = results[2].data ?? 0;
  }

  Future<void> _loadGallery() async {
    final response = await _profileRepository.getGalleryImages();
    if (response.success && response.data != null) {
      galleryImages.value = response.data!;
    }
  }

  /// Update profile (with mock mode support)
  Future<bool> updateProfile() async {
    isUpdating.value = true;
    errorMessage.value = '';

    // In mock mode, just update the local user data
    if (useMockData.value) {
      _updateMockProfile();
      isUpdating.value = false;
      return true;
    }

    try {
      final response = await _profileRepository.updateProfile(
        userName: userNameController.text.trim().isNotEmpty
            ? userNameController.text.trim()
            : null,
        age: int.tryParse(ageController.text),
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : null,
        bio: bioController.text.trim().isNotEmpty ? bioController.text.trim() : null,
        interests: selectedInterests.isNotEmpty ? selectedInterests : null,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        languages: selectedLanguages.isNotEmpty ? selectedLanguages : null,
      );

      isUpdating.value = false;

      if (response.success) {
        if (response.data != null) {
          currentUser.value = response.data;
        }
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isUpdating.value = false;
      errorMessage.value = 'Failed to update profile';
      return false;
    }
  }

  /// Update mock profile with form data
  void _updateMockProfile() {
    final current = currentUser.value;
    if (current == null) return;

    final newName = userNameController.text.trim().isNotEmpty
        ? userNameController.text.trim()
        : current.userName;

    // Generate new avatar URL based on name
    final newAvatarUrl = MockDataService.getAvatarUrl(newName ?? 'User');

    currentUser.value = UserModel(
      userId: current.userId,
      userName: newName,
      email: current.email,
      onlineStatus: current.onlineStatus,
      accountType: current.accountType,
      profile: Profile(
        age: int.tryParse(ageController.text) ?? current.profile?.age,
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : current.profile?.gender,
        bio: bioController.text.trim().isNotEmpty ? bioController.text.trim() : current.profile?.bio,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : current.profile?.location,
        interests: selectedInterests.isNotEmpty
            ? List<String>.from(selectedInterests)
            : current.profile?.interests,
        languages: selectedLanguages.isNotEmpty
            ? List<String>.from(selectedLanguages)
            : current.profile?.languages,
        images: [newAvatarUrl],
      ),
    );

    // Update profile completion based on fields filled
    int completion = 20;
    if (userNameController.text.trim().isNotEmpty) completion += 15;
    if (bioController.text.trim().isNotEmpty) completion += 15;
    if (ageController.text.isNotEmpty) completion += 10;
    if (selectedGender.value.isNotEmpty) completion += 10;
    if (locationController.text.trim().isNotEmpty) completion += 10;
    if (selectedInterests.isNotEmpty) completion += 20;
    profileCompletion.value = completion.clamp(0, 100);
  }

  /// Set browse location for finding events in different cities (travel mode)
  void setBrowseLocation(String city) {
    browseLocation.value = city;
  }

  /// Update location
  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final response = await _profileRepository.updateLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      if (response.success) {
        if (address != null) {
          locationController.text = address;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Upload gallery image
  Future<bool> uploadGalleryImage(File image) async {
    isUploadingImage.value = true;

    try {
      final response = await _profileRepository.uploadGalleryImage(image);

      isUploadingImage.value = false;

      if (response.success && response.data != null) {
        galleryImages.add(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      isUploadingImage.value = false;
      return false;
    }
  }

  /// Load badges
  Future<void> loadBadges() async {
    try {
      final response = await _profileRepository.getBadges();
      if (response.success && response.data != null) {
        badges.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
    }
  }

  /// Claim badge
  Future<bool> claimBadge(int badgeId) async {
    try {
      final response = await _profileRepository.claimBadge(badgeId);

      if (response.success) {
        // Update badge in list
        final index = badges.indexWhere((b) => b.badgeId == badgeId);
        if (index != -1) {
          final badge = badges[index];
          badges[index] = BadgeModel(
            badgeId: badge.badgeId,
            name: badge.name,
            description: badge.description,
            iconUrl: badge.iconUrl,
            category: badge.category,
            requiredProgress: badge.requiredProgress,
            currentProgress: badge.currentProgress,
            isUnlocked: badge.isUnlocked,
            isClaimed: true,
            unlockedAt: badge.unlockedAt,
            xpReward: badge.xpReward,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load leaderboard
  Future<void> loadLeaderboard() async {
    try {
      final response = await _profileRepository.getLeaderboard();
      if (response.success && response.data != null) {
        leaderboard.value = response.data!.data;
        currentUserRank.value = response.data!.currentUser;
      }
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  /// Set user online status
  Future<void> setOnline() async {
    await _profileRepository.setOnline();
  }

  /// Set user offline status
  Future<void> setOffline() async {
    await _profileRepository.setOffline();
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    await _profileRepository.updateFcmToken(token);
  }

  /// Toggle interest selection
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  /// Toggle language selection
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
  }

  /// Set gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  // Getters for convenience
  String get userName => currentUser.value?.userName ?? 'User';
  String? get profileImage => currentUser.value?.profileImage;
  String? get bio => currentUser.value?.profile?.bio;
  int? get age => currentUser.value?.profile?.age;
  String? get gender => currentUser.value?.profile?.gender;
  String? get location => currentUser.value?.profile?.location;
  List<String> get interests => currentUser.value?.profile?.interests ?? [];
  List<String> get languages => currentUser.value?.profile?.languages ?? [];
  List<String> get images => currentUser.value?.profile?.images ?? [];
  bool get isOnline => currentUser.value?.isOnline ?? false;
}
