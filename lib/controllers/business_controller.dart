import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/business_model.dart';
import '../repositories/business_repository.dart';

/// Business controller
class BusinessController extends GetxController {
  final BusinessRepository _businessRepository = BusinessRepository();

  // State
  final Rx<BusinessModel?> businessProfile = Rx<BusinessModel?>(null);
  final RxList<BusinessEvent> businessEvents = <BusinessEvent>[].obs;
  final RxList<BusinessEvent> myBusinessEvents = <BusinessEvent>[].obs;
  final RxList<BusinessEvent> savedEvents = <BusinessEvent>[].obs;
  final RxList<BusinessEvent> topEvents = <BusinessEvent>[].obs;
  final Rx<BusinessEvent?> selectedEvent = Rx<BusinessEvent?>(null);
  final Rx<BusinessAnalytics?> analytics = Rx<BusinessAnalytics?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool hasBusiness = false.obs;
  final RxString errorMessage = ''.obs;

  // Create business form controllers
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final TextEditingController businessDescriptionController = TextEditingController();
  final TextEditingController businessAddressController = TextEditingController();
  final TextEditingController businessWebsiteController = TextEditingController();

  final RxString selectedCategory = ''.obs;
  final RxDouble businessLatitude = 0.0.obs;
  final RxDouble businessLongitude = 0.0.obs;

  // Create event form controllers
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController eventSlotsController = TextEditingController();
  final TextEditingController eventPriceController = TextEditingController();

  final Rx<DateTime?> eventStartTime = Rx<DateTime?>(null);
  final Rx<DateTime?> eventEndTime = Rx<DateTime?>(null);
  final RxString eventType = ''.obs;
  final RxDouble eventLatitude = 0.0.obs;
  final RxDouble eventLongitude = 0.0.obs;
  final RxList<File> eventImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBusinessProfile();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessEmailController.dispose();
    businessPhoneController.dispose();
    businessDescriptionController.dispose();
    businessAddressController.dispose();
    businessWebsiteController.dispose();
    eventNameController.dispose();
    eventDescriptionController.dispose();
    eventLocationController.dispose();
    eventSlotsController.dispose();
    eventPriceController.dispose();
    super.onClose();
  }

  /// Load business profile
  Future<void> loadBusinessProfile() async {
    isLoading.value = true;

    try {
      final response = await _businessRepository.getBusinessProfile();

      if (response.success && response.data != null) {
        businessProfile.value = response.data;
        hasBusiness.value = true;
        _populateBusinessEditControllers();
        await _loadBusinessData();
      } else {
        hasBusiness.value = false;
      }
    } catch (e) {
      hasBusiness.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate business edit controllers
  void _populateBusinessEditControllers() {
    final business = businessProfile.value;
    if (business != null) {
      businessNameController.text = business.businessName ?? '';
      businessEmailController.text = business.email ?? '';
      businessPhoneController.text = business.phone ?? '';
      businessDescriptionController.text = business.description ?? '';
      businessAddressController.text = business.address ?? '';
      businessWebsiteController.text = business.website ?? '';
      selectedCategory.value = business.category ?? '';
      businessLatitude.value = business.latitude ?? 0;
      businessLongitude.value = business.longitude ?? 0;
    }
  }

  /// Load business data
  Future<void> _loadBusinessData() async {
    await Future.wait([
      loadMyBusinessEvents(),
      loadBusinessAnalytics(),
    ]);
  }

  /// Create business profile
  Future<bool> createBusinessProfile() async {
    if (!_validateBusinessForm()) return false;

    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _businessRepository.createBusinessProfile(
        businessName: businessNameController.text.trim(),
        email: businessEmailController.text.trim(),
        phone: businessPhoneController.text.trim(),
        description: businessDescriptionController.text.trim(),
        category: selectedCategory.value,
        address: businessAddressController.text.trim(),
        latitude: businessLatitude.value != 0 ? businessLatitude.value : null,
        longitude: businessLongitude.value != 0 ? businessLongitude.value : null,
        website: businessWebsiteController.text.trim().isNotEmpty
            ? businessWebsiteController.text.trim()
            : null,
      );

      isCreating.value = false;

      if (response.success) {
        businessProfile.value = response.data;
        hasBusiness.value = true;
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Failed to create business profile';
      return false;
    }
  }

  /// Update business profile
  Future<bool> updateBusinessProfile() async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _businessRepository.updateBusinessProfile(
        businessId: businessProfile.value?.businessId,
        businessName: businessNameController.text.trim().isNotEmpty
            ? businessNameController.text.trim()
            : null,
        email: businessEmailController.text.trim().isNotEmpty
            ? businessEmailController.text.trim()
            : null,
        phone: businessPhoneController.text.trim().isNotEmpty
            ? businessPhoneController.text.trim()
            : null,
        description: businessDescriptionController.text.trim().isNotEmpty
            ? businessDescriptionController.text.trim()
            : null,
        category: selectedCategory.value.isNotEmpty ? selectedCategory.value : null,
        address: businessAddressController.text.trim().isNotEmpty
            ? businessAddressController.text.trim()
            : null,
        latitude: businessLatitude.value != 0 ? businessLatitude.value : null,
        longitude: businessLongitude.value != 0 ? businessLongitude.value : null,
        website: businessWebsiteController.text.trim().isNotEmpty
            ? businessWebsiteController.text.trim()
            : null,
      );

      isCreating.value = false;

      if (response.success) {
        if (response.data != null) {
          businessProfile.value = response.data;
        }
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Failed to update business profile';
      return false;
    }
  }

  /// Validate business form
  bool _validateBusinessForm() {
    if (businessNameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter business name';
      return false;
    }
    if (businessEmailController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter email';
      return false;
    }
    if (businessPhoneController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter phone number';
      return false;
    }
    if (businessDescriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter description';
      return false;
    }
    if (selectedCategory.value.isEmpty) {
      errorMessage.value = 'Please select a category';
      return false;
    }
    if (businessAddressController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter address';
      return false;
    }
    return true;
  }

  /// Load business events
  Future<void> loadBusinessEvents() async {
    try {
      final response = await _businessRepository.getBusinessEvents();
      if (response.success && response.data != null) {
        businessEvents.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Load my business events
  Future<void> loadMyBusinessEvents() async {
    try {
      final response = await _businessRepository.getMyBusinessEvents();
      if (response.success && response.data != null) {
        myBusinessEvents.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Load saved events
  Future<void> loadSavedEvents() async {
    try {
      final response = await _businessRepository.getSavedEvents();
      if (response.success && response.data != null) {
        savedEvents.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Load top events
  Future<void> loadTopEvents() async {
    try {
      final response = await _businessRepository.getTopEvents();
      if (response.success && response.data != null) {
        topEvents.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get event details
  Future<void> loadEventDetails(int eventId) async {
    isLoading.value = true;

    try {
      final response = await _businessRepository.getBusinessEventDetails(eventId);
      if (response.success && response.data != null) {
        selectedEvent.value = response.data;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load event details';
    } finally {
      isLoading.value = false;
    }
  }

  /// Create business event
  Future<bool> createBusinessEvent() async {
    if (!_validateEventForm()) return false;

    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _businessRepository.createBusinessEvent(
        name: eventNameController.text.trim(),
        description: eventDescriptionController.text.trim(),
        location: eventLocationController.text.trim(),
        latitude: eventLatitude.value,
        longitude: eventLongitude.value,
        startTime: eventStartTime.value!,
        endTime: eventEndTime.value,
        eventType: eventType.value,
        totalSlots: int.parse(eventSlotsController.text),
        price: eventPriceController.text.isNotEmpty
            ? double.parse(eventPriceController.text)
            : null,
        images: eventImages.isNotEmpty ? eventImages : null,
      );

      isCreating.value = false;

      if (response.success) {
        _clearEventForm();
        await loadMyBusinessEvents();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Failed to create event';
      return false;
    }
  }

  /// Update business event
  Future<bool> updateBusinessEvent(int eventId) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _businessRepository.updateBusinessEvent(
        eventId: eventId,
        name: eventNameController.text.trim().isNotEmpty
            ? eventNameController.text.trim()
            : null,
        description: eventDescriptionController.text.trim().isNotEmpty
            ? eventDescriptionController.text.trim()
            : null,
        location: eventLocationController.text.trim().isNotEmpty
            ? eventLocationController.text.trim()
            : null,
        latitude: eventLatitude.value != 0 ? eventLatitude.value : null,
        longitude: eventLongitude.value != 0 ? eventLongitude.value : null,
        startTime: eventStartTime.value,
        endTime: eventEndTime.value,
        eventType: eventType.value.isNotEmpty ? eventType.value : null,
        totalSlots: eventSlotsController.text.isNotEmpty
            ? int.parse(eventSlotsController.text)
            : null,
        price: eventPriceController.text.isNotEmpty
            ? double.parse(eventPriceController.text)
            : null,
      );

      isCreating.value = false;

      if (response.success) {
        _clearEventForm();
        await loadMyBusinessEvents();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Failed to update event';
      return false;
    }
  }

  /// Validate event form
  bool _validateEventForm() {
    if (eventNameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter event name';
      return false;
    }
    if (eventDescriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter description';
      return false;
    }
    if (eventLocationController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter location';
      return false;
    }
    if (eventStartTime.value == null) {
      errorMessage.value = 'Please select start time';
      return false;
    }
    if (eventType.value.isEmpty) {
      errorMessage.value = 'Please select event type';
      return false;
    }
    if (eventSlotsController.text.isEmpty) {
      errorMessage.value = 'Please enter number of slots';
      return false;
    }
    return true;
  }

  /// Clear event form
  void _clearEventForm() {
    eventNameController.clear();
    eventDescriptionController.clear();
    eventLocationController.clear();
    eventSlotsController.clear();
    eventPriceController.clear();
    eventStartTime.value = null;
    eventEndTime.value = null;
    eventType.value = '';
    eventLatitude.value = 0;
    eventLongitude.value = 0;
    eventImages.clear();
  }

  /// Set event for editing
  void setEventForEditing(BusinessEvent event) {
    eventNameController.text = event.name ?? '';
    eventDescriptionController.text = event.description ?? '';
    eventLocationController.text = event.location ?? '';
    eventSlotsController.text = event.totalSlots?.toString() ?? '';
    eventPriceController.text = event.price?.toString() ?? '';
    eventStartTime.value = event.startTime;
    eventEndTime.value = event.endTime;
    eventType.value = event.eventType ?? '';
    eventLatitude.value = event.latitude ?? 0;
    eventLongitude.value = event.longitude ?? 0;
  }

  /// Join business event
  Future<bool> joinBusinessEvent(int eventId) async {
    try {
      final response = await _businessRepository.joinBusinessEvent(eventId);
      if (response.success) {
        _updateEventJoinStatus(eventId, true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Leave business event
  Future<bool> leaveBusinessEvent(int eventId) async {
    try {
      final response = await _businessRepository.leaveBusinessEvent(eventId);
      if (response.success) {
        _updateEventJoinStatus(eventId, false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Toggle save event
  Future<bool> toggleSaveEvent(int eventId) async {
    try {
      final response = await _businessRepository.toggleSaveBusinessEvent(eventId);
      if (response.success) {
        _updateEventSaveStatus(eventId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Follow/unfollow business
  Future<bool> toggleFollowBusiness(int businessId) async {
    try {
      final isFollowing = businessProfile.value?.isFollowing ?? false;
      final response = isFollowing
          ? await _businessRepository.unfollowBusiness(businessId)
          : await _businessRepository.followBusiness(businessId);

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Load business analytics
  Future<void> loadBusinessAnalytics() async {
    try {
      final response = await _businessRepository.getBusinessAnalytics();
      if (response.success && response.data != null) {
        analytics.value = response.data;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Record event click
  Future<void> recordEventClick(int eventId) async {
    await _businessRepository.recordEventClick(eventId);
  }

  /// Record event view
  Future<void> recordEventView(int eventId) async {
    await _businessRepository.recordEventView(eventId);
  }

  /// Create subscription
  Future<bool> createSubscription(String planId, String paymentMethodId) async {
    try {
      final response = await _businessRepository.createSubscription(
        planId: planId,
        paymentMethodId: paymentMethodId,
      );
      if (response.success) {
        await loadBusinessProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      final response = await _businessRepository.cancelSubscription();
      if (response.success) {
        await loadBusinessProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update event join status
  void _updateEventJoinStatus(int eventId, bool joined) {
    void updateList(RxList<BusinessEvent> list) {
      final index = list.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        final event = list[index];
        list[index] = BusinessEvent(
          eventId: event.eventId,
          businessId: event.businessId,
          name: event.name,
          description: event.description,
          location: event.location,
          latitude: event.latitude,
          longitude: event.longitude,
          startTime: event.startTime,
          endTime: event.endTime,
          eventType: event.eventType,
          images: event.images,
          totalSlots: event.totalSlots,
          remainingSlots: event.remainingSlots,
          price: event.price,
          currency: event.currency,
          attendeeCount: event.attendeeCount,
          viewCount: event.viewCount,
          clickCount: event.clickCount,
          userJoined: joined,
          userSaved: event.userSaved,
        );
      }
    }

    updateList(businessEvents);
    updateList(topEvents);

    if (selectedEvent.value?.eventId == eventId) {
      final event = selectedEvent.value!;
      selectedEvent.value = BusinessEvent(
        eventId: event.eventId,
        businessId: event.businessId,
        name: event.name,
        description: event.description,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        startTime: event.startTime,
        endTime: event.endTime,
        eventType: event.eventType,
        images: event.images,
        totalSlots: event.totalSlots,
        remainingSlots: event.remainingSlots,
        price: event.price,
        currency: event.currency,
        attendeeCount: event.attendeeCount,
        viewCount: event.viewCount,
        clickCount: event.clickCount,
        userJoined: joined,
        userSaved: event.userSaved,
      );
    }
  }

  /// Update event save status
  void _updateEventSaveStatus(int eventId) {
    void updateList(RxList<BusinessEvent> list) {
      final index = list.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        final event = list[index];
        list[index] = BusinessEvent(
          eventId: event.eventId,
          businessId: event.businessId,
          name: event.name,
          description: event.description,
          location: event.location,
          latitude: event.latitude,
          longitude: event.longitude,
          startTime: event.startTime,
          endTime: event.endTime,
          eventType: event.eventType,
          images: event.images,
          totalSlots: event.totalSlots,
          remainingSlots: event.remainingSlots,
          price: event.price,
          currency: event.currency,
          attendeeCount: event.attendeeCount,
          viewCount: event.viewCount,
          clickCount: event.clickCount,
          userJoined: event.userJoined,
          userSaved: !event.userSaved,
        );
      }
    }

    updateList(businessEvents);
    updateList(topEvents);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadBusinessProfile();
  }
}
