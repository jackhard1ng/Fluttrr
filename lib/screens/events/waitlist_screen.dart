import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/waitlist_controller.dart';
import '../../models/waitlist_model.dart';

/// Screen for viewing and managing event waitlist
class WaitlistScreen extends StatelessWidget {
  final int eventId;
  final String eventName;
  final bool isHost;

  const WaitlistScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WaitlistController());
    controller.loadWaitlist(eventId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitlist'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                            '${controller.waitlistEntries.length} on waitlist',
                            style: TextStyle(color: Colors.grey[600]),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // User's waitlist status (if not host)
              if (!isHost) ...[
                _buildUserWaitlistStatus(controller),
                const SizedBox(height: 24),
              ],

              // Waitlist entries (for host)
              if (isHost) ...[
                _buildHostWaitlistView(controller),
              ] else ...[
                // Show position info for regular users
                _buildWaitlistInfo(controller),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserWaitlistStatus(WaitlistController controller) {
    return Obx(() {
      final userEntry = controller.userWaitlistEntry.value;

      if (userEntry == null) {
        // Not on waitlist - show join button
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.access_time, size: 48, color: Colors.orange[300]),
                const SizedBox(height: 16),
                const Text(
                  'Event is Full',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the waitlist to be notified when a spot opens up.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isJoining.value
                        ? null
                        : () => controller.joinWaitlist(eventId),
                    icon: const Icon(Icons.add),
                    label: const Text('Join Waitlist'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Check if user has a pending offer
      if (userEntry.status == WaitlistStatus.offered) {
        return _buildOfferCard(userEntry, controller);
      }

      // Show current position
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#${userEntry.position}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Position',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll notify you when a spot opens up!',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: controller.isLeaving.value
                    ? null
                    : () => _showLeaveConfirmation(controller),
                icon: const Icon(Icons.close),
                label: const Text('Leave Waitlist'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOfferCard(WaitlistEntryModel entry, WaitlistController controller) {
    final expiresAt = entry.offerExpiresAt;
    final timeLeft = expiresAt != null
        ? expiresAt.difference(DateTime.now())
        : const Duration(hours: 24);

    return Card(
      color: Colors.green.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A Spot Opened Up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${_formatDuration(timeLeft)} to claim your spot.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isResponding.value
                        ? null
                        : () => controller.declineOffer(eventId),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isResponding.value
                        ? null
                        : () => controller.acceptOffer(eventId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostWaitlistView(WaitlistController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Waitlist Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.waitlistEntries.isEmpty ||
                      controller.isOffering.value
                  ? null
                  : () => controller.offerSpotToNext(eventId),
              icon: const Icon(Icons.person_add),
              label: const Text('Offer Spot'),
            )),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (controller.waitlistEntries.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No one on the waitlist yet'),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.waitlistEntries.length,
            itemBuilder: (context, index) {
              final entry = controller.waitlistEntries[index];
              return _buildWaitlistEntryCard(entry, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildWaitlistEntryCard(
    WaitlistEntryModel entry,
    WaitlistController controller,
  ) {
    Color statusColor;
    String statusText;

    switch (entry.status) {
      case WaitlistStatus.waiting:
        statusColor = Colors.orange;
        statusText = 'Waiting';
        break;
      case WaitlistStatus.offered:
        statusColor = Colors.blue;
        statusText = 'Offered';
        break;
      case WaitlistStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case WaitlistStatus.declined:
        statusColor = Colors.red;
        statusText = 'Declined';
        break;
      case WaitlistStatus.expired:
        statusColor = Colors.grey;
        statusText = 'Expired';
        break;
      case WaitlistStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Text(
            '#${entry.position}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(entry.userName ?? 'User'),
        subtitle: Text(
          'Joined ${_formatDate(entry.joinedAt)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitlistInfo(WaitlistController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              '1',
              'Join the waitlist',
              'When the event is full, join the waitlist to save your spot.',
            ),
            _buildInfoItem(
              '2',
              'Wait for an opening',
              'If someone cancels, you\'ll move up in the queue.',
            ),
            _buildInfoItem(
              '3',
              'Get notified',
              'We\'ll notify you when it\'s your turn to claim a spot.',
            ),
            _buildInfoItem(
              '4',
              'Claim your spot',
              'Accept the offer within 24 hours to secure your attendance.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(WaitlistController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Waitlist?'),
        content: const Text(
          'Are you sure you want to leave the waitlist? You will lose your position.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.leaveWaitlist(eventId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
