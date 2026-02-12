import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/memory_controller.dart';
import '../../models/memory_model.dart';
import '../../constants/utils.dart';

/// Full-screen photo viewer with zoom and swipe
class PhotoViewerScreen extends StatefulWidget {
  final List<MemoryPhotoModel> photos;
  final int initialIndex;
  final String memoryId;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    required this.memoryId,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;
  bool _isTagging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
  }

  void _toggleTagging() {
    setState(() => _isTagging = !_isTagging);
    if (_isTagging) {
      Get.snackbar(
        'Tag Mode',
        'Tap on the photo to tag someone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryBlue,
        colorText: Colors.white,
      );
    }
  }

  void _handlePhotoTap(TapDownDetails details, BoxConstraints constraints) {
    if (!_isTagging) {
      _toggleUI();
      return;
    }

    // Calculate tap position as percentage
    final xPercent = details.localPosition.dx / constraints.maxWidth;
    final yPercent = details.localPosition.dy / constraints.maxHeight;

    _showTagUserDialog(xPercent, yPercent);
  }

  void _showTagUserDialog(double xPosition, double yPosition) {
    final currentPhoto = widget.photos[_currentIndex];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _TagUserSheet(
          photoId: currentPhoto.photoId,
          memoryId: widget.memoryId,
          xPosition: xPosition,
          yPosition: yPosition,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo viewer
          GestureDetector(
            onTap: _toggleUI,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) =>
                          _handlePhotoTap(details, constraints),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Image.network(
                                photo.url,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),

                            // Photo tags
                            if (!_isTagging)
                              ...photo.tags.map((tag) => Positioned(
                                    left: tag.xPosition * constraints.maxWidth - 20,
                                    top: tag.yPosition * constraints.maxHeight - 20,
                                    child: _TagBubble(tag: tag),
                                  )),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Top bar
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(179),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1} / ${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isTagging ? Icons.person : Icons.person_add_outlined,
                        color: _isTagging ? AppColors.primaryBlue : Colors.white,
                      ),
                      onPressed: _toggleTagging,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom bar
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(179),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.download,
                        label: 'Save',
                        onTap: () => _savePhoto(),
                      ),
                      _ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () => _sharePhoto(),
                      ),
                      if (widget.photos[_currentIndex].tags.isNotEmpty)
                        _ActionButton(
                          icon: Icons.people,
                          label: '${widget.photos[_currentIndex].tags.length}',
                          onTap: () => _showTaggedPeople(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Page indicators
          if (widget.photos.length > 1)
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photos.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white.withAlpha(128),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _savePhoto() {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Saved',
      'Photo saved to gallery',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _sharePhoto() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Share',
      'Sharing photo...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showTaggedPeople() {
    final photo = widget.photos[_currentIndex];
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tagged People',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...photo.tags.map((tag) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: tag.userAvatar != null
                        ? NetworkImage(tag.userAvatar!)
                        : null,
                    backgroundColor: AppColors.primaryBlue,
                    child: tag.userAvatar == null
                        ? Text(
                            tag.userName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(tag.userName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.back();
                    // Navigate to profile
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagBubble extends StatelessWidget {
  final PhotoTagModel tag;

  const _TagBubble({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag.userName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TagUserSheet extends StatefulWidget {
  final String photoId;
  final String memoryId;
  final double xPosition;
  final double yPosition;
  final ScrollController scrollController;

  const _TagUserSheet({
    required this.photoId,
    required this.memoryId,
    required this.xPosition,
    required this.yPosition,
    required this.scrollController,
  });

  @override
  State<_TagUserSheet> createState() => _TagUserSheetState();
}

class _TagUserSheetState extends State<_TagUserSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestedUsers();
  }

  void _loadSuggestedUsers() {
    // Mock data - would come from API
    setState(() {
      _users = [
        {'id': '1', 'name': 'Alex Johnson', 'avatar': ''},
        {'id': '2', 'name': 'Sarah Smith', 'avatar': ''},
        {'id': '3', 'name': 'Mike Chen', 'avatar': ''},
        {'id': '4', 'name': 'Emma Wilson', 'avatar': ''},
        {'id': '5', 'name': 'Jordan Lee', 'avatar': ''},
      ];
    });
  }

  void _searchUsers(String query) {
    // Would call API to search users
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _tagUser(String userId, String userName) async {
    if (!Get.isRegistered<MemoryController>()) {
      Get.put(MemoryController());
    }
    final controller = Get.find<MemoryController>();

    Get.back();

    final success = await controller.tagUser(
      memoryId: widget.memoryId,
      photoId: widget.photoId,
      userId: userId,
      xPosition: widget.xPosition,
      yPosition: widget.yPosition,
    );

    if (success) {
      Get.snackbar(
        'Tagged',
        '$userName has been tagged',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tag Someone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _searchUsers,
            decoration: InputDecoration(
              hintText: 'Search friends...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: widget.scrollController,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final name = (user['name'] as String?) ?? '';
                    final id = user['id'] as String?;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(name.isEmpty ? 'Unknown' : name),
                      onTap: id != null
                          ? () => _tagUser(id, name.isEmpty ? 'Unknown' : name)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
