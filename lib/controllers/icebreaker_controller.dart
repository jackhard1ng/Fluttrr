import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/icebreaker_model.dart';
import '../repositories/icebreaker_repository.dart';

/// Controller for icebreakers
class IcebreakerController extends GetxController {
  final IcebreakerRepository _repository = IcebreakerRepository();

  // State
  final RxList<IcebreakerModel> icebreakers = <IcebreakerModel>[].obs;
  final RxList<IcebreakerModel> popularIcebreakers = <IcebreakerModel>[].obs;
  final Rx<IcebreakerModel?> currentIcebreaker = Rx<IcebreakerModel?>(null);
  final Rx<EventIcebreakerSession?> currentSession = Rx<EventIcebreakerSession?>(null);
  final RxList<IcebreakerResponseModel> responses = <IcebreakerResponseModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isStartingSession = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Form state for custom icebreakers
  final TextEditingController questionController = TextEditingController();
  final RxList<String> customOptions = <String>[].obs;
  final Rx<IcebreakerType> selectedType = IcebreakerType.question.obs;
  final Rx<IcebreakerCategory> selectedCategory = IcebreakerCategory.gettingToKnow.obs;
  final RxInt timeLimit = 0.obs;

  // User response
  final TextEditingController answerController = TextEditingController();
  final RxInt selectedOptionIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadPopularIcebreakers();
  }

  @override
  void onClose() {
    questionController.dispose();
    answerController.dispose();
    super.onClose();
  }

  /// Load icebreakers
  Future<void> loadIcebreakers({
    IcebreakerType? type,
    IcebreakerCategory? category,
  }) async {
    isLoading.value = true;

    try {
      final response = await _repository.getIcebreakers(
        type: type,
        category: category,
      );
      final data = response.data;
      if (response.success && data != null) {
        icebreakers.value = data;
      }
    } catch (e) {
      debugPrint('Error loading icebreakers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load popular icebreakers
  Future<void> loadPopularIcebreakers() async {
    try {
      final response = await _repository.getPopularIcebreakers();
      final data = response.data;
      if (response.success && data != null) {
        popularIcebreakers.value = data;
      }
    } catch (e) {
      debugPrint('Error loading popular icebreakers: $e');
    }
  }

  /// Get random icebreaker
  Future<void> getRandomIcebreaker({
    IcebreakerType? type,
    IcebreakerCategory? category,
  }) async {
    isLoading.value = true;

    try {
      final response = await _repository.getRandomIcebreaker(
        type: type,
        category: category,
      );
      if (response.success && response.data != null) {
        currentIcebreaker.value = response.data;
      }
    } catch (e) {
      debugPrint('Error getting random icebreaker: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load session for an event
  Future<void> loadSession(int eventId) async {
    isLoading.value = true;

    try {
      final response = await _repository.getIcebreakerSession(eventId: eventId);
      final data = response.data;
      if (response.success && data != null) {
        currentSession.value = data;
        if (data.currentIcebreaker != null) {
          currentIcebreaker.value = data.currentIcebreaker;
        }
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Start an icebreaker session (host only)
  Future<bool> startSession({
    required int eventId,
    List<String>? icebreakerIds,
    IcebreakerCategory? category,
    int count = 5,
  }) async {
    isStartingSession.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.startIcebreakerSession(
        eventId: eventId,
        icebreakerIds: icebreakerIds,
        category: category,
        count: count,
      );

      final data = response.data;
      if (response.success && data != null) {
        currentSession.value = data;
        currentIcebreaker.value = data.currentIcebreaker;
        successMessage.value = 'Icebreaker session started!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to start session';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to start session';
      return false;
    } finally {
      isStartingSession.value = false;
    }
  }

  /// Submit response to current icebreaker
  Future<bool> submitResponse({
    required int eventId,
  }) async {
    if (currentIcebreaker.value == null) {
      errorMessage.value = 'No active icebreaker';
      return false;
    }

    final hasAnswer = answerController.text.trim().isNotEmpty;
    final hasOption = selectedOptionIndex.value >= 0;

    if (!hasAnswer && !hasOption) {
      errorMessage.value = 'Please provide an answer';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.submitResponse(
        icebreakerId: currentIcebreaker.value!.icebreakerId!,
        eventId: eventId,
        answer: hasAnswer ? answerController.text.trim() : null,
        selectedOptionIndex: hasOption ? selectedOptionIndex.value : null,
      );

      final data = response.data;
      if (response.success && data != null) {
        responses.add(data);
        _clearAnswerForm();
        successMessage.value = 'Response submitted!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to submit response';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit response';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Load responses for current icebreaker
  Future<void> loadResponses({
    required String icebreakerId,
    required int eventId,
  }) async {
    try {
      final response = await _repository.getResponses(
        icebreakerId: icebreakerId,
        eventId: eventId,
      );
      final data = response.data;
      if (response.success && data != null) {
        responses.value = data;
      }
    } catch (e) {
      debugPrint('Error loading responses: $e');
    }
  }

  /// Move to next icebreaker (host only)
  Future<bool> nextIcebreaker(int eventId) async {
    try {
      final response = await _repository.nextIcebreaker(eventId: eventId);

      final data = response.data;
      if (response.success && data != null) {
        currentSession.value = data;
        currentIcebreaker.value = data.currentIcebreaker;
        responses.clear();
        _clearAnswerForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'No more icebreakers';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to get next icebreaker';
      return false;
    }
  }

  /// Add reaction to a response
  Future<bool> addReaction({
    required String responseId,
    required String emoji,
  }) async {
    try {
      final response = await _repository.addReaction(
        responseId: responseId,
        emoji: emoji,
      );

      final data = response.data;
      if (response.success && data != null) {
        final index = responses.indexWhere((r) => r.responseId == responseId);
        if (index != -1) {
          responses[index] = data;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// End session (host only)
  Future<bool> endSession(int eventId) async {
    try {
      final response = await _repository.endSession(eventId: eventId);

      if (response.success) {
        currentSession.value = null;
        currentIcebreaker.value = null;
        responses.clear();
        successMessage.value = 'Icebreaker session ended';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to end session';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to end session';
      return false;
    }
  }

  /// Create custom icebreaker
  Future<bool> createCustomIcebreaker() async {
    if (questionController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a question';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.createCustomIcebreaker(
        question: questionController.text.trim(),
        type: selectedType.value,
        category: selectedCategory.value,
        options: customOptions.toList(),
        timeLimit: timeLimit.value > 0 ? timeLimit.value : null,
      );

      final data = response.data;
      if (response.success && data != null) {
        icebreakers.add(data);
        _clearCreateForm();
        successMessage.value = 'Icebreaker created!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create icebreaker';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create icebreaker';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Select an option
  void selectOption(int index) {
    selectedOptionIndex.value = index;
    answerController.clear();
  }

  /// Add custom option
  void addCustomOption(String option) {
    if (option.trim().isNotEmpty && customOptions.length < 4) {
      customOptions.add(option.trim());
    }
  }

  /// Remove custom option
  void removeCustomOption(int index) {
    if (index >= 0 && index < customOptions.length) {
      customOptions.removeAt(index);
    }
  }

  /// Get default icebreakers from library
  List<IcebreakerModel> getDefaultIcebreakers({int count = 5}) {
    return IcebreakerLibrary.getRandomIcebreakers(count: count);
  }

  /// Get icebreakers by category from library
  List<IcebreakerModel> getIcebreakersByCategory(IcebreakerCategory category, {int count = 5}) {
    return IcebreakerLibrary.getByCategory(category, count: count);
  }

  /// Clear answer form
  void _clearAnswerForm() {
    answerController.clear();
    selectedOptionIndex.value = -1;
  }

  /// Clear create form
  void _clearCreateForm() {
    questionController.clear();
    customOptions.clear();
    selectedType.value = IcebreakerType.question;
    selectedCategory.value = IcebreakerCategory.gettingToKnow;
    timeLimit.value = 0;
  }

  // Getters
  bool get hasActiveSession => currentSession.value?.isActive ?? false;
  bool get hasCurrentIcebreaker => currentIcebreaker.value != null;
  int get participantCount => currentSession.value?.participantCount ?? 0;
  int get responseCount => responses.length;

  /// Get available icebreaker types
  List<IcebreakerType> get availableTypes => IcebreakerType.values;

  /// Get available categories
  List<IcebreakerCategory> get availableCategories => IcebreakerCategory.values;
}
