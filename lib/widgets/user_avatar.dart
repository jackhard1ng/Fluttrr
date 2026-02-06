import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// User avatar widget with online status indicator
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: borderWidth > 0
                  ? Border.all(
                      color: borderColor ?? AppColors.primaryBlue,
                      width: borderWidth,
                    )
                  : null,
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: _OnlineIndicator(
                isOnline: isOnline,
                size: size * 0.3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryBlue.withAlpha(51),
      child: Center(
        child: name != null && name!.isNotEmpty
            ? Text(
                _getInitials(name!),
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.primaryBlue,
              ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

class _OnlineIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const _OnlineIndicator({
    required this.isOnline,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success : AppColors.grey,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );
  }
}

/// Avatar group showing multiple users overlapping
class AvatarGroup extends StatelessWidget {
  final List<String?> imageUrls;
  final List<String>? names;
  final double size;
  final int maxDisplay;
  final double overlap;
  final VoidCallback? onTap;

  const AvatarGroup({
    super.key,
    required this.imageUrls,
    this.names,
    this.size = 32,
    this.maxDisplay = 4,
    this.overlap = 0.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length > maxDisplay ? maxDisplay : imageUrls.length;
    final remaining = imageUrls.length - maxDisplay;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + (displayCount - 1) * size * (1 - overlap) + (remaining > 0 ? size * (1 - overlap) : 0),
        height: size,
        child: Stack(
          children: [
            for (int i = 0; i < displayCount; i++)
              Positioned(
                left: i * size * (1 - overlap),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: UserAvatar(
                    imageUrl: imageUrls[i],
                    name: names != null && i < names!.length ? names![i] : null,
                    size: size - 4,
                  ),
                ),
              ),
            if (remaining > 0)
              Positioned(
                left: displayCount * size * (1 - overlap),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Large profile avatar with edit button
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool editable;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 120,
    this.editable = false,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserAvatar(
          imageUrl: imageUrl,
          name: name,
          size: size,
          onTap: onTap,
          borderColor: AppColors.primaryBlue,
          borderWidth: 3,
        ),
        if (editable)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: size * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
