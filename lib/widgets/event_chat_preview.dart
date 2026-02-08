import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';

/// Preview of event group chat - shown on activity cards
class EventChatPreview extends StatelessWidget {
  final String eventId;
  final String eventName;
  final int messageCount;
  final String? lastMessage;
  final String? lastSenderName;
  final DateTime? lastMessageTime;
  final List<String> participantAvatars;
  final VoidCallback? onTap;

  const EventChatPreview({
    super.key,
    required this.eventId,
    required this.eventName,
    this.messageCount = 0,
    this.lastMessage,
    this.lastSenderName,
    this.lastMessageTime,
    this.participantAvatars = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _openEventChat(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(13),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primaryBlue.withAlpha(38)),
        ),
        child: Row(
          children: [
            // Chat icon with badge
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                ),
                if (messageCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        messageCount > 9 ? '9+' : '$messageCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  if (lastMessage != null)
                    Text(
                      '${lastSenderName ?? 'Someone'}: $lastMessage',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Say hi to other attendees!',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                ],
              ),
            ),

            // Participant avatars
            if (participantAvatars.isNotEmpty)
              SizedBox(
                width: 50,
                height: 24,
                child: Stack(
                  children: [
                    for (int i = 0; i < participantAvatars.take(3).length; i++)
                      Positioned(
                        left: i * 14.0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: ApiEndpoints.isValidImageUrl(participantAvatars[i])
                                ? DecorationImage(
                                    image: NetworkImage(
                                      ApiEndpoints.getImageUrl(participantAvatars[i]),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: AppColors.lightGrey,
                          ),
                          child: !ApiEndpoints.isValidImageUrl(participantAvatars[i])
                              ? const Icon(Icons.person, size: 12, color: AppColors.mediumGrey)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),

            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  void _openEventChat(BuildContext context) {
    Get.to(() => EventChatScreen(
      eventId: eventId,
      eventName: eventName,
    ));
  }
}

/// Full event chat screen
class EventChatScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const EventChatScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMockMessages();
  }

  void _loadMockMessages() {
    _messages.addAll([
      _ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Alex',
        senderAvatar: null,
        message: 'Hey everyone! Excited for this event!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
      _ChatMessage(
        id: '2',
        senderId: 'user2',
        senderName: 'Jordan',
        senderAvatar: null,
        message: 'Same here! Anyone know if parking is easy?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isMe: false,
      ),
      _ChatMessage(
        id: '3',
        senderId: 'me',
        senderName: 'You',
        senderAvatar: null,
        message: 'There\'s a parking garage nearby. I can share the location!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isMe: true,
      ),
      _ChatMessage(
        id: '4',
        senderId: 'user2',
        senderName: 'Jordan',
        senderAvatar: null,
        message: 'That would be great, thanks!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
        isMe: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${_messages.length} messages',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showAttendees(context),
            tooltip: 'View attendees',
          ),
        ],
      ),
      body: Column(
        children: [
          // Event info banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: AppColors.primaryBlue.withAlpha(26),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a group chat for event attendees. Be friendly!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final showSender = index == _messages.length - 1 ||
                    _messages[_messages.length - 2 - index].senderId != message.senderId;

                return _MessageBubble(
                  message: message,
                  showSender: showSender,
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message the group...',
                      hintStyle: TextStyle(color: AppColors.mediumGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey.withAlpha(128),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentBlue],
                      ),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        senderName: 'You',
        senderAvatar: null,
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isMe: true,
      ));
    });

    _messageController.clear();
  }

  void _showAttendees(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendees in Chat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mock attendees
                  ...[
                    ('Alex', true),
                    ('Jordan', true),
                    ('Sam', false),
                    ('Taylor', false),
                  ].map((attendee) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withAlpha(51),
                          ),
                          child: Center(
                            child: Text(
                              attendee.$1[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            attendee.$1,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (attendee.$2)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(26),
                              borderRadius: BorderRadius.circular(AppRadius.circular),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 6, color: AppColors.success),
                                SizedBox(width: 4),
                                Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  _ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool showSender;

  const _MessageBubble({
    required this.message,
    required this.showSender,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 12 : 4,
        left: message.isMe ? 48 : 0,
        right: message.isMe ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                bottomRight: Radius.circular(message.isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: message.isMe ? Colors.white : AppColors.darkGrey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}';
  }
}
