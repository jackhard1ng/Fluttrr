import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Mates_Screens/SetLocation.dart';
import 'package:fluttrr/Mates_Screens/matesmatches_screen.dart';
import 'package:fluttrr/Mates_Screens/mateswhoisaround_filters.dart';

import '../Constants/Apis_Constants.dart';
import '../Controller/MatesController.dart';
import '../Home_Screen/userinfo_screen.dart';

class MateswhoisaroundScreen extends StatefulWidget {
  const MateswhoisaroundScreen({super.key});

  @override
  State<MateswhoisaroundScreen> createState() => _MateswhoisaroundScreenState();
}

class _MateswhoisaroundScreenState extends State<MateswhoisaroundScreen> {
  Matescontroller matescontroller = Get.put(Matescontroller());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apis();
  }

  void apis() async {
    await matescontroller.MatesFilter("", "", "", "", [], "", []);
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
                      Container(
                        height: 39,
                        width: 130,
                        decoration: BoxDecoration(
                          gradient: lefttorightgradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(
                          'Who’s Around',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: whiteColor),
                        )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAll(() => MatesmatchesScreen());
                        },
                        child: Container(
                          height: 39,
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: lefttorightgradient.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(
                            ' Matches',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                          )),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => MateswhoisaroundFilters());
                    },
                    child: SvgPicture.asset(
                      'assets/j.svg',
                      height: 30,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Container(
                width: double.infinity,
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetBuilder<Matescontroller>(
                        id: "Profile_update",
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: (matescontroller
                                        .matesFilterModel?.mates?.isEmpty ??
                                    true)
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Ops: No Mate is Found"),
                                        Image.asset(
                                          "assets/NoData.png",
                                          width: 300,
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    height: 600,
                                    width: double.infinity,
                                    child: CardSwiper(
                                      cardsCount: (matescontroller
                                                      .matesFilterModel
                                                      ?.mates
                                                      ?.length ??
                                                  0) <
                                              2
                                          ? 2 // Ensuring at least 2 cards
                                          : matescontroller
                                              .matesFilterModel!.mates!.length,
                                      cardBuilder: (context,
                                          index,
                                          percentThresholdX,
                                          percentThresholdY) {
                                        if (matescontroller
                                                    .matesFilterModel?.mates !=
                                                null &&
                                            index <
                                                matescontroller
                                                    .matesFilterModel!
                                                    .mates!
                                                    .length) {
                                          final user = matescontroller
                                              .matesFilterModel!.mates![index];
                                          final name =
                                              user.userName ?? "Unknown";
                                          final age = user.userProfile?.age
                                                  .toString() ??
                                              "N/A";
                                          final id =
                                              user.userID?.toString() ?? "N/A";
                                          final gender =
                                              user.userProfile?.gender ?? "N/A";
                                          final isliked =
                                              user.hasLiked ?? false;
                                          print(
                                              "is liked for te $name : $isliked");
                                          final image = (user.userProfile
                                                      ?.images?.isNotEmpty ??
                                                  false)
                                              ? NetworkImage(
                                                  "${Apis.ip}${user.userProfile?.images!.first}")
                                              : AssetImage(
                                                      'assets/Group 48095841.png')
                                                  as ImageProvider;
                                          final image2 = user
                                              .userProfile?.countryFlag
                                              .toString();

                                          return buildCard(
                                              id,
                                              name,
                                              age,
                                              gender,
                                              image,
                                              image2.toString(),
                                              isliked,
                                              context);
                                        } else {
                                          // Default fallback cards when users are less than 2
                                          return buildCard(
                                              "1",
                                              "Harry",
                                              "N/A",
                                              "N/A",
                                              AssetImage(
                                                  'assets/Group 48095841.png'),
                                              "assets/Group 48095841.png",
                                              false,
                                              context);
                                        }
                                      },
                                    ),
                                  ),
                          );
                        }),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              color: Color(0xffF1F1F1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 279,
                          child: Text(
                            'Meeting new people in your city?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 279,
                          child: Text(
                            'Set your location radius to connect with others nearby or in your next destination.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff4D4D4D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.offAll(() => MatesMapScreen());
                      },
                      child: GradientText(
                        'Set Location',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                        colors: [
                          Color(0xff4F78DA),
                          Color(0xff339003),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildCard(String id, String name, String age, String gender,
    ImageProvider image, String image2, bool Isliked, BuildContext context) {
  Matescontroller matescontroller = Get.put(Matescontroller());

  return InkWell(
    onTap: () {
      Get.to(() => UserinfoScreen(
            id: id,
          ));
    },
    child: Container(
      width: double.infinity,
      height: 410,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: image,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle, // Makes it fully circular
                  ),
                  child: ClipOval(
                    child: SvgPicture.network(
                      image2.toString(), // Replace with your SVG URL
                      fit: BoxFit
                          .cover, // Ensures it fills the container properly
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$name, $age, $gender',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        SizedBox(width: 7),
                        SvgPicture.asset('assets/Vector (2).svg', height: 19),
                      ],
                    ),
                    SizedBox(height: 7),
                    Container(
                      height: 27,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff4F78DA),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/h.svg', height: 13),
                            SizedBox(width: 5),
                            Text('Local',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () async {
                      // await matescontroller.LikedMates(id,context);
                      // await matescontroller.MatesFilter("20", "50", "both", "All", ["english"], "traveling");
                    },
                    child: SvgPicture.asset('assets/Group 48095816.svg',
                        height: 41)),
                SizedBox(width: 30),
                InkWell(
                    onTap: () async {
                      print("The is liked : $Isliked");
                      await matescontroller.LikedMates(id, context);
                      await matescontroller.MatesFilter(
                          "", "", "", "", [""], "", []);
                    },
                    child: Isliked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 40,
                          )
                        : SvgPicture.asset('assets/Group 48095815.svg',
                            height: 41)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
