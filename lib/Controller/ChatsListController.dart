import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Models/ChatListModel.dart';
import 'package:fluttrr/Repository/ChatRepository.dart';

import '../Models/GroupChatList.dart';

class ChatsListController extends GetxController {
  ChatListModel? chatListModel; // Removed Rxn
  GroupChatList? groupChatList;

  // Add this method to get unread message count
  Future<int> getUnreadMessageCount(
      String conversationId, String currentUserId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .where('isSeen', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error getting unread count: $e");
      return 0;
    }
  }

  //.............................Get Chats List...........................
  Future<bool> Chatlist() async {
    final profile = await Chatrespository().ChatList();
    print("Profile Fetch is : $profile");

    if (profile == null) {
      return false;
    } else {
      chatListModel = ChatListModel.fromJson(profile); // Directly assign value
      update(["updateChats"]); // Notify GetX listeners
      return true;
    }
  }

  //.............................Get Chats List...........................
  Future<bool> GroupList() async {
    final profile = await Chatrespository().GroupList();
    print("Profile Fetch is : $profile");

    if (profile == null) {
      return false;
    } else {
      groupChatList = GroupChatList.fromJson(profile); // Directly assign value
      update(["updateChats"]); // Notify GetX listeners
      return true;
    }
  }

  //.............................Mark as Read...........................
  Future<bool> MarkAsRead(String senderid) async {
    final profile = await Chatrespository().MarkasRead(senderid);
    print("Profile Fetch is : $profile");

    if (profile == null) {
      return false;
    } else {
      // chatListModel = ChatListModel.fromJson(profile); // Directly assign value
      update(["updateChats"]); // Notify GetX listeners
      return true;
    }
  }
}
