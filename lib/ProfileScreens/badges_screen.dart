import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/ProfileScreens/leaderboard_screen.dart';

import '../Controller/ProfileController.dart';
import '../Models/BadgesModel/BadgesModel.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  int selectedIndex1 = 0;
  List status = ['Badges', 'Leaderboard'];
  final _fromTop = true;

  @override
  void initState() {
    super.initState();
    _profileController.Badgeslist();
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Achievements & Rewards',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        id: 'Activity_update',
        builder: (controller) {
          if (controller.badgesModel?.achievements == null) {
            return Center(child: CircularProgressIndicator());
          }

          final badges = controller.badgesModel!.achievements!;
          final unlockedBadges =
              badges.where((badge) => badge.unlocked == true).length;
          final claimedBadges =
              badges.where((badge) => badge.hasClaimed == true).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  // Toggle between Badges and Leaderboard
                  _buildToggleSection(),
                  SizedBox(height: 20),

                  // Unlocked badges count
                  Text(
                    '$unlockedBadges',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Badges Unlocked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Recently unlocked badges
                  _buildRecentBadgesSection(claimedBadges),

                  // All achievements header
                  _buildAllAchievementsHeader(),
                  SizedBox(height: 10),

                  // All badges list
                  _buildAllBadgesList(badges),
                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffF1F1F1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: status.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisExtent: 57,
              ),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex1 = index;
                    if (index == 1) {
                      Get.offAll(() => LeaderboardScreen());
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
                    borderRadius: BorderRadius.circular(30),
                  ),
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
    );
  }

  Widget _buildRecentBadgesSection(List<Achievements> claimedBadges) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: claimedBadges.isEmpty
          ? Center(child: Text("No badges claimed yet"))
          : Stack(
              children: [
                if (claimedBadges.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Column(
                      children: [
                        Card(
                          color: whiteColor,
                          elevation: 4,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Apis.ip}${claimedBadges[0].icon}"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          claimedBadges[0].name ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Claimed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (claimedBadges.length >= 2)
                  Positioned(
                    left: 20,
                    top: 50,
                    child: Column(
                      children: [
                        Card(
                          color: whiteColor,
                          elevation: 4,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Apis.ip}${claimedBadges[0].icon}"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          claimedBadges[1].name ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Claimed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (claimedBadges.length >= 3)
                  Positioned(
                    right: 20,
                    top: 50,
                    child: Column(
                      children: [
                        Card(
                          color: whiteColor,
                          elevation: 4,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Apis.ip}${claimedBadges[0].icon}"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          claimedBadges[2].name ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Claimed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAllAchievementsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Achievements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        GradientText(
          'See All',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          colors: [
            Color(0xff007BFD),
            Color(0xff20235A),
          ],
        ),
      ],
    );
  }

  Widget _buildAllBadgesList(List<Achievements> badges) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: badges.length,
      itemBuilder: (BuildContext context, int index) {
        final badge = badges[index];
        return Padding(
          padding: const EdgeInsets.only(top: 13),
          child: Container(
            height: 110, // Increased height to accommodate progress bar
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffF1F1F1),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 4, right: 16, top: 3, bottom: 3),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Badge icon
                        Card(
                          color: whiteColor,
                          elevation: 4,
                          child: Container(
                            margin: EdgeInsets.all(7),
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage("${Apis.ip}${badge.icon}"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 13),

                        // Badge details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                badge.name ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 7),
                              Text(
                                badge.description ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),

                        // Claim button or status
                        _buildBadgeStatus(badge),
                      ],
                    ),
                  ),

                  // Progress bar for unlocked but unclaimed badges
                  if (badge.unlocked == true && badge.hasClaimed == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: LinearProgressIndicator(
                        value: (badge.progress ?? 0) / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeStatus(Achievements badge) {
    if (badge.unlocked == true) {
      if (badge.hasClaimed == true) {
        return GradientText(
          'Claimed',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          colors: [
            Color(0xff007BFD),
            Color(0xff20235A),
          ],
        );
      } else {
        return InkWell(
          onTap: () => _claimBadge(badge),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: lefttorightgradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Claim',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } else {
      return Column(
        children: [
          Text(
            '${badge.progress ?? 0}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            'Locked',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
  }

  void _claimBadge(Achievements badge) async {
    try {
      // Call your API to claim the badge here
      // First show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      bool success =
          await _profileController.BadgesClaimed(badge.id.toString());

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Refresh the data
        await _profileController.Badgeslist();

        // Show success dialog
        _showClaimSuccessDialog(badge);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to claim badge. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  void _showClaimSuccessDialog(Achievements badge) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: Offset(0, _fromTop ? -1 : 1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      barrierColor: Colors.black.withOpacity(0.6),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Theme.of(context).cardColor,
            ),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge image
                      Card(
                        color: whiteColor,
                        elevation: 4,
                        child: Container(
                          margin: EdgeInsets.all(15),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage("${Apis.ip}${badge.icon}"),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Congratulations text
                      SvgPicture.asset(
                        'assets/Congrats!.svg',
                        height: 40,
                      ),
                      SizedBox(height: 16),

                      // Badge name
                      Text(
                        badge.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'You have successfully claimed this badge!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),

                // Close button (positioned at bottom)
                Button(
                  width: double.infinity,
                  height: 64,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
