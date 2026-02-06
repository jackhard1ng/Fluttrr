import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';
import 'user_avatar.dart';

/// Reusable user list tile with avatar and actions
class UserListTile extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? subtitle;
  final String? trailing;
  final Widget? trailingWidget;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? badges;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool selected;

  const UserListTile({
    super.key,
    this.imageUrl,
    required this.name,
    this.subtitle,
    this.trailing,
    this.trailingWidget,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
    this.onLongPress,
    this.badges,
    this.padding,
    this.backgroundColor,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryBlue.withAlpha(26)
          : backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          child: Row(
            children: [
              // Avatar
              UserAvatar(
                imageUrl: imageUrl,
                name: name,
                size: 50,
                showOnlineIndicator: showOnlineIndicator,
                isOnline: isOnline,
              ),

              const SizedBox(width: AppSpacing.md),

              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badges != null && badges!.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.xs),
                          ...badges!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (trailing != null || trailingWidget != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailingWidget ??
                    Text(
                      trailing!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGrey,
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

/// User list tile with action buttons
class UserActionTile extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? subtitle;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final String acceptLabel;
  final String rejectLabel;
  final bool isLoading;

  const UserActionTile({
    super.key,
    this.imageUrl,
    required this.name,
    this.subtitle,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.acceptLabel = 'Accept',
    this.rejectLabel = 'Reject',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onTap,
            child: UserAvatar(
              imageUrl: imageUrl,
              name: name,
              size: 50,
              showOnlineIndicator: showOnlineIndicator,
              isOnline: isOnline,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Name and subtitle
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Action buttons
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            if (onReject != null)
              _ActionButton(
                onTap: onReject!,
                icon: Icons.close,
                color: AppColors.error,
                tooltip: rejectLabel,
              ),
            if (onReject != null && onAccept != null)
              const SizedBox(width: AppSpacing.xs),
            if (onAccept != null)
              _ActionButton(
                onTap: onAccept!,
                icon: Icons.check,
                color: AppColors.success,
                tooltip: acceptLabel,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String tooltip;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withAlpha(26),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Compact user chip for mentions/tags
class UserChip extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool selected;

  const UserChip({
    super.key,
    this.imageUrl,
    required this.name,
    this.onTap,
    this.onRemove,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryBlue
          : AppColors.primaryBlue.withAlpha(26),
      borderRadius: BorderRadius.circular(AppRadius.circular),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.circular),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 8,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                imageUrl: imageUrl,
                name: name,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: selected ? Colors.white : AppColors.primaryBlue,
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
