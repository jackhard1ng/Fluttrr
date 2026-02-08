import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../constants/utils.dart';
import '../config/routes.dart';

/// Offline/Online connectivity banner
/// Wrap your Scaffold body with this to show connectivity status
class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  bool _showBanner = false;
  bool _wasOffline = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Check initial connectivity
    _checkConnectivity();

    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (!isOnline && _isOnline) {
      // Lost connection
      _wasOffline = true;
      setState(() {
        _isOnline = false;
        _showBanner = true;
      });
      _controller.forward();
    } else if (isOnline && !_isOnline) {
      // Regained connection
      setState(() => _isOnline = true);

      // Show "back online" briefly then hide
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) setState(() => _showBanner = false);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showBanner)
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: _isOnline ? AppColors.success : AppColors.error,
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'Back online!' : 'No internet connection',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Scroll-to-top floating action button
/// Shows when user scrolls down past threshold
class ScrollToTopFAB extends StatefulWidget {
  final ScrollController scrollController;
  final double showAfter;
  final Widget? child;

  const ScrollToTopFAB({
    super.key,
    required this.scrollController,
    this.showAfter = 200,
    this.child,
  });

  @override
  State<ScrollToTopFAB> createState() => _ScrollToTopFABState();
}

class _ScrollToTopFABState extends State<ScrollToTopFAB>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final shouldShow = widget.scrollController.offset > widget.showAfter;
    if (shouldShow != _showButton) {
      setState(() => _showButton = shouldShow);
      if (_showButton) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton.small(
        heroTag: 'scroll_to_top_${widget.hashCode}',
        onPressed: _scrollToTop,
        backgroundColor: AppColors.primaryBlue,
        child: widget.child ?? const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}

/// Undo action snackbar helper
/// Shows a snackbar with undo option before permanent action
class UndoAction {
  static void show({
    required String message,
    required VoidCallback onUndo,
    VoidCallback? onTimeout,
    Duration duration = const Duration(seconds: 4),
    String undoLabel = 'UNDO',
  }) {
    HapticFeedback.lightImpact();

    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: duration,
        backgroundColor: AppColors.darkGrey,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        mainButton: TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.closeCurrentSnackbar();
            onUndo();
          },
          child: Text(
            undoLabel,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: (_) {},
        snackbarStatus: (status) {
          if (status == SnackbarStatus.CLOSED && onTimeout != null) {
            // Action was not undone, execute permanent action
            onTimeout();
          }
        },
      ),
    );
  }
}

/// Double-back-to-exit wrapper
/// Wrap your main scaffold to require double back press to exit
class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > widget.duration) {
          _lastBackPress = now;
          HapticFeedback.lightImpact();
          // Check if widget is still mounted before showing snackbar (#81)
          if (!mounted) return;
          Get.showSnackbar(
            GetSnackBar(
              message: widget.message,
              duration: widget.duration,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.darkGrey,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            ),
          );
        } else {
          // Exit the app
          SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}

/// Shake detector for feedback/bug reports
/// Wrap screens with this to detect shake gestures
class ShakeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;
  final double shakeThreshold;

  const ShakeDetector({
    super.key,
    required this.child,
    required this.onShake,
    this.shakeThreshold = 15.0,
  });

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  StreamSubscription? _subscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z
      );

      if (magnitude > widget.shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;
          HapticFeedback.heavyImpact();
          widget.onShake();
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Show shake-to-report feedback dialog
void showShakeFeedbackDialog(BuildContext context) {
  // Guard against invalid context
  try {
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FeedbackSheet(),
    );
  } catch (e) {
    debugPrint('Error showing feedback dialog: $e');
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _controller = TextEditingController();
  String _selectedType = 'bug';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.feedback,
                  color: AppColors.friendlyPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Shake anytime to report issues',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'What kind of feedback?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FeedbackChip(
                label: '🐛 Bug',
                value: 'bug',
                selected: _selectedType == 'bug',
                onTap: () => setState(() => _selectedType = 'bug'),
              ),
              _FeedbackChip(
                label: '💡 Suggestion',
                value: 'suggestion',
                selected: _selectedType == 'suggestion',
                onTap: () => setState(() => _selectedType = 'suggestion'),
              ),
              _FeedbackChip(
                label: '❓ Question',
                value: 'question',
                selected: _selectedType == 'question',
                onTap: () => setState(() => _selectedType = 'question'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your feedback...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isEmpty) {
                  Get.snackbar(
                    'Please add details',
                    'Tell us more about your feedback',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                Get.snackbar(
                  '💜 Thank you!',
                  'Your feedback has been submitted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FeedbackChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkGrey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Pull-to-refresh with loading indicator
/// Use this wrapper for screens that should refresh on pull
class RefreshableContent extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;

  const RefreshableContent({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await onRefresh();
      },
      color: AppColors.primaryBlue,
      backgroundColor: backgroundColor ?? Colors.white,
      child: child,
    );
  }
}

/// Empty state with action button
class EmptyStateAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Session timeout handler
/// Tracks user inactivity and logs them out after timeout
class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 30),
    required this.onTimeout,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      widget.onTimeout();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}

/// Animated counter for statistics
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
      setState(() => _currentValue = _animation.value.round());
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _currentValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix ?? ''}$_currentValue${widget.suffix ?? ''}',
      style: widget.style,
    );
  }
}

/// Tooltip with custom styling
class InfoTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const InfoTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}

/// Skeleton text placeholder for loading states
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({
    super.key,
    required this.width,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Confirm dialog helper
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDangerous = false,
}) async {
  // Guard against invalid context
  if (!context.mounted) return false;

  try {
    HapticFeedback.mediumImpact();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDangerous ? AppColors.error : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  } catch (e) {
    debugPrint('Error showing confirm dialog: $e');
    return false;
  }
}
