import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/routes.dart';
import '../../constants/utils.dart';
import '../../widgets/event_bookmark.dart';
import '../../widgets/advanced_ux.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  final List<_SavedEvent> _savedEvents = [
    _SavedEvent(
      id: '1',
      title: 'Weekend Hiking Trip',
      date: 'Sat, Dec 16',
      location: 'Mountain Trail Park',
      emoji: '🥾',
    ),
    _SavedEvent(
      id: '2',
      title: 'Coffee & Networking',
      date: 'Mon, Dec 18',
      location: 'The Roastery',
      emoji: '☕',
    ),
    _SavedEvent(
      id: '3',
      title: 'Art Gallery Opening',
      date: 'Fri, Dec 22',
      location: 'Downtown Gallery',
      emoji: '🎨',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          children: [
            const Text(
              'Saved Events',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Text(
                '${_savedEvents.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warmYellow,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _savedEvents.isEmpty
          ? EmptySavedEvents(
              onExplore: () => Get.back(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _savedEvents.length,
              itemBuilder: (context, index) {
                final event = _savedEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(event.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      final removed = event;
                      setState(() {
                        _savedEvents.removeAt(index);
                      });
                      UndoAction.show(
                        message: '${removed.title} removed',
                        onUndo: () {
                          setState(() {
                            _savedEvents.insert(index, removed);
                          });
                        },
                      );
                    },
                    child: _SavedEventCard(
                      event: event,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Nav.toDiscover();
                      },
                      onLongPress: () => _showEventActions(context, event, index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEventActions(BuildContext context, _SavedEvent event, int index) {
    // Check if context is still mounted before showing bottom sheet (#98)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.warmYellow.withAlpha(51),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(event.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          event.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.primaryBlue),
              title: const Text('View Event'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toDiscover();
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: AppColors.success),
              title: const Text('Add to Calendar'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  '📅 Added to Calendar',
                  '${event.title} on ${event.date}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.friendlyTeal),
              title: const Text('Share Event'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: '${event.title} - ${event.date} at ${event.location}'));
                Get.snackbar(
                  'Copied to Clipboard',
                  'Share the event with your friends!',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add, color: AppColors.friendlyPurple),
              title: const Text('Invite Friends'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toChatList();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.bookmark_remove, color: AppColors.error),
              title: Text('Remove from Saved', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                setState(() {
                  _savedEvents.removeAt(index);
                });
                showSavedToast(context, removed: true);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SavedEvent {
  final String id;
  final String title;
  final String date;
  final String location;
  final String emoji;

  _SavedEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.emoji,
  });
}

class _SavedEventCard extends StatelessWidget {
  final _SavedEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SavedEventCard({required this.event, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(event.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Text(
                        event.date,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.bookmark, color: AppColors.warmYellow),
          ],
        ),
      ),
    );
  }
}
