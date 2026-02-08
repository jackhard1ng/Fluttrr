import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/group_model.dart';
import '../models/activity_model.dart';
import '../repositories/group_repository.dart';

/// Controller for groups
class GroupController extends GetxController {
  final GroupRepository _repository = GroupRepository();

  // State
  final RxList<GroupModel> allGroups = <GroupModel>[].obs;
  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final RxList<GroupModel> suggestedGroups = <GroupModel>[].obs;
  final RxList<GroupModel> searchResults = <GroupModel>[].obs;
  final Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  final RxList<GroupMemberModel> groupMembers = <GroupMemberModel>[].obs;
  final RxList<ActivityModel> groupEvents = <ActivityModel>[].obs;
  final RxList<GroupJoinRequest> joinRequests = <GroupJoinRequest>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isJoining = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreGroups = true.obs;
  static const int pageSize = 20;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Form state
  final Rx<GroupType> selectedType = GroupType.interest.obs;
  final Rx<GroupPrivacy> selectedPrivacy = GroupPrivacy.public.obs;
  final RxList<String> selectedInterests = <String>[].obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxDouble selectedLatitude = 0.0.obs;
  final RxDouble selectedLongitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyGroups();
    loadSuggestedGroups();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  /// Load all groups
  Future<void> loadGroups({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreGroups.value = true;
      allGroups.clear();
    }

    if (!hasMoreGroups.value) return;

    isLoading.value = allGroups.isEmpty;
    isLoadingMore.value = allGroups.isNotEmpty;

    try {
      final response = await _repository.getGroups(
        page: currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          allGroups.value = response.data!;
        } else {
          allGroups.addAll(response.data!);
        }
        hasMoreGroups.value = response.data!.length >= pageSize;
        if (hasMoreGroups.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load my groups
  Future<void> loadMyGroups() async {
    try {
      final response = await _repository.getMyGroups();
      if (response.success && response.data != null) {
        myGroups.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading my groups: $e');
    }
  }

  /// Load suggested groups
  Future<void> loadSuggestedGroups() async {
    try {
      final response = await _repository.getSuggestedGroups();
      if (response.success && response.data != null) {
        suggestedGroups.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading suggested groups: $e');
    }
  }

  /// Load group details
  Future<void> loadGroupDetails(String groupId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getGroupDetails(groupId: groupId);
      if (response.success && response.data != null) {
        currentGroup.value = response.data;
      } else {
        errorMessage.value = response.error ?? 'Failed to load group';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load group';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load group members
  Future<void> loadGroupMembers(String groupId) async {
    try {
      final response = await _repository.getGroupMembers(groupId: groupId);
      if (response.success && response.data != null) {
        groupMembers.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading group members: $e');
    }
  }

  /// Load group events
  Future<void> loadGroupEvents(String groupId) async {
    try {
      final response = await _repository.getGroupEvents(groupId: groupId);
      if (response.success && response.data != null) {
        groupEvents.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading group events: $e');
    }
  }

  /// Search groups
  Future<void> searchGroups(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    try {
      final response = await _repository.searchGroups(query: query);
      if (response.success && response.data != null) {
        searchResults.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error searching groups: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a group
  Future<bool> createGroup() async {
    if (!_validateForm()) return false;

    isCreating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.createGroup(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        type: selectedType.value,
        privacy: selectedPrivacy.value,
        interests: selectedInterests.toList(),
        tags: selectedTags.toList(),
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        latitude: selectedLatitude.value != 0 ? selectedLatitude.value : null,
        longitude: selectedLongitude.value != 0 ? selectedLongitude.value : null,
      );

      if (response.success && response.data != null) {
        myGroups.add(response.data!);
        successMessage.value = 'Group created!';
        _clearForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to create group';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create group. Please try again.';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Update a group
  Future<bool> updateGroup(String groupId) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.updateGroup(
        groupId: groupId,
        name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        privacy: selectedPrivacy.value,
        interests: selectedInterests.isNotEmpty ? selectedInterests.toList() : null,
        tags: selectedTags.isNotEmpty ? selectedTags.toList() : null,
      );

      if (response.success && response.data != null) {
        final index = myGroups.indexWhere((g) => g.groupId == groupId);
        if (index != -1) {
          myGroups[index] = response.data!;
        }
        currentGroup.value = response.data;
        successMessage.value = 'Group updated!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to update group';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update group';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Delete a group
  Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await _repository.deleteGroup(groupId: groupId);

      if (response.success) {
        myGroups.removeWhere((g) => g.groupId == groupId);
        allGroups.removeWhere((g) => g.groupId == groupId);
        currentGroup.value = null;
        successMessage.value = 'Group deleted';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to delete group';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete group';
      return false;
    }
  }

  /// Join a group
  Future<bool> joinGroup(String groupId, {String? message}) async {
    isJoining.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.joinGroup(
        groupId: groupId,
        message: message,
      );

      if (response.success) {
        // Update group in lists
        void updateGroupMembership(RxList<GroupModel> list) {
          final index = list.indexWhere((g) => g.groupId == groupId);
          if (index != -1) {
            list[index] = list[index].copyWith(
              userIsMember: true,
              userRole: GroupMemberRole.member,
              memberCount: list[index].memberCount + 1,
            );
          }
        }

        updateGroupMembership(allGroups);
        updateGroupMembership(suggestedGroups);

        if (currentGroup.value?.groupId == groupId) {
          currentGroup.value = currentGroup.value?.copyWith(
            userIsMember: true,
            userRole: GroupMemberRole.member,
          );
        }

        // Reload my groups
        await loadMyGroups();

        successMessage.value = 'You\'ve joined the group!';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to join group';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to join group';
      return false;
    } finally {
      isJoining.value = false;
    }
  }

  /// Leave a group
  Future<bool> leaveGroup(String groupId) async {
    isJoining.value = true;

    try {
      final response = await _repository.leaveGroup(groupId: groupId);

      if (response.success) {
        myGroups.removeWhere((g) => g.groupId == groupId);

        if (currentGroup.value?.groupId == groupId) {
          currentGroup.value = currentGroup.value?.copyWith(
            userIsMember: false,
            userRole: null,
          );
        }

        successMessage.value = 'You\'ve left the group';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to leave group';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to leave group';
      return false;
    } finally {
      isJoining.value = false;
    }
  }

  /// Load join requests (admin only)
  Future<void> loadJoinRequests(String groupId) async {
    try {
      final response = await _repository.getJoinRequests(groupId: groupId);
      if (response.success && response.data != null) {
        joinRequests.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading join requests: $e');
    }
  }

  /// Respond to join request (admin only)
  Future<bool> respondToJoinRequest({
    required String requestId,
    required bool approve,
  }) async {
    try {
      final response = await _repository.respondToJoinRequest(
        requestId: requestId,
        approve: approve,
      );

      if (response.success) {
        joinRequests.removeWhere((r) => r.requestId == requestId);
        if (approve && response.data != null) {
          groupMembers.add(response.data!);
        }
        successMessage.value = approve ? 'Request approved' : 'Request declined';
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to respond to request';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to respond to request';
      return false;
    }
  }

  /// Get groups by interest
  Future<void> loadGroupsByInterest(String interest) async {
    isLoading.value = true;

    try {
      final response = await _repository.getGroupsByInterest(interest: interest);
      if (response.success && response.data != null) {
        searchResults.value = response.data!;
      }
    } catch (e) {
      debugPrint('Error loading groups by interest: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle interest selection
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  /// Set group for editing
  void setGroupForEditing(GroupModel group) {
    nameController.text = group.name ?? '';
    descriptionController.text = group.description ?? '';
    locationController.text = group.location ?? '';
    selectedType.value = group.type;
    selectedPrivacy.value = group.privacy;
    selectedInterests.value = group.interests.toList();
    selectedTags.value = group.tags.toList();
    selectedLatitude.value = group.latitude ?? 0.0;
    selectedLongitude.value = group.longitude ?? 0.0;
  }

  /// Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a group name';
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a description';
      return false;
    }
    if (selectedInterests.isEmpty) {
      errorMessage.value = 'Please select at least one interest';
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    selectedType.value = GroupType.interest;
    selectedPrivacy.value = GroupPrivacy.public;
    selectedInterests.clear();
    selectedTags.clear();
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
  }

  /// Get available interest categories
  Map<String, List<String>> get interestCategories => InterestCategory.categories;

  /// Get all interests
  List<String> get allInterests => InterestCategory.getAllInterests();
}
