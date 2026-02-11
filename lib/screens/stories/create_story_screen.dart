import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/story_controller.dart';
import '../../models/story_model.dart';
import '../../constants/utils.dart';

/// Screen for creating a new story
class CreateStoryScreen extends StatefulWidget {
  final String? eventId;
  final String? eventName;

  const CreateStoryScreen({
    super.key,
    this.eventId,
    this.eventName,
  });

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final StoryController _controller = Get.isRegistered<StoryController>()
      ? Get.find<StoryController>()
      : Get.put(StoryController());
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedMedia;
  StoryType _storyType = StoryType.image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Open camera/gallery picker immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMediaPicker();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showMediaPicker() {
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Create Story',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture a moment'),
              onTap: () async {
                Get.back();
                final photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() {
                    _selectedMedia = File(photo.path);
                    _storyType = StoryType.image;
                  });
                } else if (_selectedMedia == null) {
                  Get.back();
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: AppColors.friendlyPurple),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () async {
                Get.back();
                final photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() {
                    _selectedMedia = File(photo.path);
                    _storyType = StoryType.image;
                  });
                } else if (_selectedMedia == null) {
                  Get.back();
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.text_fields, color: AppColors.friendlyTeal),
              ),
              title: const Text('Text Story'),
              subtitle: const Text('Share a thought'),
              onTap: () {
                Get.back();
                setState(() {
                  _storyType = StoryType.text;
                  _selectedMedia = null;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).then((_) {
      // If nothing selected and no previous media, go back
      if (_selectedMedia == null && _storyType != StoryType.text) {
        Get.back();
      }
    });
  }

  Future<void> _postStory() async {
    if (_storyType == StoryType.image && _selectedMedia == null) {
      Get.snackbar(
        'No Media',
        'Please select a photo for your story',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_storyType == StoryType.text &&
        _captionController.text.trim().isEmpty) {
      Get.snackbar(
        'No Text',
        'Please enter some text for your story',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    final story = await _controller.createStory(
      media: _selectedMedia ?? File(''),
      type: _storyType,
      eventId: widget.eventId,
      caption: _captionController.text.trim().isNotEmpty
          ? _captionController.text.trim()
          : null,
    );

    setState(() => _isLoading = false);

    if (story != null) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.eventName ?? 'Create Story',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _postStory,
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Preview
          if (_storyType == StoryType.text)
            _buildTextStoryPreview()
          else if (_selectedMedia != null)
            _buildImagePreview()
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Caption input at bottom
          if (_storyType != StoryType.text)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

          // Change media button
          if (_storyType != StoryType.text)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 80,
              child: GestureDetector(
                onTap: _showMediaPicker,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Upload progress
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(128),
                child: Center(
                  child: Obx(() {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: _controller.uploadProgress.value > 0
                              ? _controller.uploadProgress.value
                              : null,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Posting story...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Image.file(
        _selectedMedia!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildTextStoryPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.friendlyPurple,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: TextField(
            controller: _captionController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Type your story...',
              hintStyle: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
