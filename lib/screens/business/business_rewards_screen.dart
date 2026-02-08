import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/business_rewards_controller.dart';
import '../../models/business_rewards_model.dart';

/// Screen for business rewards and referrals
class BusinessRewardsScreen extends StatelessWidget {
  const BusinessRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessRewardsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Referrals'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Obx(() {
          if (controller.isLoading.value && controller.rewardsSummary.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tier card
                _buildTierCard(controller),
                const SizedBox(height: 24),

                // Points summary
                _buildPointsSummary(controller),
                const SizedBox(height: 24),

                // Referral section
                _buildReferralSection(controller),
                const SizedBox(height: 24),

                // Pending rewards
                if (controller.pendingRewardsCount > 0) ...[
                  _buildPendingRewards(controller),
                  const SizedBox(height: 24),
                ],

                // Recent rewards
                _buildRecentRewards(controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTierCard(BusinessRewardsController controller) {
    Color tierColor;
    switch (controller.currentTier) {
      case 'Diamond':
        tierColor = Colors.cyan;
        break;
      case 'Platinum':
        tierColor = Colors.grey[300]!;
        break;
      case 'Gold':
        tierColor = Colors.amber;
        break;
      case 'Silver':
        tierColor = Colors.grey[400]!;
        break;
      default:
        tierColor = Colors.brown;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tierColor,
            tierColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.tierDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${controller.tierMultiplier}x reward multiplier',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress to next tier
          if (controller.pointsToNextTier > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.totalPoints} points',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '${controller.pointsToNextTier} to next tier',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.tierProgress / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsSummary(BusinessRewardsController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Points',
            '${controller.totalPoints}',
            Icons.stars,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Cash Earned',
            '\$${controller.totalCashEarned.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection(BusinessRewardsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.share, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Refer & Earn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Earn points when users sign up with your referral code!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Referral code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          controller.referralCode.value.isNotEmpty
                              ? controller.referralCode.value
                              : 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.referralCode.value),
                      );
                      Get.snackbar(
                        'Copied!',
                        'Referral code copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${controller.usersReferred}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Users Referred',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${controller.rewardsSummary.value?.eventsHosted ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Events Hosted',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share referral link
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Your Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRewards(BusinessRewardsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pending Rewards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.pendingRewardsCount} to claim',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.pendingRewards.map((reward) {
          return _buildRewardCard(reward, controller, canClaim: true);
        }),
      ],
    );
  }

  Widget _buildRecentRewards(BusinessRewardsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Rewards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => controller.loadRewards(refresh: true),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.rewards.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('No rewards yet. Start referring users!'),
            ),
          )
        else
          ...controller.rewards.take(5).map((reward) {
            return _buildRewardCard(reward, controller);
          }),
      ],
    );
  }

  Widget _buildRewardCard(
    BusinessRewardModel reward,
    BusinessRewardsController controller, {
    bool canClaim = false,
  }) {
    IconData icon;
    Color color;
    switch (reward.type) {
      case RewardType.userReferral:
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case RewardType.eventCreation:
        icon = Icons.event;
        color = Colors.green;
        break;
      case RewardType.attendeeCount:
        icon = Icons.groups;
        color = Colors.purple;
        break;
      case RewardType.engagement:
        icon = Icons.trending_up;
        color = Colors.orange;
        break;
      case RewardType.milestone:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case RewardType.promotion:
        icon = Icons.campaign;
        color = Colors.pink;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title ?? 'Reward',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (reward.description != null)
                    Text(
                      reward.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${reward.points} pts',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (canClaim && reward.canClaim)
                  TextButton(
                    onPressed: controller.isClaiming.value
                        ? null
                        : () => controller.claimReward(reward.rewardId!),
                    child: const Text('Claim'),
                  )
                else
                  Text(
                    reward.status.name,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
