import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Generic empty state
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
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
    );
  }
}

/// No events empty state
class NoEventsState extends StatelessWidget {
  final VoidCallback? onExplore;
  final VoidCallback? onCreate;

  const NoEventsState({super.key, this.onExplore, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🎉',
      title: 'No events yet',
      subtitle: 'Find events to join or create your own',
      actionLabel: 'Explore Events',
      onAction: onExplore,
    );
  }
}

/// No friends empty state
class NoFriendsState extends StatelessWidget {
  final VoidCallback? onFindFriends;

  const NoFriendsState({super.key, this.onFindFriends});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '👋',
      title: 'No friends yet',
      subtitle: 'Attend events to meet new people',
      actionLabel: 'Find Events',
      onAction: onFindFriends,
    );
  }
}

/// No messages empty state
class NoMessagesState extends StatelessWidget {
  const NoMessagesState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '💬',
      title: 'No messages',
      subtitle: 'Start a conversation with your friends',
    );
  }
}

/// No search results
class NoResultsState extends StatelessWidget {
  final String? query;
  final VoidCallback? onClear;

  const NoResultsState({super.key, this.query, this.onClear});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🔍',
      title: 'No results found',
      subtitle: query != null
          ? 'Nothing matches "$query"'
          : 'Try adjusting your search',
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }
}

/// No notifications
class NoNotificationsState extends StatelessWidget {
  const NoNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '🔔',
      title: 'All caught up!',
      subtitle: 'No new notifications',
    );
  }
}

/// Error state
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '😕',
      title: 'Something went wrong',
      subtitle: message ?? 'Please try again',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Coming soon state
class ComingSoonState extends StatelessWidget {
  final String feature;

  const ComingSoonState({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🚀',
      title: 'Coming Soon',
      subtitle: '$feature is on its way!',
    );
  }
}

/// Offline state
class OfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '📶',
      title: 'You\'re offline',
      subtitle: 'Check your internet connection',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Loading placeholder
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
