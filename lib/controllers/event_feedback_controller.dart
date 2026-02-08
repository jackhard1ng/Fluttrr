import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event_feedback_model.dart';
import '../repositories/event_feedback_repository.dart';

/// Controller for event feedback and ratings
class EventFeedbackController extends GetxController {
  final EventFeedbackRepository _repository = EventFeedbackRepository();

  // State
  final RxList<EventFeedbackModel> eventFeedback = <EventFeedbackModel>[].obs;
  final RxList<AttendeeRatingModel> attendeeRatings = <AttendeeRatingModel>[].obs;
  final RxList<PostEventSummaryModel> pendingFeedback = <PostEventSummaryModel>[].obs;
  final Rx<PostEventSummaryModel?> currentEventSummary = Rx<PostEventSummaryModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Form state
  final RxInt selectedRating = 0.obs;
  final TextEditingController commentController = TextEditingController();
  final RxList<String> selectedTags = <String>[].obs;

  // Currently rating attendee
  final Rx<int?> ratingAttendeeId = Rx<int?>(null);
  final RxString ratingAttendeeName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingFeedback();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  /// Load events pending feedback
  Future<void> loadPendingFeedback() async {
    try {
      final response = await _repository.getEventsPendingFeedback();
      if (response.success && response.data != null) {
        pendingFeedback.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading pending feedback: $e');
    }
  }

  /// Load feedback for an event
  Future<void> loadEventFeedback(int eventId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getEventFeedback(eventId: eventId);
      if (response.success && response.data != null) {
        eventFeedback.value = response.data!;
      } else {
        errorMessage.value = response.error ?? 'Failed to load feedback';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load feedback';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load post-event summary for host
  Future<void> loadPostEventSummary(int eventId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getPostEventSummary(eventId: eventId);
      if (response.success && response.data != null) {
        currentEventSummary.value = response.data;
      } else {
        errorMessage.value = response.error ?? 'Failed to load event summary';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load event summary';
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit event feedback
  Future<bool> submitEventFeedback({
    required int eventId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      errorMessage.value = 'Please select a rating';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.submitEventFeedback(
        eventId: eventId,
        rating: rating,
        comment: comment,
      );

      if (response.success) {
        successMessage.value = 'Thank you for your feedback!';
        _clearFeedbackForm();
        // Remove from pending feedback
        pendingFeedback.removeWhere((e) => e.eventId == eventId);
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to submit feedback';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit feedback. Please try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Rate an attendee
  Future<bool> rateAttendee({
    required int eventId,
    required int ratedUserId,
    required int rating,
    List<String> tags = const [],
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      errorMessage.value = 'Please select a rating';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.rateAttendee(
        eventId: eventId,
        ratedUserId: ratedUserId,
        rating: rating,
        tags: tags,
        comment: comment,
      );

      if (response.success && response.data != null) {
        successMessage.value = 'Rating submitted!';
        attendeeRatings.add(response.data!);
        _clearRatingForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to submit rating';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit rating. Please try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Load attendee ratings for an event
  Future<void> loadAttendeeRatings(int eventId) async {
    try {
      final response = await _repository.getAttendeeRatings(eventId: eventId);
      if (response.success && response.data != null) {
        attendeeRatings.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading attendee ratings: $e');
    }
  }

  /// Send thank you message (for hosts)
  Future<bool> sendThankYouMessage({
    required int eventId,
    String? customMessage,
    bool includeRatingRequest = true,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.sendThankYouMessage(
        eventId: eventId,
        customMessage: customMessage,
        includeRatingRequest: includeRatingRequest,
      );

      if (response.success) {
        successMessage.value = 'Thank you message sent to all attendees!';
        // Update summary
        if (currentEventSummary.value?.eventId == eventId) {
          currentEventSummary.value = PostEventSummaryModel(
            eventId: currentEventSummary.value?.eventId,
            eventName: currentEventSummary.value?.eventName,
            eventDate: currentEventSummary.value?.eventDate,
            totalAttendees: currentEventSummary.value?.totalAttendees ?? 0,
            checkedInCount: currentEventSummary.value?.checkedInCount ?? 0,
            averageRating: currentEventSummary.value?.averageRating ?? 0.0,
            totalRatings: currentEventSummary.value?.totalRatings ?? 0,
            feedback: currentEventSummary.value?.feedback ?? const [],
            thankYouSent: true,
          );
        }
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to send thank you message';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to send message. Please try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Set rating
  void setRating(int rating) {
    selectedRating.value = rating;
  }

  /// Toggle tag selection
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  /// Start rating an attendee
  void startRatingAttendee(int userId, String userName) {
    ratingAttendeeId.value = userId;
    ratingAttendeeName.value = userName;
    _clearRatingForm();
  }

  /// Cancel rating
  void cancelRating() {
    ratingAttendeeId.value = null;
    ratingAttendeeName.value = '';
    _clearRatingForm();
  }

  /// Clear feedback form
  void _clearFeedbackForm() {
    selectedRating.value = 0;
    commentController.clear();
  }

  /// Clear rating form
  void _clearRatingForm() {
    selectedRating.value = 0;
    selectedTags.clear();
    commentController.clear();
  }

  /// Get available rating tags
  List<String> get positiveTags => RatingTag.positive;
  List<String> get neutralTags => RatingTag.neutral;

  /// Check if user has pending feedback
  bool get hasPendingFeedback => pendingFeedback.isNotEmpty;

  /// Get pending feedback count
  int get pendingFeedbackCount => pendingFeedback.length;
}
