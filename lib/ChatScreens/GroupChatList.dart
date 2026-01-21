import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/ChatScreens/GroupMessageScreen.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Controller/ChatsListController.dart';

import '../Controller/ProfileController.dart';

class Groupchatlist extends StatefulWidget {
  const Groupchatlist({super.key});

  @override
  State<Groupchatlist> createState() => _GroupchatlistState();
}

class _GroupchatlistState extends State<Groupchatlist> {
  final ChatsListController controller = Get.put(ChatsListController());
  ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    controller.GroupList();
    profileController.GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ChatsListController>(
          id: "updateChats",
          builder: (context) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: controller.groupChatList?.groupList?.length ?? 0,
              itemBuilder: (context, index) {
                final chat = controller.groupChatList?.groupList?[index];

                if (chat == null) return const SizedBox.shrink();

                return _buildChatCard(context,
                    name: chat.groupName ?? "",
                    Groupid: chat.groupId.toString(),
                    id: chat.groupId.toString(),
                    currentUser:
                        profileController.profile?.userId.toString() ?? "",
                    imageUrl:
                        (chat.groupImage != null && chat.groupImage!.isNotEmpty)
                            ? chat.groupImage![0].toString()
                            : "",
                    lastMessage: chat.lastMessage.toString(),
                    time: _formatTime(chat.lastMessageTime),
                    status: "Expired",
                    unreadMessages: chat.unreadMessages.toString());
              },
            );
          }),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";

    try {
      DateTime messageTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));

      if (messageTime.year == now.year &&
          messageTime.month == now.month &&
          messageTime.day == now.day) {
        return DateFormat('h:mm a').format(messageTime); // "3:45 PM"
      } else if (messageTime.year == yesterday.year &&
          messageTime.month == yesterday.month &&
          messageTime.day == yesterday.day) {
        return "Yesterday";
      } else {
        return DateFormat('dd/MM/yyyy').format(messageTime); // "12/03/2025"
      }
    } catch (e) {
      return "";
    }
  }

  Widget _buildChatCard(
    BuildContext context, {
    required String imageUrl,
    required String id,
    required String unreadMessages,
    required String Groupid,
    required String currentUser,
    required String name,
    required String lastMessage,
    required String time,
    required String status,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage("${Apis.ip} $imageUrl")
                    : null, // Set only if available
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 28, color: Colors.white)
                    : null,
              ),
              if (status == "Active")
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: const Color(0xff339003),
                    ),
                  ),
                ),
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
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 5),
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientText(time, colors: const [
                Color(0xff007BFD),
                Color(0xff20235A),
              ]),
              const SizedBox(height: 5),
              if (unreadMessages != "0")
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xff007BFD), Color(0xff20235A)],
                    ),
                  ),
                  child: Text(
                    unreadMessages,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Groupmessagescreen(
                      providerName: name,
                      conversationId: Groupid,
                      currentuserid: currentUser,
                      reciverid: id,
                      image: imageUrl)
                  // Groupmessagescreen(Image: "", Name: name, converstaionid: Groupid, isonline: "Active", reciverid: "17")
                  // ChatScreen(providerName: name, receiverId: id,Image:imageUrl ,Online:status ,CurrentUser: "17",Conversationid:conversationid ,),
                  // ChatScreen(Image: imageUrl, Name: name, converstaionid: conversationid, isonline: status,reciverid: id,)
                  ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(left: 80, right: 20),
          child: Divider(
            color: Colors.grey,
            thickness: 0.3,
          ),
        ),
      ],
    );
  }
}
