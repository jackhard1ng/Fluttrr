import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/event_model.dart';

class DiscoverController extends GetxController {
  // State
  final isLoading = false.obs;
  final events = <EventModel>[].obs;
  final savedEventIds = <String>{}.obs;
  final searchQuery = ''.obs;
  final selectedCategories = <String>[].obs;

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
    try {
      // In production, replace with actual API call
      events.value = _mockEvents;
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
    if (dateFilter.value != null) {
      result = result.where((e) =>
          e.date.year == dateFilter.value!.year &&
          e.date.month == dateFilter.value!.month &&
          e.date.day == dateFilter.value!.day
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
    // In real app would call API
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = events[index];
      if (status == RsvpStatus.going) {
        events[index] = event.copyWith(
          currentAttendees: event.currentAttendees + 1,
        );
      }
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
  }) async {
    isLoading.value = true;
    try {
      // In production, replace with actual API call
      final event = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    } finally {
      isLoading.value = false;
    }
  }

  // Mock data
  List<EventModel> get _mockEvents => [
    EventModel(
      id: '1',
      title: 'Friday Night Board Games',
      description: 'Join us for a fun night of board games!',
      hostId: 'user1',
      hostName: 'Alex',
      date: DateTime.now().add(const Duration(days: 2)),
      startTime: const TimeOfDay(hour: 19, minute: 0),
      endTime: const TimeOfDay(hour: 22, minute: 0),
      location: 'The Game Cafe',
      maxAttendees: 12,
      currentAttendees: 8,
      categories: ['games', 'social'],
      tags: ['board games', 'catan', 'beginners welcome'],
      vibe: 'chill',
      emoji: '🎮',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EventModel(
      id: '2',
      title: 'Weekend Hiking Adventure',
      description: 'Moderate difficulty trail with beautiful views.',
      hostId: 'user2',
      hostName: 'Jordan',
      date: DateTime.now().add(const Duration(days: 4)),
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 14, minute: 0),
      location: 'Mountain Trail Park',
      maxAttendees: 15,
      currentAttendees: 6,
      categories: ['outdoor', 'sports'],
      tags: ['hiking', 'nature', 'exercise'],
      vibe: 'energetic',
      emoji: '🥾',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EventModel(
      id: '3',
      title: 'Coffee & Networking',
      description: 'Casual networking for professionals.',
      hostId: 'user3',
      hostName: 'Taylor',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      location: 'The Roastery',
      maxAttendees: 20,
      currentAttendees: 12,
      categories: ['social', 'learning'],
      tags: ['networking', 'coffee', 'professionals'],
      vibe: 'casual',
      emoji: '☕',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
