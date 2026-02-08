import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';
import '../utils/debouncer.dart';

/// Customizable search bar widget with debounce support
class AppSearchBar extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final Duration debounceDuration;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.padding,
    this.borderRadius = AppRadius.lg,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late Debouncer _debouncer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer = Debouncer(delay: widget.debounceDuration);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _debouncer.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    if (widget.onChanged != null) {
      _debouncer.run(() => widget.onChanged!(_controller.text));
    }
  }

  void _clearText() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark ? const Color(0xFF2C2C2C) : AppColors.lightGrey),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        children: [
          // Leading icon
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: widget.leading ??
                Icon(
                  Icons.search,
                  color: AppColors.mediumGrey,
                  size: 20,
                ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              onTap: widget.onTap,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: AppColors.mediumGrey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),

          // Clear button or trailing widget
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.mediumGrey,
              onPressed: _clearText,
              padding: EdgeInsets.zero,
              tooltip: 'Clear search',
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            )
          else if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: widget.trailing!,
            ),
        ],
      ),
    );
  }
}

/// Search bar that looks like a button (tappable, navigates to search screen)
class SearchBarButton extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final double borderRadius;

  const SearchBarButton({
    super.key,
    this.hint = 'Search...',
    required this.onTap,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.borderRadius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: backgroundColor ??
          (isDark ? const Color(0xFF2C2C2C) : AppColors.lightGrey),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              leading ??
                  Icon(
                    Icons.search,
                    color: AppColors.mediumGrey,
                    size: 20,
                  ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 14,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter chip row for search results
class SearchFilterChips extends StatelessWidget {
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterSelected;
  final bool showAll;
  final String allLabel;

  const SearchFilterChips({
    super.key,
    required this.filters,
    this.selectedFilter,
    required this.onFilterSelected,
    this.showAll = true,
    this.allLabel = 'All',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          if (showAll)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: allLabel,
                selected: selectedFilter == null,
                onTap: () => onFilterSelected(null),
              ),
            ),
          ...filters.map((filter) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: filter,
                  selected: selectedFilter == filter,
                  onTap: () => onFilterSelected(filter),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlue : AppColors.primaryBlue.withAlpha(26),
      borderRadius: BorderRadius.circular(AppRadius.circular),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.circular),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
