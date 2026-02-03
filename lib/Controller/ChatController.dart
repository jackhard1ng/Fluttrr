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
  void initHive(String conversationId) async {
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
        _socket!.emit('fetchPendingMessages', {'userId': profileController.profile!.userId.toString()});
      });

      _socket!.onDisconnect((_) {});

      _socket!.on('newMessage', (data) {
        if (data == null || data is! Map) {
          return;
        }

        final message = MessageModel.fromJson(Map<String, dynamic>.from(data), profileController.profile?.userId.toString() ?? "");

        if (message.conversationId.toString() == currentConversationId) {
          bool exists = messages.any((msg) => msg.id == message.id);
          if (!exists) {
            messages.add(message);
            chatBox!.add(message.toJson());
          }
        }
      });

      _socket!.onError((error) {
        Future.delayed(Duration(seconds: 2), _reconnectSocket);
      });
    } catch (e) {
      // Socket.IO connection failed
    }
  }

  void _reconnectSocket() {
    if (_socket != null) {
      _socket!.dispose();
      initSocketIO();
    }
  }

  // Send message


  // Delete a single message
  Future<void> deleteMessage(int messageId) async {
    try {
      messages.removeWhere((msg) => msg.id == messageId);
      final messageIndex = chatBox!.values.toList().indexWhere((element) {
        return MessageModel.fromJson(Map<String, dynamic>.from(element), profileController.profile?.userId.toString() ?? "").id == messageId;
      });

      if (messageIndex != -1) {
        await chatBox!.deleteAt(messageIndex);
      }
    } catch (e) {
      // Error deleting message
    }
  }

  // Clear all messages in the active chat
  Future<void> clearAllMessages() async {
    if (currentConversationId == null) {
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
    } catch (e) {
      // Error clearing messages
    }
  }


  @override
  void onClose() {
    _socket?.dispose();
    chatBox?.close();
    super.onClose();
  }
}
