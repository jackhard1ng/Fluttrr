import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/listdata.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/ChatsListController.dart';
import 'package:fluttrr/Controller/ViewProfileController.dart';

import '../Repository/ChatRepository.dart';

class UserinfoScreen extends StatefulWidget {
  final String id;
  const UserinfoScreen({super.key, required this.id});

  @override
  State<UserinfoScreen> createState() => _UserinfoScreenState();
}

class _UserinfoScreenState extends State<UserinfoScreen> {
  Viewprofilecontroller controller = Get.put(Viewprofilecontroller());
  ChatsListController chatsListController = Get.put(ChatsListController());
  bool loading = false;

  @override
  void initState() {
    super.initState();
    api();
  }

  void api() async {
    setState(() {
      loading = true;
    });
    await controller.GetProfileMates(widget.id);
    setState(() {
      loading = false;
    });
  }

  final List<File> _selectedImageFiles = [];
  TextEditingController Message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
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
          : SingleChildScrollView(
              child: GetBuilder<Viewprofilecontroller>(
                  id: "Profile_update",
                  builder: (_) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 66, left: 15, right: 15),
                      child: controller.metaprofile?.user == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ops: This Profile is Private",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Image.asset(
                                    "assets/NoData.png",
                                    width: 300,
                                  )
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 370,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13)),
                                    color: Colors.transparent,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        '${Apis.ip}${controller.metaprofile?.profile?.images?[0]}',
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(7.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape
                                                    .circle, // Makes it fully circular
                                              ),
                                              child: ClipOval(
                                                child: SvgPicture.network(
                                                  controller.metaprofile
                                                          ?.profile?.countryFlag
                                                          .toString() ??
                                                      "", // Replace with your SVG URL
                                                  fit: BoxFit
                                                      .cover, // Ensures it fills the container properly
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${controller.metaprofile?.user?.userName}, ${controller.metaprofile?.profile?.age}, ${controller.metaprofile?.profile?.gender}',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: whiteColor),
                                                    ),
                                                    SizedBox(
                                                      width: 7,
                                                    ),
                                                    SvgPicture.asset(
                                                      'assets/Vector (2).svg',
                                                      height: 19,
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 7,
                                                ),
                                                Container(
                                                  height: 27,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Color(0xff4F78DA),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/h.svg',
                                                          height: 13,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          '${controller.metaprofile?.profile?.status}',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  whiteColor),
                                                        ),
                                                      ],
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
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    color: Color(0xffF1F1F1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'About ${controller.metaprofile?.user?.userName.toString()}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "${controller.metaprofile?.profile?.bio}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff4D4D4D)),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Mate’s Interests & Hobbies',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: controller.metaprofile
                                                  ?.profile?.interests
                                                  ?.expand((interest) =>
                                                      interest.split(
                                                          " ")) // Split words
                                                  .toList()
                                                  .length ??
                                              0,
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisExtent: 39,
                                          ),
                                          itemBuilder: (_, index) {
                                            // Extract words from interests
                                            List<String> words = controller
                                                    .metaprofile
                                                    ?.profile
                                                    ?.interests
                                                    ?.expand((interest) =>
                                                        interest.split(" "))
                                                    .toList() ??
                                                [];

                                            return GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Color(0xff6C6C6C),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    words[
                                                        index], // Display each word separately
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/Group 48095805.svg',
                                              height: 21,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              'Languages I Know',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: controller.metaprofile
                                                  ?.profile?.language?.length ??
                                              0,
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 10,
                                                  mainAxisExtent: 39),
                                          itemBuilder: (_, index) {
                                            List<String> words = controller
                                                    .metaprofile
                                                    ?.profile
                                                    ?.language
                                                    ?.expand((interest) =>
                                                        interest.split(" "))
                                                    .toList() ??
                                                [];
                                            return GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Color(0xff0090FF)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      languagesData[index]
                                                          .image,
                                                      height: 17,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      words[index],
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            return null;
                                          },
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/Page-1.svg',
                                              height: 17,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              'Mate’s Location',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: mateLocation.length,
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisExtent: 39),
                                          itemBuilder: (_, index) =>
                                              GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Color(0xff339003)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape
                                                          .circle, // Makes it fully circular
                                                    ),
                                                    child: ClipOval(
                                                      child: SvgPicture.network(
                                                        controller
                                                                .metaprofile
                                                                ?.profile
                                                                ?.countryFlag
                                                                .toString() ??
                                                            "", // Replace with your SVG URL
                                                        fit: BoxFit
                                                            .cover, // Ensures it fills the container properly
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    controller.metaprofile
                                                            ?.profile?.country
                                                            .toString() ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: whiteColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  SvgPicture.asset(
                                                    'assets/Group 48096192.svg',
                                                    height: 17,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/g (2).svg',
                                              height: 21,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              'Gallery',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: controller.metaprofile
                                                  ?.profile?.images?.length ??
                                              0,
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisExtent: 117),
                                          itemBuilder: (_, index) =>
                                              GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                                color: Colors.transparent,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    '${Apis.ip}${controller.metaprofile?.profile?.images?[index]}',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Any Badges Earned',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 30,
                                          width: 160,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1.5,
                                              color: Color(0xff4F78DA),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/verify.svg',
                                                height: 17,
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text(
                                                'Verified Traveler',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xff4F78DA),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Start The Conversation',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: GradientBoxBorder(
                                                      width: 2.5,
                                                      gradient:
                                                          lefttorightgradient),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      0.17),
                                                  child: TextFormField(
                                                    controller: Message,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    cursorHeight: 23,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Theme.of(context)
                                                              .cardColor,
                                                      enabled: true,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              borderSide:
                                                                  BorderSide(
                                                                      width:
                                                                          0)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              borderSide:
                                                                  BorderSide(
                                                                      width:
                                                                          0)),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 20,
                                                        vertical: 17,
                                                      ),
                                                      hintText:
                                                          'Start The Conversation.................',
                                                      border: InputBorder.none,
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                await Chatrespository()
                                                    .StartConversation(
                                                  widget.id,
                                                  Message
                                                      .text, // Use the saved messageText, not controller.text
                                                  _selectedImageFiles,
                                                );
                                                Get.to(
                                                    () => BottomBar(screen: 3));
                                              },
                                              child: SvgPicture.asset(
                                                'assets/Group 48095829.svg',
                                                height: 61,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 45,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Block & Report',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff001851)),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 45,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/Group 48095816.svg',
                                                height: 41,
                                              ),
                                              SizedBox(
                                                width: 30,
                                              ),
                                              SvgPicture.asset(
                                                'assets/Group 48095815.svg',
                                                height: 41,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  }),
            ),
    );
  }
}
