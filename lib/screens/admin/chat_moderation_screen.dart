import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

/// Model for moderated chat conversations
class ModeratedChatModel {
  final String? chatId;
  final String? participantOneId;
  final String? participantOneName;
  final String? participantOneImage;
  final String? participantTwoId;
  final String? participantTwoName;
  final String? participantTwoImage;
  final List<ModeratedMessageModel> messages;
  final int reportCount;
  final DateTime? lastMessageAt;

  ModeratedChatModel({
    this.chatId,
    this.participantOneId,
    this.participantOneName,
    this.participantOneImage,
    this.participantTwoId,
    this.participantTwoName,
    this.participantTwoImage,
    this.messages = const [],
    this.reportCount = 0,
    this.lastMessageAt,
  });

  factory ModeratedChatModel.fromJson(Map<String, dynamic> json) {
    return ModeratedChatModel(
      chatId: json['chat_id']?.toString(),
      participantOneId: json['participant_one_id']?.toString(),
      participantOneName: json['participant_one_name'] as String?,
      participantOneImage: json['participant_one_image'] as String?,
      participantTwoId: json['participant_two_id']?.toString(),
      participantTwoName: json['participant_two_name'] as String?,
      participantTwoImage: json['participant_two_image'] as String?,
      messages: (json['messages'] as List?)
              ?.map((m) => ModeratedMessageModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      reportCount: json['report_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
    );
  }
}

class ModeratedMessageModel {
  final String? messageId;
  final String? senderId;
  final String? senderName;
  final String? content;
  final String? imageUrl;
  final DateTime? sentAt;
  final bool isReported;
  final bool isDeleted;

  ModeratedMessageModel({
    this.messageId,
    this.senderId,
    this.senderName,
    this.content,
    this.imageUrl,
    this.sentAt,
    this.isReported = false,
    this.isDeleted = false,
  });

  factory ModeratedMessageModel.fromJson(Map<String, dynamic> json) {
    return ModeratedMessageModel(
      messageId: json['message_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      senderName: json['sender_name'] as String?,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : null,
      isReported: json['is_reported'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
}

/// Screen for viewing and moderating chat messages
class ChatModerationScreen extends StatefulWidget {
  final String? userId; // If viewing a specific user's chats
  final String? reportId; // If viewing chats related to a report

  const ChatModerationScreen({
    super.key,
    this.userId,
    this.reportId,
  });

  @override
  State<ChatModerationScreen> createState() => _ChatModerationScreenState();
}

class _ChatModerationScreenState extends State<ChatModerationScreen> {
  final RxList<ModeratedChatModel> chats = <ModeratedChatModel>[].obs;
  final Rx<ModeratedChatModel?> selectedChat = Rx<ModeratedChatModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    isLoading.value = true;
    // This would call the admin repository to load chats
    // For now, showing placeholder
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  Future<void> _loadChatMessages(String chatId) async {
    isLoadingMessages.value = true;
    // This would call the admin repository to load specific chat messages
    await Future.delayed(const Duration(milliseconds: 500));
    isLoadingMessages.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Moderation'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showModerationGuidelines,
          ),
        ],
      ),
      body: Row(
        children: [
          // Chat list (left side on tablet, full screen on phone)
          Expanded(
            flex: MediaQuery.of(context).size.width > 600 ? 1 : 2,
            child: _buildChatList(),
          ),
          // Chat messages (right side on tablet)
          if (MediaQuery.of(context).size.width > 600)
            Expanded(
              flex: 2,
              child: Obx(() => selectedChat.value != null
                  ? _buildChatView(selectedChat.value!)
                  : _buildNoSelectionPlaceholder()),
            ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by user name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              searchQuery.value = value;
              _loadChats();
            },
          ),
        ),

        // Info banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Only view chats when investigating reports. All access is logged.',
                  style: TextStyle(color: Colors.amber[800], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chat list
        Expanded(
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (chats.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatListTile(chat);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Chats to Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.reportId != null
                ? 'No chat history for this report'
                : 'Search for a user to view their chats',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatListTile(ModeratedChatModel chat) {
    final isSelected = selectedChat.value?.chatId == chat.chatId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.deepPurple)
            : null,
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: chat.participantOneImage != null
                  ? NetworkImage(chat.participantOneImage!)
                  : null,
              child: chat.participantOneImage == null
                  ? Text(chat.participantOneName?.substring(0, 1).toUpperCase() ?? '?')
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundImage: chat.participantTwoImage != null
                    ? NetworkImage(chat.participantTwoImage!)
                    : null,
                child: chat.participantTwoImage == null
                    ? Text(
                        chat.participantTwoName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(fontSize: 8),
                      )
                    : null,
              ),
            ),
          ],
        ),
        title: Text(
          '${chat.participantOneName ?? "User 1"} & ${chat.participantTwoName ?? "User 2"}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Text(
              '${chat.messages.length} messages',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (chat.reportCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${chat.reportCount} reports',
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        trailing: chat.lastMessageAt != null
            ? Text(
                _formatTimeAgo(chat.lastMessageAt!),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              )
            : null,
        onTap: () {
          selectedChat.value = chat;
          if (MediaQuery.of(context).size.width <= 600) {
            // On phone, navigate to chat view
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text('${chat.participantOneName} & ${chat.participantTwoName}'),
                  ),
                  body: _buildChatView(chat),
                ),
              ),
            );
          } else {
            _loadChatMessages(chat.chatId!);
          }
        },
      ),
    );
  }

  Widget _buildChatView(ModeratedChatModel chat) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chat.participantOneName} & ${chat.participantTwoName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${chat.messages.length} messages',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Action buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'warn_both':
                      _showWarnBothDialog(chat);
                      break;
                    case 'delete_chat':
                      _showDeleteChatDialog(chat);
                      break;
                    case 'export':
                      _exportChatLog(chat);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'warn_both',
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Warn Both Users'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_chat',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Log'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Obx(() {
            if (isLoadingMessages.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (chat.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No messages in this chat',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                final isParticipantOne = message.senderId == chat.participantOneId;

                return _buildMessageBubble(message, isParticipantOne, chat);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    ModeratedMessageModel message,
    bool isParticipantOne,
    ModeratedChatModel chat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender info
          CircleAvatar(
            radius: 16,
            backgroundImage: isParticipantOne && chat.participantOneImage != null
                ? NetworkImage(chat.participantOneImage!)
                : (!isParticipantOne && chat.participantTwoImage != null
                    ? NetworkImage(chat.participantTwoImage!)
                    : null),
            child: (isParticipantOne ? chat.participantOneImage : chat.participantTwoImage) == null
                ? Text(
                    (isParticipantOne ? chat.participantOneName : chat.participantTwoName)
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        '?',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isParticipantOne
                          ? (chat.participantOneName ?? 'User 1')
                          : (chat.participantTwoName ?? 'User 2'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (message.sentAt != null)
                      Text(
                        _formatDateTime(message.sentAt!),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    if (message.isReported) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag, size: 12, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Reported', style: TextStyle(color: Colors.red, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isDeleted
                        ? Colors.grey[200]
                        : (message.isReported
                            ? Colors.red.withValues(alpha: 0.05)
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: message.isReported
                        ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: message.isDeleted
                      ? Text(
                          '[Message deleted by admin]',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  message.imageUrl!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 200,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (message.content != null)
                              Text(message.content!),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // Message actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[400]),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteMessage(message);
                  break;
                case 'warn':
                  _warnUserForMessage(message, chat);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Message'),
              ),
              const PopupMenuItem(
                value: 'warn',
                child: Text('Warn Sender'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Select a chat to view messages',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showModerationGuidelines() {
    Get.dialog(
      AlertDialog(
        title: const Text('Chat Moderation Guidelines'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuidelineItem(
                Icons.privacy_tip,
                'Privacy First',
                'Only view chats when investigating a specific report. All access is logged for accountability.',
              ),
              _buildGuidelineItem(
                Icons.warning,
                'When to Take Action',
                'Issue warnings for minor violations. Delete messages containing explicit content, threats, or personal information.',
              ),
              _buildGuidelineItem(
                Icons.gavel,
                'Escalation',
                'For serious violations (threats, harassment, illegal content), suspend or ban the user and preserve evidence.',
              ),
              _buildGuidelineItem(
                Icons.save,
                'Documentation',
                'Always document your reasoning when taking action. Export chat logs for serious cases.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWarnBothDialog(ModeratedChatModel chat) {
    final messageController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Warn Both Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send a warning to both ${chat.participantOneName} and ${chat.participantTwoName}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Warning message',
                hintText: 'Explain the policy violation...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                Get.back();
                Get.snackbar('Warnings Sent', 'Both users have been warned',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Warnings'),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog(ModeratedChatModel chat) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text(
          'This will permanently delete all messages in this conversation. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Chat Deleted', 'The conversation has been removed',
                  snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportChatLog(ModeratedChatModel chat) {
    Get.snackbar(
      'Export Started',
      'Chat log will be downloaded shortly',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteMessage(ModeratedMessageModel message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This message will be replaced with "[Message deleted by admin]"'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Message Deleted', 'The message has been removed',
                  snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _warnUserForMessage(ModeratedMessageModel message, ModeratedChatModel chat) {
    final controller = Get.find<AdminController>();
    final userName = message.senderId == chat.participantOneId
        ? chat.participantOneName
        : chat.participantTwoName;

    final messageController = TextEditingController(
      text: 'Your message was flagged for violating our community guidelines.',
    );

    Get.dialog(
      AlertDialog(
        title: Text('Warn $userName'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(labelText: 'Warning message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                Get.back();
                controller.warnUser(message.senderId!, message: messageController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
