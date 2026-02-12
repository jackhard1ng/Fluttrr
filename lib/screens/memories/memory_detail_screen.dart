import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/memory_controller.dart';
import '../../models/memory_model.dart';
import '../../constants/utils.dart';
import 'photo_viewer_screen.dart';

/// Screen showing details of a single memory with photos, comments
class MemoryDetailScreen extends StatefulWidget {
  final EventMemoryModel memory;
  final bool focusComments;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.focusComments = false,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final MemoryController _controller = Get.isRegistered<MemoryController>()
      ? Get.find<MemoryController>()
      : Get.put(MemoryController());
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late EventMemoryModel _memory;
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
    _controller.loadComments(_memory.memoryId);

    if (widget.focusComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComments();
        _commentFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final success = await _controller.addComment(
      memoryId: _memory.memoryId,
      content: content,
    );

    if (success) {
      _commentController.clear();
      _commentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _memory.uploaderName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _memory.eventName,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo carousel
                  _buildPhotoCarousel(),

                  // Photo indicators
                  if (_memory.photos.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _memory.photos.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPhotoIndex == index
                                  ? AppColors.primaryBlue
                                  : AppColors.lightGrey,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Obx(() {
                          final memory = _controller.selectedMemory.value ?? _memory;
                          return IconButton(
                            icon: Icon(
                              memory.isLikedByMe
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: memory.isLikedByMe ? Colors.red : null,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _controller.toggleLike(_memory.memoryId);
                            },
                          );
                        }),
                        Obx(() {
                          final memory = _controller.selectedMemory.value ?? _memory;
                          return Text(
                            '${memory.likeCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          );
                        }),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () {
                            _scrollToComments();
                            _commentFocus.requestFocus();
                          },
                        ),
                        Obx(() {
                          return Text(
                            '${_controller.memoryComments.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          );
                        }),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () => _shareMemory(),
                        ),
                      ],
                    ),
                  ),

                  // Caption
                  if (_memory.caption != null && _memory.caption!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: AppColors.darkGrey),
                          children: [
                            TextSpan(
                              text: '${_memory.uploaderName} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: _memory.caption),
                          ],
                        ),
                      ),
                    ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      timeago.format(_memory.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Comments section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Text(
                              '${_controller.memoryComments.length}',
                              style: TextStyle(color: AppColors.mediumGrey),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comments list
                  Obx(() {
                    if (_controller.isLoadingComments.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_controller.memoryComments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: AppColors.lightGrey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: TextStyle(color: AppColors.mediumGrey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to comment!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.memoryComments.length,
                      itemBuilder: (context, index) {
                        final comment = _controller.memoryComments[index];
                        return _CommentTile(
                          comment: comment,
                          onLike: () => _controller.toggleCommentLike(
                            memoryId: _memory.memoryId,
                            commentId: comment.commentId,
                          ),
                          onDelete: comment.userId == 'current-user-id'
                              ? () => _controller.deleteComment(
                                    memoryId: _memory.memoryId,
                                    commentId: comment.commentId,
                                  )
                              : null,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 100), // Space for input
                ],
              ),
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: AppColors.mediumGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primaryBlue),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    if (_memory.photos.isEmpty) {
      return Container(
        height: 300,
        color: AppColors.lightGrey,
        child: const Center(child: Icon(Icons.photo, size: 64)),
      );
    }

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _memory.photos.length,
        onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
        itemBuilder: (context, index) {
          final photo = _memory.photos[index];
          return GestureDetector(
            onTap: () => Get.to(
              () => PhotoViewerScreen(
                photos: _memory.photos,
                initialIndex: index,
                memoryId: _memory.memoryId,
              ),
            ),
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.lightGrey,
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOptions(BuildContext context) {
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
              leading: const Icon(Icons.download),
              title: const Text('Save photos'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Saved',
                  'Photos saved to gallery',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Get.back();
                _shareMemory();
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.friendlyOrange),
              title: const Text('Report'),
              onTap: () {
                Get.back();
                _showReportDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _shareMemory() {
    Get.snackbar(
      'Share',
      'Sharing memory...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showReportDialog() {
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
                _controller.reportMemory(
                  memoryId: _memory.memoryId,
                  reason: 'inappropriate',
                );
              },
            ),
            ListTile(
              title: const Text('Spam'),
              onTap: () {
                Get.back();
                _controller.reportMemory(
                  memoryId: _memory.memoryId,
                  reason: 'spam',
                );
              },
            ),
            ListTile(
              title: const Text('Privacy violation'),
              onTap: () {
                Get.back();
                _controller.reportMemory(
                  memoryId: _memory.memoryId,
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

class _CommentTile extends StatelessWidget {
  final MemoryCommentModel comment;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.userAvatar != null
                ? NetworkImage(comment.userAvatar!)
                : null,
            backgroundColor: AppColors.primaryBlue,
            child: comment.userAvatar == null
                ? Text(
                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${comment.userName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${comment.likeCount} like${comment.likeCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onDelete,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onLike();
            },
            child: Icon(
              comment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.isLikedByMe ? Colors.red : AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
