import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';

/// Screen for viewing group details
class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late final GroupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<GroupController>()
        ? Get.find<GroupController>()
        : Get.put(GroupController());
    controller.loadGroupDetails(widget.groupId);
    controller.loadGroupMembers(widget.groupId);
    controller.loadGroupEvents(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.currentGroup.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final group = controller.currentGroup.value;
        if (group == null) {
          return const Center(child: Text('Group not found'));
        }

        return CustomScrollView(
          slivers: [
            // App bar with cover image
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(group.name ?? 'Group'),
                background: group.coverImage != null
                    ? Image.network(
                        group.coverImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
              ),
              actions: [
                if (group.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to group settings
                    },
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (group.userIsMember)
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text('Leave Group'),
                      ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report Group'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'leave') {
                      _showLeaveConfirmation(controller, group);
                    }
                  },
                ),
              ],
            ),

            // Group info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _buildStat('${group.memberCount}', 'Members'),
                        const SizedBox(width: 24),
                        _buildStat('${group.eventCount}', 'Events'),
                        const Spacer(),
                        if (group.privacy == GroupPrivacy.private)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Private',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Join/Leave button
                    if (!group.userIsMember)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isJoining.value
                              ? null
                              : () => controller.joinGroup(widget.groupId),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isJoining.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  group.privacy == GroupPrivacy.private
                                      ? 'Request to Join'
                                      : 'Join Group',
                                ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to chat
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('Chat'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Create event in group
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Event'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.description ?? 'No description',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),

                    // Interests
                    if (group.interests.isNotEmpty) ...[
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: group.interests.map((interest) {
                          return Chip(label: Text(interest));
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Members section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Members',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // View all members
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Members list
            Obx(() {
              if (controller.groupMembers.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No members yet'),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.groupMembers.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      final member = controller.groupMembers[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: member.userImage != null
                                  ? NetworkImage(member.userImage!)
                                  : null,
                              child: member.userImage == null
                                  ? Text(member.userName?.substring(0, 1) ?? '?')
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.userName ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (member.role != GroupMemberRole.member)
                              Text(
                                member.role.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),

            // Events section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all events
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Events list
            Obx(() {
              if (controller.groupEvents.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('No upcoming events'),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = controller.groupEvents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.event,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(event.name ?? 'Untitled Event'),
                        subtitle: Text(
                          event.dateTime?.toString() ?? 'TBD',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to event details
                        },
                      ),
                    );
                  },
                  childCount: controller.groupEvents.length.clamp(0, 5),
                ),
              );
            }),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        );
      }),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showLeaveConfirmation(GroupController controller, GroupModel group) {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${group.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.leaveGroup(widget.groupId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
