import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'business_management_screen.dart';
import 'chat_moderation_screen.dart';
import 'event_moderation_screen.dart';
import 'user_management_screen.dart';
import 'reports_screen.dart';
import 'review_queue_screen.dart';

/// Main admin dashboard screen
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    controller.loadDashboardStats();
    controller.loadReports(refresh: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshDashboard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentAdmin.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isAdmin) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                const Text(
                  'Access Denied',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have admin privileges.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Admin info card
                _buildAdminInfoCard(controller),
                const SizedBox(height: 16),

                // Review Queue button - prominent for manual review
                _buildReviewQueueButton(controller),
                const SizedBox(height: 24),

                // Stats grid
                _buildStatsGrid(controller),
                const SizedBox(height: 24),

                // Quick actions
                _buildQuickActions(controller),
                const SizedBox(height: 24),

                // Pending items
                _buildPendingSection(controller),
                const SizedBox(height: 24),

                // Recent reports
                _buildRecentReports(controller),
              ],
            ),
          ),
        );
      }),
      drawer: _buildAdminDrawer(controller),
    );
  }

  Widget _buildAdminInfoCard(AdminController controller) {
    final admin = controller.currentAdmin.value!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              child: Icon(
                Icons.admin_panel_settings,
                size: 32,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin.name ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(admin.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      admin.roleDisplay,
                      style: TextStyle(
                        color: _getRoleColor(admin.role),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewQueueButton(AdminController controller) {
    return Obx(() {
      final stats = controller.stats.value;
      final pendingCount = (stats?.pendingVerifications ?? 0) + (stats?.pendingReports ?? 0);

      return InkWell(
        onTap: () => Get.to(() => const ReviewQueueScreen()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.deepPurple.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rate_review,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review Queue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review pending businesses & reports',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatsGrid(AdminController controller) {
    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            'Total Users',
            '${stats.totalUsers}',
            Icons.people,
            Colors.blue,
            subtitle: '+${stats.newUsersToday} today',
          ),
          _buildStatCard(
            'Businesses',
            '${stats.totalBusinesses}',
            Icons.business,
            Colors.green,
            subtitle: '${stats.verifiedBusinesses} verified',
          ),
          _buildStatCard(
            'Active Events',
            '${stats.activeEvents}',
            Icons.event,
            Colors.orange,
            subtitle: '${stats.eventsToday} today',
          ),
          _buildStatCard(
            'Pending Reports',
            '${stats.pendingReports}',
            Icons.flag,
            Colors.red,
            subtitle: '${stats.resolvedReportsToday} resolved today',
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionButton(
              'Businesses',
              Icons.business,
              Colors.green,
              () => Get.to(() => const BusinessManagementScreen()),
              badge: controller.pendingVerificationsCount > 0
                  ? '${controller.pendingVerificationsCount}'
                  : null,
            ),
            _buildActionButton(
              'Events',
              Icons.event,
              Colors.orange,
              () => Get.to(() => const EventModerationScreen()),
              badge: controller.flaggedEventsCount > 0
                  ? '${controller.flaggedEventsCount}'
                  : null,
            ),
            _buildActionButton(
              'Users',
              Icons.people,
              Colors.blue,
              () => Get.to(() => const UserManagementScreen()),
            ),
            _buildActionButton(
              'Reports',
              Icons.flag,
              Colors.red,
              () => Get.to(() => const ReportsScreen()),
              badge: controller.pendingReportsCount > 0
                  ? '${controller.pendingReportsCount}'
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 28),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final stats = controller.stats.value;
          if (stats == null) return const SizedBox.shrink();

          return Column(
            children: [
              if (stats.pendingVerifications > 0)
                _buildPendingItem(
                  'Business verifications pending',
                  '${stats.pendingVerifications}',
                  Icons.verified_user,
                  Colors.green,
                  () => Get.to(() => const BusinessManagementScreen()),
                ),
              if (stats.pendingReports > 0)
                _buildPendingItem(
                  'Reports need attention',
                  '${stats.pendingReports}',
                  Icons.flag,
                  Colors.red,
                  () => Get.to(() => const ReportsScreen()),
                ),
              if (stats.pendingVerifications == 0 && stats.pendingReports == 0)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Text(
                        'All caught up! No pending actions.',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPendingItem(
    String title,
    String count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentReports(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const ReportsScreen()),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.reports.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No reports yet'),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reports.take(5).length,
            itemBuilder: (context, index) {
              final report = controller.reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getReportColor(report.reportType).withValues(alpha: 0.1),
                    child: Icon(
                      _getReportIcon(report.reportType),
                      color: _getReportColor(report.reportType),
                    ),
                  ),
                  title: Text(report.entityName ?? 'Unknown'),
                  subtitle: Text(
                    '${report.reportTypeDisplay} - ${report.entityTypeDisplay}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.isPending
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.isPending ? 'Pending' : 'Resolved',
                      style: TextStyle(
                        color: report.isPending ? Colors.orange : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAdminDrawer(AdminController controller) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  controller.currentAdmin.value?.roleDisplay ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                )),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Review Queue'),
            subtitle: const Text('Verify businesses & review reports'),
            onTap: () {
              Get.back();
              Get.to(() => const ReviewQueueScreen());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Businesses'),
            onTap: () {
              Get.back();
              Get.to(() => const BusinessManagementScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Get.back();
              Get.to(() => const EventModerationScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
              Get.back();
              Get.to(() => const UserManagementScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Reports'),
            onTap: () {
              Get.back();
              Get.to(() => const ReportsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat Moderation'),
            subtitle: const Text('View user conversations'),
            onTap: () {
              Get.back();
              Get.to(() => const ChatModerationScreen());
            },
          ),
          const Divider(),
          if (controller.isSuperAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Manage Admins'),
              onTap: () {
                Get.back();
                // Navigate to admin management
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Get.back();
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(dynamic role) {
    switch (role.toString()) {
      case 'AdminRole.owner':
        return Colors.purple;
      case 'AdminRole.superAdmin':
        return Colors.deepOrange;
      case 'AdminRole.admin':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  Color _getReportColor(dynamic reportType) {
    switch (reportType.toString()) {
      case 'ReportType.spam':
        return Colors.grey;
      case 'ReportType.fake':
        return Colors.orange;
      case 'ReportType.scam':
        return Colors.red;
      case 'ReportType.harassment':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  IconData _getReportIcon(dynamic reportType) {
    switch (reportType.toString()) {
      case 'ReportType.spam':
        return Icons.report;
      case 'ReportType.fake':
        return Icons.warning;
      case 'ReportType.scam':
        return Icons.dangerous;
      case 'ReportType.harassment':
        return Icons.person_off;
      default:
        return Icons.flag;
    }
  }
}
