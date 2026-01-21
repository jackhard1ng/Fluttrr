import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';

import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Models/BussinessModel/BusinessChatModel.dart';
import 'BusinessChatScreen.dart';

class BusinessmessagesScreen extends StatefulWidget {
  const BusinessmessagesScreen({super.key});

  @override
  State<BusinessmessagesScreen> createState() => _BusinessmessagesScreenState();
}

class _BusinessmessagesScreenState extends State<BusinessmessagesScreen> {
  BusinessController businessController = Get.put(BusinessController());
  ProfileController profileController = Get.put(ProfileController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    apis();
  }

  void apis() async {
    await profileController.GetProfile();
    await businessController.BusinessChats(
        profileController.profile?.userId.toString() ?? "", "user");
    setState(() {}); // Trigger rebuild after data fetch
  }

  @override
  Widget build(BuildContext context) {
    final chatList = businessController.businessChatList?.chatList ?? [];

    return Scaffold(
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
                        name: user.businessName ?? "Unknown",
                        lastMessage: user.lastMessage ?? "",
                        image: user.logo.toString() ?? "",
                        time: formatTimestamp(user.lastMessageTime),
                        bussinesid: user.businessId.toString(),
                        converstaionid: user.conversationId.toString(),
                        currentuser: user.userId.toString(),
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
      required String currentuser,
      required String bussinesid,
      required String converstaionid,
      required String image}) {
    return Column(
      children: [
        SizedBox(height: 15),
        InkWell(
          onTap: () {
            print("hit ho rha a");
            Get.to(() => Groupmessagescreen2(
                  image: image,
                  currentuserid: currentuser,
                  reciverid: bussinesid,
                  providerName: name,
                  conversationId: converstaionid,
                ));
          },
          child: ListTile(
            minTileHeight: 50,
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      NetworkImage("${Apis.ip} ${image.toString()}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: whiteColor),
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
