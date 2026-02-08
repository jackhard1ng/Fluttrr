import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/memory_controller.dart';
import '../../models/memory_model.dart';
import '../../constants/utils.dart';
import 'event_memories_screen.dart';
import 'memory_detail_screen.dart';

/// Main memories screen - shows feed of memories from events
class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemoryController());
    controller.loadFeed(refresh: true);
    controller.loadEventsWithMemories(refresh: true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Memories'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MemoriesFeedTab(controller: controller),
            _EventsWithMemoriesTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Feed of memories
class _MemoriesFeedTab extends StatelessWidget {
  final MemoryController controller;

  const _MemoriesFeedTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingFeed.value && controller.feedMemories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.feedMemories.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadFeed(refresh: true),
        child: CustomScrollView(
          slivers: [
            // Featured memories carousel
            if (controller.featuredMemories.isNotEmpty)
              SliverToBoxAdapter(
                child: _FeaturedMemoriesCarousel(
                  memories: controller.featuredMemories,
                ),
              ),

            // Feed list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= controller.feedMemories.length) {
                    // Load more trigger
                    if (controller.hasMoreFeed.value) {
                      controller.loadFeed();
                    }
                    return const SizedBox(height: 80);
                  }

                  return _MemoryCard(
                    memory: controller.feedMemories[index],
                    controller: controller,
                  );
                },
                childCount: controller.feedMemories.length + 1,
              ),
            ),
          ],
        ),
      );
    });
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
              'Attend events and share your photos to see memories here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Events that have memories
class _EventsWithMemoriesTab extends StatelessWidget {
  final MemoryController controller;

  const _EventsWithMemoriesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.eventsWithMemories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.eventsWithMemories.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Event Memories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Events with shared photos will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadEventsWithMemories(refresh: true),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.eventsWithMemories.length,
          itemBuilder: (context, index) {
            final event = controller.eventsWithMemories[index];
            return _EventMemoryCard(event: event);
          },
        ),
      );
    });
  }
}

/// Featured memories carousel
class _FeaturedMemoriesCarousel extends StatelessWidget {
  final List<EventMemoryModel> memories;

  const _FeaturedMemoriesCarousel({required this.memories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return GestureDetector(
                onTap: () => Get.to(() => MemoryDetailScreen(memory: memory)),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: memory.primaryPhoto != null
                        ? DecorationImage(
                            image: NetworkImage(memory.primaryPhoto!.url),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${memory.photos.length} photos',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

/// Individual memory card in feed
class _MemoryCard extends StatelessWidget {
  final EventMemoryModel memory;
  final MemoryController controller;

  const _MemoryCard({
    required this.memory,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: memory.uploaderAvatar != null
                  ? NetworkImage(memory.uploaderAvatar!)
                  : null,
              child: memory.uploaderAvatar == null
                  ? Text(memory.uploaderName[0].toUpperCase())
                  : null,
            ),
            title: Text(
              memory.uploaderName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${memory.eventName} - ${memory.timeSinceEvent}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptions(context),
            ),
          ),

          // Photo grid
          GestureDetector(
            onTap: () => Get.to(() => MemoryDetailScreen(memory: memory)),
            child: _buildPhotoGrid(),
          ),

          // Caption
          if (memory.caption != null && memory.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                memory.caption!,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    memory.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    color: memory.isLikedByMe ? Colors.red : null,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.toggleLike(memory.memoryId);
                  },
                ),
                Text(
                  '${memory.likeCount}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Get.to(() => MemoryDetailScreen(
                        memory: memory,
                        focusComments: true,
                      )),
                ),
                Text(
                  '${memory.commentCount}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final photos = memory.photos;
    if (photos.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.photo, size: 48)),
      );
    }

    if (photos.length == 1) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          photos[0].url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          ),
        ),
      );
    }

    if (photos.length == 2) {
      return AspectRatio(
        aspectRatio: 2,
        child: Row(
          children: [
            Expanded(
              child: Image.network(photos[0].url, fit: BoxFit.cover),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Image.network(photos[1].url, fit: BoxFit.cover),
            ),
          ],
        ),
      );
    }

    // 3+ photos
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Image.network(photos[0].url, fit: BoxFit.cover),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(photos[1].url, fit: BoxFit.cover),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(photos[2].url, fit: BoxFit.cover),
                      if (photos.length > 3)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              '+${photos.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('View all photos'),
              onTap: () {
                Get.back();
                Get.to(() => MemoryDetailScreen(memory: memory));
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('View event memories'),
              onTap: () {
                Get.back();
                Get.to(() => EventMemoriesScreen(
                      eventId: memory.eventId,
                      eventName: memory.eventName,
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () {
                Get.back();
                _showReportDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () {
                Get.back();
                controller.reportMemory(
                  memoryId: memory.memoryId,
                  reason: 'inappropriate',
                );
              },
            ),
            ListTile(
              title: const Text('Spam'),
              onTap: () {
                Get.back();
                controller.reportMemory(
                  memoryId: memory.memoryId,
                  reason: 'spam',
                );
              },
            ),
            ListTile(
              title: const Text('Privacy violation'),
              onTap: () {
                Get.back();
                controller.reportMemory(
                  memoryId: memory.memoryId,
                  reason: 'privacy',
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Event card showing memories preview
class _EventMemoryCard extends StatelessWidget {
  final EventWithMemoriesModel event;

  const _EventMemoryCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventMemoriesScreen(
            eventId: event.eventId,
            eventName: event.eventName,
          )),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview photos grid
            if (event.previewPhotos.isNotEmpty)
              _buildPreviewGrid()
            else if (event.eventImage != null)
              Image.network(event.eventImage!, fit: BoxFit.cover)
            else
              const Center(child: Icon(Icons.photo_library, size: 48)),

            // Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(event.eventDate),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.photoCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.contributorCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  Widget _buildPreviewGrid() {
    final photos = event.previewPhotos;
    if (photos.length == 1) {
      return Image.network(photos[0], fit: BoxFit.cover);
    }

    if (photos.length == 2) {
      return Row(
        children: [
          Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
          const SizedBox(width: 2),
          Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Image.network(photos[0], fit: BoxFit.cover),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
              const SizedBox(width: 2),
              Expanded(
                child: photos.length > 2
                    ? Image.network(photos[2], fit: BoxFit.cover)
                    : Container(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
