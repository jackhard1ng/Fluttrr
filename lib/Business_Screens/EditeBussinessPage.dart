import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';
import 'package:fluttrr/Models/BussinessModel/BusinessPageModel.dart';

class EditBusinessPage extends StatefulWidget {
  final BusinessPageModel? businessData;
  const EditBusinessPage({super.key, this.businessData});

  @override
  State<EditBusinessPage> createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  BusinessController businessController = Get.put(BusinessController());
  File? profileImageFile;
  File? coverImageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.businessData != null) {
      _nameController.text = widget.businessData?.profile?.name ?? '';
      _descriptionController.text =
          widget.businessData?.profile?.description ?? '';
      _emailController.text = widget.businessData?.profile?.email ?? '';
      _phoneController.text = widget.businessData?.profile?.phoneNumber ?? '';
      _locationController.text = widget.businessData?.profile?.location ?? '';
      _websiteController.text = widget.businessData?.profile?.websiteLink ?? '';
      _facebookController.text =
          widget.businessData?.profile?.facebookLink ?? '';
      _instagramController.text =
          widget.businessData?.profile?.instagramLink ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick profile image');
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          coverImageFile = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick cover image');
    }
  }

  void _deleteProfileImage() {
    setState(() {
      profileImageFile = null;
    });
  }

  void _deleteCoverImage() {
    setState(() {
      coverImageFile = null;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await businessController.updateBusinessPage(
      widget.businessData?.profile?.id.toString() ?? "0",
      _nameController.text,
      _descriptionController.text,
      _emailController.text,
      _phoneController.text,
      _websiteController.text,
      _facebookController.text,
      _instagramController.text,
      profileImageFile,
      coverImageFile,
    );

    if (success) {
      Get.back(result: true);
      Get.snackbar('Success', 'Business profile updated successfully');
      businessController.GetBusinessPage();
    } else {
      Get.snackbar('Error', 'Failed to update business profile');
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateURL(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(
            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')
        .hasMatch(value)) {
      return 'Please enter a valid URL for $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: const Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Business Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 53),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: Container(
                            width: double.infinity,
                            height: 143,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: coverImageFile != null
                                    ? FileImage(coverImageFile!)
                                    : widget.businessData!.profile!.image !=
                                            null
                                        ? NetworkImage(
                                            "${Apis.ip}${widget.businessData!.profile!.image!}")
                                        : const AssetImage(
                                                'assets/default_cover.png')
                                            as ImageProvider,
                              ),
                            ),
                            child: coverImageFile == null &&
                                    widget.businessData?.profile!.image == null
                                ? Center(
                                    child: SvgPicture.asset(
                                        'assets/Add Photo.svg'))
                                : null,
                          ),
                        ),
                        if (coverImageFile != null ||
                            widget.businessData?.profile!.image != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _deleteCoverImage,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 6),
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 49,
                                  backgroundImage: profileImageFile != null
                                      ? FileImage(profileImageFile!)
                                      : widget.businessData?.profile?.logo !=
                                              null
                                          ? NetworkImage(
                                              "${Apis.ip}${widget.businessData!.profile!.logo!}")
                                          : const AssetImage(
                                                  'assets/default_profile.png')
                                              as ImageProvider,
                                ),
                                if (profileImageFile != null ||
                                    widget.businessData?.profile?.logo != null)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white),
                                      onPressed: _deleteProfileImage,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: SvgPicture.asset('assets/Add Photo.svg'),
                          onPressed: _pickProfileImage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _nameController,
                      hintText: 'Enter Business Name',
                      validator: (value) =>
                          _validateRequired(value, 'business name'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Business Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _descriptionController,
                      hintText: 'Description',
                      maxLines: 4,
                      validator: (value) =>
                          _validateRequired(value, 'business description'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _emailController,
                      hintText: 'Business Email',
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _phoneController,
                      hintText: 'Business Phone Number',
                      validator: _validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _locationController,
                      hintText: 'Business Location',
                      validator: (value) =>
                          _validateRequired(value, 'location'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Website Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _websiteController,
                      hintText: 'Enter Website Link',
                      validator: (value) => _validateURL(value, 'website'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Facebook Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _facebookController,
                      hintText: 'Enter Facebook Link',
                      validator: (value) => _validateURL(value, 'Facebook'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Instagram Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: _instagramController,
                      hintText: 'Enter Instagram Link',
                      validator: (value) => _validateURL(value, 'Instagram'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: GradientBoxBorder(
                                  gradient: lefttorightgradient,
                                  width: 2.3,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Button(
                            borderRadius: BorderRadius.circular(10),
                            height: 60,
                            width: double.infinity,
                            onTap: _updateProfile,
                            child: const Center(
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
