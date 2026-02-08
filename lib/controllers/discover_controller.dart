import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../repositories/activity_repository.dart';

class DiscoverController extends GetxController {
  final ActivityRepository _activityRepository = ActivityRepository();

  // State
  final isLoading = false.obs;
  final events = <EventModel>[].obs;
  final savedEventIds = <String>{}.obs;
  final searchQuery = ''.obs;
  final selectedCategories = <String>[].obs;
  final errorMessage = ''.obs;

  // Filters
  final dateFilter = Rxn<DateTime>();
  final distanceFilter = 25.0.obs; // miles
  final showFullEvents = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _activityRepository.getActivities();
      final data = response.data;
      if (response.success && data != null) {
        events.value = data.map((activity) => EventModel(
          id: activity.activityId?.toString() ?? '',
          title: activity.name ?? '',
          description: activity.description,
          hostId: activity.userId?.toString() ?? '',
          hostName: activity.userName ?? 'Unknown',
          date: activity.dateTime ?? DateTime.now(),
          startTime: TimeOfDay.fromDateTime(activity.dateTime ?? DateTime.now()),
          endTime: null,
          location: activity.location ?? '',
          maxAttendees: activity.totalSlots ?? 20,
          currentAttendees: activity.attendeeCount ?? 0,
          categories: activity.eventType != null ? [activity.eventType!] : [],
          tags: [],
          vibe: null,
          createdAt: activity.createdAt ?? DateTime.now(),
        )).toList();
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      errorMessage.value = 'Failed to load events. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents();
  }

  void searchEvents(String query) {
    searchQuery.value = query;
  }

  List<EventModel> get filteredEvents {
    var result = events.toList();

    // Search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((e) =>
          e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.description?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
          e.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }

    // Category filter
    if (selectedCategories.isNotEmpty) {
      result = result.where((e) =>
          e.categories.any((c) => selectedCategories.contains(c))
      ).toList();
    }

    // Date filter
    final filterDate = dateFilter.value;
    if (filterDate != null) {
      result = result.where((e) =>
          e.date.year == filterDate.year &&
          e.date.month == filterDate.month &&
          e.date.day == filterDate.day
      ).toList();
    }

    // Full events filter
    if (!showFullEvents.value) {
      result = result.where((e) => !e.isFull).toList();
    }

    return result;
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategories.clear();
    dateFilter.value = null;
    showFullEvents.value = false;
  }

  // Saved events
  bool isEventSaved(String eventId) {
    return savedEventIds.contains(eventId);
  }

  void toggleSaveEvent(String eventId) {
    if (savedEventIds.contains(eventId)) {
      savedEventIds.remove(eventId);
    } else {
      savedEventIds.add(eventId);
    }
  }

  List<EventModel> get savedEvents {
    return events.where((e) => savedEventIds.contains(e.id)).toList();
  }

  // RSVP
  Future<void> rsvpToEvent(String eventId, RsvpStatus status) async {
    try {
      final activityId = int.tryParse(eventId);
      if (activityId == null) {
        debugPrint('Invalid event ID: $eventId');
        return;
      }

      if (status == RsvpStatus.going) {
        final response = await _activityRepository.joinActivity(activityId);
        if (response.success) {
          final index = events.indexWhere((e) => e.id == eventId);
          if (index != -1) {
            final event = events[index];
            events[index] = event.copyWith(
              currentAttendees: event.currentAttendees + 1,
            );
          }
        }
      } else if (status == RsvpStatus.notGoing) {
        final response = await _activityRepository.leaveActivity(activityId);
        if (response.success) {
          final index = events.indexWhere((e) => e.id == eventId);
          if (index != -1) {
            final event = events[index];
            events[index] = event.copyWith(
              currentAttendees: (event.currentAttendees - 1).clamp(0, event.maxAttendees),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating RSVP: $e');
    }
  }

  // Create event
  Future<EventModel?> createEvent({
    required String title,
    String? description,
    required DateTime date,
    required TimeOfDay startTime,
    TimeOfDay? endTime,
    required String location,
    int maxAttendees = 20,
    List<String> categories = const [],
    List<String> tags = const [],
    String? vibe,
    bool isPrivate = false,
    double latitude = 0,
    double longitude = 0,
  }) async {
    isLoading.value = true;
    try {
      // Combine date and time
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      final response = await _activityRepository.createActivity(
        name: title,
        description: description ?? '',
        location: location,
        latitude: latitude,
        longitude: longitude,
        dateTime: dateTime,
        eventType: categories.isNotEmpty ? categories.first : 'social',
        totalSlots: maxAttendees,
      );

      final activityData = response.data;
      if (response.success && activityData != null) {
        final event = EventModel(
          id: activityData.activityId?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          hostId: 'current_user',
          hostName: 'You',
          date: date,
          startTime: startTime,
          endTime: endTime,
          location: location,
          maxAttendees: maxAttendees,
          categories: categories,
          tags: tags,
          vibe: vibe,
          isPrivate: isPrivate,
          createdAt: DateTime.now(),
        );

        events.insert(0, event);
        return event;
      }

      return null;
    } catch (e) {
      debugPrint('Error creating event: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
