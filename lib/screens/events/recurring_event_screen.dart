import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/recurring_event_controller.dart';
import '../../models/recurring_event_model.dart';

/// Screen for creating and managing recurring events
class RecurringEventScreen extends StatelessWidget {
  final int? seriesId;
  final bool isEditing;

  const RecurringEventScreen({
    super.key,
    this.seriesId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecurringEventController());

    if (seriesId != null) {
      controller.loadSeries(seriesId!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recurring Event' : 'Create Recurring Event'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recurrence pattern section
            const Text(
              'Repeat Pattern',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Frequency selection
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecurrenceFrequency.values.map((freq) {
                final isSelected = controller.selectedFrequency.value == freq;
                return ChoiceChip(
                  label: Text(_getFrequencyLabel(freq)),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.selectedFrequency.value = freq;
                  },
                );
              }).toList(),
            )),

            const SizedBox(height: 24),

            // Interval setting
            Obx(() {
              if (controller.selectedFrequency.value == RecurrenceFrequency.once) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Every ${controller.interval.value} ${_getFrequencyUnit(controller.selectedFrequency.value)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: controller.interval.value.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: controller.interval.value.toString(),
                    onChanged: (value) {
                      controller.interval.value = value.toInt();
                    },
                  ),
                ],
              );
            }),

            // Day selection for weekly recurrence
            Obx(() {
              if (controller.selectedFrequency.value != RecurrenceFrequency.weekly) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'On these days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDayChip('Mon', 0, controller),
                      _buildDayChip('Tue', 1, controller),
                      _buildDayChip('Wed', 2, controller),
                      _buildDayChip('Thu', 3, controller),
                      _buildDayChip('Fri', 4, controller),
                      _buildDayChip('Sat', 5, controller),
                      _buildDayChip('Sun', 6, controller),
                    ],
                  ),
                ],
              );
            }),

            // Monthly day selection
            Obx(() {
              if (controller.selectedFrequency.value != RecurrenceFrequency.monthly) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'On day of month',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Day',
                            hintText: '1-31',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            final day = int.tryParse(value);
                            if (day != null && day >= 1 && day <= 31) {
                              controller.selectedDayOfMonth.value = day;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('or'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Set to last day of month
                            controller.selectedDayOfMonth.value = -1;
                          },
                          child: const Text('Last Day'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),

            const SizedBox(height: 32),

            // End date section
            const Text(
              'Ends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Obx(() => Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Never'),
                  value: 'never',
                  groupValue: controller.endType.value,
                  onChanged: (value) => controller.endType.value = value!,
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      const Text('After'),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            controller.occurrenceCount.value =
                                int.tryParse(value) ?? 10;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('occurrences'),
                    ],
                  ),
                  value: 'count',
                  groupValue: controller.endType.value,
                  onChanged: (value) => controller.endType.value = value!,
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      const Text('On date'),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: controller.endDate.value ??
                                DateTime.now().add(const Duration(days: 90)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            controller.endDate.value = date;
                          }
                        },
                        child: Text(
                          controller.endDate.value != null
                              ? _formatDate(controller.endDate.value!)
                              : 'Select Date',
                        ),
                      ),
                    ],
                  ),
                  value: 'date',
                  groupValue: controller.endType.value,
                  onChanged: (value) => controller.endType.value = value!,
                ),
              ],
            )),

            const SizedBox(height: 32),

            // Preview section
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() => _buildPreviewCard(controller)),

            const SizedBox(height: 32),

            // Existing instances (if editing)
            if (isEditing && seriesId != null) ...[
              const Text(
                'Upcoming Instances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInstancesList(controller),
              const SizedBox(height: 24),
            ],

            // Error message
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
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Save button
            Obx(() => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () => _saveRecurrence(controller),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Recurrence' : 'Create Recurring Event'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int dayIndex, RecurringEventController controller) {
    return Obx(() {
      final isSelected = controller.selectedDays.contains(dayIndex);
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.selectedDays.add(dayIndex);
          } else {
            controller.selectedDays.remove(dayIndex);
          }
        },
      );
    });
  }

  Widget _buildPreviewCard(RecurringEventController controller) {
    final preview = controller.getRecurrencePreview();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (controller.selectedFrequency.value != RecurrenceFrequency.once) ...[
            const SizedBox(height: 12),
            Text(
              'Next occurrences:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            ...controller.getNextOccurrences(3).map((date) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• ${_formatDate(date)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInstancesList(RecurringEventController controller) {
    return Obx(() {
      if (controller.instances.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No upcoming instances'),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.instances.length,
        itemBuilder: (context, index) {
          final instance = controller.instances[index];
          return _buildInstanceCard(instance, controller);
        },
      );
    });
  }

  Widget _buildInstanceCard(
    RecurringEventInstanceModel instance,
    RecurringEventController controller,
  ) {
    Color statusColor;
    String statusText;

    switch (instance.status) {
      case InstanceStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Scheduled';
        break;
      case InstanceStatus.modified:
        statusColor = Colors.orange;
        statusText = 'Modified';
        break;
      case InstanceStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case InstanceStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event, color: statusColor),
        ),
        title: Text(_formatDate(instance.instanceDate!)),
        subtitle: Text(statusText),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'cancel':
                _confirmCancelInstance(instance, controller);
                break;
              case 'skip':
                controller.skipInstance(instance.instanceId!);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'skip',
              child: Text('Skip this occurrence'),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Text('Cancel this occurrence'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelInstance(
    RecurringEventInstanceModel instance,
    RecurringEventController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel This Occurrence?'),
        content: Text(
          'This will cancel the event on ${_formatDate(instance.instanceDate!)}. '
          'Other occurrences will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelInstance(instance.instanceId!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveRecurrence(RecurringEventController controller) {
    if (isEditing && seriesId != null) {
      controller.updateSeries(seriesId!);
    } else {
      controller.createSeries();
    }
  }

  String _getFrequencyLabel(RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.once:
        return 'One Time';
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.biweekly:
        return 'Bi-weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  String _getFrequencyUnit(RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.once:
        return '';
      case RecurrenceFrequency.daily:
        return 'day(s)';
      case RecurrenceFrequency.weekly:
      case RecurrenceFrequency.biweekly:
        return 'week(s)';
      case RecurrenceFrequency.monthly:
        return 'month(s)';
      case RecurrenceFrequency.yearly:
        return 'year(s)';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
