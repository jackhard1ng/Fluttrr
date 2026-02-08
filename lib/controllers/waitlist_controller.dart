import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/waitlist_model.dart';
import '../repositories/waitlist_repository.dart';

/// Controller for event waitlists
class WaitlistController extends GetxController {
  final WaitlistRepository _repository = WaitlistRepository();

  // State
  final Rx<EventWaitlistSummary?> currentEventWaitlist = Rx<EventWaitlistSummary?>(null);
  final RxList<WaitlistEntryModel> myWaitlists = <WaitlistEntryModel>[].obs;
  final Rx<WaitlistEntryModel?> currentUserEntry = Rx<WaitlistEntryModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;
  final RxBool isResponding = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Join waitlist form
  final TextEditingController noteController = TextEditingController();
  final RxInt guestsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyWaitlists();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  /// Load waitlist for an event
  Future<void> loadEventWaitlist(int eventId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getEventWaitlist(eventId: eventId);
      if (response.success && response.data != null) {
        currentEventWaitlist.value = response.data;
        currentUserEntry.value = response.data!.userEntry;
      } else {
        errorMessage.value = response.error ?? 'Failed to load waitlist';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load waitlist';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all waitlists user is on
  Future<void> loadMyWaitlists() async {
    try {
      final response = await _repository.getUserWaitlists();
      if (response.success && response.data != null) {
        myWaitlists.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading my waitlists: $e');
    }
  }

  /// Join an event waitlist
  Future<bool> joinWaitlist(int eventId) async {
    isJoining.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.joinWaitlist(
        eventId: eventId,
        note: noteController.text.trim().isNotEmpty
            ? noteController.text.trim()
            : null,
        guestsCount: guestsCount.value > 0 ? guestsCount.value : null,
      );

      if (response.success && response.data != null) {
        currentUserEntry.value = response.data;
        myWaitlists.add(response.data!);
        successMessage.value = 'You\'re on the waitlist! Position: #${response.data!.position}';
        _clearForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to join waitlist';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to join waitlist. Please try again.';
      return false;
    } finally {
      isJoining.value = false;
    }
  }

  /// Leave a waitlist
  Future<bool> leaveWaitlist(int eventId) async {
    isJoining.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.leaveWaitlist(eventId: eventId);

      if (response.success) {
        currentUserEntry.value = null;
        myWaitlists.removeWhere((w) => w.eventId == eventId);
        successMessage.value = 'You\'ve left the waitlist';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to leave waitlist';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to leave waitlist';
      return false;
    } finally {
      isJoining.value = false;
    }
  }

  /// Respond to a waitlist offer
  Future<bool> respondToOffer({
    required String waitlistId,
    required bool accept,
  }) async {
    isResponding.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.respondToOffer(
        waitlistId: waitlistId,
        accept: accept,
      );

      if (response.success && response.data != null) {
        currentUserEntry.value = response.data;

        // Update in myWaitlists
        final index = myWaitlists.indexWhere((w) => w.waitlistId == waitlistId);
        if (index != -1) {
          myWaitlists[index] = response.data!;
        }

        if (accept) {
          successMessage.value = 'You\'re in! You\'ve been added to the event.';
        } else {
          successMessage.value = 'Offer declined. Your spot has been given to the next person.';
        }
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to respond to offer';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to respond. Please try again.';
      return false;
    } finally {
      isResponding.value = false;
    }
  }

  /// Get user's waitlist position
  Future<void> checkWaitlistPosition(int eventId) async {
    try {
      final response = await _repository.getWaitlistPosition(eventId: eventId);
      if (response.success && response.data != null) {
        currentUserEntry.value = response.data;
      }
    } catch (e) {
      debugPrint('Error checking waitlist position: $e');
    }
  }

  // Host functions

  /// Offer spot to next waitlisted user (host only)
  Future<bool> offerSpotToNextUser(int eventId) async {
    try {
      final response = await _repository.offerSpotToNextUser(eventId: eventId);

      if (response.success && response.data != null) {
        successMessage.value = 'Spot offered to ${response.data!.userName}';
        await loadEventWaitlist(eventId);
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to offer spot';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to offer spot';
      return false;
    }
  }

  /// Remove user from waitlist (host only)
  Future<bool> removeFromWaitlist(String waitlistId) async {
    try {
      final response = await _repository.removeFromWaitlist(waitlistId: waitlistId);

      if (response.success) {
        currentEventWaitlist.value = EventWaitlistSummary(
          eventId: currentEventWaitlist.value?.eventId,
          totalWaiting: (currentEventWaitlist.value?.totalWaiting ?? 1) - 1,
          spotsAvailable: currentEventWaitlist.value?.spotsAvailable ?? 0,
          pendingOffers: currentEventWaitlist.value?.pendingOffers ?? 0,
          waitlistEnabled: currentEventWaitlist.value?.waitlistEnabled ?? true,
          maxWaitlistSize: currentEventWaitlist.value?.maxWaitlistSize ?? 50,
          entries: currentEventWaitlist.value?.entries
              .where((e) => e.waitlistId != waitlistId)
              .toList() ?? [],
        );
        successMessage.value = 'User removed from waitlist';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to remove user';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to remove user';
      return false;
    }
  }

  /// Clear form
  void _clearForm() {
    noteController.clear();
    guestsCount.value = 0;
  }

  /// Increment guests count
  void incrementGuests() {
    guestsCount.value++;
  }

  /// Decrement guests count
  void decrementGuests() {
    if (guestsCount.value > 0) {
      guestsCount.value--;
    }
  }

  // Getters
  bool get isOnWaitlist => currentUserEntry.value != null;
  bool get hasOffer => currentUserEntry.value?.hasOffer ?? false;
  int get waitlistPosition => currentUserEntry.value?.position ?? 0;
  int get totalWaiting => currentEventWaitlist.value?.totalWaiting ?? 0;
  bool get canJoinWaitlist =>
      currentEventWaitlist.value?.waitlistEnabled == true &&
      !currentEventWaitlist.value!.isFull &&
      !isOnWaitlist;

  /// Get waitlist entries with pending offers
  List<WaitlistEntryModel> get pendingOffers =>
      myWaitlists.where((w) => w.hasOffer && !w.offerExpired).toList();

  /// Check if has pending offers
  bool get hasPendingOffers => pendingOffers.isNotEmpty;

  // Additional methods for screen compatibility

  /// Alias for loadEventWaitlist
  Future<void> loadWaitlist(int eventId) => loadEventWaitlist(eventId);

  /// Alias for currentUserEntry
  Rx<WaitlistEntryModel?> get userWaitlistEntry => currentUserEntry;

  /// Get waitlist entries from current event
  List<WaitlistEntryModel> get waitlistEntries =>
      currentEventWaitlist.value?.entries ?? [];

  /// Loading state for leaving
  final RxBool isLeaving = false.obs;

  /// Loading state for offering spots
  final RxBool isOffering = false.obs;

  /// Accept offer by event ID
  Future<bool> acceptOffer(int eventId) async {
    final entry = currentUserEntry.value;
    if (entry?.waitlistId == null) return false;
    return respondToOffer(waitlistId: entry!.waitlistId!, accept: true);
  }

  /// Decline offer by event ID
  Future<bool> declineOffer(int eventId) async {
    final entry = currentUserEntry.value;
    if (entry?.waitlistId == null) return false;
    return respondToOffer(waitlistId: entry!.waitlistId!, accept: false);
  }

  /// Alias for offerSpotToNextUser
  Future<bool> offerSpotToNext(int eventId) async {
    isOffering.value = true;
    try {
      return await offerSpotToNextUser(eventId);
    } finally {
      isOffering.value = false;
    }
  }
}
