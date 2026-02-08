import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/event_reminder_controller.dart';
import '../models/event_reminder_model.dart';

/// Widget for setting event reminders
class EventReminderWidget extends StatelessWidget {
  final int eventId;
  final DateTime eventDate;
  final bool showLabel;

  const EventReminderWidget({
    super.key,
    required this.eventId,
    required this.eventDate,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventReminderController>();

    return Obx(() {
      final reminder = controller.getReminder(eventId);
      final hasReminder = reminder != null && reminder.isActive;

      if (showLabel) {
        return _buildFullWidget(hasReminder, reminder, controller);
      }

      return _buildIconButton(hasReminder, controller);
    });
  }

  Widget _buildFullWidget(
    bool hasReminder,
    EventReminderModel? reminder,
    EventReminderController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: hasReminder ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: hasReminder,
                  onChanged: (value) {
                    if (value) {
                      _showReminderOptions(controller);
                    } else {
                      controller.cancelReminder(eventId);
                    }
                  },
                ),
              ],
            ),
            if (hasReminder && reminder != null) ...[
              const SizedBox(height: 12),
              _buildActiveReminders(reminder, controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(bool hasReminder, EventReminderController controller) {
    return IconButton(
      onPressed: () {
        if (hasReminder) {
          controller.cancelReminder(eventId);
        } else {
          _showReminderOptions(controller);
        }
      },
      icon: Icon(
        hasReminder ? Icons.notifications_active : Icons.notifications_none,
        color: hasReminder ? Colors.blue : Colors.grey,
      ),
      tooltip: hasReminder ? 'Remove reminder' : 'Set reminder',
    );
  }

  Widget _buildActiveReminders(
    EventReminderModel reminder,
    EventReminderController controller,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (reminder.remindAt1Hour)
          _buildReminderChip('1 hour before', controller),
        if (reminder.remindAt1Day)
          _buildReminderChip('1 day before', controller),
        if (reminder.remindAt1Week)
          _buildReminderChip('1 week before', controller),
      ],
    );
  }

  Widget _buildReminderChip(String label, EventReminderController controller) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        // Remove specific reminder
      },
    );
  }

  void _showReminderOptions(EventReminderController controller) {
    final selectedOptions = <ReminderType>{}.obs;

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
              'Set Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you before the event starts',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Reminder options
            Obx(() => Column(
              children: [
                _buildOptionTile(
                  '1 hour before',
                  Icons.schedule,
                  selectedOptions.contains(ReminderType.oneHourBefore),
                  () => _toggleOption(selectedOptions, ReminderType.oneHourBefore),
                ),
                _buildOptionTile(
                  '1 day before',
                  Icons.today,
                  selectedOptions.contains(ReminderType.oneDayBefore),
                  () => _toggleOption(selectedOptions, ReminderType.oneDayBefore),
                ),
                _buildOptionTile(
                  '1 week before',
                  Icons.date_range,
                  selectedOptions.contains(ReminderType.oneWeekBefore),
                  () => _toggleOption(selectedOptions, ReminderType.oneWeekBefore),
                ),
              ],
            )),

            const SizedBox(height: 24),

            // Notification preferences
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Push notifications'),
              trailing: Obx(() => Switch(
                value: controller.pushEnabled.value,
                onChanged: (value) => controller.pushEnabled.value = value,
              )),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email reminder'),
              trailing: Obx(() => Switch(
                value: controller.emailEnabled.value,
                onChanged: (value) => controller.emailEnabled.value = value,
              )),
            ),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () {
                controller.setReminder(
                  eventId: eventId,
                  types: selectedOptions.toList(),
                  pushEnabled: controller.pushEnabled.value,
                  emailEnabled: controller.emailEnabled.value,
                );
                Get.back();
                Get.snackbar(
                  'Reminder Set',
                  'We\'ll remind you before the event',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      title: Text(title),
      trailing: Checkbox(
        value: selected,
        onChanged: (_) => onTap(),
      ),
      onTap: onTap,
    );
  }

  void _toggleOption(RxSet<ReminderType> options, ReminderType type) {
    if (options.contains(type)) {
      options.remove(type);
    } else {
      options.add(type);
    }
  }
}

/// Compact reminder button for event cards
class ReminderButton extends StatelessWidget {
  final int eventId;

  const ReminderButton({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventReminderController>();

    return Obx(() {
      final hasReminder = controller.hasActiveReminder(eventId);

      return IconButton(
        onPressed: () {
          if (hasReminder) {
            controller.cancelReminder(eventId);
            Get.snackbar(
              'Reminder Removed',
              'You won\'t receive notifications for this event',
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            // Quick set 1 hour reminder
            controller.setReminder(
              eventId: eventId,
              types: [ReminderType.oneHourBefore],
            );
            Get.snackbar(
              'Reminder Set',
              'We\'ll remind you 1 hour before',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        icon: Icon(
          hasReminder ? Icons.notifications_active : Icons.notifications_none,
          color: hasReminder ? Colors.blue : null,
        ),
        tooltip: hasReminder ? 'Remove reminder' : 'Set reminder',
      );
    });
  }
}

/// Widget showing upcoming reminders
class UpcomingRemindersWidget extends StatelessWidget {
  const UpcomingRemindersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventReminderController>();

    return Obx(() {
      final upcomingReminders = controller.upcomingReminders;

      if (upcomingReminders.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.upcoming, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Upcoming Reminders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...upcomingReminders.take(3).map((reminder) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event, color: Colors.blue),
                  ),
                  title: Text(reminder.eventName ?? 'Event'),
                  subtitle: Text(
                    _formatReminderTime(reminder.nextReminderAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.cancelReminder(reminder.eventId!),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  String _formatReminderTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.inMinutes < 60) {
      return 'In ${diff.inMinutes} minutes';
    } else if (diff.inHours < 24) {
      return 'In ${diff.inHours} hours';
    } else {
      return 'In ${diff.inDays} days';
    }
  }
}
