import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/guest_controller.dart';
import '../../models/guest_model.dart';

/// Screen for inviting guests who don't have the app
class InviteGuestsScreen extends StatelessWidget {
  final int eventId;
  final String eventName;
  final int maxGuests;

  const InviteGuestsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.maxGuests = 5,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuestController());
    controller.loadGuests(eventId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bring a Friend'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group_add, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Bring friends to $eventName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invite friends who don\'t have the app yet. They\'ll receive an invite link via SMS or email.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Guest count info
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.guests.length}/$maxGuests guests invited',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )),

            const SizedBox(height: 24),

            // Add guest form
            Obx(() {
              if (controller.guests.length >= maxGuests) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You\'ve reached the maximum number of guests for this event.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildInviteForm(controller);
            }),

            const SizedBox(height: 24),

            // Current guests list
            const Text(
              'Your Guests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isLoading.value && controller.guests.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.guests.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No guests invited yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.guests.length,
                itemBuilder: (context, index) {
                  return _buildGuestCard(controller.guests[index], controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteForm(GuestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Invite a Guest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Guest Name',
                hintText: 'Enter their name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Contact method toggle
            Obx(() => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.contactMethod.value = 'phone',
                    icon: const Icon(Icons.phone),
                    label: const Text('Phone'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: controller.contactMethod.value == 'phone'
                          ? Colors.blue.withValues(alpha: 0.1)
                          : null,
                      side: BorderSide(
                        color: controller.contactMethod.value == 'phone'
                            ? Colors.blue
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.contactMethod.value = 'email',
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: controller.contactMethod.value == 'email'
                          ? Colors.blue.withValues(alpha: 0.1)
                          : null,
                      side: BorderSide(
                        color: controller.contactMethod.value == 'email'
                            ? Colors.blue
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 12),

            // Contact input
            Obx(() => TextField(
              controller: controller.contactMethod.value == 'phone'
                  ? controller.phoneController
                  : controller.emailController,
              keyboardType: controller.contactMethod.value == 'phone'
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              inputFormatters: controller.contactMethod.value == 'phone'
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ]
                  : null,
              decoration: InputDecoration(
                labelText: controller.contactMethod.value == 'phone'
                    ? 'Phone Number'
                    : 'Email Address',
                hintText: controller.contactMethod.value == 'phone'
                    ? '1234567890'
                    : 'friend@example.com',
                prefixIcon: Icon(
                  controller.contactMethod.value == 'phone'
                      ? Icons.phone
                      : Icons.email,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),
            const SizedBox(height: 16),

            // Error message
            Obx(() {
              if (controller.errorMessage.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Invite button
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isInviting.value
                  ? null
                  : () => controller.inviteGuest(eventId),
              icon: const Icon(Icons.send),
              label: const Text('Send Invite'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(GuestModel guest, GuestController controller) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (guest.status) {
      case GuestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
      case GuestStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case GuestStatus.declined:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case GuestStatus.checkedIn:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusText = 'Checked In';
        break;
      case GuestStatus.noShow:
        statusColor = Colors.grey;
        statusIcon = Icons.person_off;
        statusText = 'No Show';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(
                guest.name?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Guest info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name ?? 'Guest',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    guest.phone ?? guest.email ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Action menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'resend':
                    controller.resendInvite(guest.guestId!);
                    break;
                  case 'copy':
                    _copyInviteLink(guest);
                    break;
                  case 'remove':
                    _confirmRemoveGuest(guest, controller);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'resend',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Resend Invite'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Copy Link'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyInviteLink(GuestModel guest) {
    if (guest.inviteCode != null) {
      Clipboard.setData(ClipboardData(
        text: 'https://fluttrr.app/invite/${guest.inviteCode}',
      ));
      Get.snackbar(
        'Copied!',
        'Invite link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmRemoveGuest(GuestModel guest, GuestController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Guest?'),
        content: Text(
          'Are you sure you want to remove ${guest.name ?? 'this guest'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeGuest(guest.guestId!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
