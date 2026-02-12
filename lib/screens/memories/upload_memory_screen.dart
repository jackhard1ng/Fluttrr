import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/memory_controller.dart';
import '../../constants/utils.dart';

/// Screen for uploading new memory photos
class UploadMemoryScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const UploadMemoryScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<UploadMemoryScreen> createState() => _UploadMemoryScreenState();
}

class _UploadMemoryScreenState extends State<UploadMemoryScreen> {
  final MemoryController _controller = Get.isRegistered<MemoryController>()
      ? Get.find<MemoryController>()
      : Get.put(MemoryController());
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedPhotos = [];
  bool _isUploading = false;

  static const int maxPhotos = 10;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedPhotos.length >= maxPhotos) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload up to $maxPhotos photos at once',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final remaining = maxPhotos - _selectedPhotos.length;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
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
              leading: Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back();
                final photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() {
                    _selectedPhotos.add(File(photo.path));
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: Text('Choose from Gallery (up to $remaining)'),
              onTap: () async {
                Get.back();
                final photos = await _picker.pickMultiImage(
                  imageQuality: 80,
                  limit: remaining,
                );
                if (photos.isNotEmpty) {
                  setState(() {
                    _selectedPhotos.addAll(
                      photos.take(remaining).map((xFile) => File(xFile.path)),
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _uploadMemory() async {
    if (_selectedPhotos.isEmpty) {
      Get.snackbar(
        'No Photos',
        'Please select at least one photo to upload',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _controller.uploadMemory(
      eventId: widget.eventId,
      photos: _selectedPhotos,
      caption: _captionController.text.trim().isNotEmpty
          ? _captionController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (result != null) {
      Get.back(result: true);
      Get.snackbar(
        'Success!',
        'Your memory has been shared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Memory'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _uploadMemory,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Share',
                    style: TextStyle(
                      color: _selectedPhotos.isEmpty
                          ? AppColors.mediumGrey
                          : AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event info
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryBlue.withAlpha(13),
              child: Row(
                children: [
                  Icon(Icons.event, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sharing to',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.eventName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Photos section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Photos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Text(
                        '${_selectedPhotos.length}/$maxPhotos',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Photo grid
                  if (_selectedPhotos.isEmpty)
                    _buildEmptyPhotoState()
                  else
                    _buildPhotoGrid(),
                ],
              ),
            ),

            // Caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caption (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Write something about this memory...',
                      hintStyle: TextStyle(color: AppColors.mediumGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.friendlyPurple.withAlpha(51),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: AppColors.friendlyPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.friendlyPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Photos are visible to everyone who attended the event\n'
                      '• You can tag people in your photos after uploading\n'
                      '• Other attendees will be notified of new memories',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoState() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select from camera or gallery',
              style: TextStyle(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _selectedPhotos.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedPhotos.length) {
              if (_selectedPhotos.length >= maxPhotos) {
                return const SizedBox.shrink();
              }
              return _buildAddButton();
            }
            return _buildPhotoTile(index);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoTile(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(_selectedPhotos[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(179),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
