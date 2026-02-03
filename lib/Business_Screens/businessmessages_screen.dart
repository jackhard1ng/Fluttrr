import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';

import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Models/BusinessModel/BusinessChatModel.dart';

class BusinessmessagesScreen2 extends StatefulWidget {
  const BusinessmessagesScreen2({super.key});

  @override
  State<BusinessmessagesScreen2> createState() =>
      _BusinessmessagesScreen2State();
}

class _BusinessmessagesScreen2State extends State<BusinessmessagesScreen2> {
  BusinessController businessController = Get.put(BusinessController());
  ProfileController profileController = Get.put(ProfileController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    apis();
  }

  void apis() async {
    await businessController.GetBusinessPage();
    await businessController.BusinessChats(
        businessController.businessPageModel?.profile?.id.toString() ?? "",
        "business");
    setState(() {}); // Trigger rebuild after data fetch
  }

  @override
  Widget build(BuildContext context) {
    final chatList = businessController.businessChatList?.chatList ?? [];

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerScreen(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(83),
          child: Businessappbar(
            scaffoldKey: _scaffoldKey,
          )),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SvgPicture.asset(
                  'assets/sea.svg',
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: chatList.isEmpty
                ? Center(child: Text("No Chat Found"))
                : ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      final user = chatList[index];
                      return _buildChatCard(
                        context,
                        name: user.userName ?? "Unknown",
                        lastMessage: user.lastMessage ?? "",
                        image: user.userImage?[0].toString() ?? "",
                        time: formatTimestamp(user.lastMessageTime),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context,
      {required String name,
      required String lastMessage,
      required String time,
      required String image}) {
    return Column(
      children: [
        SizedBox(height: 15),
        ListTile(
          minTileHeight: 50,
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage("${Apis.ip} ${image.toString()}"),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: 13,
                  width: 13,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: whiteColor),
                  child: Center(
                    child: Container(
                      height: 11,
                      width: 11,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xff339003)),
                    ),
                  ),
                ),
              )
            ],
          ),
          title: Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              SvgPicture.asset(
                'assets/verify.svg',
                height: 14,
              )
            ],
          ),
          subtitle: Text(
            lastMessage,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: GradientText(
            time,
            colors: [
              Color(0xff007BFD),
              Color(0xff20235A),
            ],
          ),
          onTap: () {
            // Navigate to the chat detail screen
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => ChatScreen(providerName: name),
            // ));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80, right: 20),
          child: Divider(
            color: Colors.grey.withOpacity(0.3),
          ),
        )
      ],
    );
  }

  String formatTimestamp(LastMessageTime? time) {
    if (time == null || time.iSeconds == null) return "";
    final dateTime = DateTime.fromMillisecondsSinceEpoch(time.iSeconds! * 1000);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return "${dateTime.day}/${dateTime.month}";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}h ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
