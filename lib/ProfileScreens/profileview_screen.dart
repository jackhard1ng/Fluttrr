import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/ProfileController.dart';
import 'package:fluttrr/ProfileScreens/TotalActivitesScreen.dart';
import 'package:fluttrr/ProfileScreens/TotalMatchesListScreen.dart';
import 'package:fluttrr/ProfileScreens/UploadGalleryImage.dart';
import 'package:fluttrr/ProfileScreens/joinedactivities_screen.dart';

import 'editprofile_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  final double percentage;
  const ProfileViewScreen({super.key, required this.percentage});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.GetProfile();
    profileController.GetGalleryList();
    profileController.TotalActivites();
    profileController.TotalMatches();
    profileController.JoinedActivites();
    percent = widget.percentage;
  }

  double percent = 0.4;
  _percentage(percent) {
    var value = percent * 100;
    return ('$value%');
  }

  final List<String> activitiesOverview = [
    'Today',
    '7 Days',
    '30 Days',
  ];

  String? selectedactivitiesOverview;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GetBuilder<ProfileController>(
            id: "Profile_update",
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 66, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              Get.to(() => EditProfileScreen());
                            },
                            child: SvgPicture.asset('assets/edit.svg'))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 53,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 126,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      '${Apis.ip}${profileController.profile?.profile?.coverImage?[0].toString()}'))),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircularPercentIndicator(
                                      radius: 49.0,
                                      lineWidth: 5.0,
                                      percent: percent,
                                      progressBorderColor: Color(0xff4F78DA),
                                      center: CircleAvatar(
                                        radius: 43,
                                        backgroundImage: NetworkImage(
                                          '${Apis.ip}${profileController.profile?.profile?.images?[0].toString()}',
                                        ),
                                      ),
                                      progressColor: Color(0xff4F78DA),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff4F78DA)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(
                                          child: Text(
                                        _percentage(percent),
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profileController.profile?.userName.toString()}, ${profileController.profile?.profile?.age.toString()}, ${profileController.profile?.profile?.gender.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            Text(
                              '@${profileController.profile?.userName.toString()}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                            SizedBox(
                              width: 13,
                            ),
                            Container(
                              height: 23,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xff0F172A),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/Vector (3).svg',
                                      height: 13,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '${profileController.profile?.profile?.status.toString()}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: whiteColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          '${profileController.profile?.profile?.location.toString()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          'Last Active 02:50PM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          '${profileController.profile?.profile?.bio.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).indicatorColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    thickness: 6,
                    color: Color(0xffF1F1F1),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                iconStyleData: IconStyleData(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: SvgPicture.asset(
                                      'assets/drop.svg',
                                      height: 9,
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                items: activitiesOverview
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 7),
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedactivitiesOverview,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      selectedactivitiesOverview = value;
                                    },
                                  );
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 43,
                                  width: 100,
                                  padding:
                                      const EdgeInsets.only(left: 7, right: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    color: Color(0xffD9D9D9),
                                  ),
                                  elevation: 3,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                          17,
                                        ),
                                        bottomRight: Radius.circular(17)),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: const ScrollbarThemeData(
                                    radius: Radius.circular(40),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 30, right: 7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 33,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => Totalactivitesscreen());
                                },
                                child: Container(
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: Color(0xffFFF6E7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: GradientBoxBorder(
                                      width: 2.3,
                                      gradient: lefttorightgradient,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${profileController.totalActivityCount?.totalActivitiesCreated.toString()} +',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xff339003)),
                                            ),
                                            SvgPicture.asset('assets/br.svg')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 9,
                                        ),
                                        Text(
                                          'Total Activities',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => Totalmatcheslistscreen());
                                },
                                child: Container(
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: Color(0xffBEFFF8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: GradientBoxBorder(
                                      width: 2.3,
                                      gradient: lefttorightgradient,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${profileController.totalMatchCount?.totalMates.toString()} +',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xff339003)),
                                            ),
                                            SvgPicture.asset(
                                                'assets/Group 48096198.svg')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 9,
                                        ),
                                        Text(
                                          'Total Matches',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => JoinedactivitiesScreen());
                                },
                                child: Container(
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: Color(0xffFFE1C0),
                                    borderRadius: BorderRadius.circular(10),
                                    border: GradientBoxBorder(
                                      width: 2.3,
                                      gradient: lefttorightgradient,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${profileController.totalJoinedActivitesCount?.totalActivitiesJoined.toString()} +',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xff339003)),
                                            ),
                                            SvgPicture.asset(
                                                'assets/Group 48096116.svg')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 9,
                                        ),
                                        Text(
                                          'Joined Activities',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          thickness: 6,
                          color: Color(0xffF1F1F1),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => ImageUploadScreen());
                              },
                              child: Container(
                                height: 43,
                                width: 100,
                                padding:
                                    const EdgeInsets.only(left: 7, right: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: Color(0xffD9D9D9),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Photos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: profileController
                                    .galleryDataModel?.gallery?.length ??
                                0,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${profileController.galleryDataModel?.gallery?[index].description.toString()}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        PopupMenuButton<int>(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            itemBuilder: (context) => [
                                                  // PopupMenuItem 1
                                                  PopupMenuItem(
                                                    value: 1,
                                                    // row with 2 children
                                                    child: Text(
                                                      "Edit Photo",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  // PopupMenuItem 2
                                                  PopupMenuItem(
                                                    value: 2,
                                                    // row with two children
                                                    child: Text(
                                                      "Delete Photo",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                            offset: Offset(0, 30),
                                            color: Colors.white,
                                            elevation: 2,
                                            // on selected we show the dialog box
                                            onSelected: (value) {},
                                            child: SvgPicture.asset(
                                              'assets/Group 48095916.svg',
                                              height: 27,
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 360,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  '${Apis.ip}${profileController.galleryDataModel?.gallery?[index].images?[0].toString()}'))),
                                    ),
                                    SizedBox(
                                      height: 50,
                                    )
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
