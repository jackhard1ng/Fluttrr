import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Business analytics screen
class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() =>
      _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen> {
  final _businessController = Get.isRegistered<BusinessController>()
      ? Get.find<BusinessController>()
      : Get.put(BusinessController());
  String _selectedPeriod = '7 days';

  final List<String> _periods = ['7 days', '30 days', '90 days', 'All time'];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    _businessController.loadBusinessAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_businessController.isLoading.value) {
          return const LoadingIndicator();
        }

        final analytics = _businessController.analytics.value;

        if (analytics == null) {
          return const EmptyState(
            icon: Icons.analytics_outlined,
            title: 'No Analytics Yet',
            subtitle: 'Create events to start tracking performance',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadAnalytics(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview cards
                _buildOverviewSection(analytics),

                const SizedBox(height: AppSpacing.lg),

                // Engagement metrics
                _buildSection(
                  'Engagement',
                  _buildEngagementMetrics(analytics),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Top performing events
                _buildSection(
                  'Top Events',
                  _buildTopEvents(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Growth metrics
                _buildSection(
                  'Growth',
                  _buildGrowthMetrics(analytics),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewSection(dynamic analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.event,
                label: 'Total Events',
                value: '${analytics.totalEvents ?? 0}',
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _OverviewCard(
                icon: Icons.people,
                label: 'Total Attendees',
                value: '${analytics.totalAttendees ?? 0}',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.visibility,
                label: 'Total Views',
                value: '${analytics.totalViews ?? 0}',
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _OverviewCard(
                icon: Icons.touch_app,
                label: 'Total Clicks',
                value: '${analytics.totalClicks ?? 0}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }

  Widget _buildEngagementMetrics(dynamic analytics) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          _MetricRow(
            label: 'View Rate',
            value: '${analytics.viewRate?.toStringAsFixed(1) ?? 0}%',
            progress: (analytics.viewRate ?? 0) / 100,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: 'Click Rate',
            value: '${analytics.clickRate?.toStringAsFixed(1) ?? 0}%',
            progress: (analytics.clickRate ?? 0) / 100,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: 'Conversion Rate',
            value: '${analytics.conversionRate?.toStringAsFixed(1) ?? 0}%',
            progress: (analytics.conversionRate ?? 0) / 100,
            color: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTopEvents() {
    final topEvents = _businessController.analytics.value?.topEvents ?? [];

    if (topEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
        ),
        child: const Center(
          child: Text(
            'No events data available',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: topEvents.take(5).map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name ?? 'Event',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${event.attendees ?? 0} attendees',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${event.views ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'views',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrowthMetrics(dynamic analytics) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          _GrowthItem(
            label: 'Followers',
            value: '${analytics.followers ?? 0}',
            growth: analytics.followersGrowth ?? 0,
          ),
          const Divider(),
          _GrowthItem(
            label: 'Events Created',
            value: '${analytics.eventsCreatedThisPeriod ?? 0}',
            growth: analytics.eventsGrowth ?? 0,
          ),
          const Divider(),
          _GrowthItem(
            label: 'Total Engagement',
            value: '${analytics.totalEngagement ?? 0}',
            growth: analytics.engagementGrowth ?? 0,
          ),
        ],
      ),
    );
  }
}

/// Overview card widget
class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
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
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metric row widget
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withAlpha(51),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

/// Growth item widget
class _GrowthItem extends StatelessWidget {
  final String label;
  final String value;
  final double growth;

  const _GrowthItem({
    required this.label,
    required this.value,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.success.withAlpha(26)
                      : AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    Text(
                      '${growth.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
