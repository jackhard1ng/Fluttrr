import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Event vibe selector
class VibePicker extends StatelessWidget {
  final EventVibe? selected;
  final Function(EventVibe) onSelect;

  const VibePicker({
    super.key,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s the vibe?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventVibe.values.map((vibe) {
            final isSelected = selected == vibe;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(vibe);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? vibe.color.withAlpha(26)
                      : AppColors.lightGrey.withAlpha(77),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  border: Border.all(
                    color: isSelected ? vibe.color : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vibe.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      vibe.label,
                      style: TextStyle(
                        color: isSelected ? vibe.color : AppColors.darkGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum EventVibe {
  chill('😌', 'Chill', AppColors.friendlyTeal),
  energetic('🔥', 'Energetic', AppColors.friendlyOrange),
  social('🎉', 'Social', AppColors.friendlyPurple),
  focused('🎯', 'Focused', AppColors.primaryBlue),
  creative('🎨', 'Creative', AppColors.warmYellow),
  casual('☕', 'Casual', Color(0xFF795548));

  final String emoji;
  final String label;
  final Color color;

  const EventVibe(this.emoji, this.label, this.color);
}

/// Vibe badge display
class VibeBadge extends StatelessWidget {
  final EventVibe vibe;

  const VibeBadge({super.key, required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: vibe.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(vibe.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            vibe.label,
            style: TextStyle(
              fontSize: 11,
              color: vibe.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Event energy level
class EnergyLevel extends StatelessWidget {
  final int level; // 1-5
  final bool compact;

  const EnergyLevel({
    super.key,
    required this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedLevel = level.clamp(1, 5);
    final color = _getColor(clampedLevel);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: color),
          const SizedBox(width: 4),
          ...List.generate(5, (i) {
            return Container(
              width: 4,
              height: 12,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: i < clampedLevel ? color : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            _getLabel(clampedLevel),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ...List.generate(5, (i) {
            return Container(
              width: 6,
              height: 16,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: i < clampedLevel ? color : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getColor(int level) {
    if (level <= 2) return AppColors.friendlyTeal;
    if (level <= 3) return AppColors.warmYellow;
    return AppColors.friendlyOrange;
  }

  String _getLabel(int level) {
    switch (level) {
      case 1:
        return 'Very Relaxed';
      case 2:
        return 'Laid Back';
      case 3:
        return 'Moderate';
      case 4:
        return 'Energetic';
      case 5:
        return 'High Energy';
      default:
        return '';
    }
  }
}

/// Dress code indicator
class DressCode extends StatelessWidget {
  final DressCodeType type;

  const DressCode({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 6),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

enum DressCodeType {
  casual(Icons.checkroom, 'Casual'),
  smart(Icons.dry_cleaning, 'Smart Casual'),
  athletic(Icons.fitness_center, 'Athletic'),
  themed(Icons.celebration, 'Themed'),
  outdoor(Icons.park, 'Outdoor Ready');

  final IconData icon;
  final String label;

  const DressCodeType(this.icon, this.label);
}
