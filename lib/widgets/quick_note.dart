import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Quick note from host
class HostNote extends StatelessWidget {
  final String note;
  final String? hostName;

  const HostNote({
    super.key,
    required this.note,
    this.hostName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                hostName != null ? 'Note from $hostName' : 'Host Note',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned message
class PinnedMessage extends StatelessWidget {
  final String message;
  final String? author;
  final VoidCallback? onDismiss;

  const PinnedMessage({
    super.key,
    required this.message,
    this.author,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.push_pin, size: 16, color: AppColors.warmYellow),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
                if (author != null)
                  Text(
                    '— $author',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: AppColors.mediumGrey),
            ),
        ],
      ),
    );
  }
}

/// Add a note input
class AddNoteInput extends StatefulWidget {
  final Function(String) onSubmit;
  final String? hintText;

  const AddNoteInput({
    super.key,
    required this.onSubmit,
    this.hintText,
  });

  @override
  State<AddNoteInput> createState() => _AddNoteInputState();
}

class _AddNoteInputState extends State<AddNoteInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Add a note...',
                hintStyle: TextStyle(color: AppColors.mediumGrey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (text) {
                setState(() => _hasText = text.trim().isNotEmpty);
              },
              maxLines: 2,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _hasText
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onSubmit(_controller.text.trim());
                    _controller.clear();
                    setState(() => _hasText = false);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hasText ? AppColors.primaryBlue : AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: 18,
                color: _hasText ? Colors.white : AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Update banner
class UpdateBanner extends StatelessWidget {
  final String message;
  final UpdateType type;
  final VoidCallback? onDismiss;

  const UpdateBanner({
    super.key,
    required this.message,
    this.type = UpdateType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: type.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: type.color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(type.icon, size: 20, color: type.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 18, color: AppColors.mediumGrey),
            ),
        ],
      ),
    );
  }
}

enum UpdateType {
  info(Icons.info_outline, AppColors.primaryBlue),
  warning(Icons.warning_amber, AppColors.friendlyOrange),
  success(Icons.check_circle_outline, AppColors.success),
  change(Icons.edit, AppColors.friendlyPurple);

  final IconData icon;
  final Color color;

  const UpdateType(this.icon, this.color);
}

/// Tip of the day
class TipCard extends StatelessWidget {
  final String tip;
  final VoidCallback? onDismiss;

  const TipCard({
    super.key,
    required this.tip,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple.withAlpha(26),
            AppColors.friendlyTeal.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.friendlyPurple.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Text('💡', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.friendlyPurple,
                  ),
                ),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 18, color: AppColors.mediumGrey),
            ),
        ],
      ),
    );
  }
}
