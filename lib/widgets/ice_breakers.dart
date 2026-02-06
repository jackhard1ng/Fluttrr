import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Ice breaker suggestions to help start conversations
class IceBreakerCard extends StatefulWidget {
  final String? otherPersonName;
  final List<String>? sharedInterests;
  final VoidCallback? onSend;

  const IceBreakerCard({
    super.key,
    this.otherPersonName,
    this.sharedInterests,
    this.onSend,
  });

  @override
  State<IceBreakerCard> createState() => _IceBreakerCardState();
}

class _IceBreakerCardState extends State<IceBreakerCard> {
  late String _currentIceBreaker;
  final _random = Random();

  final List<String> _genericIceBreakers = [
    "What's the best thing that happened to you this week?",
    "If you could have dinner with anyone, who would it be?",
    "What's your go-to comfort show or movie?",
    "Coffee or tea? And what's your order?",
    "What's something you're really looking forward to?",
    "What hobby have you always wanted to try?",
    "What's the last thing that made you laugh out loud?",
    "If you won the lottery, what's the first thing you'd do?",
    "What's your ideal lazy Sunday look like?",
    "What song is stuck in your head right now?",
    "Are you more of an early bird or night owl?",
    "What's a skill you'd love to master?",
    "What's your comfort food?",
    "Beach vacation or mountain retreat?",
    "What's the best advice you've ever received?",
  ];

  final Map<String, List<String>> _interestBasedIceBreakers = {
    'Music': [
      "What concert changed your life?",
      "What's on your playlist right now?",
      "Any artist you're obsessed with lately?",
    ],
    'Gaming': [
      "What game have you been playing lately?",
      "What's your all-time favorite game?",
      "Console or PC?",
    ],
    'Food': [
      "What's the best meal you've had recently?",
      "Do you have a signature dish you make?",
      "What cuisine could you eat every day?",
    ],
    'Fitness': [
      "What's your workout routine like?",
      "Morning workout or evening?",
      "Any fitness goals you're working on?",
    ],
    'Movies': [
      "Seen any good movies lately?",
      "What's a movie you can watch over and over?",
      "Marvel or DC?",
    ],
    'Reading': [
      "What book has stayed with you?",
      "Reading anything good right now?",
      "Fiction or non-fiction?",
    ],
    'Travel': [
      "What's your dream travel destination?",
      "Best trip you've ever taken?",
      "Mountains or beaches for vacation?",
    ],
    'Art': [
      "What kind of art do you make?",
      "Any artists that inspire you?",
      "Been to any good exhibits lately?",
    ],
    'Sports': [
      "What sports do you follow?",
      "Play any sports yourself?",
      "Who's your team?",
    ],
    'Outdoors': [
      "What's your favorite outdoor activity?",
      "Best hike you've done?",
      "Camping or glamping?",
    ],
  };

  @override
  void initState() {
    super.initState();
    _generateIceBreaker();
  }

  void _generateIceBreaker() {
    List<String> options = [..._genericIceBreakers];

    // Add interest-based ice breakers if we have shared interests
    if (widget.sharedInterests != null && widget.sharedInterests!.isNotEmpty) {
      for (final interest in widget.sharedInterests!) {
        if (_interestBasedIceBreakers.containsKey(interest)) {
          options.addAll(_interestBasedIceBreakers[interest]!);
        }
      }
    }

    setState(() {
      _currentIceBreaker = options[_random.nextInt(options.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyTeal.withAlpha(26),
            AppColors.primaryBlue.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.friendlyTeal.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.friendlyTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Conversation Starter',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _generateIceBreaker();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: AppColors.friendlyTeal,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _currentIceBreaker,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (widget.onSend != null) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onSend?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.otherPersonName != null
                          ? 'Ask ${widget.otherPersonName}'
                          : 'Send This',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick ice breaker suggestions as chips
class IceBreakerChips extends StatelessWidget {
  final Function(String)? onSelect;
  final List<String>? customPrompts;

  const IceBreakerChips({
    super.key,
    this.onSelect,
    this.customPrompts,
  });

  @override
  Widget build(BuildContext context) {
    final prompts = customPrompts ?? [
      "What are you up to today?",
      "How's your week going?",
      "Got any fun plans?",
      "Know any good spots around here?",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect?.call(prompt);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// "What to talk about" section showing shared interests
class SharedInterestsCard extends StatelessWidget {
  final String otherPersonName;
  final List<String> sharedInterests;

  const SharedInterestsCard({
    super.key,
    required this.otherPersonName,
    required this.sharedInterests,
  });

  @override
  Widget build(BuildContext context) {
    if (sharedInterests.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.warmYellow,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'You both like',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sharedInterests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Fun facts prompt card
class FunFactPrompt extends StatelessWidget {
  final VoidCallback? onAnswer;

  const FunFactPrompt({
    super.key,
    this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.friendlyPurple.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              color: AppColors.friendlyPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share a fun fact!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help others get to know you better',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onAnswer != null)
            GestureDetector(
              onTap: onAnswer,
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.friendlyPurple,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

/// Question game widget for starting conversations
class QuestionGame extends StatefulWidget {
  final Function(String question)? onAsk;

  const QuestionGame({super.key, this.onAsk});

  @override
  State<QuestionGame> createState() => _QuestionGameState();
}

class _QuestionGameState extends State<QuestionGame> {
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> _questionCategories = [
    {
      'category': 'Light & Fun',
      'icon': Icons.sentiment_satisfied_alt,
      'color': AppColors.warmYellow,
      'questions': [
        "What's your guilty pleasure show?",
        "Pizza toppings: what's acceptable?",
        "What's your karaoke song?",
        "What emoji do you use way too much?",
      ],
    },
    {
      'category': 'Getting Deeper',
      'icon': Icons.psychology,
      'color': AppColors.friendlyPurple,
      'questions': [
        "What's something you're proud of?",
        "What's on your bucket list?",
        "What's a life lesson you learned the hard way?",
        "What makes a good friend to you?",
      ],
    },
    {
      'category': 'Hypotheticals',
      'icon': Icons.lightbulb_outline,
      'color': AppColors.friendlyTeal,
      'questions': [
        "If you could live anywhere, where would it be?",
        "What superpower would you want?",
        "If you could have any job for a day, what would it be?",
        "What would you do with an extra hour each day?",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Take turns asking and answering',
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._questionCategories.map((category) {
          return _QuestionCategory(
            category: category,
            onAsk: widget.onAsk,
          );
        }),
      ],
    );
  }
}

class _QuestionCategory extends StatelessWidget {
  final Map<String, dynamic> category;
  final Function(String)? onAsk;

  const _QuestionCategory({
    required this.category,
    this.onAsk,
  });

  @override
  Widget build(BuildContext context) {
    final color = category['color'] as Color;
    final questions = category['questions'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withAlpha(26)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(category['icon'], color: color),
        title: Text(
          category['category'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        children: questions.map((q) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              q,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onAsk?.call(q);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: const Text(
                  'Ask',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
