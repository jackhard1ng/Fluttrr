import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Star rating display
class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final bool showValue;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18,
    this.color,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.warmYellow;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final isFilled = index < rating.floor();
          final isHalf = !isFilled && index < rating;

          return Icon(
            isFilled
                ? Icons.star
                : isHalf
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: starColor,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.8,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive star rating input
class StarRatingInput extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final Function(double)? onRatingChanged;

  const StarRatingInput({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 36,
    this.onRatingChanged,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.maxRating, (index) {
        final isFilled = index < _rating;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _rating = index + 1.0;
            });
            widget.onRatingChanged?.call(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: widget.size,
              color: AppColors.warmYellow,
            ),
          ),
        );
      }),
    );
  }
}

/// Emoji rating (thumbs up/down)
class EmojiRating extends StatefulWidget {
  final bool? initialValue;
  final Function(bool?)? onChanged;

  const EmojiRating({
    super.key,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<EmojiRating> createState() => _EmojiRatingState();
}

class _EmojiRatingState extends State<EmojiRating> {
  bool? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EmojiButton(
          emoji: '👍',
          isSelected: _value == true,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _value = _value == true ? null : true;
            });
            widget.onChanged?.call(_value);
          },
        ),
        const SizedBox(width: 16),
        _EmojiButton(
          emoji: '👎',
          isSelected: _value == false,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _value = _value == false ? null : false;
            });
            widget.onChanged?.call(_value);
          },
        ),
      ],
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue)
              : null,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

/// Satisfaction scale (1-5 faces)
class SatisfactionScale extends StatefulWidget {
  final int? initialValue;
  final Function(int)? onChanged;

  const SatisfactionScale({
    super.key,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<SatisfactionScale> createState() => _SatisfactionScaleState();
}

class _SatisfactionScaleState extends State<SatisfactionScale> {
  int? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  static const _faces = ['😞', '😕', '😐', '🙂', '😄'];
  static const _labels = ['Bad', 'Poor', 'Okay', 'Good', 'Great'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final isSelected = _value == index + 1;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _value = index + 1;
                });
                widget.onChanged?.call(index + 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: isSelected
                      ? Border.all(color: AppColors.primaryBlue)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _faces[index],
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.mediumGrey,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Rating summary (with count and distribution)
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution; // star -> count

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating
        Column(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            StarRating(rating: averageRating, showValue: false),
            const SizedBox(height: 4),
            Text(
              '$totalReviews reviews',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Distribution bars
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              final stars = 5 - index;
              final count = distribution[stars] ?? 0;
              final percentage = totalReviews > 0
                  ? count / totalReviews
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '$stars',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.star, size: 12, color: AppColors.warmYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.lightGrey,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.warmYellow,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
