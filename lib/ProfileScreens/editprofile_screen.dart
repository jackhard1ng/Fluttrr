import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Controller/ProfileController.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ProfileController profileController = Get.put(ProfileController());

  final TextEditingController username = TextEditingController();
  final TextEditingController Bio = TextEditingController();
  final TextEditingController Location = TextEditingController();

  int selectedIndex = 0;
  int selectedIndex1 = 0;
  String selectedGender = "male";
  String selectedstatus = "traveller";

  List<String> _taglist = [];
  final TextEditingController _tagController = TextEditingController();
  List<String> _taglisthobbies = [];
  final TextEditingController _taghobbiesController = TextEditingController();

  File? _selectedCoverImage;
  File? _selectedProfileImage;
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  // Function to select a cover image
  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedCoverImage = File(pickedFile.path);
      });
    }
  }

  // Function to select a profile image
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProfileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch profile data safely
    Future.microtask(() async {
      await profileController.GetProfile();

      if (profileController.profile != null &&
          profileController.profile!.profile != null) {
        setState(() {
          username.text = profileController.profile!.userName ?? "";
          Bio.text = profileController.profile!.profile!.bio ?? "";
          Location.text = profileController.profile!.profile!.location ?? "";

          // Assign selectedIndex correctly
          if (profileController.profile!.profile!.gender == "male") {
            selectedIndex = 0;
          } else if (profileController.profile!.profile!.gender == "female") {
            selectedIndex = 1;
          } else {
            selectedIndex = 2;
          }
          //Status
          if (profileController.profile!.profile!.status == "traveller") {
            selectedIndex1 = 0;
          } else {
            selectedIndex1 = 1;
          }

          //......Langauges
          _taglisthobbies = profileController.profile?.profile?.interests ?? [];
          _taglist = profileController.profile?.profile?.language ?? [];
        });
      }
    });
  }

  List gender = [
    'male',
    'female',
    'Non-Binary',
  ];
  List status = [
    'traveller',
    'local',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 66, left: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 13,
            ),
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // Cover Image
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 53),
                    child: Container(
                      width: double.infinity,
                      height: 126,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _selectedCoverImage != null
                              ? FileImage(_selectedCoverImage!) as ImageProvider
                              : NetworkImage(
                                  '${Apis.ip}${profileController.profile?.profile?.coverImage?[0]}'),
                        ),
                      ),
                      child: Center(
                        child: _selectedCoverImage == null
                            ? SvgPicture.asset('assets/Add Photo.svg')
                            : null, // Hide Add Photo icon when an image is selected
                      ),
                    ),
                  ),
                ),

                // Profile Image
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 6),
                          child: CircleAvatar(
                            radius: 49,
                            backgroundImage: _selectedProfileImage != null
                                ? FileImage(_selectedProfileImage!)
                                : NetworkImage(
                                        '${Apis.ip}${profileController.profile?.profile?.images?[0]}')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: SvgPicture.asset('assets/Add Photo.svg'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: lefttorightgradient),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.3),
                      child: TextFormField(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        cursorHeight: 23,
                        controller: username,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF1F1F1),
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          hintText: '@Username',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xff7B7575)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: lefttorightgradient),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.3),
                      child: TextFormField(
                        maxLines: 4,
                        controller: Bio,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        cursorHeight: 23,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF1F1F1),
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          hintText: 'Bio',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xff7B7575)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffF1F1F1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: gender.length,
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 0,
                                    mainAxisExtent: 57),
                            itemBuilder: (_, index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  if (selectedIndex == 0) {
                                    selectedGender = "male";
                                  } else if (selectedIndex == 1) {
                                    selectedGender = "female";
                                  } else {
                                    selectedGender = "Non-Binary";
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: selectedIndex == index
                                        ? lefttorightgradient
                                        : LinearGradient(colors: [
                                            Color(0xffF1F1F1),
                                            Color(0xffF1F1F1),
                                          ]),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                  child: Text(
                                    gender[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedIndex == index
                                          ? whiteColor
                                          : discriptionColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          cursorHeight: 23,
                          controller: Location,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF1F1F1),
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: InputBorder.none,
                            hintText: 'Add Your Location',
                            hintStyle: TextStyle(
                                fontSize: 14, color: Color(0xff7B7575)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 100,
                        height: 57,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: whiteColor),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Text(
                    'Location status:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffF1F1F1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: status.length,
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0,
                                    mainAxisExtent: 57),
                            itemBuilder: (_, index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex1 = index;
                                  if (selectedIndex1 == 0) {
                                    selectedstatus = "traveller";
                                  } else {
                                    selectedstatus = "local";
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: selectedIndex1 == index
                                        ? lefttorightgradient
                                        : LinearGradient(colors: [
                                            Color(0xffF1F1F1),
                                            Color(0xffF1F1F1),
                                          ]),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                  child: Text(
                                    status[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedIndex1 == index
                                          ? whiteColor
                                          : discriptionColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: TextFormField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17, horizontal: 13),
                              filled: true,
                              fillColor: Color(0xffF1F1F1),
                              hintText: "Add Lannguages.....",
                              suffixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/s.svg',
                                    height: 23,
                                  ),
                                ],
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 14, color: discriptionColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // Add item to the list
                          if (_tagController.text.isNotEmpty) {
                            setState(() {
                              _taglist.add(_tagController.text.trim());
                              _tagController.clear();
                            });
                          }
                        },
                        child: Container(
                          height: 57,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: lightBlue,
                          ),
                          child: Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  // Display List of Chips for Equipment
                  Wrap(
                    spacing: 3.0,
                    runSpacing: 4.0,
                    children: List.generate(
                      _taglist.length,
                      (index) => Chip(
                        avatar: SvgPicture.asset(
                          'assets/Group 48096194.svg',
                          height: 17,
                          color: Theme.of(context).primaryColor,
                        ),
                        color:
                            WidgetStatePropertyAll(lightBlue.withOpacity(0.1)),
                        label: Text(_taglist[index]),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _taglist
                                .removeAt(index); // Remove item from the list
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 13),

                  Text(
                    'Interests & Hobbies',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: TextFormField(
                            controller: _taghobbiesController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17, horizontal: 13),
                              filled: true,
                              fillColor: Color(0xffF1F1F1),
                              hintText: "Add Interests & Hobbies.....",
                              hintStyle: TextStyle(
                                  fontSize: 14, color: discriptionColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // Add item to the list
                          if (_taghobbiesController.text.isNotEmpty) {
                            setState(() {
                              _taglisthobbies
                                  .add(_taghobbiesController.text.trim());
                              _taghobbiesController.clear();
                            });
                          }
                        },
                        child: Container(
                          height: 57,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: lightBlue,
                          ),
                          child: Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  // Display List of Chips for Equipment
                  Wrap(
                    spacing: 3.0,
                    runSpacing: 4.0,
                    children: List.generate(
                      _taglisthobbies.length,
                      (index) => Chip(
                        avatar: SvgPicture.asset(
                          'assets/sss (2).svg',
                          height: 17,
                        ),
                        color:
                            WidgetStatePropertyAll(lightBlue.withOpacity(0.1)),
                        label: Text(_taglisthobbies[index]),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _taglisthobbies
                                .removeAt(index); // Remove item from the list
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: GradientBoxBorder(
                                  gradient: lefttorightgradient, width: 2.3)),
                          child: Center(
                              child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: loading
                            ? GradientProgressIndicator(
                                radius: 21,
                                duration: 3,
                                strokeWidth: 7,
                                backgroundColor: Colors.white,
                                gradientStops: const [
                                  0.2,
                                  0.7,
                                  0.3,
                                  0.3,
                                ],
                                gradientColors: const [
                                  Color(0xff007BFD),
                                  Color(0xff20235A),
                                  Color(0xff007BFD),
                                  Colors.white
                                ],
                                child: Text(''),
                              )
                            : Button(
                                borderRadius: BorderRadius.circular(10),
                                height: 60,
                                width: double.infinity,
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  final update =
                                      await profileController.editProfile(
                                          age: profileController
                                                  .profile?.profile?.age
                                                  .toString() ??
                                              "18",
                                          gender: selectedGender.toString(),
                                          status: selectedstatus.toString(),
                                          bio: Bio.text,
                                          interests: _taglisthobbies,
                                          Language: _taglist,
                                          longitude: "-89",
                                          latitude: "90",
                                          userName: username.text,
                                          coverImage: _selectedCoverImage,
                                          image: _selectedProfileImage);
                                  if (update) {
                                    await profileController.GetProfile();
                                    setState(() {
                                      loading = false;
                                    });
                                    Get.back();
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message: "Failed to update Profile.",
                                      ),
                                    );
                                  }
                                },
                                child: const Center(
                                    child: Text(
                                  'Save Changes',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 17,
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
