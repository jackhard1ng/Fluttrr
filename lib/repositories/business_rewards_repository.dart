import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/business_rewards_model.dart';
import 'base_repository.dart';

/// Repository for business rewards operations
class BusinessRewardsRepository extends BaseRepository {
  /// Get business rewards summary
  Future<ApiResponse<BusinessRewardsSummary>> getRewardsSummary() async {
    return get<BusinessRewardsSummary>(
      ApiEndpoints.businessRewardsSummary,
      fromJson: BusinessRewardsSummary.fromJson,
    );
  }

  /// Get list of business rewards
  Future<ApiResponse<List<BusinessRewardModel>>> getRewardsList({
    RewardStatus? status,
    RewardType? type,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (type != null) {
      queryParams['type'] = type.name;
    }

    final response = await get<dynamic>(
      ApiEndpoints.businessRewardsList,
      queryParams: queryParams,
    );
    return parseListResponse(response, BusinessRewardModel.fromJson);
  }

  /// Claim a reward
  Future<ApiResponse<BusinessRewardModel>> claimReward({
    required String rewardId,
  }) async {
    return post<BusinessRewardModel>(
      ApiEndpoints.claimBusinessReward,
      body: {
        'reward_id': rewardId,
      },
      fromJson: BusinessRewardModel.fromJson,
    );
  }

  /// Get business referrals
  Future<ApiResponse<List<BusinessReferralModel>>> getReferrals({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<dynamic>(
      ApiEndpoints.businessReferrals,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return parseListResponse(response, BusinessReferralModel.fromJson);
  }

  /// Get or generate referral code
  Future<ApiResponse<Map<String, dynamic>>> getReferralCode() async {
    final response = await get<dynamic>(
      ApiEndpoints.businessReferralCode,
    );
    if (response.success && response.data != null && response.data is Map<String, dynamic>) {
      return ApiResponse.success(
        data: response.data as Map<String, dynamic>,
        message: response.message,
      );
    }
    return ApiResponse.failure(error: response.error ?? 'Failed to get referral code');
  }

  /// Generate new referral code
  Future<ApiResponse<Map<String, dynamic>>> generateReferralCode() async {
    final response = await post<dynamic>(
      ApiEndpoints.businessReferralCode,
      body: {'generate': true},
    );
    if (response.success && response.data != null && response.data is Map<String, dynamic>) {
      return ApiResponse.success(
        data: response.data as Map<String, dynamic>,
        message: response.message,
      );
    }
    return ApiResponse.failure(error: response.error ?? 'Failed to generate referral code');
  }

  /// Track referral conversion
  Future<ApiResponse<dynamic>> trackReferralConversion({
    required String referralCode,
    required int userId,
    required String action,
  }) async {
    return post(
      '${ApiEndpoints.businessReferrals}/track',
      body: {
        'referral_code': referralCode,
        'user_id': userId,
        'action': action,
      },
    );
  }
}
