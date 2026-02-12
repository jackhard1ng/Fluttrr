import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/api_endpoints.dart';
import '../constants/utils.dart';

/// Safe network image widget that handles invalid URLs gracefully
///
/// Features:
/// - Automatic caching with configurable memory size
/// - Placeholder during loading with smooth transitions
/// - Error widget on failure
/// - Memory-efficient image resizing via cacheWidth/cacheHeight
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  /// Cache width for memory efficiency (auto-calculated from display width if not set)
  final int? cacheWidth;
  /// Cache height for memory efficiency (auto-calculated from display height if not set)
  final int? cacheHeight;

  const SafeNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ApiEndpoints.getImageUrl(imageUrl);

    if (!ApiEndpoints.isValidImageUrl(imageUrl)) {
      return _buildPlaceholder();
    }

    // Calculate cache dimensions for memory efficiency
    // Use 2x for retina displays, capped at reasonable maximums
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final effectiveCacheWidth = cacheWidth ??
        (width != null ? (width! * devicePixelRatio).toInt().clamp(0, 1200) : null);
    final effectiveCacheHeight = cacheHeight ??
        (height != null ? (height! * devicePixelRatio).toInt().clamp(0, 1200) : null);

    Widget image = Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: effectiveCacheWidth,
      cacheHeight: effectiveCacheHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: frame != null
              ? child
              : placeholder ?? _buildPlaceholder(),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('SafeNetworkImage error for $imageUrl: $error');
        return errorWidget ?? _buildPlaceholder();
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.grey,
        size: 32,
      ),
    );
  }
}

/// Safe decoration image provider
class SafeNetworkImageProvider extends ImageProvider<NetworkImage> {
  final String? imageUrl;

  SafeNetworkImageProvider(this.imageUrl);

  @override
  ImageStreamCompleter loadImage(NetworkImage key, ImageDecoderCallback decode) {
    final fullUrl = ApiEndpoints.getImageUrl(imageUrl);
    if (!ApiEndpoints.isValidImageUrl(imageUrl)) {
      // Return a transparent image for invalid URLs
      return OneFrameImageStreamCompleter(
        Future.error('Invalid image URL'),
      );
    }
    return NetworkImage(fullUrl).loadImage(key, decode);
  }

  @override
  Future<NetworkImage> obtainKey(ImageConfiguration configuration) {
    final fullUrl = ApiEndpoints.getImageUrl(imageUrl);
    return Future.value(NetworkImage(fullUrl));
  }
}

/// Gradient button widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.borderRadius = AppRadius.md,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppGradients.primaryHorizontal
            : null,
        color: onPressed == null || isLoading ? AppColors.grey : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Custom text field widget
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                text: 'Retry',
                onPressed: onRetry,
                width: 120,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading card
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Avatar widget with online indicator
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 50,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ApiEndpoints.getImageUrl(imageUrl);
    final hasValidImage = ApiEndpoints.isValidImageUrl(imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGrey,
              image: hasValidImage
                  ? DecorationImage(
                      image: NetworkImage(fullUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
                  : null,
            ),
            child: !hasValidImage
                ? Icon(
                    Icons.person,
                    size: size * 0.5,
                    color: AppColors.grey,
                  )
                : null,
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.online : AppColors.offline,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gradient text widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradient = AppGradients.primaryHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style ?? Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

/// Tag/chip widget
class TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? selectedColor;

  const TagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (selectedColor ?? AppColors.primaryBlue)
              : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkGrey,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Attendee avatars widget - shows overlapping profile pictures with +X more
class AttendeeAvatars extends StatelessWidget {
  final List<String?> imageUrls;
  final int totalCount;
  final double avatarSize;
  final double overlap;
  final int maxVisible;
  final VoidCallback? onTap;

  const AttendeeAvatars({
    super.key,
    required this.imageUrls,
    required this.totalCount,
    this.avatarSize = 32,
    this.overlap = 0.3,
    this.maxVisible = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = imageUrls.length.clamp(0, maxVisible);
    final remainingCount = totalCount - visibleCount;
    final effectiveOverlap = avatarSize * overlap;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: avatarSize,
        width: visibleCount * (avatarSize - effectiveOverlap) +
            effectiveOverlap +
            (remainingCount > 0 ? avatarSize : 0),
        child: Stack(
          children: [
            // Visible avatars
            for (int i = 0; i < visibleCount; i++)
              Positioned(
                left: i * (avatarSize - effectiveOverlap),
                child: _buildAvatar(imageUrls[i], i),
              ),
            // +X more indicator
            if (remainingCount > 0)
              Positioned(
                left: visibleCount * (avatarSize - effectiveOverlap),
                child: _buildMoreIndicator(remainingCount),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, int index) {
    final fullUrl = ApiEndpoints.getImageUrl(imageUrl);
    final hasValidImage = ApiEndpoints.isValidImageUrl(imageUrl);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColorForIndex(index),
        border: Border.all(color: Colors.white, width: 2),
        image: hasValidImage
            ? DecorationImage(
                image: NetworkImage(fullUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: !hasValidImage
          ? Icon(
              Icons.person,
              size: avatarSize * 0.5,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: avatarSize * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      AppColors.friendlyTeal,
      AppColors.friendlyPink,
      AppColors.friendlyPurple,
      AppColors.friendlyOrange,
    ];
    return colors[index % colors.length];
  }
}

/// Event capacity indicator - shows "5/15 joined" or "5 joined so far"
class EventCapacityIndicator extends StatelessWidget {
  final int joinedCount;
  final int? totalSlots;
  final bool compact;

  const EventCapacityIndicator({
    super.key,
    required this.joinedCount,
    this.totalSlots,
    this.compact = false,
  });

  bool get hasLimit => totalSlots != null && totalSlots! > 0;
  bool get isFull => hasLimit && joinedCount >= totalSlots!;
  double get fillPercentage =>
      hasLimit ? (joinedCount / totalSlots!).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFull
            ? AppColors.error.withAlpha(26)
            : AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: isFull
              ? AppColors.error.withAlpha(77)
              : AppColors.primaryBlue.withAlpha(77),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.group_off : Icons.group,
            size: 14,
            color: isFull ? AppColors.error : AppColors.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            hasLimit ? '$joinedCount/$totalSlots' : '$joinedCount joined',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFull ? AppColors.error : AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isFull ? Icons.group_off : Icons.group,
              size: 18,
              color: isFull ? AppColors.error : AppColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              hasLimit
                  ? '$joinedCount of $totalSlots spots filled'
                  : '$joinedCount people joined so far',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isFull ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (hasLimit) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillPercentage,
              minHeight: 6,
              backgroundColor: AppColors.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? AppColors.error : AppColors.primaryBlue,
              ),
            ),
          ),
          if (isFull) ...[
            const SizedBox(height: 4),
            Text(
              'This event is full',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Business badge indicator
class BusinessBadge extends StatelessWidget {
  final bool compact;
  final double? size;

  const BusinessBadge({
    super.key,
    this.compact = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? (compact ? 10.0 : 14.0);
    final fontSize = size != null ? size! * 0.5 : (compact ? 9.0 : 12.0);
    final paddingH = size != null ? size! * 0.3 : (compact ? 6.0 : 10.0);
    final paddingV = size != null ? size! * 0.1 : (compact ? 2.0 : 4.0);

    if (compact || size != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: iconSize, color: Colors.white),
            SizedBox(width: size != null ? 1 : 2),
            Text(
              'BIZ',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Business',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Event tags input widget - allows adding/removing tags
class EventTagsInput extends StatefulWidget {
  final List<String> tags;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final int maxTags;

  const EventTagsInput({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
    this.maxTags = 5,
  });

  @override
  State<EventTagsInput> createState() => _EventTagsInputState();
}

class _EventTagsInputState extends State<EventTagsInput> {
  final TextEditingController _controller = TextEditingController();

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag) && widget.tags.length < widget.maxTags) {
      widget.onAdd(tag);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add a tag...',
                  filled: true,
                  fillColor: AppColors.lightGrey.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add_circle),
              color: AppColors.primaryBlue,
              tooltip: 'Add tag',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.tags.length}/${widget.maxTags} tags',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.tags.map((tag) => Chip(
            label: Text(tag),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => widget.onRemove(tag),
            backgroundColor: AppColors.primaryBlue.withAlpha(26),
            labelStyle: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
            deleteIconColor: AppColors.primaryBlue,
          )).toList(),
        ),
      ],
    );
  }
}
