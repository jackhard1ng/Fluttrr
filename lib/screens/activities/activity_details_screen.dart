import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/mates_controller.dart';
import '../../widgets/common_widgets.dart';

/// Activity details screen
class ActivityDetailsScreen extends StatefulWidget {
  final int activityId;

  const ActivityDetailsScreen({super.key, required this.activityId});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  void _loadActivity() {
    final controller = Get.find<ActivityController>();
    controller.loadActivityDetails(widget.activityId);
  }

  void _showShareOptions(BuildContext context, dynamic activity) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Send to friend option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add, color: AppColors.primaryBlue),
                ),
                title: const Text('Send to a Friend'),
                subtitle: const Text('Share with a connection in the app'),
                onTap: () {
                  Navigator.pop(context);
                  _showFriendPicker(context, activity);
                },
              ),

              const Divider(),

              // Share link option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyTeal.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.link, color: AppColors.friendlyTeal),
                ),
                title: const Text('Share Link'),
                subtitle: const Text('Copy link or share via other apps'),
                onTap: () {
                  Navigator.pop(context);
                  _shareExternally(activity);
                },
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showFriendPicker(BuildContext context, dynamic activity) {
    final matesController = Get.find<MatesController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send to Friend',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select a friend to share "${activity.displayName}"',
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: Obx(() {
                  final connections = matesController.matches;

                  if (connections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.mediumGrey,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'No connections yet',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Connect with people on the Mates tab to share activities!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mediumGrey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final friend = connections[index];
                      // Safely extract image URL with null-safe chain
                      final images = friend.matchedUser?.profile?.images;
                      final imageUrl = (images != null && images.isNotEmpty) ? images.first : null;
                      return ListTile(
                        leading: UserAvatar(
                          imageUrl: imageUrl,
                          size: 45,
                        ),
                        title: Text(friend.matchedUser?.userName ?? 'Friend'),
                        subtitle: Text(
                          'Tap to send activity',
                          style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _sendToFriend(friend, activity);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendToFriend(dynamic friend, dynamic activity) async {
    HapticFeedback.mediumImpact();

    // Get ChatController and send the activity share message
    final chatController = Get.find<ChatController>();
    final friendUserId = friend.matchedUser?.userId ?? friend.userId;
    final friendName = friend.matchedUser?.userName ?? 'your friend';

    if (friendUserId != null) {
      // Create a message about the activity
      final activityMessage = '''Check out this activity!

${activity.displayName}
${activity.location ?? 'Location TBD'}
${activity.dateTime != null ? DateFormat('EEEE, MMMM d at h:mm a').format(activity.dateTime!) : 'Date TBD'}

Want to join me?''';

      // Send the message via ChatController
      final success = await chatController.sendMessage(content: activityMessage);

      if (success) {
        Get.snackbar(
          'Activity Shared!',
          'Sent "${activity.displayName}" to $friendName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(AppSpacing.md),
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // If direct send failed, navigate to chat with the user
        Nav.toChatList();
        Get.snackbar(
          'Open Chat',
          'Navigate to $friendName to share the activity',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryBlue,
          colorText: Colors.white,
          margin: const EdgeInsets.all(AppSpacing.md),
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      Get.snackbar(
        'Activity Shared!',
        'Sent "${activity.displayName}" to $friendName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }

  void _shareExternally(dynamic activity) async {
    HapticFeedback.lightImpact();
    final text = '''
Check out this activity on Fluttrr!

${activity.displayName}
${activity.location ?? 'Location TBD'}
${activity.dateTime != null ? DateFormat('EEEE, MMMM d • h:mm a').format(activity.dateTime!) : 'Date TBD'}

Join me! 🎉
''';

    try {
      await Share.share(text.trim());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share activity',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Scaffold(
      body: Obx(() {
        final activity = activityController.selectedActivity.value;

        if (activityController.isLoading.value && activity == null) {
          return const LoadingIndicator();
        }

        if (activity == null) {
          return ErrorState(
            message: 'Failed to load activity',
            onRetry: _loadActivity,
          );
        }

        return CustomScrollView(
          slivers: [
            // Image header
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: activity.primaryImage != null
                    ? Image.network(
                        activity.primaryImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.event,
                          size: 80,
                          color: AppColors.grey,
                        ),
                      ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    activity.userSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  onPressed: () => activityController
                      .toggleSaveActivity(activity.activityId!),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _showShareOptions(context, activity),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event type badge
                    if (activity.eventType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          activity.eventType!,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Title
                    Text(
                      activity.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Details
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date & Time',
                      value: activity.dateTime != null
                          ? DateFormat('EEEE, MMMM d, y • h:mm a')
                              .format(activity.dateTime!)
                          : 'Date TBD',
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: activity.location ?? 'Location TBD',
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _DetailRow(
                      icon: Icons.people_outline,
                      title: 'Attendees',
                      value: activity.totalSlots != null
                          ? '${activity.attendeeCount} / ${activity.totalSlots} spots filled'
                          : '${activity.attendeeCount} people joined • Open event',
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      activity.description ?? 'No description provided.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),

                    // Attendees
                    Text(
                      'Attendees (${activity.attendees.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (activity.attendees.isEmpty)
                      Text(
                        'No attendees yet. Be the first to join!',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: activity.attendees.length,
                          itemBuilder: (context, index) {
                            final attendee = activity.attendees[index];
                            return GestureDetector(
                              onTap: () => Nav.toMateProfile(attendee.userId!),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: AppSpacing.md),
                                child: Column(
                                  children: [
                                    UserAvatar(
                                      imageUrl: attendee.profileImage,
                                      size: 50,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      attendee.name ?? 'User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl * 2),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Bottom button
      bottomNavigationBar: Obx(() {
        final activity = activityController.selectedActivity.value;
        if (activity == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: AppShadows.medium,
          ),
          child: SafeArea(
            child: activity.userJoined
                ? OutlinedButton(
                    onPressed: activityController.isJoining.value
                        ? null
                        : () => activityController
                            .leaveActivity(activity.activityId!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: activityController.isJoining.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Leave Activity'),
                  )
                : GradientButton(
                    text: activity.isFull ? 'Activity Full' : 'Join Activity',
                    isLoading: activityController.isJoining.value,
                    onPressed: activity.isFull
                        ? null
                        : () => activityController
                            .joinActivity(activity.activityId!),
                  ),
          ),
        );
      }),
    );
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withAlpha(26),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
