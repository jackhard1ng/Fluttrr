import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/chat_model.dart';
import 'base_repository.dart';

/// Chat repository
class ChatRepository extends BaseRepository {
  /// Send a message
  Future<ApiResponse<ChatMessage>> sendMessage({
    required int receiverId,
    required String content,
    String? imageUrl,
  }) async {
    return post<ChatMessage>(
      ApiEndpoints.sendMessage,
      body: {
        'receiverId': receiverId,
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      fromJson: ChatMessage.fromJson,
    );
  }

  /// Get chat list (conversations)
  Future<ApiResponse<List<ChatConversation>>> getChatList() async {
    final response = await get<dynamic>(ApiEndpoints.chatList);
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> chats = [];

      if (data is Map<String, dynamic>) {
        chats = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        chats = data;
      }

      final chatList = chats
          .where((e) => e != null)
          .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: chatList);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Get group chat list
  Future<ApiResponse<List<GroupChat>>> getGroupChatList() async {
    final response = await get<dynamic>(ApiEndpoints.groupList);
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> groups = [];

      if (data is Map<String, dynamic>) {
        groups = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        groups = data;
      }

      final groupList = groups
          .where((e) => e != null)
          .map((e) => GroupChat.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: groupList);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Mark messages as read
  Future<ApiResponse<dynamic>> markAsRead({
    required int senderId,
  }) async {
    return post(
      ApiEndpoints.markAsRead,
      body: {'senderId': senderId},
    );
  }

  /// Get business chat list
  Future<ApiResponse<List<ChatConversation>>> getBusinessChatList() async {
    final response = await get<dynamic>(ApiEndpoints.businessChatList);
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> chats = [];

      if (data is Map<String, dynamic>) {
        chats = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        chats = data;
      }

      final chatList = chats
          .where((e) => e != null)
          .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: chatList);
    }
    return ApiResponse.failure(error: response.error);
  }

  /// Send business message
  Future<ApiResponse<ChatMessage>> sendBusinessMessage({
    required int businessId,
    required String content,
    String? imageUrl,
  }) async {
    return post<ChatMessage>(
      ApiEndpoints.sendBusinessMessage,
      body: {
        'businessId': businessId,
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      fromJson: ChatMessage.fromJson,
    );
  }
}
