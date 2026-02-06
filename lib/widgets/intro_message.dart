import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Quick intro message templates
class IntroMessagePicker extends StatelessWidget {
  final String personName;
  final List<String>? sharedInterests;
  final String? sharedEvent;
  final Function(String) onSelect;

  const IntroMessagePicker({
    super.key,
    required this.personName,
    this.sharedInterests,
    this.sharedEvent,
    required this.onSelect,
  });

  List<String> get _messages {
    final messages = <String>[
      "Hey $personName! 👋",
      "Hi! Nice to meet you!",
    ];

    if (sharedInterests != null && sharedInterests!.isNotEmpty) {
      messages.add(
        "Hey! I noticed we both like ${sharedInterests!.first}. That's awesome!",
      );
    }

    if (sharedEvent != null) {
      messages.add(
        "Hey! Saw you at $sharedEvent. Great event right?",
      );
    }

    messages.addAll([
      "Hi $personName! Would love to connect!",
      "Hey! Your profile caught my eye. What's your favorite hangout spot?",
    ]);

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start the conversation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        ..._messages.take(4).map((msg) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _MessageOption(
            message: msg,
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(msg);
            },
          ),
        )),
      ],
    );
  }
}

class _MessageOption extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _MessageOption({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Icon(
              Icons.send,
              size: 16,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wave with optional message
class WaveButton extends StatelessWidget {
  final String personName;
  final bool hasWaved;
  final VoidCallback? onWave;

  const WaveButton({
    super.key,
    required this.personName,
    this.hasWaved = false,
    this.onWave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasWaved ? null : () {
        HapticFeedback.mediumImpact();
        onWave?.call();
        Get.snackbar(
          '👋 Wave Sent!',
          '$personName will be notified',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.friendlyTeal,
          colorText: Colors.white,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: hasWaved
              ? AppColors.success.withAlpha(26)
              : AppColors.friendlyTeal,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '👋',
              style: TextStyle(fontSize: hasWaved ? 16 : 18),
            ),
            const SizedBox(width: 8),
            Text(
              hasWaved ? 'Waved!' : 'Wave',
              style: TextStyle(
                color: hasWaved ? AppColors.success : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Connection prompt after event
class ConnectionPrompt extends StatelessWidget {
  final String personName;
  final String eventName;
  final VoidCallback? onConnect;
  final VoidCallback? onDismiss;

  const ConnectionPrompt({
    super.key,
    required this.personName,
    required this.eventName,
    this.onConnect,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple.withAlpha(26),
            AppColors.primaryBlue.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.friendlyPurple.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.friendlyPurple.withAlpha(51),
            ),
            child: Center(
              child: Text(
                personName[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.friendlyPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Met $personName?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'You were both at $eventName',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              size: 20,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
