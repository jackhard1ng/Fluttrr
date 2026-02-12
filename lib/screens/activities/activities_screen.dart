import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/activity_model.dart';
import '../../utils/debouncer.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/advanced_ux.dart';

/// Activities main screen with list and map view toggle
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  bool _isMapView = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final activityController = Get.find<ActivityController>();
    final profileController = Get.find<ProfileController>();
    final canCreateEvents = profileController.currentUser.value?.canCreateEvents ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GradientText(
                    text: 'Activities',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Map/List toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isMapView = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isMapView
                                      ? AppColors.primaryBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                  Icons.list,
                                  size: 20,
                                  color: !_isMapView
                                      ? Colors.white
                                      : AppColors.darkGrey,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isMapView = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: _isMapView
                                      ? AppColors.primaryBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                  Icons.map,
                                  size: 20,
                                  color: _isMapView
                                      ? Colors.white
                                      : AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _showSearchBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            const _FilterChips(),

            // Activities list or map
            Expanded(
              child: Obx(() {
                if (activityController.isLoading.value &&
                    activityController.allActivities.isEmpty) {
                  return const LoadingIndicator();
                }

                if (activityController.allActivities.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_busy,
                    title: 'No Activities Found',
                    subtitle: canCreateEvents
                        ? 'Be the first to create an activity!'
                        : 'Check back later for new activities!',
                    action: canCreateEvents
                        ? GradientButton(
                            text: 'Create Activity',
                            width: 180,
                            onPressed: () => Nav.toCreateActivity(),
                          )
                        : null,
                  );
                }

                if (_isMapView) {
                  return _ActivitiesMapView(
                    activities: activityController.allActivities,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => activityController.loadActivities(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: activityController.allActivities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == activityController.allActivities.length) {
                        return _buildLoadMore(activityController);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ActivityCard(
                          activity: activityController.allActivities[index],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Scroll to top FAB (only in list view)
          if (!_isMapView)
            Padding(
              padding: EdgeInsets.only(right: canCreateEvents ? 12 : 0),
              child: ScrollToTopFAB(scrollController: _scrollController),
            ),
          // Create activity FAB
          if (canCreateEvents)
            FloatingActionButton.extended(
              heroTag: 'create_activity',
              onPressed: () {
                HapticFeedback.mediumImpact();
                Nav.toCreateActivity();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadMore(ActivityController controller) {
    // Already inside parent Obx - no nested Obx needed
    if (!controller.hasMorePages.value) {
      return const SizedBox.shrink();
    }

    if (controller.isLoadingMore.value) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: LoadingIndicator(size: 30),
      );
    }

    return TextButton(
      onPressed: controller.loadMoreActivities,
      child: const Text('Load More'),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#65)
    if (!context.mounted) return;

    final activityController = Get.find<ActivityController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _FilterBottomSheet(controller: activityController),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#65)
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => const _SearchBottomSheet(),
    );
  }
}

/// Map view for activities
class _ActivitiesMapView extends StatefulWidget {
  final List<ActivityModel> activities;

  const _ActivitiesMapView({required this.activities});

  @override
  State<_ActivitiesMapView> createState() => _ActivitiesMapViewState();
}

class _ActivitiesMapViewState extends State<_ActivitiesMapView> {
  final MapController _mapController = MapController();
  ActivityModel? _selectedActivity;

  String _markerEmoji(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'sports': return '\u{26BD}';
      case 'music': return '\u{1F3B5}';
      case 'food': return '\u{1F355}';
      case 'art': return '\u{1F3A8}';
      case 'social': return '\u{1F389}';
      case 'gaming': return '\u{1F3AE}';
      case 'fitness': return '\u{1F4AA}';
      case 'travel': return '\u{2708}';
      case 'outdoor': return '\u{26F0}';
      case 'wellness': return '\u{1F9D8}';
      case 'learning': return '\u{1F4DA}';
      default: return '\u{1F4CD}';
    }
  }

  Color _markerColor(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'sports': return const Color(0xFF4CAF50);
      case 'music': return const Color(0xFF9C27B0);
      case 'food': return const Color(0xFFFF5722);
      case 'art': return const Color(0xFFE91E63);
      case 'social': return AppColors.primaryBlue;
      case 'gaming': return const Color(0xFF3F51B5);
      case 'fitness': return const Color(0xFFFF9800);
      case 'outdoor': return const Color(0xFF2E7D32);
      case 'wellness': return const Color(0xFF00BCD4);
      case 'learning': return const Color(0xFF795548);
      default: return AppColors.friendlyTeal;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get activities with valid locations
    final activitiesWithLocation = widget.activities
        .where((a) => a.hasLocation)
        .toList();

    // Default center (Kansas City)
    LatLng center = const LatLng(39.0997, -94.5786);

    if (activitiesWithLocation.isNotEmpty) {
      // Center on first activity
      center = LatLng(
        activitiesWithLocation.first.latitude!,
        activitiesWithLocation.first.longitude!,
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12.0,
            onTap: (_, __) => setState(() => _selectedActivity = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fluttrr.app',
            ),
            MarkerLayer(
              markers: activitiesWithLocation.map((activity) {
                final isSelected = _selectedActivity?.activityId == activity.activityId;
                return Marker(
                  point: LatLng(activity.latitude!, activity.longitude!),
                  width: isSelected ? 50 : 40,
                  height: isSelected ? 50 : 40,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedActivity = activity),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : _markerColor(activity.eventType),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Center(
                        child: Text(
                          _markerEmoji(activity.eventType),
                          style: TextStyle(fontSize: isSelected ? 18 : 14),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Selected activity card
        if (_selectedActivity != null)
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: _MapActivityCard(
              activity: _selectedActivity!,
              onClose: () => setState(() => _selectedActivity = null),
            ),
          ),

        // Empty state for no locations
        if (activitiesWithLocation.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 48,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No activities with locations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Activities will appear on the map once they have location data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Activity card shown on map when marker is selected
class _MapActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onClose;

  const _MapActivityCard({
    required this.activity,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Nav.toActivityDetails(activity.activityId!),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.large,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                image: activity.primaryImage != null
                    ? DecorationImage(
                        image: NetworkImage(activity.primaryImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.lightGrey,
              ),
              child: activity.primaryImage == null
                  ? const Icon(Icons.event, color: AppColors.grey)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (activity.eventType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            activity.eventType!,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (activity.isRecurring) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.friendlyTeal.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.repeat, size: 10, color: AppColors.friendlyTeal),
                              const SizedBox(width: 2),
                              Text(
                                activity.recurrenceLabel ?? 'Recurring',
                                style: const TextStyle(
                                  color: AppColors.friendlyTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activity.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          activity.location ?? 'Location TBD',
                          style: TextStyle(
                            color: AppColors.mediumGrey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.totalSlots != null
                            ? '${activity.attendeeCount}/${activity.totalSlots}'
                            : '${activity.attendeeCount} joined',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close button
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter chips row
class _FilterChips extends StatelessWidget {
  const _FilterChips();

  static const List<String> _eventTypes = [
    'All',
    'Social',
    'Food & Drinks',
    'Sports',
    'Nightlife',
    'Live Music',
    'Outdoor',
    'Fitness',
    'Networking',
  ];

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return SizedBox(
      height: 40,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _eventTypes.length,
            itemBuilder: (context, index) {
              final type = _eventTypes[index];
              final isSelected = activityController.filterEventType.value ==
                      (type == 'All' ? '' : type);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) {
                    activityController.filterEventType.value =
                        type == 'All' ? '' : type;
                    activityController.loadActivities(refresh: true);
                  },
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkGrey,
                  ),
                  checkmarkColor: Colors.white,
                ),
              );
            },
          )),
    );
  }
}

/// Activity card widget
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Nav.toActivityDetails(activity.activityId!),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                image: activity.primaryImage != null
                    ? DecorationImage(
                        image: NetworkImage(activity.primaryImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.lightGrey,
              ),
              child: Stack(
                children: [
                  if (activity.primaryImage == null)
                    const Center(
                      child: Icon(
                        Icons.event,
                        size: 50,
                        color: AppColors.grey,
                      ),
                    ),

                  // Event type badge
                  if (activity.eventType != null)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          activity.eventType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Recurring badge
                  if (activity.isRecurring)
                    Positioned(
                      top: AppSpacing.sm,
                      left: activity.eventType != null
                          ? null // positioned after event type badge
                          : AppSpacing.sm,
                      right: null,
                      bottom: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.friendlyTeal,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.repeat, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              activity.recurrenceLabel ?? 'Recurring',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Save button
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _SaveButton(activity: activity),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location ?? 'Location TBD',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.totalSlots != null
                                ? '${activity.attendeeCount}/${activity.totalSlots}'
                                : '${activity.attendeeCount} joined',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (activity.userJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'Joined',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Save button widget
class _SaveButton extends StatelessWidget {
  final ActivityModel activity;

  const _SaveButton({required this.activity});

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return GestureDetector(
      onTap: () => activityController.toggleSaveActivity(activity.activityId!),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.small,
        ),
        child: Icon(
          activity.userSaved ? Icons.bookmark : Icons.bookmark_border,
          color: activity.userSaved ? AppColors.primaryBlue : AppColors.grey,
          size: 20,
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatelessWidget {
  final ActivityController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Activities',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Distance slider
          Text(
            'Distance',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Obx(() => Slider(
                value: controller.filterRadius.value,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${controller.filterRadius.value.round()} mi',
                onChanged: (value) => controller.filterRadius.value = value,
              )),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GradientButton(
                  text: 'Apply',
                  onPressed: () {
                    controller.loadActivities(refresh: true);
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search bottom sheet
class _SearchBottomSheet extends StatefulWidget {
  const _SearchBottomSheet();

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 400));

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _searchController,
            hintText: 'Search activities...',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              // Debounce search to avoid excessive API calls
              _searchDebouncer.run(() {
                activityController.searchActivities(value);
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),

          Obx(() {
            if (activityController.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: activityController.searchResults.length,
                itemBuilder: (context, index) {
                  final activity = activityController.searchResults[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        image: activity.primaryImage != null
                            ? DecorationImage(
                                image: NetworkImage(activity.primaryImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    title: Text(activity.displayName),
                    subtitle: Text(activity.location ?? ''),
                    onTap: () {
                      Get.back();
                      Nav.toActivityDetails(activity.activityId!);
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
