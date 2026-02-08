import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class ReportScreen extends StatefulWidget {
  final String? userName;
  final String? eventName;
  final String? businessName;

  const ReportScreen({super.key, this.userName, this.eventName, this.businessName});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();
  bool _blockUser = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String get _reportingWhat {
    if (widget.userName != null) return widget.userName!;
    if (widget.eventName != null) return widget.eventName!;
    if (widget.businessName != null) return widget.businessName!;
    return 'this content';
  }

  bool get _isUserReport => widget.userName != null;
  bool get _isBusinessReport => widget.businessName != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'Report',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(13),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report $_reportingWhat',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Your report is anonymous',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason selection
            Text(
              'Why are you reporting?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            ...ReportReason.values.map((reason) {
              final isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedReason = reason);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withAlpha(13)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.lightGrey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Additional details
            Text(
              'Additional details (optional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: TextField(
                controller: _detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us more about what happened...',
                  hintStyle: TextStyle(color: AppColors.mediumGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Block option (for users and businesses)
            if (_isUserReport || _isBusinessReport)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _blockUser = !_blockUser);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _blockUser
                        ? AppColors.error.withAlpha(13)
                        : AppColors.lightGrey.withAlpha(77),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: _blockUser ? AppColors.error : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _blockUser ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _blockUser ? AppColors.error : AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isUserReport
                                  ? 'Also block ${widget.userName}'
                                  : 'Also unfollow ${widget.businessName}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _isUserReport
                                  ? 'They won\'t be able to see your profile or contact you'
                                  : 'You won\'t see their events in your feed',
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
                ),
              ),
            const SizedBox(height: 32),

            // Submit button
            GestureDetector(
              onTap: _selectedReason != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      Get.back();
                      Get.snackbar(
                        'Report Submitted',
                        'Thank you for helping keep Fluttrr safe',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedReason != null
                      ? AppColors.error
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    'Submit Report',
                    style: TextStyle(
                      color: _selectedReason != null
                          ? Colors.white
                          : AppColors.mediumGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ReportReason {
  inappropriate('Inappropriate content'),
  harassment('Harassment or bullying'),
  spam('Spam or scam'),
  fake('Fake profile or event'),
  safety('Safety concern'),
  other('Something else');

  final String label;
  const ReportReason(this.label);
}
