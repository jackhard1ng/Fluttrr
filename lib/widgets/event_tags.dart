import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Simple event tags
class EventTags extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onTagTap;

  const EventTags({
    super.key,
    required this.tags,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return GestureDetector(
          onTap: () => onTagTap?.call(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getTagColor(tag).withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(
                color: _getTagColor(tag),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getTagColor(String tag) {
    final tagLower = tag.toLowerCase();
    if (tagLower.contains('outdoor') || tagLower.contains('nature')) {
      return AppColors.friendlyTeal;
    }
    if (tagLower.contains('chill') || tagLower.contains('relax')) {
      return AppColors.primaryBlue;
    }
    if (tagLower.contains('active') || tagLower.contains('sport')) {
      return AppColors.friendlyOrange;
    }
    if (tagLower.contains('food') || tagLower.contains('coffee')) {
      return const Color(0xFF8D6E63);
    }
    if (tagLower.contains('game') || tagLower.contains('fun')) {
      return AppColors.friendlyPurple;
    }
    return AppColors.mediumGrey;
  }
}

/// Predefined tag suggestions
class TagSuggestions extends StatelessWidget {
  final List<String> selectedTags;
  final Function(String) onToggle;

  const TagSuggestions({
    super.key,
    required this.selectedTags,
    required this.onToggle,
  });

  static const suggestions = [
    'outdoor', 'chill', 'active', 'foodie', 'games',
    'creative', 'music', 'sports', 'social', 'learning',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggle(tag);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.lightGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(AppRadius.circular),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              ),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Event tags input with add/remove functionality
class EventTagsInput extends StatefulWidget {
  final List<String> tags;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const EventTagsInput({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<EventTagsInput> createState() => _EventTagsInputState();
}

class _EventTagsInputState extends State<EventTagsInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim().toLowerCase();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onAdd(tag);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.tags.map((tag) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onRemove(tag);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.close, size: 14, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withAlpha(128),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a tag...',
                    hintStyle: TextStyle(color: AppColors.mediumGrey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              GestureDetector(
                onTap: _addTag,
                child: Icon(Icons.add_circle, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
