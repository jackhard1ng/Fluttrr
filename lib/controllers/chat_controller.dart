import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_endpoints.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';

/// Chat controller with Socket.IO support
class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();

  // Socket connection
  io.Socket? _socket;
  final RxBool isConnected = false.obs;

  // State
  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxList<GroupChat> groupChats = <GroupChat>[].obs;
  final RxList<ChatConversation> businessChats = <ChatConversation>[].obs;
  final RxList<ChatMessage> currentMessages = <ChatMessage>[].obs;

  final Rx<ChatConversation?> currentConversation = Rx<ChatConversation?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();

  // Current user ID
  int? _currentUserId;

  // Hive box for message caching
  Box? _chatBox;
  Box? _deletedMessagesBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
    loadChatList();
  }

  @override
  void onClose() {
    _disconnectSocket();
    messageController.dispose();
    super.onClose();
  }

  /// Initialize Hive boxes
  Future<void> _initHive() async {
    try {
      _chatBox = Hive.box('chatBox');
      _deletedMessagesBox = Hive.box('deleted_messages');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  /// Set current user ID and connect socket
  void initialize(int userId) {
    _currentUserId = userId;
    _connectSocket();
  }

  /// Connect to Socket.IO server
  void _connectSocket() {
    if (_currentUserId == null) return;

    try {
      final socket = io.io(
        ApiEndpoints.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'userId': _currentUserId.toString()})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _socket = socket;

      socket.onConnect((_) {
        debugPrint('Socket connected');
        isConnected.value = true;
      });

      socket.onDisconnect((_) {
        debugPrint('Socket disconnected');
        isConnected.value = false;
      });

      socket.on('newMessage', _handleNewMessage);
      socket.on('messageRead', _handleMessageRead);
      socket.on('typing', _handleTyping);

      socket.connect();
    } catch (e) {
      debugPrint('Socket connection error: $e');
    }
  }

  /// Disconnect socket and unregister all event listeners
  void _disconnectSocket() {
    // Unregister all event listeners to prevent memory leaks
    _socket?.off('newMessage');
    _socket?.off('messageRead');
    _socket?.off('typing');
    _socket?.off('connect');
    _socket?.off('disconnect');

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  /// Handle incoming message
  void _handleNewMessage(dynamic data) {
    try {
      final message = ChatMessage.fromJson(data as Map<String, dynamic>);

      // Add to current messages if in the same conversation
      final conv = currentConversation.value;
      if (conv != null &&
          (message.senderId == conv.otherUserId ||
              message.receiverId == conv.otherUserId)) {
        currentMessages.add(message);
      }

      // Update conversation list
      _updateConversationWithNewMessage(message);

      // Cache message
      _cacheMessage(message);
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }

  /// Handle message read event
  void _handleMessageRead(dynamic data) {
    try {
      final senderId = data['senderId'] as int?;
      if (senderId != null) {
        // Update messages as read - create a new list to avoid concurrent modification
        final updatedMessages = currentMessages.map((message) {
          if (message.senderId == _currentUserId && !message.isRead) {
            return message.copyWith(isRead: true);
          }
          return message;
        }).toList();
        currentMessages.value = updatedMessages;
      }
    } catch (e) {
      debugPrint('Error handling message read: $e');
    }
  }

  /// Handle typing event
  void _handleTyping(dynamic data) {
    // Handle typing indicator
    // Can be expanded to show "User is typing..." UI
  }

  /// Update conversation with new message
  void _updateConversationWithNewMessage(ChatMessage message) {
    final userId = message.senderId == _currentUserId
        ? message.receiverId
        : message.senderId;

    final index = conversations.indexWhere((c) => c.otherUserId == userId);
    // Double-check bounds to prevent race conditions with reactive lists
    if (index != -1 && index < conversations.length) {
      final conv = conversations[index];
      final updatedConversation = ChatConversation(
        conversationId: conv.conversationId,
        otherUserId: conv.otherUserId,
        otherUserName: conv.otherUserName,
        otherUserImages: conv.otherUserImages,
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
        unreadCount: message.senderId != _currentUserId
            ? conv.unreadCount + 1
            : conv.unreadCount,
        isOnline: conv.isOnline,
      );

      // Move to top - wrap in try-catch to handle race conditions (#79)
      try {
        if (index < conversations.length) {
          conversations.removeAt(index);
          conversations.insert(0, updatedConversation);
        }
      } catch (e) {
        // List was modified during operation, just log and continue
        debugPrint('ChatController: Race condition in list update: $e');
      }
    }
  }

  /// Load chat list
  Future<void> loadChatList() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _chatRepository.getChatList();
      final data = response.data;
      if (response.success && data != null) {
        conversations.value = data;
      } else {
        errorMessage.value = response.displayMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load chats. Please try again.';
      debugPrint('Error loading chat list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load group chats
  Future<void> loadGroupChats() async {
    try {
      final response = await _chatRepository.getGroupChatList();
      final data = response.data;
      if (response.success && data != null) {
        groupChats.value = data;
      }
    } catch (e) {
      debugPrint('Error loading group chats: $e');
    }
  }

  /// Load business chats
  Future<void> loadBusinessChats() async {
    try {
      final response = await _chatRepository.getBusinessChatList();
      final data = response.data;
      if (response.success && data != null) {
        businessChats.value = data;
      }
    } catch (e) {
      debugPrint('Error loading business chats: $e');
    }
  }

  /// Open conversation
  Future<void> openConversation(ChatConversation conversation) async {
    currentConversation.value = conversation;
    currentMessages.clear();

    // Load cached messages
    _loadCachedMessages(conversation.otherUserId);

    // Mark as read
    if (conversation.otherUserId != null && conversation.unreadCount > 0) {
      await markAsRead(conversation.otherUserId!);
    }
  }

  /// Close conversation
  void closeConversation() {
    currentConversation.value = null;
    currentMessages.clear();
  }

  /// Send message
  Future<bool> sendMessage({String? content, String? imageUrl}) async {
    final text = content ?? messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return false;
    final conv = currentConversation.value;
    if (conv == null || conv.otherUserId == null) return false;

    if (_currentUserId == null) {
      isSending.value = false;
      return false;
    }

    isSending.value = true;
    messageController.clear();

    // Add optimistic message
    final tempMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId!,
      receiverId: conv.otherUserId,
      content: text.isNotEmpty ? text : null,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isSent: false,
    );
    currentMessages.add(tempMessage);

    try {
      final response = await _chatRepository.sendMessage(
        receiverId: conv.otherUserId!,
        content: text,
        imageUrl: imageUrl,
      );

      isSending.value = false;

      if (response.success) {
        // Update optimistic message
        final index = currentMessages.indexWhere(
            (m) => m.messageId == tempMessage.messageId);
        final messageData = response.data;
        if (index != -1 && messageData != null) {
          currentMessages[index] = messageData;
          _cacheMessage(messageData);
        }
        return true;
      } else {
        // Remove failed message
        currentMessages.removeWhere((m) => m.messageId == tempMessage.messageId);
        return false;
      }
    } catch (e) {
      isSending.value = false;
      currentMessages.removeWhere((m) => m.messageId == tempMessage.messageId);
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(int senderId) async {
    try {
      await _chatRepository.markAsRead(senderId: senderId);

      // Update conversation unread count
      final index = conversations.indexWhere((c) => c.otherUserId == senderId);
      // Double-check bounds to prevent race conditions with reactive lists
      if (index != -1 && index < conversations.length) {
        final conv = conversations[index];
        conversations[index] = ChatConversation(
          conversationId: conv.conversationId,
          otherUserId: conv.otherUserId,
          otherUserName: conv.otherUserName,
          otherUserImages: conv.otherUserImages,
          lastMessage: conv.lastMessage,
          lastMessageTime: conv.lastMessageTime,
          unreadCount: 0,
          isOnline: conv.isOnline,
        );
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  /// Send typing indicator
  void sendTypingIndicator() {
    final socket = _socket;
    final conv = currentConversation.value;
    final otherUserId = conv?.otherUserId;
    if (socket != null && otherUserId != null && _currentUserId != null) {
      socket.emit('typing', {
        'senderId': _currentUserId,
        'receiverId': otherUserId,
      });
    }
  }

  /// Cache message locally
  void _cacheMessage(ChatMessage message) {
    try {
      final key = '${message.senderId}_${message.receiverId}_${message.messageId}';
      _chatBox?.put(key, message.toJson());
    } catch (e) {
      debugPrint('Error caching message: $e');
    }
  }

  /// Load cached messages
  void _loadCachedMessages(int? userId) {
    final chatBox = _chatBox;
    if (userId == null || chatBox == null) return;

    try {
      final messages = <ChatMessage>[];

      for (var key in chatBox.keys) {
        final keyStr = key.toString();
        if (keyStr.contains('${_currentUserId}_$userId') ||
            keyStr.contains('${userId}_$_currentUserId')) {
          final data = chatBox.get(key);
          if (data != null) {
            messages.add(ChatMessage.fromJson(Map<String, dynamic>.from(data)));
          }
        }
      }

      // Sort by timestamp
      messages.sort((a, b) =>
          (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));

      currentMessages.value = messages;
    } catch (e) {
      debugPrint('Error loading cached messages: $e');
    }
  }

  /// Delete message locally
  void deleteMessage(String messageId) {
    currentMessages.removeWhere((m) => m.messageId == messageId);
    _deletedMessagesBox?.put(messageId, true);
  }

  /// Refresh chat list
  Future<void> refreshChatList() async {
    await loadChatList();
  }

  // Getters
  int get totalUnreadCount =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  bool get hasUnreadMessages => totalUnreadCount > 0;
}
