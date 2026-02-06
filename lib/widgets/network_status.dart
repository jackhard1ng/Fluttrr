import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Network status banner
class NetworkStatusBanner extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onRetry;

  const NetworkStatusBanner({
    super.key,
    required this.isOnline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text(
            'No internet connection',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Connection status indicator
class ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final bool showLabel;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            isConnected ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: isConnected ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Sync status indicator
class SyncStatus extends StatelessWidget {
  final SyncState state;
  final String? message;

  const SyncStatus({
    super.key,
    required this.state,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (state) {
      case SyncState.syncing:
        icon = Icons.sync;
        color = AppColors.primaryBlue;
        label = message ?? 'Syncing...';
        break;
      case SyncState.synced:
        icon = Icons.cloud_done;
        color = AppColors.success;
        label = message ?? 'Synced';
        break;
      case SyncState.error:
        icon = Icons.cloud_off;
        color = AppColors.error;
        label = message ?? 'Sync failed';
        break;
      case SyncState.offline:
        icon = Icons.cloud_off;
        color = AppColors.mediumGrey;
        label = message ?? 'Offline';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == SyncState.syncing)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          )
        else
          Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

enum SyncState {
  syncing,
  synced,
  error,
  offline,
}

/// Retry button
class RetryButton extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const RetryButton({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Something went wrong',
            style: TextStyle(color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection required overlay
class ConnectionRequired extends StatelessWidget {
  final Widget child;
  final bool isConnected;
  final VoidCallback? onRetry;

  const ConnectionRequired({
    super.key,
    required this.child,
    required this.isConnected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return child;

    return Stack(
      children: [
        child,
        Container(
          color: Colors.white.withAlpha(230),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again',
                  style: TextStyle(color: AppColors.mediumGrey),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Last updated indicator
class LastUpdated extends StatelessWidget {
  final DateTime? lastUpdate;

  const LastUpdated({super.key, this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    if (lastUpdate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final diff = now.difference(lastUpdate!);

    String text;
    if (diff.inMinutes < 1) {
      text = 'Just now';
    } else if (diff.inMinutes < 60) {
      text = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      text = '${diff.inHours}h ago';
    } else {
      text = '${diff.inDays}d ago';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.update, size: 14, color: AppColors.mediumGrey),
        const SizedBox(width: 4),
        Text(
          'Updated $text',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}
