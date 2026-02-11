import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../models/badge_model.dart';
import '../repositories/profile_repository.dart';

/// Profile controller for managing user profile data
class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

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

  /// Low Profile mode - hides user from Discover but allows event participation
  final RxBool isLowProfile = false.obs;

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
    // Text controllers are intentionally NOT disposed here because
    // widgets (e.g. ProfileSetupScreen) may still reference them
    // after this controller is deleted during navigation transitions.
    // They will be garbage collected when no longer referenced.
    super.onClose();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        _populateEditControllers();
        await _loadAdditionalData();
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile. Please try again.';
      debugPrint('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
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
      isLowProfile.value = user.isLowProfile;
    }
  }

  /// Load additional profile data with individual error handling
  Future<void> _loadAdditionalData() async {
    try {
      // Load in parallel - each method handles its own errors
      await Future.wait([
        _loadProfileCompletion(),
        _loadStatistics(),
        _loadGallery(),
      ], eagerError: false);
    } catch (e) {
      // Set error message for UI to display if all operations fail
      debugPrint('Error loading additional profile data: $e');
      // Don't override main profile error - only log additional data failures
    }
  }

  Future<void> _loadProfileCompletion() async {
    try {
      final response = await _profileRepository.getProfileCompletion();
      final data = response.data;
      if (response.success && data != null) {
        profileCompletion.value = data;
      }
    } catch (e) {
      debugPrint('Error loading profile completion: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final results = await Future.wait([
        _profileRepository.getTotalActivityCount(),
        _profileRepository.getTotalMatchCount(),
        _profileRepository.getJoinedActivitiesCount(),
      ], eagerError: false);

      // Safely access results with bounds checking
      if (results.isNotEmpty && results[0].success) {
        totalActivities.value = results[0].data ?? 0;
      }
      if (results.length > 1 && results[1].success) {
        totalMatches.value = results[1].data ?? 0;
      }
      if (results.length > 2 && results[2].success) {
        joinedActivities.value = results[2].data ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<void> _loadGallery() async {
    try {
      final response = await _profileRepository.getGalleryImages();
      final data = response.data;
      if (response.success && data != null) {
        galleryImages.value = data;
      }
    } catch (e) {
      debugPrint('Error loading gallery: $e');
    }
  }

  /// Update profile
  Future<bool> updateProfile() async {
    isUpdating.value = true;
    errorMessage.value = '';

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
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  /// Upload gallery image
  Future<bool> uploadGalleryImage(File image) async {
    isUploadingImage.value = true;

    try {
      final response = await _profileRepository.uploadGalleryImage(image);

      isUploadingImage.value = false;

      final data = response.data;
      if (response.success && data != null) {
        galleryImages.add(data);
        return true;
      }
      return false;
    } catch (e) {
      isUploadingImage.value = false;
      debugPrint('Error uploading gallery image: $e');
      return false;
    }
  }

  /// Load badges
  Future<void> loadBadges() async {
    try {
      final response = await _profileRepository.getBadges();
      final data = response.data;
      if (response.success && data != null) {
        badges.value = data;
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
      debugPrint('Error claiming badge: $e');
      return false;
    }
  }

  /// Load leaderboard
  Future<void> loadLeaderboard() async {
    try {
      final response = await _profileRepository.getLeaderboard();
      final data = response.data;
      if (response.success && data != null) {
        leaderboard.value = data.data;
        currentUserRank.value = data.currentUser;
      }
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  /// Set user online status with error handling
  Future<void> setOnline() async {
    try {
      final response = await _profileRepository.setOnline();
      if (!response.success) {
        debugPrint('Failed to set online status: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error setting online status: $e');
    }
  }

  /// Set user offline status with error handling
  Future<void> setOffline() async {
    try {
      final response = await _profileRepository.setOffline();
      if (!response.success) {
        debugPrint('Failed to set offline status: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error setting offline status: $e');
    }
  }

  /// Update FCM token with error handling
  Future<void> updateFcmToken(String token) async {
    if (token.isEmpty) {
      debugPrint('Cannot update FCM token: token is empty');
      return;
    }

    try {
      final response = await _profileRepository.updateFcmToken(token);
      if (!response.success) {
        debugPrint('Failed to update FCM token: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
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

  /// Toggle Low Profile mode
  /// When enabled, user is hidden from Discover but can still join events
  Future<bool> toggleLowProfile() async {
    final newValue = !isLowProfile.value;

    try {
      final response = await _profileRepository.updateLowProfileStatus(newValue);

      if (response.success) {
        isLowProfile.value = newValue;
        // Update the user model
        final user = currentUser.value;
        if (user != null) {
          currentUser.value = user.copyWith(isLowProfile: newValue);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling Low Profile mode: $e');
      return false;
    }
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
