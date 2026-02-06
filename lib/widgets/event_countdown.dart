import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';

/// Event countdown card - builds excitement for upcoming events
class EventCountdownCard extends StatefulWidget {
  final String eventId;
  final String eventName;
  final DateTime eventDate;
  final String? eventLocation;
  final String? eventImage;
  final int attendeeCount;
  final List<String> friendsGoing;
  final VoidCallback? onTap;
  final VoidCallback? onInviteFriends;

  const EventCountdownCard({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    this.eventLocation,
    this.eventImage,
    this.attendeeCount = 0,
    this.friendsGoing = const [],
    this.onTap,
    this.onInviteFriends,
  });

  @override
  State<EventCountdownCard> createState() => _EventCountdownCardState();
}

class _EventCountdownCardState extends State<EventCountdownCard> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    if (widget.eventDate.isAfter(now)) {
      setState(() {
        _timeRemaining = widget.eventDate.difference(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.eventImage != null &&
        ApiEndpoints.isValidImageUrl(widget.eventImage);
    final isToday = _timeRemaining.inDays == 0;
    final isHappening = _timeRemaining.inMinutes <= 30 && _timeRemaining.inMinutes > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: (isHappening ? AppColors.success : AppColors.primaryBlue)
                  .withAlpha(51),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              // Background image or gradient
              if (hasImage)
                Image.network(
                  ApiEndpoints.getImageUrl(widget.eventImage),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHappening
                          ? [AppColors.success, AppColors.friendlyTeal]
                          : [AppColors.primaryBlue, AppColors.friendlyPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

              // Gradient overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(26),
                      Colors.black.withAlpha(179),
                    ],
                  ),
                ),
              ),

              // Content
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row - status badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isHappening
                                  ? AppColors.success
                                  : isToday
                                      ? AppColors.friendlyOrange
                                      : Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(AppRadius.circular),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isHappening) ...[
                                  const _PulsingDot(),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  isHappening
                                      ? 'Starting Soon!'
                                      : isToday
                                          ? 'Today'
                                          : _formatDate(widget.eventDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Invite button
                          GestureDetector(
                            onTap: widget.onInviteFriends ??
                                () => _showInviteSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Event name
                      Text(
                        widget.eventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location
                      if (widget.eventLocation != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.eventLocation!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Bottom row - countdown and friends
                      Row(
                        children: [
                          // Countdown
                          _CountdownDisplay(
                            duration: _timeRemaining,
                            isHappening: isHappening,
                          ),

                          const Spacer(),

                          // Friends going
                          if (widget.friendsGoing.isNotEmpty)
                            _FriendsGoingBadge(
                              friends: widget.friendsGoing,
                              totalCount: widget.attendeeCount,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickInviteSheet(
        eventName: widget.eventName,
        eventDate: widget.eventDate,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withAlpha((128 * _controller.value).round()),
                blurRadius: 4 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountdownDisplay extends StatelessWidget {
  final Duration duration;
  final bool isHappening;

  const _CountdownDisplay({
    required this.duration,
    required this.isHappening,
  });

  @override
  Widget build(BuildContext context) {
    if (duration.inSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Text(
          'Happening Now!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (days > 0) ...[
            _TimeUnit(value: days, label: 'd'),
            const SizedBox(width: 8),
          ],
          _TimeUnit(value: hours, label: 'h'),
          const SizedBox(width: 8),
          _TimeUnit(value: minutes, label: 'm'),
          if (days == 0) ...[
            const SizedBox(width: 8),
            _TimeUnit(value: seconds, label: 's'),
          ],
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(179),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FriendsGoingBadge extends StatelessWidget {
  final List<String> friends;
  final int totalCount;

  const _FriendsGoingBadge({
    required this.friends,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stacked avatars
          SizedBox(
            width: 36,
            height: 20,
            child: Stack(
              children: [
                for (int i = 0; i < friends.take(2).length; i++)
                  Positioned(
                    left: i * 12.0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          friends[i][0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '+$totalCount going',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick invite sheet - invite friends to events
class QuickInviteSheet extends StatefulWidget {
  final String eventName;
  final DateTime eventDate;

  const QuickInviteSheet({
    super.key,
    required this.eventName,
    required this.eventDate,
  });

  @override
  State<QuickInviteSheet> createState() => _QuickInviteSheetState();
}

class _QuickInviteSheetState extends State<QuickInviteSheet> {
  final Set<String> _selectedFriends = {};

  // Mock friends list
  final _friends = [
    _Friend(id: '1', name: 'Alex', initial: 'A', isOnline: true),
    _Friend(id: '2', name: 'Jordan', initial: 'J', isOnline: true),
    _Friend(id: '3', name: 'Sam', initial: 'S', isOnline: false),
    _Friend(id: '4', name: 'Taylor', initial: 'T', isOnline: false),
    _Friend(id: '5', name: 'Casey', initial: 'C', isOnline: true),
    _Friend(id: '6', name: 'Morgan', initial: 'M', isOnline: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Friends',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.eventName,
                            style: TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Friends list
                Text(
                  'Select friends to invite',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),

                // Online friends first
                ..._friends
                    .where((f) => f.isOnline)
                    .map((friend) => _buildFriendTile(friend)),

                if (_friends.any((f) => !f.isOnline)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._friends
                      .where((f) => !f.isOnline)
                      .map((friend) => _buildFriendTile(friend)),
                ],

                const SizedBox(height: 20),

                // Send button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedFriends.isNotEmpty
                        ? () => _sendInvites(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: AppColors.lightGrey,
                    ),
                    child: Text(
                      _selectedFriends.isEmpty
                          ? 'Select friends to invite'
                          : 'Send ${_selectedFriends.length} Invite${_selectedFriends.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Share link option
                Center(
                  child: TextButton.icon(
                    onPressed: () => _shareLink(context),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Or share invite link'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mediumGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildFriendTile(_Friend friend) {
    final isSelected = _selectedFriends.contains(friend.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (isSelected) {
            _selectedFriends.remove(friend.id);
          } else {
            _selectedFriends.add(friend.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withAlpha(51),
                  ),
                  child: Center(
                    child: Text(
                      friend.initial,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                if (friend.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _sendInvites(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    Get.snackbar(
      'Invites Sent!',
      '${_selectedFriends.length} friend${_selectedFriends.length > 1 ? 's' : ''} invited to ${widget.eventName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _shareLink(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Get.snackbar(
      'Link Copied!',
      'Share it with anyone',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryBlue,
      colorText: Colors.white,
      icon: const Icon(Icons.link, color: Colors.white),
    );
  }
}

class _Friend {
  final String id;
  final String name;
  final String initial;
  final bool isOnline;

  _Friend({
    required this.id,
    required this.name,
    required this.initial,
    required this.isOnline,
  });
}

/// Compact countdown widget for lists
class CompactEventCountdown extends StatefulWidget {
  final DateTime eventDate;

  const CompactEventCountdown({super.key, required this.eventDate});

  @override
  State<CompactEventCountdown> createState() => _CompactEventCountdownState();
}

class _CompactEventCountdownState extends State<CompactEventCountdown> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _timeRemaining = widget.eventDate.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining.inMinutes <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Text(
          'Now',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    String text;
    Color color;

    if (_timeRemaining.inDays > 0) {
      text = '${_timeRemaining.inDays}d';
      color = AppColors.mediumGrey;
    } else if (_timeRemaining.inHours > 0) {
      text = '${_timeRemaining.inHours}h';
      color = AppColors.friendlyOrange;
    } else {
      text = '${_timeRemaining.inMinutes}m';
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
