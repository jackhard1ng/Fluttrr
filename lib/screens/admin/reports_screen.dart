import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/admin_model.dart';

/// Screen for managing content reports
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    controller.loadReports(refresh: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Reports'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    controller.reportFilter.value == null,
                    () {
                      controller.reportFilter.value = null;
                      controller.loadReports(refresh: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    controller.reportFilter.value == ReportStatus.pending,
                    () {
                      controller.reportFilter.value = ReportStatus.pending;
                      controller.loadReports(refresh: true);
                    },
                    badgeCount: controller.pendingReportsCount,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Under Review',
                    controller.reportFilter.value == ReportStatus.underReview,
                    () {
                      controller.reportFilter.value = ReportStatus.underReview;
                      controller.loadReports(refresh: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Resolved',
                    controller.reportFilter.value == ReportStatus.resolved,
                    () {
                      controller.reportFilter.value = ReportStatus.resolved;
                      controller.loadReports(refresh: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Dismissed',
                    controller.reportFilter.value == ReportStatus.dismissed,
                    () {
                      controller.reportFilter.value = ReportStatus.dismissed;
                      controller.loadReports(refresh: true);
                    },
                  ),
                ],
              ),
            )),
          ),

          // Reports list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingReports.value && controller.reports.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No reports found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadReports(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.reports.length + (controller.hasMoreReports.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.reports.length) {
                      controller.loadReports();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final report = controller.reports[index];
                    return _buildReportCard(report, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, {int? badgeCount}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[700],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: selected ? Colors.deepPurple : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ContentReportModel report, AdminController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReportDetails(report, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getReportTypeColor(report.reportType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getReportTypeIcon(report.reportType),
                      color: _getReportTypeColor(report.reportType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.entityName ?? 'Unknown Content',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.entityTypeDisplay,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              report.reportTypeDisplay,
                              style: TextStyle(
                                color: _getReportTypeColor(report.reportType),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(report.status),
                ],
              ),

              if (report.reason != null) ...[
                const SizedBox(height: 12),
                Text(
                  report.reason!,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Reported by ${report.reportedByName ?? 'Anonymous'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  if (report.createdAt != null)
                    Text(
                      _formatTimeAgo(report.createdAt!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),

              // Quick actions for pending reports
              if (report.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDismissDialog(report, controller),
                        child: const Text('Dismiss'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showResolveDialog(report, controller),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ReportStatus.underReview:
        color = Colors.blue;
        text = 'Reviewing';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        text = 'Resolved';
        break;
      case ReportStatus.dismissed:
        color = Colors.grey;
        text = 'Dismissed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showReportDetails(ContentReportModel report, AdminController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getReportTypeColor(report.reportType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getReportTypeIcon(report.reportType),
                      color: _getReportTypeColor(report.reportType),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.reportTypeDisplay,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Report on ${report.entityTypeDisplay}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(report.status),
                ],
              ),
              const SizedBox(height: 24),

              // Reported content info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reported Content',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (report.entityImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              report.entityImage!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (report.entityImage != null) const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.entityName ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              if (report.entityOwnerName != null)
                                Text(
                                  'by ${report.entityOwnerName}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Reported by', report.reportedByName ?? 'Anonymous'),
              if (report.reason != null)
                _buildDetailRow('Reason', report.reason!),
              if (report.details != null)
                _buildDetailRow('Details', report.details!),
              if (report.createdAt != null)
                _buildDetailRow('Reported', _formatDate(report.createdAt!)),
              if (report.assignedTo != null)
                _buildDetailRow('Assigned to', report.assignedTo!),
              if (report.resolution != null)
                _buildDetailRow('Resolution', report.resolution!),
              if (report.resolvedAt != null)
                _buildDetailRow('Resolved', _formatDate(report.resolvedAt!)),

              const SizedBox(height: 24),

              // Actions
              if (report.isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          _showDismissDialog(report, controller);
                        },
                        child: const Text('Dismiss'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _showResolveDialog(report, controller);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Close'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
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
              decoration: const InputDecoration(
                labelText: 'Action Taken',
              ),
              items: const [
                DropdownMenuItem(value: 'warning_sent', child: Text('Warning sent to user')),
                DropdownMenuItem(value: 'content_removed', child: Text('Content removed')),
                DropdownMenuItem(value: 'user_suspended', child: Text('User suspended')),
                DropdownMenuItem(value: 'user_banned', child: Text('User banned')),
                DropdownMenuItem(value: 'other', child: Text('Other action')),
              ],
              onChanged: (value) => actionTaken = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution Notes',
                hintText: 'Describe how the report was resolved...',
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
            onPressed: () {
              if (resolutionController.text.isNotEmpty) {
                Get.back();
                controller.resolveReport(
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

  void _showDismissDialog(ContentReportModel report, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Dismiss Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to dismiss this report?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why is this report being dismissed?',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.dismissReport(
                report.reportId!,
                reason: reasonController.text.isNotEmpty ? reasonController.text : null,
              );
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(AdminController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterOption('All', controller.reportFilter.value == null, () {
                  controller.reportFilter.value = null;
                }),
                ...ReportStatus.values.map((status) {
                  return _buildFilterOption(
                    status.name,
                    controller.reportFilter.value == status,
                    () => controller.reportFilter.value = status,
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.loadReports(refresh: true);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
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
        return Colors.amber;
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
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return _formatDate(date);
    }
  }
}
