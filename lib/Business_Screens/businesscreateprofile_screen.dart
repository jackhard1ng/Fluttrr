import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';

import 'businessevents_screen.dart';

class BusinesscreateprofileScreen extends StatefulWidget {
  const BusinesscreateprofileScreen({super.key});

  @override
  State<BusinesscreateprofileScreen> createState() =>
      _BusinesscreateprofileScreenState();
}

class _BusinesscreateprofileScreenState
    extends State<BusinesscreateprofileScreen> {
  final _formKey = GlobalKey<FormState>();
  BusinessController businessController = Get.put(BusinessController());
  bool isEmailVerified = false;
  bool showOtpField = false;
  bool loading = false;
  File? profileImageFile;
  File? coverImageFile;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController NameController = TextEditingController();
  final TextEditingController DescriptionController = TextEditingController();
  final TextEditingController PhoneNumberController = TextEditingController();
  final TextEditingController LocationController = TextEditingController();
  final TextEditingController WebSiteLinkController = TextEditingController();
  final TextEditingController FacebookController = TextEditingController();
  final TextEditingController InstagramController = TextEditingController();
  int _countdown = 59;
  late Timer _timer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    NameController.dispose();
    DescriptionController.dispose();
    PhoneNumberController.dispose();
    LocationController.dispose();
    WebSiteLinkController.dispose();
    FacebookController.dispose();
    InstagramController.dispose();
    _timer.cancel();
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
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to pick profile image",
        ),
      );
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
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to pick cover image",
        ),
      );
    }
  }

  Future<void> _verifyEmail() async {
    if (_emailController.text.isEmpty) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please enter your email address",
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please enter a valid email address",
        ),
      );
      return;
    }

    final email = await businessController.SendOtp(_emailController.text);
    if (email) {
      setState(() {
        showOtpField = true;
        _countdown = 59;
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (_countdown > 0) {
            setState(() {
              _countdown--;
            });
          } else {
            _timer.cancel();
          }
        });
      });
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "Check your email for OTP!",
        ),
      );
    } else {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to send OTP!",
        ),
      );
    }
  }

  Future<void> _submitOtp() async {
    if (_otpController.text.isEmpty) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please enter the OTP",
        ),
      );
      return;
    }

    final opt = await businessController.VerifyOtp(
        _otpController.text, _emailController.text);
    if (opt) {
      setState(() {
        isEmailVerified = true;
        showOtpField = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "Email verified successfully!",
        ),
      );
    } else {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Invalid OTP. Please try again!",
        ),
      );
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

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      loading = true;
    });

    if (!isEmailVerified) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please verify your email first!",
        ),
      );
      return;
    }

    if (profileImageFile == null) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please select a profile image",
        ),
      );
      return;
    }

    if (coverImageFile == null) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Please select a cover image",
        ),
      );
      return;
    }

    // All validations passed, proceed with profile creation
    final profile = await businessController.CreateBussinessPage(
        NameController.text,
        DescriptionController.text,
        _emailController.text,
        PhoneNumberController.text,
        WebSiteLinkController.text,
        FacebookController.text,
        InstagramController.text,
        profileImageFile!,
        coverImageFile!);
    // Add your profile creation logic here
    if (profile) {
      setState(() {
        loading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "Profile created successfully!",
        ),
      );
      Get.to(() => BusinesseventsScreen());
    } else {
      setState(() {
        loading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Event is Failed to Create!",
        ),
      );
    }

    // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
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
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Profile',
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
                                    : AssetImage(
                                            'assets/fantasy-shooting-star-landscape-night (1).png')
                                        as ImageProvider,
                              ),
                            ),
                            child: coverImageFile == null
                                ? Center(
                                    child: SvgPicture.asset(
                                        'assets/Add Photo.svg'))
                                : null,
                          ),
                        ),
                        if (coverImageFile != null)
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
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
                                      : AssetImage('assets/Group 48096083.png')
                                          as ImageProvider,
                                ),
                                if (profileImageFile != null)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.delete,
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
              SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Profile Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: NameController,
                      hintText: 'Enter Profile Name',
                      validator: (value) =>
                          _validateRequired(value, 'profile name'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Business Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: DescriptionController,
                      hintText: 'Description',
                      maxLines: 4,
                      validator: (value) =>
                          _validateRequired(value, 'business description'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (showOtpField)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Business_TextField(
                            controller: _otpController,
                            hintText: 'Enter OTP',
                            validator: (value) =>
                                _validateRequired(value, 'OTP'),
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _countdown.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff4F78DA)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _verifyEmail,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Resend OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: lightBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                      onPressed: _submitOtp,
                                      child: Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (isEmailVerified)
                      Business_TextField(
                        controller: _emailController,
                        hintText: 'Business Email',
                        // enabled: false,
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.verified, color: Colors.green),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Business_TextField(
                              controller: _emailController,
                              hintText: 'Business Email',
                              validator: _validateEmail,
                              suffix: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _countdown.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff4F78DA)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 115,
                            height: 61,
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: _verifyEmail,
                              child: Text(
                                'Verify',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    SizedBox(height: 15),
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: PhoneNumberController,
                      hintText: 'Business Phone Number',
                      validator: _validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: LocationController,
                      hintText: 'USA',
                      validator: (value) =>
                          _validateRequired(value, 'location'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Website Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: WebSiteLinkController,
                      hintText: 'Enter Web Link',
                      validator: (value) => _validateURL(value, 'website'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Facebook Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: FacebookController,
                      hintText: 'Enter Facebook Link',
                      validator: (value) => _validateURL(value, 'Facebook'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Instagram Link',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: InstagramController,
                      hintText: 'Enter Instagram Link',
                      validator: (value) => _validateURL(value, 'Instagram'),
                    ),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: GradientBoxBorder(
                                      gradient: lefttorightgradient,
                                      width: 2.3)),
                              child: Center(
                                  child: Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
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
                                  onTap: _createProfile,
                                  child: const Center(
                                      child: Text(
                                    'Create Now',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  )),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
