import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Simple poll for event planning
class QuickPoll extends StatelessWidget {
  final String question;
  final List<PollOption> options;
  final String? userVote;
  final Function(String) onVote;
  final bool showResults;

  const QuickPoll({
    super.key,
    required this.question,
    required this.options,
    this.userVote,
    required this.onVote,
    this.showResults = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalVotes = options.fold(0, (sum, o) => sum + o.votes);

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
          // Question
          Row(
            children: [
              Icon(
                Icons.poll,
                size: 20,
                color: AppColors.friendlyPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Options
          ...options.map((option) {
            final isSelected = userVote == option.id;
            final percentage = totalVotes > 0
                ? (option.votes / totalVotes * 100).round()
                : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onVote(option.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.friendlyPurple
                          : AppColors.lightGrey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md - 1),
                    child: Stack(
                      children: [
                        // Progress bar (when showing results)
                        if (showResults || userVote != null)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                color: isSelected
                                    ? AppColors.friendlyPurple.withAlpha(51)
                                    : AppColors.lightGrey.withAlpha(128),
                              ),
                            ),
                          ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Radio indicator
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.friendlyPurple
                                        : AppColors.mediumGrey,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppColors.friendlyPurple
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Option text
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),

                              // Percentage
                              if (showResults || userVote != null)
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.friendlyPurple
                                        : AppColors.mediumGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Total votes
          if (showResults || userVote != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$totalVotes vote${totalVotes != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });
}

/// Create poll sheet
class CreatePollSheet extends StatefulWidget {
  final Function(String question, List<String> options) onCreate;

  const CreatePollSheet({super.key, required this.onCreate});

  @override
  State<CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends State<CreatePollSheet> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.poll, color: AppColors.friendlyPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Create Poll',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Question
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        hintText: 'What time works best?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Options',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Options
                    ...List.generate(_optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            if (_optionControllers.length > 2)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _optionControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),

                    // Add option button
                    if (_optionControllers.length < 5)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _optionControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Option'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.friendlyPurple,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canCreate()
                            ? () {
                                widget.onCreate(
                                  _questionController.text,
                                  _optionControllers
                                      .map((c) => c.text)
                                      .where((t) => t.isNotEmpty)
                                      .toList(),
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.friendlyPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Create Poll',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCreate() {
    if (_questionController.text.isEmpty) return false;
    final filledOptions = _optionControllers
        .where((c) => c.text.isNotEmpty)
        .length;
    return filledOptions >= 2;
  }
}

/// Yes/No quick poll
class YesNoPoll extends StatelessWidget {
  final String question;
  final int yesVotes;
  final int noVotes;
  final bool? userVote; // true = yes, false = no, null = not voted
  final Function(bool) onVote;

  const YesNoPoll({
    super.key,
    required this.question,
    this.yesVotes = 0,
    this.noVotes = 0,
    this.userVote,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final total = yesVotes + noVotes;

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
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Yes button
              Expanded(
                child: _VoteButton(
                  label: 'Yes',
                  emoji: '👍',
                  votes: yesVotes,
                  total: total,
                  isSelected: userVote == true,
                  color: AppColors.success,
                  onTap: () => onVote(true),
                ),
              ),
              const SizedBox(width: 12),
              // No button
              Expanded(
                child: _VoteButton(
                  label: 'No',
                  emoji: '👎',
                  votes: noVotes,
                  total: total,
                  isSelected: userVote == false,
                  color: AppColors.error,
                  onTap: () => onVote(false),
                ),
              ),
            ],
          ),

          if (total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '$total vote${total != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final String emoji;
  final int votes;
  final int total;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.emoji,
    required this.votes,
    required this.total,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (votes / total * 100).round() : 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.darkGrey,
              ),
            ),
            if (total > 0)
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
