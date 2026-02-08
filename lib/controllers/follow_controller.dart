import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/follow_model.dart';
import '../models/business_model.dart';
import '../repositories/follow_repository.dart';

/// Controller for following businesses
class FollowController extends GetxController {
  final FollowRepository _repository = FollowRepository();

  // State
  final RxList<BusinessFollowModel> followedBusinesses = <BusinessFollowModel>[].obs;
  final RxList<BusinessEvent> followedBusinessEvents = <BusinessEvent>[].obs;
  final RxMap<int, FollowNotificationSettings> notificationSettings = <int, FollowNotificationSettings>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isFollowing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Pagination for events
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreEvents = true.obs;
  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadFollowedBusinesses();
    loadFollowedBusinessEvents();
  }

  /// Load followed businesses
  Future<void> loadFollowedBusinesses() async {
    isLoading.value = true;

    try {
      final response = await _repository.getFollowedBusinesses();
      if (response.success && response.data != null) {
        followedBusinesses.value = response.data!.businesses;
      }
    } catch (e) {
      debugPrint('Error loading followed businesses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load events from followed businesses
  Future<void> loadFollowedBusinessEvents({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreEvents.value = true;
      followedBusinessEvents.clear();
    }

    if (!hasMoreEvents.value) return;

    isLoadingEvents.value = true;

    try {
      final response = await _repository.getFollowedBusinessEvents(
        page: currentPage.value,
        limit: pageSize,
        fromDate: DateTime.now(),
      );

      if (response.success && response.data != null) {
        if (refresh) {
          followedBusinessEvents.value = response.data!;
        } else {
          followedBusinessEvents.addAll(response.data!);
        }
        hasMoreEvents.value = response.data!.length >= pageSize;
        if (hasMoreEvents.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error loading followed business events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// Follow a business
  Future<bool> followBusiness({
    required int businessId,
    bool enableNotifications = true,
  }) async {
    isFollowing.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.followBusiness(
        businessId: businessId,
        enableNotifications: enableNotifications,
      );

      if (response.success && response.data != null) {
        followedBusinesses.add(response.data!);
        successMessage.value = 'Now following ${response.data!.businessName}';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to follow business';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to follow business';
      return false;
    } finally {
      isFollowing.value = false;
    }
  }

  /// Unfollow a business
  Future<bool> unfollowBusiness(int businessId) async {
    isFollowing.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.unfollowBusiness(businessId: businessId);

      if (response.success) {
        final businessName = followedBusinesses
            .firstWhereOrNull((b) => b.businessId == businessId)
            ?.businessName;
        followedBusinesses.removeWhere((b) => b.businessId == businessId);
        notificationSettings.remove(businessId);
        successMessage.value = businessName != null
            ? 'Unfollowed $businessName'
            : 'Unfollowed business';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to unfollow business';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to unfollow business';
      return false;
    } finally {
      isFollowing.value = false;
    }
  }

  /// Toggle follow status
  Future<bool> toggleFollow(int businessId) async {
    if (isFollowingBusiness(businessId)) {
      return unfollowBusiness(businessId);
    } else {
      return followBusiness(businessId: businessId);
    }
  }

  /// Update notification settings for a followed business
  Future<bool> updateNotificationSettings({
    required int businessId,
    bool? newEvents,
    bool? eventReminders,
    bool? promotions,
    bool? updates,
  }) async {
    try {
      final response = await _repository.updateFollowNotifications(
        businessId: businessId,
        newEvents: newEvents,
        eventReminders: eventReminders,
        promotions: promotions,
        updates: updates,
      );

      if (response.success && response.data != null) {
        notificationSettings[businessId] = response.data!;

        // Update in followed businesses list
        final index = followedBusinesses.indexWhere((b) => b.businessId == businessId);
        if (index != -1) {
          followedBusinesses[index] = followedBusinesses[index].copyWith(
            notificationsEnabled: response.data!.newEvents ||
                response.data!.eventReminders ||
                response.data!.promotions ||
                response.data!.updates,
          );
        }

        successMessage.value = 'Notification settings updated';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to update settings';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update settings';
      return false;
    }
  }

  /// Load notification settings for a business
  Future<void> loadNotificationSettings(int businessId) async {
    try {
      final response = await _repository.getFollowNotificationSettings(
        businessId: businessId,
      );
      if (response.success && response.data != null) {
        notificationSettings[businessId] = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// Check if following a business
  bool isFollowingBusiness(int businessId) {
    return followedBusinesses.any((b) => b.businessId == businessId);
  }

  /// Get notification settings for a business
  FollowNotificationSettings? getNotificationSettings(int businessId) {
    return notificationSettings[businessId];
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadFollowedBusinesses(),
      loadFollowedBusinessEvents(refresh: true),
    ]);
  }

  // Getters
  int get followedCount => followedBusinesses.length;
  int get upcomingEventsCount => followedBusinessEvents.length;

  /// Get businesses with upcoming events
  List<BusinessFollowModel> get businessesWithUpcomingEvents {
    return followedBusinesses
        .where((b) => b.upcomingEventCount > 0)
        .toList();
  }

  /// Get business IDs for quick lookup
  Set<int> get followedBusinessIds {
    return followedBusinesses
        .map((b) => b.businessId)
        .whereType<int>()
        .toSet();
  }
}
