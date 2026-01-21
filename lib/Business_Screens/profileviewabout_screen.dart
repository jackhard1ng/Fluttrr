import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';

import 'EditeBussinessPage.dart';

class ProfileviewaboutScreen extends StatefulWidget {
  const ProfileviewaboutScreen({super.key});

  @override
  State<ProfileviewaboutScreen> createState() => _ProfileviewaboutScreenState();
}

class _ProfileviewaboutScreenState extends State<ProfileviewaboutScreen> {
  BusinessController businessController = Get.put(BusinessController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    businessController.GetBusinessPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(),
      appBar: AppBar(
        elevation: 1,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                Get.to(() => EditBusinessPage(
                      businessData: businessController.businessPageModel,
                    ));
              },
              child: SvgPicture.asset(
                'assets/Group 48096067.svg',
                height: 39,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: GetBuilder<BusinessController>(
            id: "Activity_update",
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 53,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 179,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      '${Apis.ip}${businessController.businessPageModel?.profile?.image.toString() ?? ""}'))),
                          child: Center(
                              child: SvgPicture.asset('assets/Add Photo.svg')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 6),
                          child: CircleAvatar(
                            radius: 49,
                            backgroundImage: NetworkImage(
                                '${Apis.ip}${businessController.businessPageModel?.profile?.logo.toString() ?? ""}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 27,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessController.businessPageModel?.profile?.name
                                  .toString() ??
                              "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          '${businessController.businessPageModel?.totalEventsCreated.toString() ?? ""} Past Events | ${businessController.businessPageModel?.totalEventsCreated.toString() ?? ""} followers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          businessController
                                  .businessPageModel?.profile?.description
                                  .toString() ??
                              "",
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).indicatorColor),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 6,
                          color: Color(0xffF1F1F1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              'Events',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: lightBlue),
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              'About',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Contact info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/Group 48096060.svg'),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          businessController.businessPageModel?.profile?.email
                                  .toString() ??
                              "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/Group 48096063.svg'),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          businessController
                                  .businessPageModel?.profile?.phoneNumber
                                  .toString() ??
                              "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/Group 48096064.svg'),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          businessController
                                  .businessPageModel?.profile?.location
                                  .toString() ??
                              "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Social Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                                'assets/7935ec95c421cee6d86eb22ecd133734.svg'),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Website',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          businessController
                                  .businessPageModel?.profile?.websiteLink
                                  .toString() ??
                              "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
