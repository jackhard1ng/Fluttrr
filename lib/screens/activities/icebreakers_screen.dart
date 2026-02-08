import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/icebreaker_controller.dart';
import '../../models/icebreaker_model.dart';

/// Screen for icebreakers during an event
class IcebreakersScreen extends StatelessWidget {
  final int eventId;
  final bool isHost;

  const IcebreakersScreen({
    super.key,
    required this.eventId,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IcebreakerController());
    controller.loadSession(eventId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Icebreakers'),
        centerTitle: true,
        actions: [
          if (isHost)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSessionSettings(controller),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasActiveSession) {
          return _buildStartSessionView(controller);
        }

        return _buildActiveSessionView(controller);
      }),
    );
  }

  Widget _buildStartSessionView(IcebreakerController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: Colors.purple[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'Break the Ice!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start an icebreaker session to help everyone get to know each other.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (isHost) ...[
            // Category selection
            const Text(
              'Choose a category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: IcebreakerCategory.values.map((category) {
                return Obx(() => ChoiceChip(
                  label: Text(_getCategoryLabel(category)),
                  selected: controller.selectedCategory.value == category,
                  onSelected: (selected) {
                    controller.selectedCategory.value = category;
                  },
                ));
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Start button
            ElevatedButton.icon(
              onPressed: controller.isStartingSession.value
                  ? null
                  : () => controller.startSession(
                        eventId: eventId,
                        category: controller.selectedCategory.value,
                      ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Icebreakers'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Waiting for the host to start',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'The icebreaker session will begin soon!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Preview some icebreakers
          const Text(
            'Sample Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.getDefaultIcebreakers(count: 3).map((icebreaker) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            icebreaker.typeDisplay,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      icebreaker.displayText,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (icebreaker.options.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: icebreaker.options.map((option) {
                          return Chip(
                            label: Text(option),
                            backgroundColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(IcebreakerController controller) {
    return Column(
      children: [
        // Session header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Text(
                '${controller.participantCount} participating',
                style: TextStyle(color: Colors.purple[700]),
              ),
              const Spacer(),
              Text(
                '${controller.responseCount} responses',
                style: TextStyle(color: Colors.purple[700]),
              ),
            ],
          ),
        ),

        // Current icebreaker
        Expanded(
          child: Obx(() {
            final icebreaker = controller.currentIcebreaker.value;
            if (icebreaker == null) {
              return const Center(child: Text('No active icebreaker'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icebreaker card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              icebreaker.typeDisplay,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            icebreaker.displayText,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Options or answer input
                          if (icebreaker.options.isNotEmpty)
                            ...icebreaker.options.asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              return Obx(() => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => controller.selectOption(index),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor:
                                        controller.selectedOptionIndex.value == index
                                            ? Colors.purple.withValues(alpha: 0.1)
                                            : null,
                                    side: BorderSide(
                                      color: controller.selectedOptionIndex.value == index
                                          ? Colors.purple
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(option),
                                ),
                              ));
                            })
                          else
                            TextField(
                              controller: controller.answerController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Type your answer...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitResponse(eventId: eventId),
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
                        : const Text('Submit'),
                  ),

                  const SizedBox(height: 32),

                  // Responses
                  if (controller.responses.isNotEmpty) ...[
                    const Text(
                      'Responses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...controller.responses.map((response) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: response.userImage != null
                                ? NetworkImage(response.userImage!)
                                : null,
                            child: response.userImage == null
                                ? Text(response.userName?.substring(0, 1) ?? '?')
                                : null,
                          ),
                          title: Text(response.userName ?? 'Anonymous'),
                          subtitle: Text(
                            response.answer ??
                                (response.selectedOptionIndex != null &&
                                        icebreaker.options.isNotEmpty
                                    ? icebreaker.options[response.selectedOptionIndex!]
                                    : ''),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_outlined),
                                onPressed: () => controller.addReaction(
                                  responseId: response.responseId!,
                                  emoji: 'thumbs_up',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          }),
        ),

        // Host controls
        if (isHost)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEndSessionConfirmation(controller),
                    child: const Text('End Session'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.nextIcebreaker(eventId),
                    child: const Text('Next Question'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getCategoryLabel(IcebreakerCategory category) {
    switch (category) {
      case IcebreakerCategory.gettingToKnow:
        return 'Getting to Know';
      case IcebreakerCategory.funAndSilly:
        return 'Fun & Silly';
      case IcebreakerCategory.deep:
        return 'Deep';
      case IcebreakerCategory.professional:
        return 'Professional';
      case IcebreakerCategory.creative:
        return 'Creative';
      case IcebreakerCategory.physical:
        return 'Physical';
    }
  }

  void _showSessionSettings(IcebreakerController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Session Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Shuffle Questions'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Time Limit'),
              trailing: Text('${controller.timeLimit.value}s'),
              onTap: () {
                // Set time limit
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndSessionConfirmation(IcebreakerController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Are you sure you want to end the icebreaker session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.endSession(eventId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
