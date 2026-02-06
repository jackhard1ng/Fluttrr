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
              // Navigate to add friends
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _PendingTile extends StatelessWidget {
  final _Friend friend;

  const _PendingTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final isReceived = friend.lastSeen.contains('Received');

    return Container(
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
    );
  }
}
