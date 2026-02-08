import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../constants/api_endpoints.dart';

/// Screen for businesses to manage their event photo gallery
class EventPhotosScreen extends StatefulWidget {
  const EventPhotosScreen({super.key});

  @override
  State<EventPhotosScreen> createState() => _EventPhotosScreenState();
}

class _EventPhotosScreenState extends State<EventPhotosScreen> {
  String? _selectedEvent;
  final List<String> _selectedPhotos = [];
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedPhotos.length} selected'
            : 'Event Photos'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedPhotos.clear();
                  _isSelectionMode = false;
                });
              },
              icon: const Icon(Icons.close),
            ),
            IconButton(
              onPressed: _selectedPhotos.isNotEmpty ? _deleteSelectedPhotos : null,
              icon: Icon(
                Icons.delete_outline,
                color: _selectedPhotos.isNotEmpty ? AppColors.error : AppColors.lightGrey,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _uploadPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Event filter
          _EventFilterBar(
            selectedEvent: _selectedEvent,
            onEventSelected: (event) => setState(() => _selectedEvent = event),
          ),

          // Stats row
          const _PhotoStatsRow(),

          // Photo grid
          Expanded(
            child: _PhotoGrid(
              selectedEvent: _selectedEvent,
              selectedPhotos: _selectedPhotos,
              isSelectionMode: _isSelectionMode,
              onPhotoTap: _onPhotoTap,
              onPhotoLongPress: _onPhotoLongPress,
            ),
          ),
        ],
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _uploadPhotos,
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photos'),
            )
          : null,
    );
  }

  void _onPhotoTap(String photoId) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedPhotos.contains(photoId)) {
          _selectedPhotos.remove(photoId);
          if (_selectedPhotos.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedPhotos.add(photoId);
        }
      });
    } else {
      // View photo fullscreen
      _showPhotoViewer(photoId);
    }
  }

  void _onPhotoLongPress(String photoId) {
    setState(() {
      _isSelectionMode = true;
      if (!_selectedPhotos.contains(photoId)) {
        _selectedPhotos.add(photoId);
      }
    });
  }

  void _uploadPhotos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _UploadPhotosSheet(
        onUploadComplete: () {
          Navigator.pop(context);
          Get.snackbar(
            'Photos Uploaded',
            'Your photos have been added to the gallery',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _deleteSelectedPhotos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos?'),
        content: Text(
          'Are you sure you want to delete ${_selectedPhotos.length} photo${_selectedPhotos.length > 1 ? 's' : ''}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedPhotos.clear();
                _isSelectionMode = false;
              });
              Get.snackbar(
                'Photos Deleted',
                'Selected photos have been removed',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPhotoViewer(String photoId) {
    // Navigate to full-screen photo viewer
    Get.to(() => _PhotoViewerScreen(photoId: photoId));
  }
}

class _EventFilterBar extends StatelessWidget {
  final String? selectedEvent;
  final ValueChanged<String?> onEventSelected;

  const _EventFilterBar({
    required this.selectedEvent,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final events = [
      null, // All events
      'Board Game Night',
      'Coffee & Conversations',
      'Hiking Meetup',
      'Photography Walk',
    ];

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isSelected = selectedEvent == event;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(event ?? 'All Events'),
              selected: isSelected,
              onSelected: (_) => onEventSelected(event),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhotoStatsRow extends StatelessWidget {
  const _PhotoStatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.photo_library,
            value: '47',
            label: 'Total Photos',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatItem(
            icon: Icons.event,
            value: '8',
            label: 'Events',
            color: AppColors.friendlyPurple,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatItem(
            icon: Icons.visibility,
            value: '1.2k',
            label: 'Views',
            color: AppColors.friendlyTeal,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final String? selectedEvent;
  final List<String> selectedPhotos;
  final bool isSelectionMode;
  final ValueChanged<String> onPhotoTap;
  final ValueChanged<String> onPhotoLongPress;

  const _PhotoGrid({
    required this.selectedEvent,
    required this.selectedPhotos,
    required this.isSelectionMode,
    required this.onPhotoTap,
    required this.onPhotoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Mock photo data grouped by event
    final photoGroups = [
      _PhotoGroup(
        eventName: 'Board Game Night',
        date: DateTime.now().subtract(const Duration(days: 3)),
        photos: ['photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5', 'photo_6'],
      ),
      _PhotoGroup(
        eventName: 'Coffee & Conversations',
        date: DateTime.now().subtract(const Duration(days: 10)),
        photos: ['photo_7', 'photo_8', 'photo_9', 'photo_10'],
      ),
      _PhotoGroup(
        eventName: 'Hiking Meetup',
        date: DateTime.now().subtract(const Duration(days: 17)),
        photos: ['photo_11', 'photo_12', 'photo_13', 'photo_14', 'photo_15'],
      ),
    ];

    // Filter by selected event
    final filteredGroups = selectedEvent == null
        ? photoGroups
        : photoGroups.where((g) => g.eventName == selectedEvent).toList();

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No photos yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos from your events to showcase\nyour vibe to potential attendees',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _PhotoGroupSection(
          group: group,
          selectedPhotos: selectedPhotos,
          isSelectionMode: isSelectionMode,
          onPhotoTap: onPhotoTap,
          onPhotoLongPress: onPhotoLongPress,
        );
      },
    );
  }
}

class _PhotoGroup {
  final String eventName;
  final DateTime date;
  final List<String> photos;

  _PhotoGroup({
    required this.eventName,
    required this.date,
    required this.photos,
  });
}

class _PhotoGroupSection extends StatelessWidget {
  final _PhotoGroup group;
  final List<String> selectedPhotos;
  final bool isSelectionMode;
  final ValueChanged<String> onPhotoTap;
  final ValueChanged<String> onPhotoLongPress;

  const _PhotoGroupSection({
    required this.group,
    required this.selectedPhotos,
    required this.isSelectionMode,
    required this.onPhotoTap,
    required this.onPhotoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.eventName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(group.date),
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${group.photos.length} photos',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: group.photos.length,
          itemBuilder: (context, index) {
            final photoId = group.photos[index];
            final isSelected = selectedPhotos.contains(photoId);

            return GestureDetector(
              onTap: () => onPhotoTap(photoId),
              onLongPress: () => onPhotoLongPress(photoId),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo placeholder with gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getEventColor(group.eventName).withAlpha(77),
                          _getEventColor(group.eventName).withAlpha(179),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getEventIcon(group.eventName),
                        color: Colors.white.withAlpha(128),
                        size: 32,
                      ),
                    ),
                  ),

                  // Selection overlay
                  if (isSelectionMode)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? AppColors.primaryBlue.withAlpha(128)
                            : Colors.black.withAlpha(51),
                      ),
                    ),

                  // Selection checkbox
                  if (isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primaryBlue : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getEventColor(String eventName) {
    final colors = {
      'Board Game Night': AppColors.friendlyPurple,
      'Coffee & Conversations': AppColors.friendlyOrange,
      'Hiking Meetup': AppColors.friendlyTeal,
      'Photography Walk': AppColors.primaryBlue,
    };
    return colors[eventName] ?? AppColors.primaryBlue;
  }

  IconData _getEventIcon(String eventName) {
    final icons = {
      'Board Game Night': Icons.casino,
      'Coffee & Conversations': Icons.coffee,
      'Hiking Meetup': Icons.terrain,
      'Photography Walk': Icons.camera_alt,
    };
    return icons[eventName] ?? Icons.event;
  }
}

class _UploadPhotosSheet extends StatefulWidget {
  final VoidCallback onUploadComplete;

  const _UploadPhotosSheet({required this.onUploadComplete});

  @override
  State<_UploadPhotosSheet> createState() => _UploadPhotosSheetState();
}

class _UploadPhotosSheetState extends State<_UploadPhotosSheet> {
  String? _selectedEvent;
  int _photoCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Event Photos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Show potential attendees the vibe of your events',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Event selector
                Text(
                  'Select Event',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedEvent,
                    hint: const Text('Choose an event...'),
                    underline: const SizedBox(),
                    items: [
                      'Board Game Night - Jan 15',
                      'Coffee & Conversations - Jan 10',
                      'Hiking Meetup - Jan 5',
                    ].map((event) {
                      return DropdownMenuItem(
                        value: event,
                        child: Text(event),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEvent = value);
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Photo picker area
                GestureDetector(
                  onTap: () {
                    // Simulate photo selection
                    setState(() => _photoCount = 4);
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.primaryBlue.withAlpha(77),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: _photoCount > 0
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 48,
                                  color: AppColors.success,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_photoCount photos selected',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _photoCount = 0);
                                  },
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select photos',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose up to 10 photos',
                                style: TextStyle(
                                  color: AppColors.mediumGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Upload button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedEvent != null && _photoCount > 0)
                        ? widget.onUploadComplete
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      disabledBackgroundColor: AppColors.lightGrey,
                    ),
                    child: const Text('Upload Photos'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

/// Full-screen photo viewer
class _PhotoViewerScreen extends StatelessWidget {
  final String photoId;

  const _PhotoViewerScreen({required this.photoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSharePhotoOptions(context, photoId);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              // Delete photo
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Photo?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Get.snackbar(
                          'Photo Deleted',
                          'The photo has been removed',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.friendlyPurple.withAlpha(77),
                AppColors.primaryBlue.withAlpha(179),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Center(
            child: Icon(
              Icons.photo,
              size: 80,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  void _showSharePhotoOptions(BuildContext context, String photoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.link, color: AppColors.primaryBlue),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(
                    ClipboardData(text: 'https://fluttrr.com/photos/$photoId'),
                  );
                  Get.snackbar(
                    'Link Copied',
                    'Photo link copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: AppColors.friendlyTeal),
                title: const Text('Share to Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Share',
                    'Photo shared to chat',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.friendlyTeal,
                    colorText: Colors.white,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: AppColors.friendlyPurple),
                title: const Text('Save to Device'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Saved',
                    'Photo saved to your device',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
