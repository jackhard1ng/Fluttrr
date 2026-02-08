import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/memory_controller.dart';
import '../../models/memory_model.dart';
import '../../constants/utils.dart';
import 'memory_detail_screen.dart';

/// Screen showing user's own memories
class MyMemoriesScreen extends StatefulWidget {
  const MyMemoriesScreen({super.key});

  @override
  State<MyMemoriesScreen> createState() => _MyMemoriesScreenState();
}

class _MyMemoriesScreenState extends State<MyMemoriesScreen>
    with SingleTickerProviderStateMixin {
  final MemoryController _controller = Get.find<MemoryController>();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller.loadMyMemories(refresh: true);
    _controller.loadTaggedMemories(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_tabController.index == 0 && !_controller.isLoadingMy.value) {
        _controller.loadMyMemories();
      } else if (_tabController.index == 1 && !_controller.isLoadingTagged.value) {
        _controller.loadTaggedMemories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memories'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.mediumGrey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'My Posts'),
            Tab(text: 'Tagged'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My posts tab
          _buildMyPostsTab(),

          // Tagged tab
          _buildTaggedTab(),

          // Saved tab
          _buildSavedTab(),
        ],
      ),
    );
  }

  Widget _buildMyPostsTab() {
    return Obx(() {
      if (_controller.isLoadingMy.value && _controller.myMemories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.myMemories.isEmpty) {
        return _buildEmptyState(
          icon: Icons.photo_camera,
          title: 'No Memories Yet',
          subtitle: 'Your shared event photos will appear here',
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.loadMyMemories(refresh: true),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: _controller.myMemories.length,
          itemBuilder: (context, index) {
            final memory = _controller.myMemories[index];
            return _MemoryGridTile(
              memory: memory,
              onTap: () => Get.to(() => MemoryDetailScreen(memory: memory)),
              onLongPress: () => _showMemoryOptions(memory),
            );
          },
        ),
      );
    });
  }

  Widget _buildTaggedTab() {
    return Obx(() {
      if (_controller.isLoadingTagged.value && _controller.taggedMemories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.taggedMemories.isEmpty) {
        return _buildEmptyState(
          icon: Icons.person_pin,
          title: 'No Tagged Photos',
          subtitle: 'Photos you\'ve been tagged in will appear here',
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.loadTaggedMemories(refresh: true),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: _controller.taggedMemories.length,
          itemBuilder: (context, index) {
            final memory = _controller.taggedMemories[index];
            return _MemoryGridTile(
              memory: memory,
              onTap: () => Get.to(() => MemoryDetailScreen(memory: memory)),
              showTagIndicator: true,
            );
          },
        ),
      );
    });
  }

  Widget _buildSavedTab() {
    return Obx(() {
      if (_controller.savedMemories.isEmpty) {
        return _buildEmptyState(
          icon: Icons.bookmark_border,
          title: 'No Saved Memories',
          subtitle: 'Memories you save will appear here',
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _controller.savedMemories.length,
        itemBuilder: (context, index) {
          final memory = _controller.savedMemories[index];
          return _MemoryGridTile(
            memory: memory,
            onTap: () => Get.to(() => MemoryDetailScreen(memory: memory)),
          );
        },
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.lightGrey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemoryOptions(EventMemoryModel memory) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View'),
              onTap: () {
                Get.back();
                Get.to(() => MemoryDetailScreen(memory: memory));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Caption'),
              onTap: () {
                Get.back();
                _showEditCaptionDialog(memory);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                _confirmDelete(memory);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditCaptionDialog(EventMemoryModel memory) {
    final textController = TextEditingController(text: memory.caption);
    final isUpdating = false.obs;

    showDialog(
      context: context,
      builder: (context) => Obx(() => AlertDialog(
        title: const Text('Edit Caption'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          enabled: !isUpdating.value,
          decoration: const InputDecoration(
            hintText: 'Write a caption...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isUpdating.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isUpdating.value ? null : () async {
              final newCaption = textController.text.trim();
              isUpdating.value = true;

              final success = await _controller.updateCaption(
                memoryId: memory.memoryId,
                caption: newCaption,
              );

              isUpdating.value = false;

              if (success) {
                Get.back();
                Get.snackbar(
                  'Updated',
                  'Caption updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  _controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
              }
            },
            child: isUpdating.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      )),
    );
  }

  void _confirmDelete(EventMemoryModel memory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text(
          'This will permanently delete this memory and all its photos. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _controller.deleteMemory(memory.memoryId);
              if (success) {
                Get.snackbar(
                  'Deleted',
                  'Memory deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MemoryGridTile extends StatelessWidget {
  final EventMemoryModel memory;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showTagIndicator;

  const _MemoryGridTile({
    required this.memory,
    required this.onTap,
    this.onLongPress,
    this.showTagIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              onLongPress!();
            }
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          memory.primaryPhoto != null
              ? Image.network(
                  memory.primaryPhoto!.displayUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.lightGrey,
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.photo),
                ),

          // Multi-photo indicator
          if (memory.photos.length > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.collections,
                size: 16,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black.withAlpha(128),
                  ),
                ],
              ),
            ),

          // Tag indicator
          if (showTagIndicator)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 10, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'Tagged',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
