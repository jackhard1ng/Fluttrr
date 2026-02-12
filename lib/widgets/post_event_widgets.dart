import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';

/// Post-event thank you card - shown after attending an event
class ThankYouCard extends StatelessWidget {
  final String eventName;
  final String hostName;
  final String? hostAvatar;
  final VoidCallback? onSendThanks;
  final VoidCallback? onDismiss;

  const ThankYouCard({
    super.key,
    required this.eventName,
    required this.hostName,
    this.hostAvatar,
    this.onSendThanks,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyOrange.withAlpha(26),
            AppColors.warmYellow.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.friendlyOrange.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.friendlyOrange.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: AppColors.friendlyOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You attended "$eventName"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.mediumGrey,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Host info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withAlpha(26),
                  image: hostAvatar != null && ApiEndpoints.isValidImageUrl(hostAvatar)
                      ? DecorationImage(
                          image: NetworkImage(ApiEndpoints.getImageUrl(hostAvatar)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hostAvatar == null
                    ? Center(
                        child: Text(
                          hostName[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hosted by $hostName',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Send a thank you note!',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick thank you buttons
          Row(
            children: [
              Expanded(
                child: _QuickThankButton(
                  emoji: '🙏',
                  label: 'Thanks!',
                  onTap: () => _sendQuickThanks(context, '🙏 Thanks for hosting!'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickThankButton(
                  emoji: '⭐',
                  label: 'Great event!',
                  onTap: () => _sendQuickThanks(context, '⭐ Great event!'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickThankButton(
                  emoji: '🎉',
                  label: 'Had fun!',
                  onTap: () => _sendQuickThanks(context, '🎉 Had so much fun!'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Custom message option
          GestureDetector(
            onTap: () => _showCustomMessageSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.friendlyOrange.withAlpha(77)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.friendlyOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Write a custom note',
                    style: TextStyle(
                      color: AppColors.friendlyOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuickThanks(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Thank You Sent!',
      '$hostName will appreciate it',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.friendlyOrange,
      colorText: Colors.white,
      icon: const Icon(Icons.favorite, color: Colors.white),
    );
    onDismiss?.call();
  }

  void _showCustomMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CustomThankYouSheet(
        hostName: hostName,
        onSend: (message) {
          Navigator.pop(context);
          _sendQuickThanks(context, message);
        },
      ),
    );
  }
}

class _QuickThankButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickThankButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomThankYouSheet extends StatefulWidget {
  final String hostName;
  final Function(String) onSend;

  const _CustomThankYouSheet({
    required this.hostName,
    required this.onSend,
  });

  @override
  State<_CustomThankYouSheet> createState() => _CustomThankYouSheetState();
}

class _CustomThankYouSheetState extends State<_CustomThankYouSheet> {
  final TextEditingController _controller = TextEditingController();

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
      ),
      child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send a note to ${widget.hostName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Thanks for hosting such a great event...',
                      hintStyle: TextStyle(color: AppColors.mediumGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.friendlyOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.text.isNotEmpty
                          ? () => widget.onSend(_controller.text)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.friendlyOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Send Thank You',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

/// Event memories - photo sharing after events
class EventMemoriesCard extends StatelessWidget {
  final String eventName;
  final String eventId;
  final List<String> photos;
  final int totalPhotos;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddPhotos;

  const EventMemoriesCard({
    super.key,
    required this.eventName,
    required this.eventId,
    this.photos = const [],
    this.totalPhotos = 0,
    this.onViewAll,
    this.onAddPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.friendlyPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Memories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        eventName,
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalPhotos > 0)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'See all $totalPhotos',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Photo grid or empty state
          if (photos.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: GestureDetector(
                onTap: onAddPhotos,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withAlpha(77),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.friendlyPurple.withAlpha(77),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 32,
                        color: AppColors.friendlyPurple,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share photos from the event',
                        style: TextStyle(
                          color: AppColors.friendlyPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Be the first to add memories!',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                itemCount: photos.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == photos.length) {
                    // Add more button
                    return GestureDetector(
                      onTap: onAddPhotos,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: AppColors.friendlyPurple.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.friendlyPurple.withAlpha(77),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: AppColors.friendlyPurple,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add more',
                              style: TextStyle(
                                color: AppColors.friendlyPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        ApiEndpoints.getImageUrl(photos[index]),
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 120,
                            color: AppColors.lightGrey,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact "Rate this event" prompt
class RateEventPrompt extends StatelessWidget {
  final String eventName;
  final VoidCallback? onRate;
  final VoidCallback? onDismiss;

  const RateEventPrompt({
    super.key,
    required this.eventName,
    this.onRate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warmYellow.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_outline,
            color: AppColors.warmYellow,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate your experience',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  eventName,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onRate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmYellow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Text(
                    'Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  color: AppColors.mediumGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
