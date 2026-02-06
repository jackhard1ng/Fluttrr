import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../widgets/event_bookmark.dart';

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
                      setState(() {
                        _savedEvents.removeAt(index);
                      });
                      showSavedToast(context, removed: true);
                    },
                    child: _SavedEventCard(
                      event: event,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Navigate to event details
                      },
                    ),
                  ),
                );
              },
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

  const _SavedEventCard({required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
