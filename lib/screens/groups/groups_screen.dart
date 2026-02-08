import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

/// Main groups screen
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Discover'),
              Tab(text: 'My Groups'),
              Tab(text: 'Suggested'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(controller),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDiscoverTab(controller),
            _buildMyGroupsTab(controller),
            _buildSuggestedTab(controller),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const CreateGroupScreen()),
          icon: const Icon(Icons.add),
          label: const Text('Create Group'),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(GroupController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadGroups(refresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.allGroups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No groups found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadGroups(refresh: true),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allGroups.length + (controller.hasMoreGroups.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.allGroups.length) {
              controller.loadGroups();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildGroupCard(controller.allGroups[index], controller);
          },
        );
      }),
    );
  }

  Widget _buildMyGroupsTab(GroupController controller) {
    return RefreshIndicator(
      onRefresh: controller.loadMyGroups,
      child: Obx(() {
        if (controller.myGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_add, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'You haven\'t joined any groups yet',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover groups to connect with people who share your interests',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myGroups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(controller.myGroups[index], controller);
          },
        );
      }),
    );
  }

  Widget _buildSuggestedTab(GroupController controller) {
    return RefreshIndicator(
      onRefresh: controller.loadSuggestedGroups,
      child: Obx(() {
        if (controller.suggestedGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No suggestions yet',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your interests to get personalized suggestions',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.suggestedGroups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(controller.suggestedGroups[index], controller);
          },
        );
      }),
    );
  }

  Widget _buildGroupCard(GroupModel group, GroupController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.to(() => GroupDetailsScreen(groupId: group.groupId!)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: group.image != null
                      ? DecorationImage(
                          image: NetworkImage(group.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: group.image == null
                    ? Icon(Icons.group, color: Colors.grey[400], size: 32)
                    : null,
              ),
              const SizedBox(width: 16),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name ?? 'Unnamed Group',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (group.privacy == GroupPrivacy.private)
                          Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (group.description != null)
                      Text(
                        group.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} members',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.event, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${group.eventCount} events',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (group.interests.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: group.interests.take(3).map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(Get.context!).primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Join/Joined button
              const SizedBox(width: 8),
              if (group.userIsMember)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Joined',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Obx(() => ElevatedButton(
                  onPressed: controller.isJoining.value
                      ? null
                      : () => controller.joinGroup(group.groupId!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Join'),
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(GroupController controller) {
    final searchController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  controller.searchGroups(value);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Text(
                        'No results',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final group = controller.searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: group.image != null
                              ? NetworkImage(group.image!)
                              : null,
                          child: group.image == null
                              ? const Icon(Icons.group)
                              : null,
                        ),
                        title: Text(group.name ?? 'Unnamed'),
                        subtitle: Text('${group.memberCount} members'),
                        onTap: () {
                          Get.back();
                          Get.to(() => GroupDetailsScreen(groupId: group.groupId!));
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
