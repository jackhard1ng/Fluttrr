import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';

/// Chat list screen
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChats();
  }

  Future<void> _loadChats() async {
    final controller = Get.find<ChatController>();
    // Load all chat types with error handling
    await Future.wait([
      controller.loadChatList(),
      controller.loadGroupChats(),
      controller.loadBusinessChats(),
    ], eagerError: false).catchError((e) {
      debugPrint('Error loading chats: $e');
      return <void>[];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showChatSearch(BuildContext context) {
    // Guard against invalid context
    if (!context.mounted) return;
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, color: AppColors.mediumGrey),
                  filled: true,
                  fillColor: AppColors.lightGrey.withAlpha(128),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  if (value.isNotEmpty) {
                    Get.snackbar(
                      'Search',
                      'Searching for "$value" in conversations...',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Search by name or message content',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    } catch (e) {
      debugPrint('Error showing chat search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GradientText(
                    text: 'Messages',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _showChatSearch(context);
                    },
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.primaryBlue,
              tabs: const [
                Tab(text: 'Direct'),
                Tab(text: 'Groups'),
                Tab(text: 'Business'),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const _DirectChatsTab(),
                  const _GroupChatsTab(),
                  const _BusinessChatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Direct chats tab
class _DirectChatsTab extends StatelessWidget {
  const _DirectChatsTab();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Obx(() {
      if (chatController.isLoading.value &&
          chatController.conversations.isEmpty) {
        return const LoadingIndicator();
      }

      if (chatController.conversations.isEmpty) {
        return const EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'No Messages',
          subtitle: 'Start a conversation with your matches!',
        );
      }

      return RefreshIndicator(
        onRefresh: chatController.refreshChatList,
        child: ListView.builder(
          itemCount: chatController.conversations.length,
          itemBuilder: (context, index) {
            return _ChatTile(conversation: chatController.conversations[index]);
          },
        ),
      );
    });
  }
}

/// Group chats tab
class _GroupChatsTab extends StatelessWidget {
  const _GroupChatsTab();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Obx(() {
      if (chatController.groupChats.isEmpty) {
        return const EmptyState(
          icon: Icons.groups_outlined,
          title: 'No Group Chats',
          subtitle: 'Join activities to access group chats',
        );
      }

      return ListView.builder(
        itemCount: chatController.groupChats.length,
        itemBuilder: (context, index) {
          return _GroupChatTile(group: chatController.groupChats[index]);
        },
      );
    });
  }
}

/// Business chats tab
class _BusinessChatsTab extends StatelessWidget {
  const _BusinessChatsTab();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Obx(() {
      if (chatController.businessChats.isEmpty) {
        return const EmptyState(
          icon: Icons.business_outlined,
          title: 'No Business Chats',
          subtitle: 'Message businesses about their events',
        );
      }

      return ListView.builder(
        itemCount: chatController.businessChats.length,
        itemBuilder: (context, index) {
          return _ChatTile(
            conversation: chatController.businessChats[index],
            isBusiness: true,
          );
        },
      );
    });
  }
}

/// Chat tile widget
class _ChatTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool isBusiness;

  const _ChatTile({
    required this.conversation,
    this.isBusiness = false,
  });

  void _showChatActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: SafeArea(
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
              ListTile(
                leading: Icon(Icons.push_pin_outlined, color: AppColors.friendlyPurple),
                title: const Text('Pin Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Pinned',
                    'Chat pinned to top',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.friendlyPurple,
                    colorText: Colors.white,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_off_outlined, color: AppColors.friendlyOrange),
                title: const Text('Mute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Muted',
                    'Notifications muted for this chat',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.archive_outlined, color: AppColors.primaryBlue),
                title: const Text('Archive Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Archived',
                    'Chat moved to archive',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Delete Chat', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Deleted',
                    'Chat deleted',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.error,
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('chat_${conversation.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        _showChatActions(context);
        return false; // Don't actually dismiss, just show options
      },
      background: Container(
        color: AppColors.primaryBlue,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.more_horiz, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () => _showChatActions(context),
        child: ListTile(
          onTap: () => Nav.toChat(conversation, isBusiness: isBusiness),
          leading: Stack(
        children: [
          UserAvatar(
            imageUrl: conversation.profileImage,
            size: 50,
          ),
          if (conversation.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.displayName,
        style: TextStyle(
          fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.lastMessage ?? '',
        style: TextStyle(
          color: conversation.hasUnread
              ? Theme.of(context).textTheme.bodyMedium?.color
              : AppColors.grey,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageTime != null)
            Text(
              timeago.format(conversation.lastMessageTime!, locale: 'en_short'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (conversation.hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}

/// Group chat tile widget
class _GroupChatTile extends StatelessWidget {
  final GroupChat group;

  const _GroupChatTile({required this.group});

  void _showGroupActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: SafeArea(
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
              ListTile(
                leading: Icon(Icons.push_pin_outlined, color: AppColors.friendlyPurple),
                title: const Text('Pin Group'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Pinned',
                    'Group pinned to top',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.friendlyPurple,
                    colorText: Colors.white,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_off_outlined, color: AppColors.friendlyOrange),
                title: const Text('Mute Group'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Muted',
                    'Group notifications muted',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline, color: AppColors.primaryBlue),
                title: const Text('View Members'),
                onTap: () {
                  Navigator.pop(context);
                  Nav.toGroupChat(groupId: group.id, groupName: group.displayName);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: AppColors.error),
                title: Text('Leave Group', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Left Group',
                    'You left ${group.displayName}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.error,
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('group_${group.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        _showGroupActions(context);
        return false;
      },
      background: Container(
        color: AppColors.primaryBlue,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.more_horiz, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () => _showGroupActions(context),
        child: ListTile(
          onTap: () {
            Nav.toGroupChat(groupId: group.id, groupName: group.displayName);
          },
          leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            // Safely access first character with fallback
            group.displayName.isNotEmpty
                ? group.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      title: Text(
        group.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          const Icon(
            Icons.people,
            size: 14,
            color: AppColors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${group.memberCount} members',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (group.lastMessageTime != null)
            Text(
              timeago.format(group.lastMessageTime!, locale: 'en_short'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (group.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                group.unreadCount > 99 ? '99+' : group.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}
