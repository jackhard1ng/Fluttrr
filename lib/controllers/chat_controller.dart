import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_endpoints.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import '../services/mock_data_service.dart';

/// Chat controller with Socket.IO support and mock data fallback
class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();

  /// Flag to use mock data when API fails
  final RxBool useMockData = true.obs;

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
      _socket = io.io(
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

      _socket!.onConnect((_) {
        debugPrint('Socket connected');
        isConnected.value = true;
      });

      _socket!.onDisconnect((_) {
        debugPrint('Socket disconnected');
        isConnected.value = false;
      });

      _socket!.on('newMessage', _handleNewMessage);
      _socket!.on('messageRead', _handleMessageRead);
      _socket!.on('typing', _handleTyping);

      _socket!.connect();
    } catch (e) {
      debugPrint('Socket connection error: $e');
    }
  }

  /// Disconnect socket
  void _disconnectSocket() {
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
      if (currentConversation.value != null &&
          (message.senderId == currentConversation.value!.otherUserId ||
              message.receiverId == currentConversation.value!.otherUserId)) {
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
        // Update messages as read
        for (var i = 0; i < currentMessages.length; i++) {
          if (currentMessages[i].senderId == _currentUserId &&
              !currentMessages[i].isRead) {
            currentMessages[i] = currentMessages[i].copyWith(isRead: true);
          }
        }
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
    if (index != -1) {
      final conv = conversations[index];
      conversations[index] = ChatConversation(
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

      // Move to top
      final conversation = conversations.removeAt(index);
      conversations.insert(0, conversation);
    }
  }

  /// Load chat list (with mock data fallback)
  Future<void> loadChatList() async {
    isLoading.value = true;

    try {
      final response = await _chatRepository.getChatList();
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        conversations.value = response.data!;
        useMockData.value = false;
      } else {
        _loadMockChats();
      }
    } catch (e) {
      _loadMockChats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load mock chats for demo
  void _loadMockChats() {
    useMockData.value = true;
    final mockData = MockDataService.generateMockChats(10);

    conversations.value = mockData.map((data) => ChatConversation(
      conversationId: data['chatId']?.toString(),
      otherUserId: data['otherUserId'] as int,
      otherUserName: data['otherUserName'] as String,
      otherUserImages: [data['otherUserImage'] as String],
      lastMessage: data['lastMessage'] as String,
      lastMessageTime: DateTime.tryParse(data['lastMessageTime'] as String),
      unreadCount: data['unreadCount'] as int,
      isOnline: data['isOnline'] as bool,
    )).toList();
  }

  /// Load mock messages for a conversation
  void _loadMockMessages(int otherUserId) {
    final mockChat = MockDataService.generateMockChat(
      otherUser: MockDataService.generateMockUser(id: otherUserId),
    );

    final messages = mockChat['messages'] as List<Map<String, dynamic>>;
    currentMessages.value = messages.map((data) => ChatMessage(
      messageId: data['messageId'].toString(),
      senderId: data['senderId'] == 'me' ? _currentUserId : otherUserId,
      receiverId: data['senderId'] == 'me' ? otherUserId : _currentUserId,
      content: data['text'] as String,
      timestamp: DateTime.tryParse(data['timestamp'] as String),
      isRead: data['isRead'] as bool,
      isSent: true,
    )).toList();
  }

  /// Load group chats
  Future<void> loadGroupChats() async {
    try {
      final response = await _chatRepository.getGroupChatList();
      if (response.success && response.data != null) {
        groupChats.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Load business chats
  Future<void> loadBusinessChats() async {
    try {
      final response = await _chatRepository.getBusinessChatList();
      if (response.success && response.data != null) {
        businessChats.value = response.data!;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Open conversation (with mock data support)
  Future<void> openConversation(ChatConversation conversation) async {
    currentConversation.value = conversation;
    currentMessages.clear();

    // In mock mode, load mock messages
    if (useMockData.value && conversation.otherUserId != null) {
      _loadMockMessages(conversation.otherUserId!);
      // Clear unread count in conversations list
      final index = conversations.indexWhere((c) => c.otherUserId == conversation.otherUserId);
      if (index != -1) {
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
      return;
    }

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

  /// Send message (with mock mode support)
  Future<bool> sendMessage({String? content, String? imageUrl}) async {
    final text = content ?? messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return false;
    if (currentConversation.value?.otherUserId == null) return false;

    isSending.value = true;
    messageController.clear();

    // Add optimistic message
    final tempMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId ?? 1,
      receiverId: currentConversation.value!.otherUserId,
      content: text.isNotEmpty ? text : null,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isSent: false,
    );
    currentMessages.add(tempMessage);

    // In mock mode, just simulate sending
    if (useMockData.value) {
      await Future.delayed(const Duration(milliseconds: 300));
      isSending.value = false;

      // Update message as sent
      final index = currentMessages.indexWhere((m) => m.messageId == tempMessage.messageId);
      if (index != -1) {
        currentMessages[index] = tempMessage.copyWith(isSent: true);
      }

      // Update last message in conversation list
      final convIndex = conversations.indexWhere(
        (c) => c.otherUserId == currentConversation.value!.otherUserId
      );
      if (convIndex != -1) {
        final conv = conversations[convIndex];
        conversations[convIndex] = ChatConversation(
          conversationId: conv.conversationId,
          otherUserId: conv.otherUserId,
          otherUserName: conv.otherUserName,
          otherUserImages: conv.otherUserImages,
          lastMessage: text,
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isOnline: conv.isOnline,
        );
      }

      // Simulate a reply after a short delay
      _simulateMockReply();

      return true;
    }

    try {
      final response = await _chatRepository.sendMessage(
        receiverId: currentConversation.value!.otherUserId!,
        content: text,
        imageUrl: imageUrl,
      );

      isSending.value = false;

      if (response.success) {
        // Update optimistic message
        final index = currentMessages.indexWhere(
            (m) => m.messageId == tempMessage.messageId);
        if (index != -1 && response.data != null) {
          currentMessages[index] = response.data!;
          _cacheMessage(response.data!);
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

  /// Simulate a mock reply from the other user
  Future<void> _simulateMockReply() async {
    if (currentConversation.value == null) return;

    // Random chance to get a reply
    if (MockDataService.generateMockUser()['isOnline'] as bool) {
      await Future.delayed(Duration(seconds: 2 + DateTime.now().second % 3));

      if (currentConversation.value == null) return; // Check if still in conversation

      final replies = [
        "That sounds great!",
        "I'd love to!",
        "When works for you?",
        "Thanks for reaching out!",
        "Let me think about it",
        "Sure thing!",
        "Sounds fun!",
      ];

      final replyMessage = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentConversation.value!.otherUserId,
        receiverId: _currentUserId ?? 1,
        content: replies[DateTime.now().second % replies.length],
        timestamp: DateTime.now(),
        isSent: true,
        isRead: true,
      );

      currentMessages.add(replyMessage);
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(int senderId) async {
    try {
      await _chatRepository.markAsRead(senderId: senderId);

      // Update conversation unread count
      final index = conversations.indexWhere((c) => c.otherUserId == senderId);
      if (index != -1) {
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
      // Ignore errors
    }
  }

  /// Send typing indicator
  void sendTypingIndicator() {
    if (_socket != null && currentConversation.value?.otherUserId != null) {
      _socket!.emit('typing', {
        'senderId': _currentUserId,
        'receiverId': currentConversation.value!.otherUserId,
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
    if (userId == null || _chatBox == null) return;

    try {
      final messages = <ChatMessage>[];

      for (var key in _chatBox!.keys) {
        final keyStr = key.toString();
        if (keyStr.contains('${_currentUserId}_$userId') ||
            keyStr.contains('${userId}_$_currentUserId')) {
          final data = _chatBox!.get(key);
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
