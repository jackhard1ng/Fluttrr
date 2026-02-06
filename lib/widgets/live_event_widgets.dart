import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Live event indicator - shows when an event is happening now
class LiveEventBadge extends StatefulWidget {
  final bool isLive;
  final int? currentAttendees;
  final VoidCallback? onTap;

  const LiveEventBadge({
    super.key,
    this.isLive = false,
    this.currentAttendees,
    this.onTap,
  });

  @override
  State<LiveEventBadge> createState() => _LiveEventBadgeState();
}

class _LiveEventBadgeState extends State<LiveEventBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isLive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppRadius.circular),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withAlpha((77 * _controller.value).round()),
                  blurRadius: 8 * _controller.value,
                  spreadRadius: 2 * _controller.value,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                if (widget.currentAttendees != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 12,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.currentAttendees} there',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Event vibe indicator - how's the atmosphere?
class EventVibeIndicator extends StatelessWidget {
  final EventVibe vibe;
  final int vibeCount;
  final VoidCallback? onTap;

  const EventVibeIndicator({
    super.key,
    required this.vibe,
    this.vibeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: vibe.color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(color: vibe.color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vibe.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              vibe.label,
              style: TextStyle(
                color: vibe.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (vibeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: vibe.color.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$vibeCount',
                  style: TextStyle(
                    color: vibe.color,
                    fontSize: 11,
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

enum EventVibe {
  amazing('Amazing!', '🔥', AppColors.error),
  great('Great vibes', '✨', AppColors.friendlyOrange),
  chill('Chill', '😌', AppColors.friendlyTeal),
  fun('Super fun', '🎉', AppColors.friendlyPurple),
  friendly('Very friendly', '💜', AppColors.primaryBlue);

  final String label;
  final String emoji;
  final Color color;

  const EventVibe(this.label, this.emoji, this.color);
}

/// Vibe check sheet - let attendees share how it's going
class VibeCheckSheet extends StatelessWidget {
  final String eventName;
  final Function(EventVibe) onVibeSelected;

  const VibeCheckSheet({
    super.key,
    required this.eventName,
    required this.onVibeSelected,
  });

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
              children: [
                Text(
                  'How\'s the vibe?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  eventName,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                  ),
                ),

                const SizedBox(height: 24),

                // Vibe options
                ...EventVibe.values.map((vibe) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VibeOption(
                    vibe: vibe,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      onVibeSelected(vibe);
                    },
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _VibeOption extends StatelessWidget {
  final EventVibe vibe;
  final VoidCallback onTap;

  const _VibeOption({required this.vibe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: vibe.color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: vibe.color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Text(vibe.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              vibe.label,
              style: TextStyle(
                color: vibe.color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: vibe.color),
          ],
        ),
      ),
    );
  }
}

/// Live event card with vibe and check-in
class LiveEventCard extends StatelessWidget {
  final String eventName;
  final String? eventLocation;
  final int currentAttendees;
  final EventVibe? currentVibe;
  final int vibeCount;
  final bool userCheckedIn;
  final VoidCallback? onCheckIn;
  final VoidCallback? onShareVibe;

  const LiveEventCard({
    super.key,
    required this.eventName,
    this.eventLocation,
    this.currentAttendees = 0,
    this.currentVibe,
    this.vibeCount = 0,
    this.userCheckedIn = false,
    this.onCheckIn,
    this.onShareVibe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.error, AppColors.friendlyOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const LiveEventBadge(isLive: true),
                    const Spacer(),
                    if (currentAttendees > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$currentAttendees there now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Event name
                Text(
                  eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                if (eventLocation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eventLocation!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],

                // Current vibe
                if (currentVibe != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Text(
                          currentVibe!.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Vibe',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                currentVibe!.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            '$vibeCount votes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                // Check in button
                Expanded(
                  child: GestureDetector(
                    onTap: onCheckIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            userCheckedIn
                                ? Icons.check_circle
                                : Icons.location_on_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userCheckedIn ? 'Checked In' : 'Check In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white24,
                ),

                // Share vibe button
                Expanded(
                  child: GestureDetector(
                    onTap: onShareVibe,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✨', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Share Vibe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick check-in button for event details
class QuickCheckInButton extends StatelessWidget {
  final bool isCheckedIn;
  final VoidCallback? onTap;

  const QuickCheckInButton({
    super.key,
    this.isCheckedIn = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isCheckedIn
              ? null
              : const LinearGradient(
                  colors: [AppColors.success, AppColors.friendlyTeal],
                ),
          color: isCheckedIn ? AppColors.success.withAlpha(26) : null,
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: isCheckedIn
              ? Border.all(color: AppColors.success)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCheckedIn ? Icons.check_circle : Icons.location_on,
              color: isCheckedIn ? AppColors.success : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isCheckedIn ? "I'm Here!" : 'Check In',
              style: TextStyle(
                color: isCheckedIn ? AppColors.success : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event pulse - shows real-time activity
class EventPulse extends StatelessWidget {
  final int recentJoins;
  final int recentVibes;
  final int recentPhotos;

  const EventPulse({
    super.key,
    this.recentJoins = 0,
    this.recentVibes = 0,
    this.recentPhotos = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivity = recentJoins > 0 || recentVibes > 0 || recentPhotos > 0;
    if (!hasActivity) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt,
            size: 16,
            color: AppColors.friendlyPurple,
          ),
          const SizedBox(width: 8),
          Text(
            _buildActivityText(),
            style: TextStyle(
              color: AppColors.friendlyPurple,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _buildActivityText() {
    final parts = <String>[];
    if (recentJoins > 0) parts.add('$recentJoins joined');
    if (recentVibes > 0) parts.add('$recentVibes vibes');
    if (recentPhotos > 0) parts.add('$recentPhotos photos');
    return '${parts.join(' • ')} in last hour';
  }
}
