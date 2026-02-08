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
    return parseListResponse(response, ChatConversation.fromJson);
  }

  /// Get group chat list
  Future<ApiResponse<List<GroupChat>>> getGroupChatList() async {
    final response = await get<dynamic>(ApiEndpoints.groupList);
    return parseListResponse(response, GroupChat.fromJson);
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
    return parseListResponse(response, ChatConversation.fromJson);
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
