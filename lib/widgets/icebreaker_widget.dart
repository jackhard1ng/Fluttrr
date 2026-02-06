import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Icebreaker system to help people start conversations at events
class IcebreakerWidget extends StatefulWidget {
  final String? eventType;
  final VoidCallback? onDismiss;

  const IcebreakerWidget({
    super.key,
    this.eventType,
    this.onDismiss,
  });

  @override
  State<IcebreakerWidget> createState() => _IcebreakerWidgetState();
}

class _IcebreakerWidgetState extends State<IcebreakerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _currentQuestion = '';
  int _questionIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
    _pickRandomQuestion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pickRandomQuestion() {
    final questions = _getQuestions(widget.eventType);
    final random = Random();
    setState(() {
      _questionIndex = random.nextInt(questions.length);
      _currentQuestion = questions[_questionIndex];
    });
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    _animationController.reset();
    _pickRandomQuestion();
    _animationController.forward();
  }

  List<String> _getQuestions(String? eventType) {
    // General icebreakers
    final general = [
      "What's the most spontaneous thing you've ever done?",
      "If you could learn any skill instantly, what would it be?",
      "What's your go-to karaoke song?",
      "What's the best piece of advice you've ever received?",
      "If you could have dinner with anyone, living or dead, who would it be?",
      "What's something on your bucket list?",
      "What's your hidden talent?",
      "What's the last thing that made you laugh out loud?",
      "If you could live anywhere for a year, where would you choose?",
      "What's your comfort movie or TV show?",
      "What's a hobby you'd love to pick up?",
      "What's the best trip you've ever taken?",
      "If you won the lottery tomorrow, what's the first thing you'd do?",
      "What's something that always makes your day better?",
      "What's a fun fact about you that surprises people?",
    ];

    // Event-specific icebreakers
    final eventSpecific = <String, List<String>>{
      'Coffee': [
        "What's your coffee order? Strong and black or sweet and creamy?",
        "Morning person or night owl?",
        "What's the weirdest thing you've ever added to coffee?",
        "Favorite cozy café memory?",
      ],
      'Hiking': [
        "What's the most beautiful place you've hiked?",
        "Sunrise hikes or sunset views?",
        "Mountains or beaches for relaxation?",
        "What's in your ideal hiking snack bag?",
      ],
      'Games': [
        "What's your all-time favorite board game?",
        "Are you a sore loser or gracious winner?",
        "Video games, board games, or card games?",
        "What game are you unbeatable at?",
      ],
      'Food': [
        "What's your signature dish to cook?",
        "Spicy or mild?",
        "What's a food you've never tried but want to?",
        "Best restaurant you've ever been to?",
      ],
      'Sports': [
        "What sport did you play growing up?",
        "Favorite team to cheer for?",
        "Play to win or play for fun?",
        "What sport have you always wanted to try?",
      ],
      'Music': [
        "What's the last concert you went to?",
        "Can you play any instruments?",
        "What song is your current earworm?",
        "What's your guilty pleasure music genre?",
      ],
      'Arts': [
        "What form of art speaks to you most?",
        "Do you create art yourself?",
        "What's the most memorable piece of art you've seen?",
        "If you could own any famous artwork, which would it be?",
      ],
      'Outdoors': [
        "Camping in a tent or glamping?",
        "Favorite outdoor activity?",
        "Best wildlife encounter you've had?",
        "Beach day or forest adventure?",
      ],
    };

    // Combine general with event-specific if available
    if (eventType != null && eventSpecific.containsKey(eventType)) {
      return [...eventSpecific[eventType]!, ...general];
    }
    return general;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.friendlyPurple,
              AppColors.primaryBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.friendlyPurple.withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.psychology_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversation Starter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Break the ice with this question',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDismiss != null)
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Question
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: AppColors.friendlyPurple.withAlpha(77),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentQuestion,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                // Copy button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _currentQuestion));
                      Get.snackbar(
                        'Copied!',
                        'Question copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Next button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: const Icon(Icons.shuffle, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.friendlyPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick icebreaker card that can be shown anywhere
class IcebreakerCard extends StatelessWidget {
  final String? eventType;

  const IcebreakerCard({super.key, this.eventType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showIcebreakerSheet(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.friendlyPurple.withAlpha(26),
              AppColors.primaryBlue.withAlpha(26),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.friendlyPurple.withAlpha(77),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.psychology_alt,
                color: AppColors.friendlyPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need a Conversation Starter?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap for icebreaker questions',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.friendlyPurple,
            ),
          ],
        ),
      ),
    );
  }

  void _showIcebreakerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: IcebreakerWidget(
          eventType: eventType,
          onDismiss: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

/// Floating icebreaker button for events
class FloatingIcebreakerButton extends StatefulWidget {
  final String? eventType;

  const FloatingIcebreakerButton({super.key, this.eventType});

  @override
  State<FloatingIcebreakerButton> createState() => _FloatingIcebreakerButtonState();
}

class _FloatingIcebreakerButtonState extends State<FloatingIcebreakerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: FloatingActionButton(
        onPressed: () => _showIcebreakerSheet(context),
        backgroundColor: AppColors.friendlyPurple,
        child: const Icon(Icons.psychology_alt, color: Colors.white),
      ),
    );
  }

  void _showIcebreakerSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: IcebreakerWidget(
          eventType: widget.eventType,
          onDismiss: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

/// Quick two-person game suggestions for awkward moments
class TwoPersonGames extends StatelessWidget {
  const TwoPersonGames({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      GameSuggestion(
        name: 'Two Truths & A Lie',
        description: 'Each person shares three facts - guess which is false!',
        icon: Icons.psychology,
      ),
      GameSuggestion(
        name: 'Would You Rather',
        description: 'Take turns asking impossible choices',
        icon: Icons.compare_arrows,
      ),
      GameSuggestion(
        name: '20 Questions',
        description: 'Think of something, other person has 20 yes/no questions',
        icon: Icons.help_outline,
      ),
      GameSuggestion(
        name: 'Story Builder',
        description: 'Take turns adding one sentence to a story',
        icon: Icons.auto_stories,
      ),
      GameSuggestion(
        name: 'Word Association',
        description: 'Say the first word that comes to mind',
        icon: Icons.chat_bubble_outline,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_esports, color: AppColors.friendlyTeal),
              const SizedBox(width: 8),
              Text(
                'Quick Games for Two',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...games.map((game) => _GameTile(game: game)),
        ],
      ),
    );
  }
}

class GameSuggestion {
  final String name;
  final String description;
  final IconData icon;

  GameSuggestion({
    required this.name,
    required this.description,
    required this.icon,
  });
}

class _GameTile extends StatelessWidget {
  final GameSuggestion game;

  const _GameTile({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.friendlyTeal.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(game.icon, size: 20, color: AppColors.friendlyTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  game.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
