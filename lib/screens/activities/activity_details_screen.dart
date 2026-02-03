import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/activity_controller.dart';
import '../../widgets/common_widgets.dart';
import '../mates/mate_profile_screen.dart';

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
                  onPressed: () {
                    // Share activity
                  },
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
                          color: AppColors.primaryBlue.withOpacity(0.1),
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
                      value:
                          '${activity.attendeeCount} / ${activity.totalSlots ?? "∞"} spots filled',
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
                              onTap: () => Get.to(() =>
                                  MateProfileScreen(userId: attendee.userId!)),
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
            color: AppColors.primaryBlue.withOpacity(0.1),
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
