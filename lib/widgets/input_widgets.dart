import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Custom text field
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? AppColors.lightGrey.withAlpha(128)
                : AppColors.lightGrey.withAlpha(51),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: _errorText != null
                ? Border.all(color: AppColors.error)
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    widget.prefixIcon,
                    color: AppColors.mediumGrey,
                    size: 20,
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.obscureText && _obscureText,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(color: AppColors.mediumGrey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 10 : 16,
                      vertical: widget.maxLines > 1 ? 14 : 16,
                    ),
                  ),
                  onChanged: (value) {
                    if (widget.validator != null) {
                      setState(() => _errorText = widget.validator!(value));
                    }
                    widget.onChanged?.call(value);
                  },
                ),
              ),
              if (widget.obscureText)
                GestureDetector(
                  onTap: () => setState(() => _obscureText = !_obscureText),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mediumGrey,
                      size: 20,
                    ),
                  ),
                ),
              if (widget.suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffix,
                ),
            ],
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            _errorText!,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// Search input field
class SearchInput extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  const SearchInput({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.mediumGrey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                autofocus: autofocus,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: AppColors.mediumGrey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: onChanged,
                onTap: onTap,
              ),
            ),
            if (controller != null && controller!.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller!.clear();
                  onClear?.call();
                },
                child: Icon(Icons.close, color: AppColors.mediumGrey, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tag input field
class TagInput extends StatefulWidget {
  final List<String> tags;
  final Function(String)? onAdd;
  final Function(String)? onRemove;
  final int maxTags;
  final String? hint;

  const TagInput({
    super.key,
    this.tags = const [],
    this.onAdd,
    this.onRemove,
    this.maxTags = 5,
    this.hint = 'Add tag...',
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && widget.tags.length < widget.maxTags) {
      widget.onAdd?.call(tag);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onRemove?.call(tag);
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                )),
            if (widget.tags.length < widget.maxTags)
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
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
      ],
    );
  }
}

/// OTP input field
class OTPInput extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;

  const OTPInput({
    super.key,
    this.length = 6,
    this.onCompleted,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(right: index < widget.length - 1 ? 12 : 0),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.lightGrey.withAlpha(128),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}

/// Slider input with labels
class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueLabel;
  final Function(double)? onChanged;

  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.valueLabel,
    this.onChanged,
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
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              valueLabel?.call(value) ?? value.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primaryBlue,
          inactiveColor: AppColors.lightGrey,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(0),
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
            ),
            Text(
              max.toStringAsFixed(0),
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ],
    );
  }
}
