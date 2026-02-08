import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../widgets/last_seen.dart';
import '../../widgets/empty_states.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_Friend> _friends = [
    _Friend(name: 'Sarah Chen', isOnline: true, lastSeen: 'Online now', mutualEvents: 5),
    _Friend(name: 'Mike Johnson', isOnline: true, lastSeen: 'Online now', mutualEvents: 3),
    _Friend(name: 'Jordan Lee', isOnline: false, lastSeen: '2 hours ago', mutualEvents: 8),
    _Friend(name: 'Alex Rivera', isOnline: false, lastSeen: 'Yesterday', mutualEvents: 2),
    _Friend(name: 'Taylor Kim', isOnline: false, lastSeen: '3 days ago', mutualEvents: 4),
  ];

  final List<_Friend> _pending = [
    _Friend(name: 'Emma Wilson', isOnline: false, lastSeen: 'Sent request', mutualEvents: 1),
    _Friend(name: 'Chris Park', isOnline: false, lastSeen: 'Received request', mutualEvents: 2),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_Friend> get _filteredFriends {
    if (_searchQuery.isEmpty) return _friends;
    return _friends
        .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
        title: const Text(
          'Friends',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black),
            onPressed: () {
              HapticFeedback.lightImpact();
              Nav.toMatches();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withAlpha(128),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.mediumGrey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search friends',
                            hintStyle: TextStyle(color: AppColors.mediumGrey),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.mediumGrey,
                indicatorColor: AppColors.primaryBlue,
                tabs: [
                  Tab(text: 'All (${_friends.length})'),
                  Tab(text: 'Pending (${_pending.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All friends
          _filteredFriends.isEmpty
              ? _searchQuery.isNotEmpty
                  ? NoResultsState(
                      query: _searchQuery,
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : const NoFriendsState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    return _FriendTile(friend: _filteredFriends[index]);
                  },
                ),

          // Pending
          _pending.isEmpty
              ? const Center(
                  child: EmptyState(
                    emoji: '✉️',
                    title: 'No pending requests',
                    subtitle: 'Friend requests will appear here',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _pending.length,
                  itemBuilder: (context, index) {
                    return _PendingTile(friend: _pending[index]);
                  },
                ),
        ],
      ),
    );
  }
}

class _Friend {
  final String name;
  final bool isOnline;
  final String lastSeen;
  final int mutualEvents;

  _Friend({
    required this.name,
    required this.isOnline,
    required this.lastSeen,
    required this.mutualEvents,
  });
}

class _FriendTile extends StatelessWidget {
  final _Friend friend;

  const _FriendTile({required this.friend});

  void _showFriendActions(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#91)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withAlpha(26),
                    ),
                    child: Center(
                      child: Text(
                        friend.name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (friend.isOnline)
                          Text(
                            'Online now',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.message, color: AppColors.primaryBlue),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toMessages();
                Get.snackbar(
                  'Opening chat',
                  'Starting conversation with ${friend.name}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.friendlyPurple),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toUserProfile(
                  userId: 'friend_${friend.name.toLowerCase().replaceAll(' ', '_')}',
                  userName: friend.name,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.friendlyTeal),
              title: Text('${friend.mutualEvents} mutual events'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toDiscover();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.notifications_off, color: AppColors.mediumGrey),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Notifications muted',
                  'You won\'t receive notifications from ${friend.name}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_remove, color: AppColors.error),
              title: Text('Remove Friend', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                _confirmRemoveFriend(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveFriend(BuildContext context) {
    // Check if context is still mounted before showing dialog (#91)
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend?'),
        content: Text('Are you sure you want to remove ${friend.name} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              Get.snackbar(
                'Friend Removed',
                '${friend.name} has been removed from your friends',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Nav.toUserProfile(
          userId: 'friend_${friend.name.toLowerCase().replaceAll(' ', '_')}',
          userName: friend.name,
        );
      },
      onLongPress: () => _showFriendActions(context),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withAlpha(26),
                ),
                child: Center(
                  child: Text(
                    friend.name[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              if (friend.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                OnlineStatus(
                  isOnline: friend.isOnline,
                  lastSeen: friend.lastSeen,
                ),
              ],
            ),
          ),
          EventsInCommon(count: friend.mutualEvents),
        ],
      ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final _Friend friend;

  const _PendingTile({required this.friend});

  void _showPendingActions(BuildContext context, bool isReceived) {
    // Check if context is still mounted before showing bottom sheet (#91)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.friendlyPurple.withAlpha(26),
                    ),
                    child: Center(
                      child: Text(
                        friend.name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.friendlyPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isReceived ? 'Wants to connect' : 'Request pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.friendlyOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.friendlyPurple),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toUserProfile(
                  userId: 'pending_${friend.name.toLowerCase().replaceAll(' ', '_')}',
                  userName: friend.name,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.friendlyTeal),
              title: Text('${friend.mutualEvents} mutual events'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toDiscover();
              },
            ),
            if (isReceived) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.success),
                title: const Text('Accept Request'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    'Friend Added!',
                    '${friend.name} is now your friend',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: AppColors.error),
                title: Text('Decline Request', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    'Request Declined',
                    'Friend request from ${friend.name} declined',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ] else ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.cancel, color: AppColors.error),
                title: Text('Cancel Request', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    'Request Cancelled',
                    'Friend request to ${friend.name} cancelled',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReceived = friend.lastSeen.contains('Received');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Nav.toUserProfile(
          userId: 'pending_${friend.name.toLowerCase().replaceAll(' ', '_')}',
          userName: friend.name,
        );
      },
      onLongPress: () => _showPendingActions(context, isReceived),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.friendlyPurple.withAlpha(26),
            ),
            child: Center(
              child: Text(
                friend.name[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.friendlyPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${friend.mutualEvents} mutual events',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          if (isReceived) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Friend Added!',
                  '${friend.name} is now your friend',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Request Declined',
                  'Friend request from ${friend.name} declined',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 18, color: AppColors.mediumGrey),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.friendlyOrange.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Text(
                'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.friendlyOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
