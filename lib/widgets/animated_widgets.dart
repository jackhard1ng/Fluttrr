import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Animated profile completion ring
class ProfileCompletionRing extends StatefulWidget {
  final int percentage;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showPercentage;
  final bool animate;

  const ProfileCompletionRing({
    super.key,
    required this.percentage,
    this.size = 80,
    this.strokeWidth = 6,
    this.child,
    this.showPercentage = true,
    this.animate = true,
  });

  @override
  State<ProfileCompletionRing> createState() => _ProfileCompletionRingState();
}

class _ProfileCompletionRingState extends State<ProfileCompletionRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(ProfileCompletionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage / 100,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.friendlyTeal;
    if (percentage >= 30) return AppColors.friendlyOrange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percentage: 1,
                  strokeWidth: widget.strokeWidth,
                  color: AppColors.lightGrey,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percentage: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: _getColorForPercentage(widget.percentage),
                  useGradient: true,
                ),
              ),
              // Center content
              widget.child ??
                  (widget.showPercentage
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${((_animation.value) * 100).round()}%',
                              style: TextStyle(
                                fontSize: widget.size * 0.2,
                                fontWeight: FontWeight.bold,
                                color: _getColorForPercentage(widget.percentage),
                              ),
                            ),
                            Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: widget.size * 0.1,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;
  final bool useGradient;

  _RingPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.color,
    this.useGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (useGradient) {
      paint.shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          color,
          color.withAlpha(200),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = color;
    }

    final sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

/// Pulsing online indicator
class PulsingOnlineIndicator extends StatefulWidget {
  final double size;
  final bool isOnline;

  const PulsingOnlineIndicator({
    super.key,
    this.size = 12,
    required this.isOnline,
  });

  @override
  State<PulsingOnlineIndicator> createState() => _PulsingOnlineIndicatorState();
}

class _PulsingOnlineIndicatorState extends State<PulsingOnlineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.offline,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.online,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.online.withAlpha((255 * _animation.value).round()),
                blurRadius: widget.size * 0.5 * _animation.value,
                spreadRadius: widget.size * 0.1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated wave button
class AnimatedWaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isWaved;
  final double size;

  const AnimatedWaveButton({
    super.key,
    required this.onPressed,
    this.isWaved = false,
    this.size = 56,
  });

  @override
  State<AnimatedWaveButton> createState() => _AnimatedWaveButtonState();
}

class _AnimatedWaveButtonState extends State<AnimatedWaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * (widget.isWaved ? -1 : 1),
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: widget.isWaved
                      ? const LinearGradient(
                          colors: [AppColors.friendlyTeal, AppColors.success],
                        )
                      : AppGradients.primaryHorizontal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isWaved ? AppColors.friendlyTeal : AppColors.primaryBlue)
                          .withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isWaved ? Icons.check : Icons.waving_hand,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interest match indicator
class InterestMatchIndicator extends StatelessWidget {
  final int matchCount;
  final int totalInterests;
  final bool compact;

  const InterestMatchIndicator({
    super.key,
    required this.matchCount,
    required this.totalInterests,
    this.compact = false,
  });

  Color _getMatchColor() {
    final percentage = totalInterests > 0 ? matchCount / totalInterests : 0;
    if (percentage >= 0.7) return AppColors.success;
    if (percentage >= 0.4) return AppColors.friendlyTeal;
    if (percentage >= 0.2) return AppColors.friendlyOrange;
    return AppColors.mediumGrey;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getMatchColor().withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.interests,
              size: 12,
              color: _getMatchColor(),
            ),
            const SizedBox(width: 4),
            Text(
              '$matchCount match${matchCount != 1 ? 'es' : ''}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getMatchColor(),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Match circles
        SizedBox(
          width: 40,
          height: 20,
          child: Stack(
            children: List.generate(
              matchCount.clamp(0, 3),
              (index) => Positioned(
                left: index * 12.0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getMatchColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$matchCount of $totalInterests',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getMatchColor(),
              ),
            ),
            Text(
              'interests match',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Story-style avatar with ring
class StoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool hasNewStory;
  final bool isOnline;
  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 70,
    this.hasNewStory = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Story ring
              Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(hasNewStory ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasNewStory
                      ? const LinearGradient(
                          colors: [
                            AppColors.friendlyPink,
                            AppColors.friendlyPurple,
                            AppColors.primaryBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: !hasNewStory
                      ? Border.all(color: AppColors.lightGrey, width: 2)
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: AppColors.lightGrey,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: size * 0.4,
                          color: AppColors.grey,
                        )
                      : null,
                ),
              ),
              // Online indicator
              if (isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: PulsingOnlineIndicator(size: size * 0.2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: size,
            child: Text(
              name.split(' ').first,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size * 0.15,
                fontWeight: hasNewStory ? FontWeight.w600 : FontWeight.normal,
                color: hasNewStory ? AppColors.textPrimary : AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating action button with expanding options
class ExpandingFAB extends StatefulWidget {
  final List<ExpandingFABItem> items;
  final IconData icon;
  final IconData closeIcon;

  const ExpandingFAB({
    super.key,
    required this.items,
    this.icon = Icons.add,
    this.closeIcon = Icons.close,
  });

  @override
  State<ExpandingFAB> createState() => _ExpandingFABState();
}

class _ExpandingFABState extends State<ExpandingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expandable items
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final delay = (widget.items.length - index - 1) * 0.1;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(delay, 1.0, curve: Curves.easeOut),
              );

              return Transform.translate(
                offset: Offset(0, 20 * (1 - animation.value)),
                child: Opacity(
                  opacity: animation.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(26),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              item.label!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        FloatingActionButton.small(
                          heroTag: 'fab_item_$index',
                          backgroundColor: item.color ?? AppColors.primaryBlue,
                          onPressed: () {
                            _toggle();
                            item.onPressed();
                          },
                          child: Icon(item.icon, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 0.75 * pi,
                child: Icon(
                  _isOpen ? widget.closeIcon : widget.icon,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExpandingFABItem {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback onPressed;

  const ExpandingFABItem({
    required this.icon,
    this.label,
    this.color,
    required this.onPressed,
  });
}

/// Animated like/wave reaction
class AnimatedReaction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const AnimatedReaction({
    super.key,
    required this.icon,
    required this.color,
    this.size = 80,
    this.onComplete,
  });

  @override
  State<AnimatedReaction> createState() => _AnimatedReactionState();
}

class _AnimatedReactionState extends State<AnimatedReaction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.icon,
              size: widget.size,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

/// Radar animation for nearby discovery
class RadarAnimation extends StatefulWidget {
  final double size;
  final Widget? centerWidget;

  const RadarAnimation({
    super.key,
    this.size = 200,
    this.centerWidget,
  });

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar rings
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.33;
                final progress = (_controller.value + delay) % 1;

                return Opacity(
                  opacity: (1 - progress) * 0.6,
                  child: Container(
                    width: widget.size * progress,
                    height: widget.size * progress,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Center widget
          widget.centerWidget ??
              Container(
                width: widget.size * 0.2,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(77),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              ),
        ],
      ),
    );
  }
}

/// Skeleton loading with shimmer
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                AppColors.lightGrey,
                AppColors.lightGrey.withAlpha(128),
                AppColors.lightGrey,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Match celebration confetti widget
class MatchCelebration extends StatefulWidget {
  final VoidCallback? onComplete;

  const MatchCelebration({super.key, this.onComplete});

  @override
  State<MatchCelebration> createState() => _MatchCelebrationState();
}

class _MatchCelebrationState extends State<MatchCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Confetti> _confetti = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _confetti.add(_Confetti(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.3,
        color: [
          AppColors.primaryBlue,
          AppColors.friendlyTeal,
          AppColors.friendlyPink,
          AppColors.friendlyPurple,
          AppColors.friendlyOrange,
        ][_random.nextInt(5)],
        size: 8 + _random.nextDouble() * 8,
        velocity: 0.5 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 2 * pi,
      ));
    }

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            confetti: _confetti,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _Confetti {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double velocity;
  final double rotation;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      final paint = Paint()
        ..color = c.color.withAlpha((255 * (1 - progress)).round())
        ..style = PaintingStyle.fill;

      final x = c.x * size.width + sin(progress * 10 + c.rotation) * 20;
      final y = c.y * size.height + progress * size.height * c.velocity;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * c.rotation * 5);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
