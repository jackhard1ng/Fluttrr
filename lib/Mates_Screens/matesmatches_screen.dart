import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Controller/MatesController.dart';
import '../Home_Screen/userinfo_screen.dart';
import '../Repository/ChatRespository.dart';

class MatesmatchesScreen extends StatefulWidget {
  const MatesmatchesScreen({super.key});

  @override
  State<MatesmatchesScreen> createState() => _MatesmatchesScreenState();
}

class _MatesmatchesScreenState extends State<MatesmatchesScreen> {
  Matescontroller matescontroller = Get.put(Matescontroller());
  int selectedIndex = 2;
  final List<File> _selectedImageFiles = [];

  List sortMatches = [
    'Recently Active',
    'Joined Recently',
    'All',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    matescontroller.MatesMatchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75), child: CustomAppbar()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.offAll(() => BottomBar(screen: 1));
                        },
                        child: Container(
                          height: 39,
                          width: 130,
                          decoration: BoxDecoration(
                            gradient: lefttorightgradient.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(
                            'Who’s Around',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 39,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: lefttorightgradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(
                          ' Matches',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      modalBottomSheet();
                    },
                    child: SvgPicture.asset(
                      'assets/Group 48095852.svg',
                      height: 30,
                    ),
                  )
                ],
              ),
            ),
            GetBuilder<Matescontroller>(
                id: "Profile_update",
                builder: (_) {
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          matescontroller.matesMatchModel?.mates?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        final image = (matescontroller
                                    .matesMatchModel
                                    ?.mates?[index]
                                    .userProfile
                                    ?.images
                                    ?.isNotEmpty ??
                                false)
                            ? matescontroller.matesMatchModel!.mates![index]
                                .userProfile!.images![0]
                            : "";

                        final name = matescontroller
                            .matesMatchModel?.mates?[index].userName
                            .toString();
                        final age = matescontroller
                            .matesMatchModel?.mates?[index].userProfile?.age
                            .toString();
                        final online = matescontroller
                            .matesMatchModel?.mates?[index].onlineStatus;
                        final usertype = matescontroller
                            .matesMatchModel?.mates?[index].onlineStatus;
                        final interest = matescontroller.matesMatchModel
                            ?.mates?[index].userProfile?.interests?[0]
                            .toString();
                        final verified = matescontroller
                            .matesMatchModel?.mates?[index].verified;
                        final id = matescontroller
                            .matesMatchModel?.mates?[index].userID;

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 15),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => UserinfoScreen(
                                    id: id.toString(),
                                  ));
                            },
                            child: Container(
                              height: 110,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: GradientBoxBorder(
                                      gradient: toptobottomgradient,
                                      width: 2.1),
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Color(0xff4F78DA),
                                    Color(0xff000000).withOpacity(0.49),
                                  ])),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      CircleAvatar(
                                        radius: 33,
                                        backgroundImage:
                                            NetworkImage('${Apis.ip}$image'),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 17,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: whiteColor),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Center(
                                                      child: Text(
                                                    '$interest',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff930000)),
                                                  )),
                                                ),
                                              ),
                                              Text(
                                                online == true
                                                    ? "      Online"
                                                    : '      Offline',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff339003)),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '$name, $age',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: whiteColor),
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              verified == true
                                                  ? SvgPicture.asset(
                                                      'assets/verify.svg',
                                                      height: 19,
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Container(
                                            height: 27,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Color(0xff339003),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/Vector (3).svg',
                                                    height: 13,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'Traveler',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: whiteColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Chatrespository().StartConversation(
                                        matescontroller.matesMatchModel
                                                ?.mates?[index].userID
                                                .toString() ??
                                            "",
                                        "Hey Mate", // Use the saved messageText, not controller.text
                                        _selectedImageFiles,
                                      );
                                      Get.to(() => BottomBar(screen: 3));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: SvgPicture.asset(
                                          'assets/Group 48096085.svg'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  void modalBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(top: 21),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 21,
                        left: 21,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort Matches:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/Group 48096193.svg',
                            height: 25,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 21,
                    ),
                    Container(
                      height: 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: lefttorightgradient,
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortMatches.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                selectedIndex = index;
                              });

                              if (index == 0) {
                                await matescontroller.MatesMatchActiveList();
                              } else if (index == 1) {
                                await matescontroller.MatesMatchRecentlyList();
                              } else {
                                await matescontroller.MatesMatchList();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: GradientBoxBorder(
                                        width: 2.1,
                                        gradient: lefttorightgradient),
                                    gradient: selectedIndex == index
                                        ? lefttorightgradient
                                        : lefttorightgradient.withOpacity(0.3)),
                                child: ListTile(
                                  leading: Text(
                                    sortMatches[index],
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: selectedIndex == index
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  trailing: selectedIndex == index
                                      ? Container(
                                          height: 39,
                                          width: 39,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: whiteColor),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/Group 48095854 (3).svg',
                                              height: 21,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 39,
                                          width: 39,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: whiteColor),
                                        ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            );
          });
        });
  }
}
