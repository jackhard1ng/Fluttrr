import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';
import '../mates/mate_profile_screen.dart';

/// Chat screen for direct messaging
class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;
  final bool isBusiness;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.isBusiness = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatController = Get.find<ChatController>();
    chatController.openConversation(widget.conversation);
  }

  @override
  void dispose() {
    final chatController = Get.find<ChatController>();
    chatController.closeConversation();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: widget.conversation.otherUserId != null && !widget.isBusiness
              ? () => Get.to(() =>
                  MateProfileScreen(userId: widget.conversation.otherUserId!))
              : null,
          child: Row(
            children: [
              UserAvatar(
                imageUrl: widget.conversation.profileImage,
                size: 40,
                showOnlineIndicator: true,
                isOnline: widget.conversation.isOnline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.conversation.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.conversation.isOnline
                            ? AppColors.success
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              final messages = chatController.currentMessages;

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserAvatar(
                        imageUrl: widget.conversation.profileImage,
                        size: 80,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        widget.conversation.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Start the conversation!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final previousMessage =
                      index > 0 ? messages[index - 1] : null;
                  final showDateSeparator = previousMessage == null ||
                      !_isSameDay(
                          message.timestamp, previousMessage.timestamp);

                  return Column(
                    children: [
                      if (showDateSeparator)
                        _DateSeparator(date: message.timestamp),
                      _MessageBubble(
                        message: message,
                        isMe: message.senderId != widget.conversation.otherUserId,
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Input field
          _MessageInput(
            controller: chatController.messageController,
            onSend: () async {
              final success = await chatController.sendMessage();
              if (success) {
                _scrollToBottom();
              }
            },
            isSending: chatController.isSending.value,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Date separator widget
class _DateSeparator extends StatelessWidget {
  final DateTime? date;

  const _DateSeparator({this.date});

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    String text;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date!.year, date!.month, date!.day);

    if (messageDate == today) {
      text = 'Today';
    } else if (messageDate == yesterday) {
      text = 'Yesterday';
    } else {
      text = DateFormat('MMMM d, y').format(date!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
          left: isMe ? AppSpacing.xl : 0,
          right: isMe ? 0 : AppSpacing.xl,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : AppColors.lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(isMe ? AppRadius.md : 0),
            bottomRight: Radius.circular(isMe ? 0 : AppRadius.md),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Image message
            if (message.isImageMessage && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),

            // Text content
            if (message.content != null && message.content!.isNotEmpty)
              Text(
                message.content!,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.black,
                ),
              ),

            const SizedBox(height: 4),

            // Timestamp and status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timestamp != null
                      ? DateFormat('h:mm a').format(message.timestamp!)
                      : '',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Message input widget
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: AppShadows.small,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () {
                // Pick image
              },
            ),

            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Send button
            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryHorizontal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
