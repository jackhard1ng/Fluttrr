import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/business_rewards_model.dart';
import '../repositories/business_rewards_repository.dart';

/// Controller for business rewards
class BusinessRewardsController extends GetxController {
  final BusinessRewardsRepository _repository = BusinessRewardsRepository();

  // State
  final Rx<BusinessRewardsSummary?> rewardsSummary = Rx<BusinessRewardsSummary?>(null);
  final RxList<BusinessRewardModel> rewards = <BusinessRewardModel>[].obs;
  final RxList<BusinessRewardModel> pendingRewards = <BusinessRewardModel>[].obs;
  final RxList<BusinessReferralModel> referrals = <BusinessReferralModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isClaiming = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Referral code
  final RxString referralCode = ''.obs;
  final RxString referralLink = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreRewards = true.obs;
  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadRewardsSummary();
    loadReferralCode();
  }

  /// Load rewards summary
  Future<void> loadRewardsSummary() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getRewardsSummary();
      if (response.success && response.data != null) {
        rewardsSummary.value = response.data;
        pendingRewards.value = response.data!.recentRewards
            .where((r) => r.status == RewardStatus.pending)
            .toList();
      } else {
        errorMessage.value = response.error ?? 'Failed to load rewards';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load rewards';
      debugPrint('Error loading rewards summary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load rewards list
  Future<void> loadRewards({
    bool refresh = false,
    RewardStatus? status,
    RewardType? type,
  }) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreRewards.value = true;
      rewards.clear();
    }

    if (!hasMoreRewards.value) return;

    try {
      final response = await _repository.getRewardsList(
        status: status,
        type: type,
        page: currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          rewards.value = response.data!;
        } else {
          rewards.addAll(response.data!);
        }
        hasMoreRewards.value = response.data!.length >= pageSize;
        if (hasMoreRewards.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error loading rewards: $e');
    }
  }

  /// Claim a reward
  Future<bool> claimReward(String rewardId) async {
    isClaiming.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.claimReward(rewardId: rewardId);

      if (response.success && response.data != null) {
        // Update reward in list
        final index = rewards.indexWhere((r) => r.rewardId == rewardId);
        if (index != -1) {
          rewards[index] = response.data!;
        }

        // Remove from pending
        pendingRewards.removeWhere((r) => r.rewardId == rewardId);

        // Update summary
        await loadRewardsSummary();

        successMessage.value = 'Reward claimed successfully!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to claim reward';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to claim reward. Please try again.';
      return false;
    } finally {
      isClaiming.value = false;
    }
  }

  /// Load referrals
  Future<void> loadReferrals({bool refresh = false}) async {
    try {
      final response = await _repository.getReferrals(
        page: refresh ? 1 : currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          referrals.value = response.data!;
        } else {
          referrals.addAll(response.data!);
        }
      }
    } catch (e) {
      debugPrint('Error loading referrals: $e');
    }
  }

  /// Load or generate referral code
  Future<void> loadReferralCode() async {
    try {
      final response = await _repository.getReferralCode();
      if (response.success && response.data != null) {
        referralCode.value = response.data!['referral_code'] as String? ?? '';
        referralLink.value = response.data!['referral_link'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('Error loading referral code: $e');
    }
  }

  /// Generate new referral code
  Future<bool> generateNewReferralCode() async {
    try {
      final response = await _repository.generateReferralCode();
      if (response.success && response.data != null) {
        referralCode.value = response.data!['referral_code'] as String? ?? '';
        referralLink.value = response.data!['referral_link'] as String? ?? '';
        successMessage.value = 'New referral code generated!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to generate referral code';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate referral code';
      return false;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadRewardsSummary(),
      loadRewards(refresh: true),
      loadReferrals(refresh: true),
    ]);
  }

  // Getters
  int get totalPoints => rewardsSummary.value?.totalPoints ?? 0;
  double get totalCashEarned => rewardsSummary.value?.totalCashEarned ?? 0.0;
  int get pendingRewardsCount => rewardsSummary.value?.pendingRewards ?? 0;
  int get usersReferred => rewardsSummary.value?.usersReferred ?? 0;
  String get currentTier => rewardsSummary.value?.tier ?? 'Bronze';
  int get tierProgress => rewardsSummary.value?.tierProgress ?? 0;
  int get pointsToNextTier => rewardsSummary.value?.pointsToNextTier ?? 1000;

  String get tierDisplayName {
    switch (currentTier) {
      case 'Diamond':
        return 'Diamond Partner';
      case 'Platinum':
        return 'Platinum Partner';
      case 'Gold':
        return 'Gold Partner';
      case 'Silver':
        return 'Silver Partner';
      default:
        return 'Bronze Partner';
    }
  }

  double get tierMultiplier {
    return RewardTier.multipliers[currentTier] ?? 1.0;
  }
}
