import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/admin_model.dart';

/// Screen for managing businesses as admin
class BusinessManagementScreen extends StatelessWidget {
  const BusinessManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    controller.loadBusinesses(refresh: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Businesses'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBusinessDialog(controller),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.loadBusinesses(refresh: true);
              },
            ),
          ),

          // Filter chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  controller.businessFilter.value == null,
                  () {
                    controller.businessFilter.value = null;
                    controller.loadBusinesses(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending',
                  controller.businessFilter.value == BusinessVerificationStatus.pending,
                  () {
                    controller.businessFilter.value = BusinessVerificationStatus.pending;
                    controller.loadBusinesses(refresh: true);
                  },
                  badgeCount: controller.pendingVerificationsCount,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Verified',
                  controller.businessFilter.value == BusinessVerificationStatus.verified,
                  () {
                    controller.businessFilter.value = BusinessVerificationStatus.verified;
                    controller.loadBusinesses(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Suspended',
                  controller.businessFilter.value == BusinessVerificationStatus.suspended,
                  () {
                    controller.businessFilter.value = BusinessVerificationStatus.suspended;
                    controller.loadBusinesses(refresh: true);
                  },
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),

          // Business list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingBusinesses.value && controller.businesses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.businesses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No businesses found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadBusinesses(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.businesses.length + (controller.hasMoreBusinesses.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.businesses.length) {
                      controller.loadBusinesses();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final business = controller.businesses[index];
                    return _buildBusinessCard(business, controller);
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

  Widget _buildBusinessCard(ManagedBusinessModel business, AdminController controller) {
    Color statusColor;
    switch (business.verificationStatus) {
      case BusinessVerificationStatus.verified:
        statusColor = Colors.green;
        break;
      case BusinessVerificationStatus.pending:
        statusColor = Colors.orange;
        break;
      case BusinessVerificationStatus.suspended:
        statusColor = Colors.red;
        break;
      case BusinessVerificationStatus.rejected:
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBusinessDetails(business, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: business.image != null
                        ? NetworkImage(business.image!)
                        : null,
                    child: business.image == null
                        ? Text(business.name?.substring(0, 1).toUpperCase() ?? 'B')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                business.name ?? 'Unknown Business',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (business.isFeatured)
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          business.email ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      business.verificationStatusDisplay,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(Icons.event, '${business.eventCount}', 'Events'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.people, '${business.followerCount}', 'Followers'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.star, business.rating.toStringAsFixed(1), 'Rating'),
                  if (business.reportCount > 0) ...[
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.flag, '${business.reportCount}', 'Reports', color: Colors.red),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Quick actions
              Row(
                children: [
                  if (business.hasPendingVerification) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.verifyBusiness(business.businessId!, approve: false),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.verifyBusiness(business.businessId!, approve: true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Verify'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showBusinessActions(business, controller),
                        icon: const Icon(Icons.more_horiz),
                        label: const Text('Actions'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showBusinessDetails(ManagedBusinessModel business, AdminController controller) {
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
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: business.image != null
                        ? NetworkImage(business.image!)
                        : null,
                    child: business.image == null
                        ? Text(business.name?.substring(0, 1).toUpperCase() ?? 'B')
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          business.verificationStatusDisplay,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildDetailRow('Email', business.email ?? 'N/A'),
              _buildDetailRow('Phone', business.phone ?? 'N/A'),
              _buildDetailRow('Owner', business.ownerName ?? 'N/A'),
              _buildDetailRow('Owner Email', business.ownerEmail ?? 'N/A'),
              _buildDetailRow('Events', '${business.eventCount}'),
              _buildDetailRow('Followers', '${business.followerCount}'),
              _buildDetailRow('Reports', '${business.reportCount}'),
              if (business.createdAt != null)
                _buildDetailRow('Created', _formatDate(business.createdAt!)),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.toggleBusinessFeatured(business.businessId!);
                      },
                      icon: Icon(business.isFeatured ? Icons.star_border : Icons.star),
                      label: Text(business.isFeatured ? 'Unfeature' : 'Feature'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showBusinessActions(business, controller);
                      },
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('More'),
                    ),
                  ),
                ],
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

  void _showBusinessActions(ManagedBusinessModel business, AdminController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              business.name ?? 'Business',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (!business.isVerified && !business.hasPendingVerification)
              ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: const Text('Mark as Verified'),
                onTap: () {
                  Get.back();
                  controller.verifyBusiness(business.businessId!, approve: true);
                },
              ),

            if (!business.isSuspended)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Suspend Business'),
                onTap: () {
                  Get.back();
                  _showSuspendDialog(business, controller);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Unsuspend Business'),
                onTap: () {
                  Get.back();
                  controller.unsuspendBusiness(business.businessId!);
                },
              ),

            ListTile(
              leading: Icon(business.isFeatured ? Icons.star_border : Icons.star, color: Colors.amber),
              title: Text(business.isFeatured ? 'Remove from Featured' : 'Add to Featured'),
              onTap: () {
                Get.back();
                controller.toggleBusinessFeatured(business.businessId!);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Business', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(business, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(ManagedBusinessModel business, AdminController controller) {
    final reasonController = TextEditingController();
    int? durationDays;

    Get.dialog(
      AlertDialog(
        title: const Text('Suspend Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why is this business being suspended?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Duration',
              ),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 days')),
                DropdownMenuItem(value: 14, child: Text('14 days')),
                DropdownMenuItem(value: 30, child: Text('30 days')),
                DropdownMenuItem(value: 90, child: Text('90 days')),
                DropdownMenuItem(value: null, child: Text('Indefinite')),
              ],
              onChanged: (value) => durationDays = value,
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
              if (reasonController.text.isNotEmpty) {
                Get.back();
                controller.suspendBusiness(
                  business.businessId!,
                  reason: reasonController.text,
                  durationDays: durationDays,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ManagedBusinessModel business, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Business?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete "${business.name}"? This action cannot be undone.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for deletion',
                hintText: 'Why is this business being deleted?',
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
              if (reasonController.text.isNotEmpty) {
                Get.back();
                controller.deleteBusiness(business.businessId!, reason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateBusinessDialog(AdminController controller) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final descriptionController = TextEditingController();
    bool autoVerify = true;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Business'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => CheckboxListTile(
                  title: const Text('Auto-verify this business'),
                  value: autoVerify,
                  onChanged: (value) => setState(() => autoVerify = value ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                Get.back();
                controller.createBusiness(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  autoVerify: autoVerify,
                );
              }
            },
            child: const Text('Create'),
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
              'Filter Businesses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterOption('All', controller.businessFilter.value == null, () {
                  controller.businessFilter.value = null;
                }),
                ...BusinessVerificationStatus.values.map((status) {
                  return _buildFilterOption(
                    status.name,
                    controller.businessFilter.value == status,
                    () => controller.businessFilter.value = status,
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
                      controller.loadBusinesses(refresh: true);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
