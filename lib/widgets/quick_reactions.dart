import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Quick emoji reactions for events and posts
class QuickReactions extends StatelessWidget {
  final Map<String, int> reactions;
  final String? userReaction;
  final Function(String) onReact;

  const QuickReactions({
    super.key,
    required this.reactions,
    this.userReaction,
    required this.onReact,
  });

  static const defaultReactions = ['👋', '🔥', '💜', '🙌', '😍'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: defaultReactions.map((emoji) {
        final count = reactions[emoji] ?? 0;
        final isSelected = userReaction == emoji;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onReact(emoji);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withAlpha(26)
                  : AppColors.lightGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(AppRadius.circular),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Floating reaction button that expands
class ReactionButton extends StatefulWidget {
  final String? currentReaction;
  final Function(String) onReact;

  const ReactionButton({
    super.key,
    this.currentReaction,
    required this.onReact,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 12 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.circular),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isExpanded
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: QuickReactions.defaultReactions.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onReact(emoji);
                      setState(() => _isExpanded = false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              )
            : Text(
                widget.currentReaction ?? '😊',
                style: const TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}

/// Reaction summary - shows who reacted
class ReactionSummary extends StatelessWidget {
  final int totalReactions;
  final List<String> topReactions;
  final VoidCallback? onTap;

  const ReactionSummary({
    super.key,
    required this.totalReactions,
    required this.topReactions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalReactions == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...topReactions.take(3).map((emoji) => Text(
              emoji,
              style: const TextStyle(fontSize: 14),
            )),
            const SizedBox(width: 6),
            Text(
              '$totalReactions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
