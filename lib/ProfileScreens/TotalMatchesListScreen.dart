import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

class Totalmatcheslistscreen extends StatefulWidget {
  const Totalmatcheslistscreen({super.key});

  @override
  State<Totalmatcheslistscreen> createState() => _TotalmatcheslistscreenState();
}

class _TotalmatcheslistscreenState extends State<Totalmatcheslistscreen> {
  ProfileController controller = Get.put(ProfileController());
  int selectedIndex = 2;
  @override
  void initState() {
    super.initState();
    controller.TotalMatchesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75), child: CustomAppbar()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GetBuilder<ProfileController>(
                id: "Profile_update",
                builder: (_) {
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          controller.totalMatchListModel?.likedMates?.length ??
                              0,
                      itemBuilder: (BuildContext context, int index) {
                        final image = (controller
                                    .totalMatchListModel
                                    ?.likedMates?[index]
                                    .liked
                                    ?.userProfile
                                    ?.images
                                    ?.isNotEmpty ??
                                false)
                            ? controller.totalMatchListModel!.likedMates![index]
                                .liked!.userProfile?.images![0]
                            : "";

                        final name = controller.totalMatchListModel
                            ?.likedMates?[index].liked?.userName;
                        final age = controller.totalMatchListModel
                            ?.likedMates?[index].liked?.userProfile?.age;
                        final online = controller.totalMatchListModel
                            ?.likedMates?[index].liked?.onlineStatus;
                        final usertype = controller.totalMatchListModel
                            ?.likedMates?[index].liked?.onlineStatus;
                        final interest = controller
                            .totalMatchListModel
                            ?.likedMates?[index]
                            .liked
                            ?.userProfile
                            ?.interests?[0];
                        final verified = controller.totalMatchListModel
                            ?.likedMates?[index].liked?.userProfile?.status;

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 15),
                          child: Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: GradientBoxBorder(
                                    gradient: toptobottomgradient, width: 2.1),
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Color(0xff4F78DA),
                                  Color(0xff000000).withOpacity(0.49),
                                ])),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                      BorderRadius.circular(30),
                                                  color: whiteColor),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Center(
                                                    child: Text(
                                                  '$interest',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff930000)),
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
                                            padding: const EdgeInsets.symmetric(
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SvgPicture.asset(
                                      'assets/Group 48096085.svg'),
                                ),
                              ],
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

  // void modalBottomSheet() {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (BuildContext context,
  //             StateSetter setState /*You can rename this!*/) {
  //           return Container(
  //             color: Colors.transparent,
  //             child: Padding(
  //               padding: const EdgeInsets.only(top: 21),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                       right: 21,
  //                       left: 21,
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           'Sort Matches:',
  //                           style: TextStyle(
  //                             fontSize: 15,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         SvgPicture.asset(
  //                           'assets/Group 48096193.svg',
  //                           height: 25,
  //                           color: Theme.of(context).primaryColor,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 21,
  //                   ),
  //                   Container(
  //                     height: 3,
  //                     width: double.infinity,
  //                     decoration: BoxDecoration(
  //                       gradient: lefttorightgradient,
  //                     ),
  //                   ),
  //                   ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: sortMatches.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return GestureDetector(
  //                           onTap: () async {
  //                             setState(() {
  //                               selectedIndex = index;
  //                             });
  //
  //                             if (index == 0) {
  //                               await matescontroller.MatesMatchActiveList();
  //                             } else if (index == 1) {
  //                               await matescontroller.MatesMatchRecentlyList();
  //                             } else {
  //                               await matescontroller.MatesMatchList();
  //                             }
  //                           },
  //                           child: Padding(
  //                             padding: const EdgeInsets.only(
  //                                 left: 20, right: 20, top: 20),
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                   border: GradientBoxBorder(
  //                                       width: 2.1,
  //                                       gradient: lefttorightgradient),
  //                                   gradient: selectedIndex == index
  //                                       ? lefttorightgradient
  //                                       : lefttorightgradient.withOpacity(0.3)),
  //                               child: ListTile(
  //                                 leading: Text(
  //                                   sortMatches[index],
  //                                   style: TextStyle(
  //                                       fontSize: 17,
  //                                       color: selectedIndex == index
  //                                           ? Colors.white
  //                                           : Colors.black),
  //                                 ),
  //                                 trailing: selectedIndex == index
  //                                     ? Container(
  //                                   height: 39,
  //                                   width: 39,
  //                                   decoration: BoxDecoration(
  //                                       shape: BoxShape.circle,
  //                                       color: whiteColor),
  //                                   child: Center(
  //                                     child: SvgPicture.asset(
  //                                       'assets/Group 48095854 (3).svg',
  //                                       height: 21,
  //                                     ),
  //                                   ),
  //                                 )
  //                                     : Container(
  //                                   height: 39,
  //                                   width: 39,
  //                                   decoration: BoxDecoration(
  //                                       shape: BoxShape.circle,
  //                                       color: whiteColor),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       }),
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }
}
