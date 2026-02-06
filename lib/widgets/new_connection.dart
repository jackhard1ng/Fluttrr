import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// New connection prompt
class NewConnectionCard extends StatelessWidget {
  final String name;
  final String? sharedEvent;
  final VoidCallback? onConnect;
  final VoidCallback? onDismiss;

  const NewConnectionCard({
    super.key,
    required this.name,
    this.sharedEvent,
    this.onConnect,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                    name[0],
                    style: TextStyle(
                      fontSize: 20,
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (sharedEvent != null)
                      Text(
                        'Met at $sharedEvent',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                  ],
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 20, color: AppColors.mediumGrey),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onConnect?.call();
                    Get.snackbar(
                      'Connection Sent!',
                      'Waiting for $name to accept',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: Text(
                        'Connect',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Connection request badge
class ConnectionRequest extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const ConnectionRequest({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              '$count new connection${count > 1 ? 's' : ''}',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friends since badge
class FriendsSince extends StatelessWidget {
  final String date;

  const FriendsSince({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 5),
          Text(
            'Friends since $date',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection accepted notification
class ConnectionAccepted extends StatelessWidget {
  final String name;
  final VoidCallback? onMessage;
  final VoidCallback? onDismiss;

  const ConnectionAccepted({
    super.key,
    required this.name,
    this.onMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withAlpha(26),
            AppColors.friendlyTeal.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You\'re connected!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'You and $name are now friends',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onMessage?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Say Hi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick connect button
class QuickConnectButton extends StatelessWidget {
  final bool isConnected;
  final bool isPending;
  final VoidCallback onTap;

  const QuickConnectButton({
    super.key,
    this.isConnected = false,
    this.isPending = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    if (isConnected) {
      color = AppColors.success;
      icon = Icons.check;
      label = 'Connected';
    } else if (isPending) {
      color = AppColors.friendlyOrange;
      icon = Icons.hourglass_empty;
      label = 'Pending';
    } else {
      color = AppColors.primaryBlue;
      icon = Icons.person_add;
      label = 'Connect';
    }

    return GestureDetector(
      onTap: (isConnected || isPending)
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: (isConnected || isPending)
              ? color.withAlpha(26)
              : color,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: (isConnected || isPending) ? color : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: (isConnected || isPending) ? color : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
