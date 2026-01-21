import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  ProfileController profileController = Get.put(ProfileController());
  final TextEditingController username = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController location = TextEditingController();
  bool loading = false;
  int selectedGenderIndex = 0;
  int selectedStatusIndex = 0;
  int? selectedAge;
  String? selectedCountry;

  final List<String> _languages = [];
  final TextEditingController _languageController = TextEditingController();
  final List<String> _hobbies = [];
  final TextEditingController _hobbyController = TextEditingController();

  File? _selectedCoverImage;
  File? _selectedProfileImage;
  final ImagePicker _picker = ImagePicker();

  // List of countries for dropdown
  final List<String> countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'France',
    'Germany',
    'Japan',
    'India',
    'Brazil',
    'Mexico'
  ];

  // List of ages from 18 to 100
  final List<int> ages = List.generate(83, (index) => index + 18);

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedCoverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProfileImage = File(pickedFile.path);
      });
    }
  }

  List<String> genderOptions = ['Male', 'Female', 'Non-Binary'];
  List<String> statusOptions = ['traveller', 'local'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Images Section
            _buildProfileImagesSection(),
            const SizedBox(height: 30),

            // Username
            _buildInputField(
              label: 'Username',
              hint: '@username',
              controller: username,
            ),
            const SizedBox(height: 20),

            // Bio
            _buildInputField(
              label: 'Bio',
              hint: 'Tell us about yourself...',
              controller: bio,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Age Dropdown
            _buildDropdownField(
              label: 'Age',
              value: selectedAge?.toString(),
              items: ages.map((age) => age.toString()).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAge = int.tryParse(value ?? '18');
                });
              },
              hint: 'Select your age',
            ),
            const SizedBox(height: 20),

            // Country Dropdown
            _buildDropdownField(
              label: 'Country',
              value: selectedCountry,
              items: countries,
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
              hint: 'Select your country',
            ),
            const SizedBox(height: 20),

            // Location
            _buildInputField(
              label: 'Location',
              hint: 'City or specific location',
              controller: location,
            ),
            const SizedBox(height: 20),

            // Gender Selection
            _buildSelectionGrid(
              label: 'Gender',
              options: genderOptions,
              selectedIndex: selectedGenderIndex,
              onSelected: (index) {
                setState(() {
                  selectedGenderIndex = index;
                });
              },
            ),
            const SizedBox(height: 20),

            // Status Selection
            _buildSelectionGrid(
              label: 'I am a',
              options: statusOptions,
              selectedIndex: selectedStatusIndex,
              onSelected: (index) {
                setState(() {
                  selectedStatusIndex = index;
                });
              },
            ),
            const SizedBox(height: 20),

            // Languages
            _buildTagInputSection(
              label: 'Languages',
              tags: _languages,
              controller: _languageController,
              hint: 'Add languages...',
              onAdd: () {
                if (_languageController.text.isNotEmpty) {
                  setState(() {
                    _languages.add(_languageController.text.trim());
                    _languageController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Hobbies & Interests
            _buildTagInputSection(
              label: 'Hobbies & Interests',
              tags: _hobbies,
              controller: _hobbyController,
              hint: 'Add hobbies...',
              onAdd: () {
                if (_hobbyController.text.isNotEmpty) {
                  setState(() {
                    _hobbies.add(_hobbyController.text.trim());
                    _hobbyController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 30),

            // Save Button
            loading
                ? Center(
                    child: GradientProgressIndicator(
                      radius: 17,
                      duration: 3,
                      strokeWidth: 5,
                      backgroundColor: Colors.white,
                      gradientStops: const [
                        0.2,
                        0.7,
                        0.3,
                        0.3,
                      ],
                      gradientColors: const [
                        Color(0xff4F78DA),
                        Color(0xff339003),
                        Color(0xff4F78DA),
                        Colors.white
                      ],
                      child: Text(''),
                    ),
                  )
                : Button(
                    borderRadius: BorderRadius.circular(10),
                    height: 60,
                    width: double.infinity,
                    onTap: () {
                      // Save profile logic
                      if (_validateForm()) {
                        _saveProfile();
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Complete Setup',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagesSection() {
    return Column(
      children: [
        // Cover Photo
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: _selectedCoverImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedCoverImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedCoverImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text(
                        'Add Cover Photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Profile Photo
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white, width: 3),
                  image: _selectedProfileImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedProfileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedProfileImage == null
                    ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[500])
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: lefttorightgradient,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.3),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffF1F1F1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: lefttorightgradient,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffF1F1F1),
              ),
              child: DropdownButtonFormField<String>(
                value: value,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionGrid({
    required String label,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffF1F1F1),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: selectedIndex == index
                        ? lefttorightgradient
                        : LinearGradient(colors: [
                            const Color(0xffF1F1F1),
                            const Color(0xffF1F1F1),
                          ]),
                  ),
                  child: Center(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagInputSection({
    required String label,
    required List<String> tags,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF1F1F1),
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: lefttorightgradient,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: onAdd,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  bool _validateForm() {
    if (username.text.isEmpty) {
      // showSnackBar('Please enter a username');
      return false;
    }
    if (_selectedProfileImage == null) {
      // showSnackBar('Please select a profile photo');
      return false;
    }
    if (selectedAge == null) {
      // showSnackBar('Please select your age');
      return false;
    }
    if (selectedCountry == null) {
      // showSnackBar('Please select your country');
      return false;
    }
    return true;
  }

  void _saveProfile() async {
    setState(() {
      loading = true;
    });
    final ok = await profileController.setupProfile(
        age: selectedAge!,
        username: username.text,
        gender: genderOptions[selectedGenderIndex],
        status: statusOptions[selectedStatusIndex],
        bio: bio.text,
        country: selectedCountry ?? 'Unknown',
        interests: _hobbies,
        image: _selectedProfileImage!,
        coverImage: _selectedCoverImage!,
        latitude: -80.000,
        longitude: 90.000,
        languages: _languages,
        location: location.text);

    if (ok) {
      setState(() {
        loading = false;
      });
      Get.to(() => BottomBar(screen: 0));
    } else {
      setState(() {
        loading = false;
      });
    }
  }
}
