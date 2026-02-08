import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/chat_model.dart';
import 'base_repository.dart';

/// Chat repository with input validation
class ChatRepository extends BaseRepository {
  /// Maximum allowed message content length
  static const int _maxContentLength = 5000;

  /// Maximum allowed URL length
  static const int _maxUrlLength = 2048;

  /// Validate receiver/sender ID
  String? _validateId(int id, String fieldName) {
    if (id <= 0) {
      return 'Invalid $fieldName: must be a positive integer';
    }
    return null;
  }

  /// Validate message content
  String? _validateContent(String content) {
    if (content.isEmpty) {
      return 'Message content cannot be empty';
    }
    if (content.length > _maxContentLength) {
      return 'Message content too long (max $_maxContentLength characters)';
    }
    return null;
  }

  /// Validate optional URL
  String? _validateUrl(String? url) {
    if (url == null) return null;
    if (url.length > _maxUrlLength) {
      return 'URL too long (max $_maxUrlLength characters)';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Invalid URL format';
    }
    return null;
  }

  /// Send a message with input validation
  Future<ApiResponse<ChatMessage>> sendMessage({
    required int receiverId,
    required String content,
    String? imageUrl,
  }) async {
    // Validate inputs
    final idError = _validateId(receiverId, 'receiverId');
    if (idError != null) {
      return ApiResponse.failure(error: idError);
    }

    final contentError = _validateContent(content);
    if (contentError != null) {
      return ApiResponse.failure(error: contentError);
    }

    final urlError = _validateUrl(imageUrl);
    if (urlError != null) {
      return ApiResponse.failure(error: urlError);
    }

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

  /// Mark messages as read with input validation
  Future<ApiResponse<dynamic>> markAsRead({
    required int senderId,
  }) async {
    final idError = _validateId(senderId, 'senderId');
    if (idError != null) {
      return ApiResponse.failure(error: idError);
    }

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

  /// Send business message with input validation
  Future<ApiResponse<ChatMessage>> sendBusinessMessage({
    required int businessId,
    required String content,
    String? imageUrl,
  }) async {
    // Validate inputs
    final idError = _validateId(businessId, 'businessId');
    if (idError != null) {
      return ApiResponse.failure(error: idError);
    }

    final contentError = _validateContent(content);
    if (contentError != null) {
      return ApiResponse.failure(error: contentError);
    }

    final urlError = _validateUrl(imageUrl);
    if (urlError != null) {
      return ApiResponse.failure(error: urlError);
    }

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
