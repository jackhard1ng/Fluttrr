import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/story_controller.dart';
import '../../models/story_model.dart';
import '../../constants/utils.dart';

/// Full-screen story viewer with auto-advance
class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  final StoryController _controller = Get.isRegistered<StoryController>()
      ? Get.find<StoryController>()
      : Get.put(StoryController());

  late AnimationController _progressController;
  late int _currentIndex;
  Timer? _autoAdvanceTimer;
  bool _isPaused = false;

  static const Duration storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    // Clamp initialIndex to valid range to prevent out-of-bounds access
    _currentIndex = widget.stories.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.stories.length - 1);

    _progressController = AnimationController(
      vsync: this,
      duration: storyDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNext();
      }
    });

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _startProgress();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  void _pauseProgress() {
    _isPaused = true;
    _progressController.stop();
  }

  void _resumeProgress() {
    _isPaused = false;
    _progressController.forward();
  }

  void _goToNext() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _controller.nextStory();
      _startProgress();
    } else {
      Get.back();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _controller.previousStory();
      _startProgress();
    } else {
      _startProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_stories, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text('No stories available', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pauseProgress(),
        onTapUp: (details) {
          _resumeProgress();
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _goToPrevious();
          } else if (details.globalPosition.dx > width * 2 / 3) {
            _goToNext();
          }
        },
        onLongPressStart: (_) => _pauseProgress(),
        onLongPressEnd: (_) => _resumeProgress(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story content
            _buildStoryContent(story),

            // Gradient overlays
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withAlpha(128),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withAlpha(128),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Top section (progress + user info)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Column(
                children: [
                  // Progress bars
                  Row(
                    children: List.generate(
                      widget.stories.length,
                      (index) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: index == _currentIndex
                              ? AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    return LinearProgressIndicator(
                                      value: _progressController.value,
                                      backgroundColor: Colors.white38,
                                      valueColor: const AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: index < _currentIndex
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: story.userAvatar != null
                            ? NetworkImage(story.userAvatar!)
                            : null,
                        backgroundColor: AppColors.primaryBlue,
                        child: story.userAvatar == null
                            ? Text(
                                story.userName.isNotEmpty
                                    ? story.userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  timeago.format(story.createdAt),
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(179),
                                    fontSize: 12,
                                  ),
                                ),
                                if (story.eventName != null) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(179),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      story.eventName!,
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(179),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Caption at bottom
            if (story.caption != null && story.caption!.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    story.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Bottom reactions
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ReactionButton(
                    emoji: '❤️',
                    onTap: () => _controller.addReaction('❤️'),
                  ),
                  _ReactionButton(
                    emoji: '🔥',
                    onTap: () => _controller.addReaction('🔥'),
                  ),
                  _ReactionButton(
                    emoji: '😍',
                    onTap: () => _controller.addReaction('😍'),
                  ),
                  _ReactionButton(
                    emoji: '😂',
                    onTap: () => _controller.addReaction('😂'),
                  ),
                  _ReactionButton(
                    emoji: '👏',
                    onTap: () => _controller.addReaction('👏'),
                  ),
                ],
              ),
            ),

            // Paused indicator
            if (_isPaused)
              Center(
                child: Icon(
                  Icons.pause_circle_outline,
                  size: 64,
                  color: Colors.white.withAlpha(128),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    switch (story.type) {
      case StoryType.image:
        return Image.network(
          story.mediaUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            _pauseProgress();
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
          errorBuilder: (_, __, ___) {
            _resumeProgress();
            return const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
            );
          },
        );

      case StoryType.video:
        // Video would use video_player package
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 64, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                'Video stories coming soon',
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ],
          ),
        );

      case StoryType.text:
        return Container(
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                story.caption ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
