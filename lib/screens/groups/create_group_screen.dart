import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';

/// Screen for creating a new group
class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<GroupController>()
        ? Get.find<GroupController>()
        : Get.put(GroupController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group name
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Group Name*',
                hintText: 'Enter a name for your group',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description*',
                hintText: 'What is this group about?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Group type
            const Text(
              'Group Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GroupType.values.map((type) {
                final isSelected = controller.selectedType.value == type;
                return ChoiceChip(
                  label: Text(_getTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.selectedType.value = type;
                  },
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // Privacy
            const Text(
              'Privacy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Column(
              children: GroupPrivacy.values.map((privacy) {
                return RadioListTile<GroupPrivacy>(
                  title: Text(_getPrivacyLabel(privacy)),
                  subtitle: Text(_getPrivacyDescription(privacy)),
                  value: privacy,
                  groupValue: controller.selectedPrivacy.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedPrivacy.value = value;
                    }
                  },
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // Interests
            const Text(
              'Interests*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select interests that describe your group',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ...controller.interestCategories.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((interest) {
                        final isSelected = controller.selectedInterests.contains(interest);
                        return FilterChip(
                          label: Text(interest),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.toggleInterest(interest);
                          },
                        );
                      }).toList(),
                    )),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Location (optional)
            TextField(
              controller: controller.locationController,
              decoration: InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'City or area',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Create button
            Obx(() => ElevatedButton(
              onPressed: controller.isCreating.value
                  ? null
                  : () async {
                      final success = await controller.createGroup();
                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Group created successfully!',
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
              child: controller.isCreating.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Group'),
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.interest:
        return 'Interest';
      case GroupType.activity:
        return 'Activity';
      case GroupType.event:
        return 'Event';
      case GroupType.social:
        return 'Social';
      case GroupType.custom:
        return 'Custom';
    }
  }

  String _getPrivacyLabel(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return 'Public';
      case GroupPrivacy.private:
        return 'Private';
      case GroupPrivacy.secret:
        return 'Secret';
    }
  }

  String _getPrivacyDescription(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return 'Anyone can find and join this group';
      case GroupPrivacy.private:
        return 'Anyone can find this group, but must request to join';
      case GroupPrivacy.secret:
        return 'Only members can find this group';
    }
  }
}
