import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Constants/Apis_Constants.dart';
import '../Models/ChatmessageModel.dart';
import 'ProfileController.dart';

class Chatcontroller extends GetxController {
  IO.Socket? _socket;
  ProfileController profileController = Get.put(ProfileController());
  var messages = <MessageModel>[].obs;
  Box? chatBox;
  String? currentConversationId; // Track the currently open chat

  // Initialize Hive and load stored messages for the active chat
  Future<void> initHive(String conversationId) async {
    currentConversationId = conversationId; // Set active chat
    chatBox = await Hive.openBox('chatBox');

    messages.assignAll(chatBox!.values
        .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e), profileController.profile?.userId.toString() ?? ""))
        .where((msg) => msg.conversationId.toString() == conversationId) // Filter messages for active chat
        .toList());

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Initialize Socket.IO connection
  void initSocketIO() {
    try {
      print("🔗 Connecting to Socket.IO with userId: ${profileController.profile!.userId.toString()}");

      _socket = IO.io(
        Apis.ip,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'userId': profileController.profile!.userId.toString()})
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ Socket.IO connected');
        _socket!.emit('fetchPendingMessages', {'userId': profileController.profile!.userId.toString()});
      });

      _socket!.onDisconnect((_) => print('⚠️ Socket.IO disconnected, attempting reconnection...'));

      _socket!.on('newMessage', (data) {
        if (data == null || data is! Map) {
          print('❌ Invalid message data received');
          return;
        }

        final message = MessageModel.fromJson(Map<String, dynamic>.from(data), profileController.profile?.userId.toString() ?? "");

        if (message.conversationId.toString() == currentConversationId) {
          bool exists = messages.any((msg) => msg.id == message.id);
          if (!exists) {
            messages.add(message);
            chatBox!.add(message.toJson());
          } else {
            print("⚠️ Duplicate message detected, not adding to list");
          }
        } else {
          print("📩 Message belongs to another conversation, ignoring...");
        }
      });

      // _socket!.on('pendingMessages', (data) {
      //   if (data == null || data is! List) {
      //     print('❌ Invalid pending messages data received');
      //     return;
      //   }
      //
      //   final List<MessageModel> pendingMessages = data
      //       .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e), profileController.profile?.userId.toString() ?? ""))
      //       .where((msg) => msg.conversationId.toString() == currentConversationId) // Only load messages for the open chat
      //       .toList();
      //
      //   messages.addAll(pendingMessages);
      //   for (var message in pendingMessages) {
      //     chatBox!.add(message.toJson());
      //   }
      // });

      _socket!.onError((error) {
        print('❌ Socket.IO error: $error');
        Future.delayed(Duration(seconds: 2), _reconnectSocket);
      });
    } catch (e) {
      print("❌ Socket.IO connection failed: $e");
    }
  }

  void _reconnectSocket() {
    if (_socket != null) {
      _socket!.dispose();
      initSocketIO();
    }
  }

  // Send message


  // 🔥 Delete a single message
  Future<void> deleteMessage(int messageId) async {
    try {
      messages.removeWhere((msg) => msg.id == messageId);
      final messageIndex = chatBox!.values.toList().indexWhere((element) {
        return MessageModel.fromJson(Map<String, dynamic>.from(element), profileController.profile?.userId.toString() ?? "").id == messageId;
      });

      if (messageIndex != -1) {
        await chatBox!.deleteAt(messageIndex);
      }

      print("✅ Message deleted successfully");
    } catch (e) {
      print("❌ Error deleting message: $e");
    }
  }

  // 🔥 Clear all messages in the active chat
  Future<void> clearAllMessages() async {
    if (currentConversationId == null) {
      print("❌ No active conversation selected, cannot clear messages.");
      return;
    }

    try {
      // Remove only the messages from the active conversation
      messages.removeWhere((msg) => msg.conversationId.toString() == currentConversationId);

      // Filter and delete only the messages related to the current conversation from Hive
      final keysToDelete = chatBox!.keys.where((key) {
        var messageData = chatBox!.get(key);
        if (messageData != null) {
          var message = MessageModel.fromJson(
            Map<String, dynamic>.from(messageData),
            profileController.profile?.userId.toString() ?? "",
          );
          return message.conversationId.toString() == currentConversationId;
        }
        return false;
      }).toList();

      for (var key in keysToDelete) {
        await chatBox!.delete(key);
      }

      print("✅ All messages cleared for conversation: $currentConversationId");
    } catch (e) {
      print("❌ Error clearing messages: $e");
    }
  }


  @override
  void onClose() {
    _socket?.dispose();
    chatBox?.close();
    super.onClose();
  }
}
