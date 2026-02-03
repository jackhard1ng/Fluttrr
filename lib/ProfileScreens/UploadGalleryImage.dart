import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:fluttrr/Controller/ProfileController.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  ProfileController controller = Get.put(ProfileController());
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_descriptionController.text.isNotEmpty && _image != null) {
      final upload =
          await controller.UploadGallery(_descriptionController.text, _image);
      // Implement upload logic here
      if (upload) {
        await controller.GetGalleryList();
        await controller.GetProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post uploaded successfully!")),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post uploaded successfully!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add a description and an image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Write a description...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Image.file(_image!,
                      height: 200, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text("Tap to upload image")),
                    ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
              onPressed: _uploadPost,
              child: Text(
                "Post",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
