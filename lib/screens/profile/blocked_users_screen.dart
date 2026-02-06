import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Mock blocked users
  final List<_BlockedUser> _blockedUsers = [
    _BlockedUser(
      id: '1',
      name: 'John Smith',
      blockedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    _BlockedUser(
      id: '2',
      name: 'Jane Doe',
      blockedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

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
          'Blocked Users',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _blockedUsers.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _blockedUsers.length,
              itemBuilder: (context, index) {
                final user = _blockedUsers[index];
                return _BlockedUserTile(
                  user: user,
                  onUnblock: () => _showUnblockDialog(user),
                );
              },
            ),
    );
  }

  void _showUnblockDialog(_BlockedUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Unblock ${user.name}? They will be able to see your profile and message you again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _blockedUsers.remove(user);
              });
              Navigator.pop(context);
              Get.snackbar(
                'Unblocked',
                '${user.name} has been unblocked',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text(
              'Unblock',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime blockedAt;

  _BlockedUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.blockedAt,
  });
}

class _BlockedUserTile extends StatelessWidget {
  final _BlockedUser user;
  final VoidCallback onUnblock;

  const _BlockedUserTile({
    required this.user,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.mediumGrey.withAlpha(77),
            child: Text(
              user.name[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Blocked ${_formatDate(user.blockedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onUnblock();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Unblock',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${(diff.inDays / 30).floor()} months ago';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block_outlined,
            size: 64,
            color: AppColors.mediumGrey.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No blocked users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you block someone, they\'ll appear here',
            style: TextStyle(
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
