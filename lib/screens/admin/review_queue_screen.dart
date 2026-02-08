import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/admin_model.dart';

/// Combined review queue for pending items - businesses and reports
class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    // Load both pending businesses and reports
    controller.businessFilter.value = BusinessVerificationStatus.pending;
    controller.loadBusinesses(refresh: true);
    controller.reportFilter.value = ReportStatus.pending;
    controller.loadReports(refresh: true);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Queue'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Obx(() => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Businesses'),
                    if (controller.businesses.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.businesses.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
              Obx(() => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Reports'),
                    if (controller.reports.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.reports.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
              const Tab(text: 'All Activity'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBusinessVerificationTab(controller),
            _buildReportsTab(controller),
            _buildActivityTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessVerificationTab(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingBusinesses.value && controller.businesses.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.businesses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
              const SizedBox(height: 16),
              const Text(
                'All caught up!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No businesses pending verification',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.businesses.length,
        itemBuilder: (context, index) {
          final business = controller.businesses[index];
          return _buildBusinessVerificationCard(business, controller);
        },
      );
    });
  }

  Widget _buildBusinessVerificationCard(ManagedBusinessModel business, AdminController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with business info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: business.image != null
                      ? NetworkImage(business.image!)
                      : null,
                  child: business.image == null
                      ? Text(
                          business.name?.substring(0, 1).toUpperCase() ?? 'B',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name ?? 'Unknown Business',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.email ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Business details
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, 'Owner', business.ownerName ?? 'Unknown'),
                if (business.ownerEmail != null)
                  _buildInfoRow(Icons.email, 'Owner Email', business.ownerEmail!),
                if (business.phone != null)
                  _buildInfoRow(Icons.phone, 'Phone', business.phone!),
                if (business.description != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.description!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
                if (business.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Submitted: ${_formatDate(business.createdAt!)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () => _showRejectDialog(business, controller),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () => _verifyBusiness(business, controller),
                    icon: const Icon(Icons.check),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingReports.value && controller.reports.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
              const SizedBox(height: 16),
              const Text(
                'All caught up!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No pending reports to review',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.reports.length,
        itemBuilder: (context, index) {
          final report = controller.reports[index];
          return _buildReportReviewCard(report, controller);
        },
      );
    });
  }

  Widget _buildReportReviewCard(ContentReportModel report, AdminController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getReportTypeColor(report.reportType).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  _getReportTypeIcon(report.reportType),
                  color: _getReportTypeColor(report.reportType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportTypeDisplay,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getReportTypeColor(report.reportType),
                        ),
                      ),
                      Text(
                        'Reported ${report.entityTypeDisplay}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (report.createdAt != null)
                  Text(
                    _formatTimeAgo(report.createdAt!),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ),

          // Reported content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reported Content:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (report.entityImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.entityImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                      if (report.entityImage != null) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.entityName ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (report.entityOwnerName != null)
                              Text(
                                'by ${report.entityOwnerName}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _viewReportedContent(report),
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reason
                if (report.reason != null) ...[
                  const Text(
                    'Reason given:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.reason!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],

                if (report.details != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Additional details:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.details!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  'Reported by: ${report.reportedByName ?? 'Anonymous'}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick actions based on report type
                if (report.entityType == EntityType.user)
                  _buildQuickActionRow([
                    _QuickAction('Warn User', Icons.warning, Colors.amber,
                      () => _warnUser(report, controller)),
                    _QuickAction('Suspend', Icons.block, Colors.orange,
                      () => _suspendUser(report, controller)),
                    _QuickAction('Ban', Icons.gavel, Colors.red,
                      () => _banUser(report, controller)),
                  ])
                else if (report.entityType == EntityType.business)
                  _buildQuickActionRow([
                    _QuickAction('Warn', Icons.warning, Colors.amber,
                      () => _warnBusinessOwner(report, controller)),
                    _QuickAction('Suspend', Icons.block, Colors.orange,
                      () => _suspendBusiness(report, controller)),
                    _QuickAction('Delete', Icons.delete, Colors.red,
                      () => _deleteBusiness(report, controller)),
                  ])
                else if (report.entityType == EntityType.event)
                  _buildQuickActionRow([
                    _QuickAction('Warn Host', Icons.warning, Colors.amber,
                      () => _warnEventHost(report, controller)),
                    _QuickAction('Remove Event', Icons.delete, Colors.red,
                      () => _removeEvent(report, controller)),
                  ]),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => _dismissReport(report, controller),
                        child: const Text('Dismiss'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => _showResolveDialog(report, controller),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(List<_QuickAction> actions) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton.icon(
              onPressed: action.onTap,
              icon: Icon(action.icon, size: 16),
              label: Text(action.label, style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: action.color,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityTab(AdminController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Recent Activity Log',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyBusiness(ManagedBusinessModel business, AdminController controller) async {
    final success = await controller.verifyBusiness(business.businessId!, approve: true);
    if (success) {
      Get.snackbar(
        'Business Verified',
        '${business.name} has been verified',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _showRejectDialog(ManagedBusinessModel business, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject verification for "${business.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'This will be sent to the business owner',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                final success = await controller.verifyBusiness(
                  business.businessId!,
                  approve: false,
                  reason: reasonController.text,
                );
                if (success) {
                  Get.snackbar(
                    'Business Rejected',
                    'The business owner has been notified',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _dismissReport(ContentReportModel report, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Dismiss Report?'),
        content: const Text('This report will be marked as dismissed with no action taken.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.dismissReport(report.reportId!);
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(ContentReportModel report, AdminController controller) {
    final resolutionController = TextEditingController();
    String? actionTaken;

    Get.dialog(
      AlertDialog(
        title: const Text('Resolve Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Action Taken'),
              items: const [
                DropdownMenuItem(value: 'warning_sent', child: Text('Warning sent')),
                DropdownMenuItem(value: 'content_removed', child: Text('Content removed')),
                DropdownMenuItem(value: 'user_suspended', child: Text('User suspended')),
                DropdownMenuItem(value: 'user_banned', child: Text('User banned')),
                DropdownMenuItem(value: 'no_violation', child: Text('No violation found')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => actionTaken = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution notes',
                hintText: 'Describe how you resolved this...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resolutionController.text.isNotEmpty) {
                Get.back();
                await controller.resolveReport(
                  report.reportId!,
                  resolution: resolutionController.text,
                  actionTaken: actionTaken,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _viewReportedContent(ContentReportModel report) {
    // Navigate to the reported content
    Get.snackbar(
      'View Content',
      'Navigate to ${report.entityType.name} ${report.entityId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Quick action handlers
  void _warnUser(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      _showWarnDialog(report.entityId!, report.entityName ?? 'User', controller);
    }
  }

  void _suspendUser(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      _showSuspendDialog(report.entityId!, report.entityName ?? 'User', controller);
    }
  }

  void _banUser(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      _showBanDialog(report.entityId!, report.entityName ?? 'User', controller);
    }
  }

  void _warnBusinessOwner(ContentReportModel report, AdminController controller) {
    if (report.entityOwnerId != null) {
      _showWarnDialog(report.entityOwnerId!, report.entityOwnerName ?? 'Business Owner', controller);
    }
  }

  void _suspendBusiness(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Suspend Business?'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.suspendBusiness(report.entityId!, reason: 'Policy violation');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Suspend'),
            ),
          ],
        ),
      );
    }
  }

  void _deleteBusiness(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Business?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.deleteBusiness(report.entityId!, reason: 'Policy violation');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _warnEventHost(ContentReportModel report, AdminController controller) {
    if (report.entityOwnerId != null) {
      _showWarnDialog(report.entityOwnerId!, report.entityOwnerName ?? 'Event Host', controller);
    }
  }

  void _removeEvent(ContentReportModel report, AdminController controller) {
    if (report.entityId != null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Remove Event?'),
          content: const Text('This will remove the event and notify attendees.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.removeEvent(report.entityId!, reason: 'Policy violation');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }
  }

  void _showWarnDialog(String userId, String userName, AdminController controller) {
    final messageController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Warn $userName'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Warning message',
            hintText: 'Explain the policy violation...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                Get.back();
                controller.warnUser(userId, message: messageController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(String userId, String userName, AdminController controller) {
    int? duration;
    Get.dialog(
      AlertDialog(
        title: Text('Suspend $userName'),
        content: DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Duration'),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 day')),
            DropdownMenuItem(value: 3, child: Text('3 days')),
            DropdownMenuItem(value: 7, child: Text('7 days')),
            DropdownMenuItem(value: 14, child: Text('14 days')),
            DropdownMenuItem(value: 30, child: Text('30 days')),
          ],
          onChanged: (value) => duration = value,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.suspendUser(userId, reason: 'Policy violation', durationDays: duration);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(String userId, String userName, AdminController controller) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Ban $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will permanently ban the user.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Ban reason'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                controller.banUser(userId, reason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.spam:
        return Colors.grey;
      case ReportType.inappropriate:
        return Colors.orange;
      case ReportType.fake:
        return Colors.amber[700]!;
      case ReportType.scam:
        return Colors.red;
      case ReportType.harassment:
        return Colors.deepOrange;
      case ReportType.copyright:
        return Colors.purple;
      case ReportType.other:
        return Colors.blue;
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.spam:
        return Icons.report;
      case ReportType.inappropriate:
        return Icons.visibility_off;
      case ReportType.fake:
        return Icons.warning;
      case ReportType.scam:
        return Icons.dangerous;
      case ReportType.harassment:
        return Icons.person_off;
      case ReportType.copyright:
        return Icons.copyright;
      case ReportType.other:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatDate(date);
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAction(this.label, this.icon, this.color, this.onTap);
}
