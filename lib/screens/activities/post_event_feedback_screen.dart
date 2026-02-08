import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_feedback_controller.dart';
import '../../models/event_feedback_model.dart';

/// Screen for post-event feedback and ratings
class PostEventFeedbackScreen extends StatelessWidget {
  final int eventId;
  final String eventName;
  final bool isHost;

  const PostEventFeedbackScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventFeedbackController());

    return Scaffold(
      appBar: AppBar(
        title: Text(isHost ? 'Event Summary' : 'Rate Event'),
        centerTitle: true,
      ),
      body: isHost
          ? _buildHostView(controller)
          : _buildAttendeeView(controller),
    );
  }

  Widget _buildHostView(EventFeedbackController controller) {
    controller.loadPostEventSummary(eventId);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final summary = controller.currentEventSummary.value;
      if (summary == null) {
        return const Center(child: Text('No summary available'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          'Attendees',
                          '${summary.totalAttendees}',
                          Icons.people,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Checked In',
                          '${summary.checkedInCount}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          'Avg Rating',
                          summary.averageRating.toStringAsFixed(1),
                          Icons.star,
                          Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Reviews',
                          '${summary.totalRatings}',
                          Icons.rate_review,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Send thank you button
            if (!summary.thankYouSent)
              ElevatedButton.icon(
                onPressed: () => _showThankYouDialog(controller),
                icon: const Icon(Icons.favorite),
                label: const Text('Send Thank You to Attendees'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Thank you message sent!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Feedback list
            const Text(
              'Attendee Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (summary.feedback.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No feedback yet'),
                ),
              )
            else
              ...summary.feedback.map((feedback) => _buildFeedbackCard(feedback)),
          ],
        ),
      );
    });
  }

  Widget _buildAttendeeView(EventFeedbackController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.celebration,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            'Thanks for attending!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            eventName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          const Text(
            'How was the event?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Star rating
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () => controller.setRating(rating),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    controller.selectedRating.value >= rating
                        ? Icons.star
                        : Icons.star_border,
                    size: 48,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          )),

          const SizedBox(height: 32),

          // Comment field
          TextField(
            controller: controller.commentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Share your thoughts (optional)',
              hintText: 'What did you enjoy? Any suggestions?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Error/Success messages
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Submit button
          Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final success = await controller.submitEventFeedback(
                      eventId: eventId,
                      rating: controller.selectedRating.value,
                      comment: controller.commentController.text.trim().isNotEmpty
                          ? controller.commentController.text.trim()
                          : null,
                    );
                    if (success) {
                      Get.back();
                      Get.snackbar(
                        'Thank you!',
                        'Your feedback has been submitted',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Feedback'),
          )),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
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
      ),
    );
  }

  Widget _buildFeedbackCard(EventFeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: feedback.userImage != null
                      ? NetworkImage(feedback.userImage!)
                      : null,
                  child: feedback.userImage == null
                      ? Text(feedback.userName?.substring(0, 1) ?? '?')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < feedback.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(feedback.comment!),
            ],
          ],
        ),
      ),
    );
  }

  void _showThankYouDialog(EventFeedbackController controller) {
    final messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Send Thank You'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send a thank you message to all attendees and request ratings.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Custom message (optional)',
                hintText: 'Thanks for coming!',
                border: OutlineInputBorder(),
              ),
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
              Get.back();
              await controller.sendThankYouMessage(
                eventId: eventId,
                customMessage: messageController.text.trim().isNotEmpty
                    ? messageController.text.trim()
                    : null,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
