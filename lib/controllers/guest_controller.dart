import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/guest_model.dart';
import '../repositories/guest_repository.dart';

/// Controller for guest/bring-a-friend feature
class GuestController extends GetxController {
  final GuestRepository _repository = GuestRepository();

  // State
  final Rx<EventGuestSummary?> currentEventGuests = Rx<EventGuestSummary?>(null);
  final RxList<GuestModel> myGuests = <GuestModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isInviting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Invite form controllers
  final TextEditingController guestNameController = TextEditingController();
  final TextEditingController guestPhoneController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController personalMessageController = TextEditingController();

  // Invite options
  final RxBool sendSms = false.obs;
  final RxBool sendEmail = true.obs;

  @override
  void onClose() {
    guestNameController.dispose();
    guestPhoneController.dispose();
    guestEmailController.dispose();
    personalMessageController.dispose();
    super.onClose();
  }

  /// Load guests for an event
  Future<void> loadEventGuests(int eventId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getEventGuests(eventId: eventId);
      if (response.success && response.data != null) {
        currentEventGuests.value = response.data;
        myGuests.value = response.data!.guests
            .where((g) => g.invitedByUserId != null)
            .toList();
      } else {
        errorMessage.value = response.error ?? 'Failed to load guests';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load guests';
    } finally {
      isLoading.value = false;
    }
  }

  /// Invite a guest to an event
  Future<bool> inviteGuest({
    required int eventId,
  }) async {
    if (!_validateInviteForm()) return false;

    isInviting.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.inviteGuest(
        eventId: eventId,
        guestName: guestNameController.text.trim(),
        guestPhone: guestPhoneController.text.trim().isNotEmpty
            ? guestPhoneController.text.trim()
            : null,
        guestEmail: guestEmailController.text.trim().isNotEmpty
            ? guestEmailController.text.trim()
            : null,
        sendSms: sendSms.value,
        sendEmail: sendEmail.value,
        personalMessage: personalMessageController.text.trim().isNotEmpty
            ? personalMessageController.text.trim()
            : null,
      );

      if (response.success && response.data != null) {
        successMessage.value = 'Invitation sent to ${guestNameController.text.trim()}!';
        myGuests.add(response.data!);
        _updateGuestCount();
        _clearInviteForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to send invitation';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to send invitation. Please try again.';
      return false;
    } finally {
      isInviting.value = false;
    }
  }

  /// Cancel a guest invitation
  Future<bool> cancelInvitation(String guestId) async {
    try {
      final response = await _repository.cancelGuestInvite(guestId: guestId);

      if (response.success) {
        myGuests.removeWhere((g) => g.guestId == guestId);
        _updateGuestCount();
        successMessage.value = 'Invitation cancelled';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to cancel invitation';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to cancel invitation';
      return false;
    }
  }

  /// Resend invitation
  Future<bool> resendInvitation({
    required String guestId,
    bool sendSms = false,
    bool sendEmail = true,
  }) async {
    try {
      final response = await _repository.resendInvitation(
        guestId: guestId,
        sendSms: sendSms,
        sendEmail: sendEmail,
      );

      if (response.success) {
        successMessage.value = 'Invitation resent!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to resend invitation';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to resend invitation';
      return false;
    }
  }

  /// Check in a guest
  Future<bool> checkInGuest(String guestId) async {
    try {
      final response = await _repository.checkInGuest(guestId: guestId);

      if (response.success && response.data != null) {
        final index = myGuests.indexWhere((g) => g.guestId == guestId);
        if (index != -1) {
          myGuests[index] = response.data!;
        }
        successMessage.value = 'Guest checked in!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to check in guest';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to check in guest';
      return false;
    }
  }

  /// Update guest count in summary
  void _updateGuestCount() {
    if (currentEventGuests.value != null) {
      currentEventGuests.value = EventGuestSummary(
        eventId: currentEventGuests.value!.eventId,
        maxGuests: currentEventGuests.value!.maxGuests,
        totalInvited: myGuests.length,
        confirmed: myGuests.where((g) => g.isConfirmed).length,
        declined: myGuests.where((g) => g.status == GuestStatus.declined).length,
        pending: myGuests.where((g) => g.isPending).length,
        guests: myGuests,
      );
    }
  }

  /// Validate invite form
  bool _validateInviteForm() {
    if (guestNameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter the guest\'s name';
      return false;
    }

    final hasPhone = guestPhoneController.text.trim().isNotEmpty;
    final hasEmail = guestEmailController.text.trim().isNotEmpty;

    if (!hasPhone && !hasEmail) {
      errorMessage.value = 'Please enter a phone number or email';
      return false;
    }

    if (hasEmail && !GetUtils.isEmail(guestEmailController.text.trim())) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }

    // Check if we can invite more guests
    if (currentEventGuests.value != null &&
        !currentEventGuests.value!.canInviteMore) {
      errorMessage.value = 'Maximum number of guests reached';
      return false;
    }

    return true;
  }

  /// Clear invite form
  void _clearInviteForm() {
    guestNameController.clear();
    guestPhoneController.clear();
    guestEmailController.clear();
    personalMessageController.clear();
    sendSms.value = false;
    sendEmail.value = true;
  }

  /// Get available guest slots
  int get availableSlots => currentEventGuests.value?.availableSlots ?? 0;

  /// Check if can invite more guests
  bool get canInviteMore => currentEventGuests.value?.canInviteMore ?? true;

  /// Get confirmed guests count
  int get confirmedCount => myGuests.where((g) => g.isConfirmed).length;

  /// Get pending guests count
  int get pendingCount => myGuests.where((g) => g.isPending).length;

  /// Get guests by status
  List<GuestModel> getGuestsByStatus(GuestStatus status) {
    return myGuests.where((g) => g.status == status).toList();
  }
}
