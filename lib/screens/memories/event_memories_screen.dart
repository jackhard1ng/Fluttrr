import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/memory_controller.dart';
import '../../models/memory_model.dart';
import '../../constants/utils.dart';
import 'memory_detail_screen.dart';
import 'upload_memory_screen.dart';

/// Screen showing all memories for a specific event
class EventMemoriesScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String? eventImage;

  const EventMemoriesScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.eventImage,
  });

  @override
  State<EventMemoriesScreen> createState() => _EventMemoriesScreenState();
}

class _EventMemoriesScreenState extends State<EventMemoriesScreen> {
  final MemoryController _controller = Get.isRegistered<MemoryController>()
      ? Get.find<MemoryController>()
      : Get.put(MemoryController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.loadEventMemories(eventId: widget.eventId, refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoadingEvent.value &&
          _controller.hasMoreEventMemories.value) {
        _controller.loadEventMemories(eventId: widget.eventId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.eventName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.eventImage != null)
                    Image.network(
                      widget.eventImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryBlue.withAlpha(51),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.friendlyPurple,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.photo_library,
                          size: 60,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(128),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Obx(() {
              final memories = _controller.eventMemories;
              final totalPhotos = memories.fold<int>(
                0,
                (sum, m) => sum + m.photos.length,
              );
              final contributors = memories.map((m) => m.uploaderId).toSet();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.lightGrey),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.photo_library,
                      value: '$totalPhotos',
                      label: 'Photos',
                    ),
                    _StatItem(
                      icon: Icons.collections,
                      value: '${memories.length}',
                      label: 'Memories',
                    ),
                    _StatItem(
                      icon: Icons.people,
                      value: '${contributors.length}',
                      label: 'Contributors',
                    ),
                  ],
                ),
              );
            }),
          ),

          // Memories grid
          Obx(() {
            if (_controller.isLoadingEvent.value &&
                _controller.eventMemories.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (_controller.eventMemories.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _controller.eventMemories.length) {
                      return _controller.hasMoreEventMemories.value
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final memory = _controller.eventMemories[index];
                    return _MemoryGridItem(
                      memory: memory,
                      onTap: () => Get.to(
                        () => MemoryDetailScreen(memory: memory),
                      ),
                    );
                  },
                  childCount: _controller.eventMemories.length +
                      (_controller.hasMoreEventMemories.value ? 1 : 0),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Get.to(() => UploadMemoryScreen(
                eventId: widget.eventId,
                eventName: widget.eventName,
              ));
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Photos'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Memories Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to share photos from this event!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => UploadMemoryScreen(
                    eventId: widget.eventId,
                    eventName: widget.eventName,
                  )),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add First Memory'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

class _MemoryGridItem extends StatelessWidget {
  final EventMemoryModel memory;
  final VoidCallback onTap;

  const _MemoryGridItem({
    required this.memory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
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

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(179),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Photo count badge
              if (memory.photos.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${memory.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom info
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: memory.uploaderAvatar != null
                              ? NetworkImage(memory.uploaderAvatar!)
                              : null,
                          backgroundColor: AppColors.primaryBlue,
                          child: memory.uploaderAvatar == null
                              ? Text(
                                  memory.uploaderName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            memory.uploaderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          memory.isLikedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: memory.isLikedByMe ? Colors.red : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${memory.likeCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${memory.commentCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
