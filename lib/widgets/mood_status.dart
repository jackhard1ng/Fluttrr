import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// User's current mood and availability status
enum MoodStatus {
  openToHangout,
  upForAnything,
  needsCompany,
  chillVibes,
  energetic,
  busyButFriendly,
  offline,
}

extension MoodStatusExtension on MoodStatus {
  String get label {
    switch (this) {
      case MoodStatus.openToHangout:
        return 'Open to Hangout';
      case MoodStatus.upForAnything:
        return 'Up for Anything!';
      case MoodStatus.needsCompany:
        return 'Looking for Company';
      case MoodStatus.chillVibes:
        return 'Chill Vibes Only';
      case MoodStatus.energetic:
        return 'Feeling Energetic';
      case MoodStatus.busyButFriendly:
        return 'Busy but Say Hi!';
      case MoodStatus.offline:
        return 'Taking a Break';
    }
  }

  String get emoji {
    switch (this) {
      case MoodStatus.openToHangout:
        return '👋';
      case MoodStatus.upForAnything:
        return '🎉';
      case MoodStatus.needsCompany:
        return '🤗';
      case MoodStatus.chillVibes:
        return '😌';
      case MoodStatus.energetic:
        return '⚡';
      case MoodStatus.busyButFriendly:
        return '📱';
      case MoodStatus.offline:
        return '💤';
    }
  }

  Color get color {
    switch (this) {
      case MoodStatus.openToHangout:
        return AppColors.success;
      case MoodStatus.upForAnything:
        return AppColors.friendlyPurple;
      case MoodStatus.needsCompany:
        return AppColors.friendlyOrange;
      case MoodStatus.chillVibes:
        return AppColors.friendlyTeal;
      case MoodStatus.energetic:
        return AppColors.warmYellow;
      case MoodStatus.busyButFriendly:
        return AppColors.primaryBlue;
      case MoodStatus.offline:
        return AppColors.mediumGrey;
    }
  }

  IconData get icon {
    switch (this) {
      case MoodStatus.openToHangout:
        return Icons.waving_hand;
      case MoodStatus.upForAnything:
        return Icons.celebration;
      case MoodStatus.needsCompany:
        return Icons.groups;
      case MoodStatus.chillVibes:
        return Icons.spa;
      case MoodStatus.energetic:
        return Icons.bolt;
      case MoodStatus.busyButFriendly:
        return Icons.schedule;
      case MoodStatus.offline:
        return Icons.dark_mode;
    }
  }
}

/// Compact mood status badge
class MoodBadge extends StatelessWidget {
  final MoodStatus status;
  final double size;
  final bool showLabel;
  final VoidCallback? onTap;

  const MoodBadge({
    super.key,
    required this.status,
    this.size = 24,
    this.showLabel = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == MoodStatus.offline && !showLabel) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 10 : 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: status.color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: status.color.withAlpha(77),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.emoji, style: TextStyle(fontSize: size * 0.7)),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: status.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mood status selector sheet
class MoodStatusSelector extends StatelessWidget {
  final MoodStatus currentStatus;
  final ValueChanged<MoodStatus> onStatusChanged;

  const MoodStatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  static void show(BuildContext context, {
    required MoodStatus currentStatus,
    required ValueChanged<MoodStatus> onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MoodStatusSelector(
        currentStatus: currentStatus,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

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
                Row(
                  children: [
                    Icon(Icons.mood, color: AppColors.friendlyPurple),
                    const SizedBox(width: 8),
                    Text(
                      'How are you feeling?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Let others know your current vibe',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                  ),
                ),

                const SizedBox(height: 20),

                // Status options
                ...MoodStatus.values.map((status) {
                  final isSelected = status == currentStatus;
                  return _StatusOption(
                    status: status,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onStatusChanged(status);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final MoodStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? status.color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? status.color : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji
            Text(
              status.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            // Label and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? status.color : AppColors.darkGrey,
                    ),
                  ),
                  Text(
                    _getStatusDescription(status),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Check mark
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(MoodStatus status) {
    switch (status) {
      case MoodStatus.openToHangout:
        return 'Ready to meet up and make new friends';
      case MoodStatus.upForAnything:
        return 'Spontaneous and ready for adventure';
      case MoodStatus.needsCompany:
        return 'Would love someone to chat with';
      case MoodStatus.chillVibes:
        return 'Low-key hangouts preferred';
      case MoodStatus.energetic:
        return 'Ready for active events';
      case MoodStatus.busyButFriendly:
        return 'Limited time but still social';
      case MoodStatus.offline:
        return 'Not visible to others right now';
    }
  }
}

/// Widget for setting availability time windows
class AvailabilityTimeWidget extends StatefulWidget {
  const AvailabilityTimeWidget({super.key});

  @override
  State<AvailabilityTimeWidget> createState() => _AvailabilityTimeWidgetState();
}

class _AvailabilityTimeWidgetState extends State<AvailabilityTimeWidget> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Mon-Fri by default

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Usual Availability',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Help others know when you\'re usually free',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),

          const SizedBox(height: 16),

          // Day selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _selectedDays.contains(dayNum);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(dayNum);
                    } else {
                      _selectedDays.add(dayNum);
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.lightGrey,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.mediumGrey,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Time range
          Row(
            children: [
              Expanded(
                child: _TimePickerButton(
                  label: 'From',
                  time: _startTime,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _startTime = time);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: AppColors.mediumGrey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerButton(
                  label: 'To',
                  time: _endTime,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime ?? const TimeOfDay(hour: 22, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _endTime = time);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time != null
                  ? time!.format(context)
                  : 'Select',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: time != null ? AppColors.darkGrey : AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick status update floating button
class QuickMoodButton extends StatelessWidget {
  final MoodStatus currentStatus;
  final ValueChanged<MoodStatus> onStatusChanged;

  const QuickMoodButton({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => MoodStatusSelector.show(
        context,
        currentStatus: currentStatus,
        onStatusChanged: onStatusChanged,
      ),
      backgroundColor: currentStatus.color,
      child: Text(
        currentStatus.emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
