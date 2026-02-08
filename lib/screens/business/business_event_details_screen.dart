import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../models/business_model.dart';
import '../../widgets/common_widgets.dart';

/// Business event details screen
class BusinessEventDetailsScreen extends StatefulWidget {
  final BusinessEvent event;

  const BusinessEventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<BusinessEventDetailsScreen> createState() =>
      _BusinessEventDetailsScreenState();
}

class _BusinessEventDetailsScreenState
    extends State<BusinessEventDetailsScreen> {
  final _businessController = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    // Track event view
    _trackView();
  }

  void _trackView() {
    final eventId = widget.event.eventId ?? widget.event.id;
    if (eventId != null) {
      _businessController.recordEventView(eventId);
    }
  }

  Future<void> _openTicketUrl() async {
    final url = widget.event.ticketUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Track click
        final eventId = widget.event.eventId ?? widget.event.id;
        if (eventId != null) {
          _businessController.recordEventClick(eventId);
        }
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final eventId = widget.event.eventId ?? widget.event.id;
              if (eventId != null) {
                final success = await _businessController.deleteBusinessEvent(
                  eventId,
                );
                if (success) {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Event deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditComingSoon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_calendar,
                  size: 30,
                  color: AppColors.friendlyPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Event Editing',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The ability to edit events is coming soon! We\'re working hard to bring you this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    '🔔 You\'re on the list!',
                    'We\'ll notify you when event editing is ready',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyPurple,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Center(
                    child: Text(
                      'Notify Me When Ready',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: AppColors.mediumGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.event.image ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.lightGrey,
                      child: const Icon(
                        Icons.event,
                        size: 80,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179),
                        ],
                      ),
                    ),
                  ),
                  // Event type badge
                  Positioned(
                    top: 100,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: widget.event.eventType == 'Free'
                            ? AppColors.success
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        widget.event.eventType ?? 'Event',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      HapticFeedback.lightImpact();
                      _showEditComingSoon(context);
                      break;
                    case 'share':
                      final eventId = widget.event.eventId ?? widget.event.id;
                      final eventUrl = 'https://fluttrr.com/events/$eventId';
                      Clipboard.setData(ClipboardData(text: eventUrl));
                      HapticFeedback.lightImpact();
                      Get.snackbar(
                        'Link Copied',
                        'Event link copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                      break;
                    case 'report':
                      Nav.toReport(eventName: widget.event.name ?? 'Event');
                      break;
                    case 'help':
                      Nav.toHelp();
                      break;
                    case 'delete':
                      _showDeleteDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: AppSpacing.sm),
                        Text('Edit Event'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: AppSpacing.sm),
                        Text('Share Event'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, color: AppColors.friendlyOrange),
                        SizedBox(width: AppSpacing.sm),
                        Text('Report Event'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: AppColors.primaryBlue),
                        SizedBox(width: AppSpacing.sm),
                        Text('Get Help'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: AppSpacing.sm),
                        Text('Delete Event',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
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
                  // Event name
                  Text(
                    widget.event.name ?? 'Event Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Stats card
                  _buildStatsCard(),

                  const SizedBox(height: AppSpacing.lg),

                  // Details section
                  _buildSection(
                    'Event Details',
                    Column(
                      children: [
                        _buildDetailItem(
                          Icons.calendar_today,
                          'Start Date',
                          widget.event.startDate != null
                              ? DateFormat('EEEE, MMMM d, y • h:mm a')
                                  .format(widget.event.startDate!)
                              : 'Date TBD',
                        ),
                        _buildDetailItem(
                          Icons.event_available,
                          'End Date',
                          widget.event.endDate != null
                              ? DateFormat('EEEE, MMMM d, y • h:mm a')
                                  .format(widget.event.endDate!)
                              : 'Date TBD',
                        ),
                        _buildDetailItem(
                          Icons.location_on,
                          'Location',
                          widget.event.locationName ?? 'Location TBD',
                        ),
                        _buildDetailItem(
                          Icons.people,
                          'Max Attendees',
                          '${widget.event.maxAttendees ?? 'Unlimited'}',
                        ),
                        _buildDetailItem(
                          Icons.visibility,
                          'Privacy',
                          widget.event.privacy ?? 'Public',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Description section
                  _buildSection(
                    'About This Event',
                    Text(
                      widget.event.description ?? 'No description provided.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Attendees section
                  _buildSection(
                    'Attendees (${widget.event.attendeesCount ?? 0})',
                    SizedBox(
                      height: 60,
                      child: widget.event.attendeesCount != null &&
                              widget.event.attendeesCount! > 0
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.event.attendeesCount,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: AppSpacing.sm),
                                  child: UserAvatar(size: 50),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'No attendees yet',
                                style: TextStyle(color: AppColors.grey),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Ticket button
                  if (widget.event.ticketUrl != null &&
                      widget.event.ticketUrl!.isNotEmpty)
                    GradientButton(
                      text: 'Get Tickets',
                      onPressed: _openTicketUrl,
                      icon: Icons.confirmation_number,
                    ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryHorizontal,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${widget.event.attendeesCount ?? 0}',
            'Attendees',
            Icons.people,
          ),
          _buildStatDivider(),
          _buildStatItem(
            '${widget.event.views ?? 0}',
            'Views',
            Icons.visibility,
          ),
          _buildStatDivider(),
          _buildStatItem(
            '${widget.event.clicks ?? 0}',
            'Clicks',
            Icons.touch_app,
          ),
          _buildStatDivider(),
          _buildStatItem(
            '${widget.event.saves ?? 0}',
            'Saves',
            Icons.bookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(204),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withAlpha(77),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                  label,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
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
