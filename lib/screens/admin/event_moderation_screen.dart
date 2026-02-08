import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/admin_model.dart';

/// Screen for moderating events as admin
class EventModerationScreen extends StatelessWidget {
  const EventModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    controller.loadEvents(refresh: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderate Events'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateEventDialog(controller),
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
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.loadEvents(refresh: true);
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
                  controller.eventFilter.value == null,
                  () {
                    controller.eventFilter.value = null;
                    controller.loadEvents(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending',
                  controller.eventFilter.value == ContentStatus.pending,
                  () {
                    controller.eventFilter.value = ContentStatus.pending;
                    controller.loadEvents(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Flagged',
                  controller.eventFilter.value == ContentStatus.flagged,
                  () {
                    controller.eventFilter.value = ContentStatus.flagged;
                    controller.loadEvents(refresh: true);
                  },
                  badgeCount: controller.flaggedEventsCount,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Approved',
                  controller.eventFilter.value == ContentStatus.approved,
                  () {
                    controller.eventFilter.value = ContentStatus.approved;
                    controller.loadEvents(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Removed',
                  controller.eventFilter.value == ContentStatus.removed,
                  () {
                    controller.eventFilter.value = ContentStatus.removed;
                    controller.loadEvents(refresh: true);
                  },
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),

          // Events list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingEvents.value && controller.events.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadEvents(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.events.length + (controller.hasMoreEvents.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.events.length) {
                      controller.loadEvents();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final event = controller.events[index];
                    return _buildEventCard(event, controller);
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

  Widget _buildEventCard(ManagedEventModel event, AdminController controller) {
    Color statusColor;
    switch (event.status) {
      case ContentStatus.approved:
        statusColor = Colors.green;
        break;
      case ContentStatus.pending:
        statusColor = Colors.orange;
        break;
      case ContentStatus.flagged:
        statusColor = Colors.red;
        break;
      case ContentStatus.removed:
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEventDetails(event, controller),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (event.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.image!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.event, size: 48, color: Colors.grey),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title ?? 'Untitled Event',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (event.isFeatured)
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.statusDisplay,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (event.businessName != null)
                    Row(
                      children: [
                        Icon(Icons.business, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          event.businessName!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),

                  const SizedBox(height: 4),

                  if (event.location != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (event.startDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(event.startDate!),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        if (event.isPast) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Past',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildStatItem(Icons.people, '${event.attendeeCount}/${event.maxAttendees}'),
                      if (event.reportCount > 0) ...[
                        const SizedBox(width: 16),
                        _buildStatItem(Icons.flag, '${event.reportCount}', color: Colors.red),
                      ],
                    ],
                  ),

                  // Quick actions for flagged/pending events
                  if (event.isPending || event.isFlagged) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(event, controller),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.approveEvent(event.eventId!),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, {Color? color}) {
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

  void _showEventDetails(ManagedEventModel event, AdminController controller) {
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
              Text(
                event.title ?? 'Untitled Event',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(event.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.statusDisplay,
                  style: TextStyle(
                    color: _getStatusColor(event.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (event.description != null) ...[
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(event.description!, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 16),
              ],

              _buildDetailRow('Business', event.businessName ?? 'N/A'),
              _buildDetailRow('Location', event.location ?? 'N/A'),
              _buildDetailRow('Date', event.startDate != null ? _formatDateTime(event.startDate!) : 'N/A'),
              _buildDetailRow('Attendees', '${event.attendeeCount} / ${event.maxAttendees}'),
              _buildDetailRow('Created by', event.createdByName ?? 'N/A'),
              _buildDetailRow('Reports', '${event.reportCount}'),
              if (event.createdAt != null)
                _buildDetailRow('Created', _formatDate(event.createdAt!)),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.toggleEventFeatured(event.eventId!);
                      },
                      icon: Icon(event.isFeatured ? Icons.star_border : Icons.star),
                      label: Text(event.isFeatured ? 'Unfeature' : 'Feature'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showEventActions(event, controller);
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

  void _showEventActions(ManagedEventModel event, AdminController controller) {
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
              event.title ?? 'Event',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (event.isPending || event.isFlagged)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Approve Event'),
                onTap: () {
                  Get.back();
                  controller.approveEvent(event.eventId!);
                },
              ),

            if (event.status == ContentStatus.approved)
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.orange),
                title: const Text('Flag Event'),
                onTap: () {
                  Get.back();
                  // Flag logic would go here
                },
              ),

            ListTile(
              leading: Icon(event.isFeatured ? Icons.star_border : Icons.star, color: Colors.amber),
              title: Text(event.isFeatured ? 'Remove from Featured' : 'Add to Featured'),
              onTap: () {
                Get.back();
                controller.toggleEventFeatured(event.eventId!);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Event', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showRemoveConfirmation(event, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(ManagedEventModel event, AdminController controller) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Event'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Why is this event being rejected?',
          ),
          maxLines: 3,
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
                controller.rejectEvent(event.eventId!, reason: reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(ManagedEventModel event, AdminController controller) {
    final reasonController = TextEditingController();
    bool notifyAttendees = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Remove Event?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to remove "${event.title}"?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for removal',
                  hintText: 'Why is this event being removed?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Notify attendees'),
                value: notifyAttendees,
                onChanged: (value) => setState(() => notifyAttendees = value ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
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
                  controller.removeEvent(
                    event.eventId!,
                    reason: reasonController.text,
                    notifyAttendees: notifyAttendees,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventDialog(AdminController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime startDate = DateTime.now().add(const Duration(days: 1));

    Get.dialog(
      AlertDialog(
        title: const Text('Create Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_formatDateTime(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    startDate = date;
                  }
                },
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
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                Get.back();
                controller.createEvent(
                  title: titleController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  startDate: startDate,
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
              'Filter Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterOption('All', controller.eventFilter.value == null, () {
                  controller.eventFilter.value = null;
                }),
                ...ContentStatus.values.map((status) {
                  return _buildFilterOption(
                    status.name,
                    controller.eventFilter.value == status,
                    () => controller.eventFilter.value = status,
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
                      controller.loadEvents(refresh: true);
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

  Color _getStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.approved:
        return Colors.green;
      case ContentStatus.pending:
        return Colors.orange;
      case ContentStatus.flagged:
        return Colors.red;
      case ContentStatus.removed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
