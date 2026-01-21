import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Constants/listdata.dart';
import 'package:fluttrr/Constants/utils.dart';

class ProfilevieweventScreen extends StatelessWidget {
  const ProfilevieweventScreen({super.key});

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
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                            image: AssetImage(
                                'assets/fantasy-shooting-star-landscape-night (1).png'))),
                    child:
                        Center(child: SvgPicture.asset('assets/Add Photo.svg')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 6),
                    child: CircleAvatar(
                      radius: 49,
                      backgroundImage: AssetImage('assets/Group 48096083.png'),
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
                    'TripMates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    '5 Past Events | 10K followers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Passionate traveler exploring the world, from hidden gems to iconic landmarks. I love embracing new cultures, savoring local cuisines, and chasing unforgettable adventures!',
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).indicatorColor),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 33,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: lightBlue,
                        ),
                        child: Center(
                          child: Text(
                            'Follow Up',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: whiteColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Card(
                          color: whiteColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          child: SvgPicture.asset('assets/cha.svg'))
                    ],
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
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 13),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 183,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            dicoverActivitiesData[index]
                                                .image))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 27,
                                            backgroundImage: AssetImage(
                                                dicoverActivitiesData[index]
                                                    .profile),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 170,
                                                child: Text(
                                                  'Sunrise Yoga in the Park',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/pin.svg',
                                                    height: 14,
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  SizedBox(
                                                    width: 160,
                                                    child: Text(
                                                      'Central Park, Meadow Area',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Friday, February 23, 2025,',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff00D4BD)),
                                                  ),
                                                  Text(
                                                    'at 01:00 PM',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff00D4BD)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              SizedBox(
                                                width: 279,
                                                child: Text(
                                                  'Start your day with a rejuvenatingyoga session surrounded by nature.',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 26,
                                                    width: 26,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Color(0xff5A5A5A)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 26,
                                                        color: whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text(
                                                '08/10 Joined',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: whiteColor),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                height: 21,
                                                width: 49,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.black54),
                                                child: Center(
                                                  child: Text(
                                                    'Skip',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: whiteColor),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  height: 21,
                                                  width: 57,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: Color(0xff007BFD)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Join',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: whiteColor),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      SvgPicture.asset(
                                                          'assets/Group 48096111.svg')
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/Group 48095897.svg',
                                      height: 21,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    SvgPicture.asset(
                                      'assets/Group 48095896.svg',
                                      height: 21,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    SvgPicture.asset(
                                      'assets/l (2).svg',
                                      color: Colors.white,
                                      height: 21,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
