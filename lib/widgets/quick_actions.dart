import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Quick action buttons row
class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: action != actions.last ? 8 : 0,
            ),
            child: _QuickActionButton(action: action),
          ),
        );
      }).toList(),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: action.isPrimary
              ? action.color
              : action.color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              action.icon,
              color: action.isPrimary ? Colors.white : action.color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: action.isPrimary ? Colors.white : action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating action menu
class FloatingActionMenu extends StatelessWidget {
  final List<FloatingAction> actions;
  final VoidCallback? onClose;

  const FloatingActionMenu({
    super.key,
    required this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          return _FloatingActionItem(action: action);
        }).toList(),
      ),
    );
  }
}

class FloatingAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  FloatingAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _FloatingActionItem extends StatelessWidget {
  final FloatingAction action;

  const _FloatingActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: action.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, size: 20, color: action.color),
            ),
            const SizedBox(width: 12),
            Text(
              action.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon action button (compact)
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final bool isActive;
  final String? badge;

  const IconActionButton({
    super.key,
    required this.icon,
    this.color,
    required this.onTap,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.mediumGrey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? buttonColor.withAlpha(26)
                  : AppColors.lightGrey.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? buttonColor : AppColors.mediumGrey,
            ),
          ),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Swipe action indicator
class SwipeHint extends StatelessWidget {
  final SwipeDirection direction;
  final String label;

  const SwipeHint({
    super.key,
    required this.direction,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (direction == SwipeDirection.left) ...[
          Icon(Icons.arrow_back, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.mediumGrey,
          ),
        ),
        if (direction == SwipeDirection.right) ...[
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 14, color: AppColors.mediumGrey),
        ],
      ],
    );
  }
}

enum SwipeDirection { left, right }
