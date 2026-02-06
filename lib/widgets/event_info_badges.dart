import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Cost indicator - Free / $ / $$ / $$$
class CostBadge extends StatelessWidget {
  final EventCost cost;

  const CostBadge({super.key, required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cost.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        cost.label,
        style: TextStyle(
          color: cost.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

enum EventCost {
  free('Free', AppColors.success),
  low('\$', AppColors.friendlyTeal),
  medium('\$\$', AppColors.friendlyOrange),
  high('\$\$\$', AppColors.friendlyPurple);

  final String label;
  final Color color;

  const EventCost(this.label, this.color);
}

/// Group size indicator
class GroupSizeBadge extends StatelessWidget {
  final GroupSize size;

  const GroupSizeBadge({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(size.icon, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
          Text(
            size.label,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

enum GroupSize {
  small(Icons.person, 'Small (2-5)'),
  medium(Icons.people, 'Medium (6-15)'),
  large(Icons.groups, 'Large (15+)');

  final IconData icon;
  final String label;

  const GroupSize(this.icon, this.label);
}

/// First timer badge
class FirstTimerBadge extends StatelessWidget {
  const FirstTimerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: AppColors.warmYellow.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⭐', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            'First Event',
            style: TextStyle(
              color: AppColors.warmYellow,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verified host badge
class VerifiedHostBadge extends StatelessWidget {
  const VerifiedHostBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: AppColors.primaryBlue),
          const SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// What to bring list
class WhatToBring extends StatelessWidget {
  final List<String> items;

  const WhatToBring({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.friendlyTeal.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.friendlyTeal.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backpack, size: 18, color: AppColors.friendlyTeal),
              const SizedBox(width: 8),
              Text(
                'What to Bring',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.friendlyTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: AppColors.friendlyTeal),
                    const SizedBox(width: 4),
                    Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Simple info row with icon
class EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const EventInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.mediumGrey),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

/// Accessibility badges
class AccessibilityBadges extends StatelessWidget {
  final bool wheelchairAccessible;
  final bool hasParking;
  final bool petFriendly;

  const AccessibilityBadges({
    super.key,
    this.wheelchairAccessible = false,
    this.hasParking = false,
    this.petFriendly = false,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    if (wheelchairAccessible) {
      badges.add(_Badge(icon: Icons.accessible, label: 'Accessible'));
    }
    if (hasParking) {
      badges.add(_Badge(icon: Icons.local_parking, label: 'Parking'));
    }
    if (petFriendly) {
      badges.add(_Badge(icon: Icons.pets, label: 'Pet Friendly'));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: badges);
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
          Text(
            label,
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
