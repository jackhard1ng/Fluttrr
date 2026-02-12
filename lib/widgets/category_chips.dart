import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Event category chip
class CategoryChip extends StatelessWidget {
  final EventCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color
              : category.color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                color: isSelected ? Colors.white : category.color,
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

enum EventCategory {
  social('🎉', 'Social', AppColors.friendlyPurple),
  food('🍕', 'Food & Drinks', AppColors.friendlyOrange),
  outdoor('🌳', 'Outdoor', AppColors.success),
  sports('⚽', 'Sports', AppColors.primaryBlue),
  nightlife('🌙', 'Nightlife', Color(0xFF6A1B9A)),
  liveMusic('🎵', 'Live Music', Color(0xFFE91E63)),
  fitness('💪', 'Fitness', AppColors.friendlyTeal),
  arts('🎨', 'Arts & Culture', AppColors.warmYellow),
  networking('🤝', 'Networking', Color(0xFF0288D1)),
  community('🏘️', 'Community', Color(0xFF795548)),
  wellness('🧘', 'Wellness', Color(0xFF00BCD4)),
  comedy('😂', 'Comedy', Color(0xFFFF6F00)),
  markets('🛍️', 'Markets & Fairs', Color(0xFF9C27B0)),
  family('👨‍👩‍👧', 'Family', Color(0xFF2E7D32));

  final String emoji;
  final String label;
  final Color color;

  const EventCategory(this.emoji, this.label, this.color);
}

/// Category picker grid
class CategoryPicker extends StatelessWidget {
  final List<EventCategory> selected;
  final Function(EventCategory) onToggle;
  final int maxSelections;

  const CategoryPicker({
    super.key,
    this.selected = const [],
    required this.onToggle,
    this.maxSelections = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              '${selected.length}/$maxSelections',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventCategory.values.map((cat) {
            final isSelected = selected.contains(cat);
            return CategoryChip(
              category: cat,
              isSelected: isSelected,
              onTap: () => onToggle(cat),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Filter chips row
class FilterChips extends StatelessWidget {
  final List<FilterOption> options;
  final String? selected;
  final Function(String?) onSelect;

  const FilterChips({
    super.key,
    required this.options,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: option.label,
              icon: option.icon,
              isSelected: selected == option.id,
              onTap: () => onSelect(option.id),
            ),
          )),
        ],
      ),
    );
  }
}

class FilterOption {
  final String id;
  final String label;
  final IconData? icon;

  FilterOption({required this.id, required this.label, this.icon});
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.mediumGrey,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGrey,
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

/// Interest chip (for profiles)
class InterestChip extends StatelessWidget {
  final String interest;
  final bool isHighlighted;

  const InterestChip({
    super.key,
    required this.interest,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.friendlyPurple.withAlpha(26)
            : AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: isHighlighted
              ? AppColors.friendlyPurple
              : Colors.transparent,
        ),
      ),
      child: Text(
        interest,
        style: TextStyle(
          fontSize: 13,
          color: isHighlighted ? AppColors.friendlyPurple : AppColors.darkGrey,
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
