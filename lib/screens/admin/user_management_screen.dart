import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/admin_model.dart';

/// Screen for managing users as admin
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    controller.loadUsers(refresh: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.loadUsers(refresh: true);
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
                  controller.userFilter.value == null,
                  () {
                    controller.userFilter.value = null;
                    controller.loadUsers(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Active',
                  controller.userFilter.value == UserAccountStatus.active,
                  () {
                    controller.userFilter.value = UserAccountStatus.active;
                    controller.loadUsers(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Suspended',
                  controller.userFilter.value == UserAccountStatus.suspended,
                  () {
                    controller.userFilter.value = UserAccountStatus.suspended;
                    controller.loadUsers(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Banned',
                  controller.userFilter.value == UserAccountStatus.banned,
                  () {
                    controller.userFilter.value = UserAccountStatus.banned;
                    controller.loadUsers(refresh: true);
                  },
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),

          // Users list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingUsers.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadUsers(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.users.length + (controller.hasMoreUsers.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.users.length) {
                      controller.loadUsers();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final user = controller.users[index];
                    return _buildUserCard(user, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
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
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(ManagedUserModel user, AdminController controller) {
    Color statusColor;
    switch (user.status) {
      case UserAccountStatus.active:
        statusColor = Colors.green;
        break;
      case UserAccountStatus.suspended:
        statusColor = Colors.orange;
        break;
      case UserAccountStatus.banned:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUserDetails(user, controller),
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
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? Text(user.name?.substring(0, 1).toUpperCase() ?? 'U')
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
                                user.name ?? 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(Icons.verified, color: Colors.blue, size: 18),
                            if (user.isBusinessOwner) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.business, color: Colors.green, size: 18),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
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
                      user.statusDisplay,
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
                  _buildStatItem(Icons.event, '${user.eventCount}', 'Events'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.event_available, '${user.attendedCount}', 'Attended'),
                  if (user.reportCount > 0) ...[
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.flag, '${user.reportCount}', 'Reports', color: Colors.red),
                  ],
                  if (user.warningCount > 0) ...[
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.warning, '${user.warningCount}', 'Warnings', color: Colors.orange),
                  ],
                ],
              ),

              // Show suspension info if suspended
              if (user.isSuspended && user.suspendedUntil != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Suspended until ${_formatDate(user.suspendedUntil!)}',
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // Quick actions
              const SizedBox(height: 12),
              Row(
                children: [
                  if (user.isActive)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showSuspendDialog(user, controller),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                        child: const Text('Suspend'),
                      ),
                    )
                  else if (user.isSuspended)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.unsuspendUser(user.userId!),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Unsuspend'),
                      ),
                    )
                  else if (user.isBanned)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.unbanUser(user.userId!),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Unban'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUserActions(user, controller),
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('Actions'),
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

  void _showUserDetails(ManagedUserModel user, AdminController controller) {
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
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? Text(user.name?.substring(0, 1).toUpperCase() ?? 'U')
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(Icons.verified, color: Colors.blue),
                          ],
                        ),
                        Text(
                          user.statusDisplay,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildDetailRow('Email', user.email ?? 'N/A'),
              _buildDetailRow('Phone', user.phone ?? 'N/A'),
              _buildDetailRow('Events Created', '${user.eventCount}'),
              _buildDetailRow('Events Attended', '${user.attendedCount}'),
              _buildDetailRow('Reports Against', '${user.reportCount}'),
              _buildDetailRow('Warnings', '${user.warningCount}'),
              _buildDetailRow('Business Owner', user.isBusinessOwner ? 'Yes' : 'No'),
              if (user.createdAt != null)
                _buildDetailRow('Joined', _formatDate(user.createdAt!)),
              if (user.lastActiveAt != null)
                _buildDetailRow('Last Active', _formatDate(user.lastActiveAt!)),

              if (user.isSuspended && user.suspensionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Suspension Reason:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(user.suspensionReason!),
                    ],
                  ),
                ),
              ],

              if (user.isBanned && user.banReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ban Reason:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(user.banReason!),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showWarnDialog(user, controller);
                      },
                      icon: const Icon(Icons.warning),
                      label: const Text('Warn'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showUserActions(user, controller);
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
            width: 120,
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

  void _showUserActions(ManagedUserModel user, AdminController controller) {
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
              user.name ?? 'User',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.warning, color: Colors.amber),
              title: const Text('Send Warning'),
              onTap: () {
                Get.back();
                _showWarnDialog(user, controller);
              },
            ),

            if (user.isActive)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Suspend User'),
                onTap: () {
                  Get.back();
                  _showSuspendDialog(user, controller);
                },
              )
            else if (user.isSuspended)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Unsuspend User'),
                onTap: () {
                  Get.back();
                  controller.unsuspendUser(user.userId!);
                },
              ),

            if (!user.isBanned)
              ListTile(
                leading: const Icon(Icons.gavel, color: Colors.red),
                title: const Text('Ban User'),
                onTap: () {
                  Get.back();
                  _showBanDialog(user, controller);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Unban User'),
                onTap: () {
                  Get.back();
                  controller.unbanUser(user.userId!);
                },
              ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(user, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWarnDialog(ManagedUserModel user, AdminController controller) {
    final messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Send Warning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send a warning to ${user.name ?? 'this user'}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Warning Message',
                hintText: 'Explain why the user is being warned...',
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
              if (messageController.text.isNotEmpty) {
                Get.back();
                controller.warnUser(user.userId!, message: messageController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(ManagedUserModel user, AdminController controller) {
    final reasonController = TextEditingController();
    int? durationDays;

    Get.dialog(
      AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suspend ${user.name ?? 'this user'}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why is this user being suspended?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Duration',
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 day')),
                DropdownMenuItem(value: 3, child: Text('3 days')),
                DropdownMenuItem(value: 7, child: Text('7 days')),
                DropdownMenuItem(value: 14, child: Text('14 days')),
                DropdownMenuItem(value: 30, child: Text('30 days')),
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
                controller.suspendUser(
                  user.userId!,
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

  void _showBanDialog(ManagedUserModel user, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ban User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to ban ${user.name ?? 'this user'}? This will permanently restrict their access.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Ban Reason',
                hintText: 'Why is this user being banned?',
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
              if (reasonController.text.isNotEmpty) {
                Get.back();
                controller.banUser(user.userId!, reason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ManagedUserModel user, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete ${user.name ?? 'this user'}\'s account? This action cannot be undone.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for deletion',
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
                controller.deleteUser(user.userId!, reason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
              'Filter Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterOption('All', controller.userFilter.value == null, () {
                  controller.userFilter.value = null;
                }),
                ...UserAccountStatus.values.map((status) {
                  return _buildFilterOption(
                    status.name,
                    controller.userFilter.value == status,
                    () => controller.userFilter.value = status,
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
                      controller.loadUsers(refresh: true);
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
