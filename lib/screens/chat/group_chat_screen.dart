import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_GroupMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages
    _messages.addAll([
      _GroupMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Alex',
        message: 'Hey everyone! Excited for the event tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _GroupMessage(
        id: '2',
        senderId: 'user2',
        senderName: 'Jordan',
        message: 'Same here! What time should we meet?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      _GroupMessage(
        id: '3',
        senderId: 'current_user',
        senderName: 'You',
        message: 'Let\'s meet 15 minutes early at the entrance',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isCurrentUser: true,
      ),
      _GroupMessage(
        id: '4',
        senderId: 'user3',
        senderName: 'Taylor',
        message: 'Sounds good to me!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_GroupMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current_user',
        senderName: 'You',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isCurrentUser: true,
      ));
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: GestureDetector(
          onTap: () => _showGroupInfo(),
          child: Row(
            children: [
              _GroupAvatar(name: widget.groupName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '4 members',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
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
            icon: Icon(Icons.info_outline, color: AppColors.darkGrey),
            onPressed: () => _showGroupInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showAvatar = index == 0 ||
                    _messages[index - 1].senderId != message.senderId;

                return _MessageBubble(
                  message: message,
                  showAvatar: showAvatar,
                );
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Alex is typing...',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
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
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Show attachment options
                    },
                    child: Icon(Icons.add_circle_outline, color: AppColors.mediumGrey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: AppColors.mediumGrey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
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
          ),
        ],
      ),
    );
  }

  void _showGroupInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GroupAvatar(name: widget.groupName, size: 60),
            const SizedBox(height: 12),
            Text(
              widget.groupName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '4 members',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 24),
            _InfoTile(
              icon: Icons.people,
              title: 'Members',
              onTap: () {
                Get.back();
                // Show members
              },
            ),
            _InfoTile(
              icon: Icons.photo_library,
              title: 'Shared Media',
              onTap: () {
                Get.back();
                // Show media
              },
            ),
            _InfoTile(
              icon: Icons.notifications,
              title: 'Mute Notifications',
              onTap: () {
                Get.back();
              },
            ),
            _InfoTile(
              icon: Icons.exit_to_app,
              title: 'Leave Group',
              isDestructive: true,
              onTap: () {
                Get.back();
                _showLeaveConfirmation();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
              Get.snackbar(
                'Left Group',
                'You have left ${widget.groupName}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;

  _GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isCurrentUser = false,
  });
}

class _MessageBubble extends StatelessWidget {
  final _GroupMessage message;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 12 : 2,
        left: message.isCurrentUser ? 48 : 0,
        right: message.isCurrentUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            message.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isCurrentUser) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryBlue.withAlpha(26),
                child: Text(
                  message.senderName[0],
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showAvatar && !message.isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isCurrentUser
                        ? AppColors.primaryBlue
                        : AppColors.lightGrey.withAlpha(128),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: message.isCurrentUser ? Colors.white : AppColors.darkGrey,
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
}

class _GroupAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _GroupAvatar({required this.name, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.friendlyPurple],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.group,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.darkGrey;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
