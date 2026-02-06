import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../widgets/common_widgets.dart';

/// Quick hangout creation - simple flow for spontaneous plans
class QuickHangoutScreen extends StatefulWidget {
  const QuickHangoutScreen({super.key});

  @override
  State<QuickHangoutScreen> createState() => _QuickHangoutScreenState();
}

class _QuickHangoutScreenState extends State<QuickHangoutScreen> {
  int _currentStep = 0;
  String? _selectedActivity;
  String _selectedTiming = 'now';
  DateTime _customDate = DateTime.now();
  TimeOfDay _customTime = TimeOfDay.now();
  int _groupSize = 4;
  String _vibe = 'Casual';
  bool _friendsOnly = true;
  final _noteController = TextEditingController();
  final List<String> _invitedFriends = [];

  final List<Map<String, dynamic>> _quickActivities = [
    {'name': 'Coffee', 'icon': Icons.coffee, 'color': const Color(0xFF8D6E63)},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': AppColors.friendlyOrange},
    {'name': 'Drinks', 'icon': Icons.local_bar, 'color': AppColors.friendlyPurple},
    {'name': 'Walk', 'icon': Icons.directions_walk, 'color': AppColors.friendlyTeal},
    {'name': 'Games', 'icon': Icons.sports_esports, 'color': AppColors.primaryBlue},
    {'name': 'Movies', 'icon': Icons.movie, 'color': const Color(0xFFE91E63)},
    {'name': 'Sports', 'icon': Icons.sports_basketball, 'color': AppColors.success},
    {'name': 'Study', 'icon': Icons.menu_book, 'color': AppColors.warmYellow},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': AppColors.mediumGrey},
  ];

  final List<Map<String, dynamic>> _timingOptions = [
    {'value': 'now', 'label': 'Right now', 'icon': Icons.flash_on},
    {'value': '1hour', 'label': 'In an hour', 'icon': Icons.schedule},
    {'value': 'today', 'label': 'Later today', 'icon': Icons.today},
    {'value': 'tomorrow', 'label': 'Tomorrow', 'icon': Icons.event},
    {'value': 'custom', 'label': 'Pick a time', 'icon': Icons.calendar_today},
  ];

  final List<String> _vibeOptions = ['Casual', 'Energetic', 'Chill', 'Active', 'Creative'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _createHangout();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  void _createHangout() {
    HapticFeedback.heavyImpact();

    // Show success
    Get.dialog(
      _SuccessDialog(
        activity: _selectedActivity!,
        timing: _selectedTiming,
        groupSize: _groupSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quick Hangout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppColors.primaryBlue
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(),
            ),
          ),

          // Bottom actions
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 80),
                const Spacer(),
                GradientButton(
                  text: _currentStep < 3 ? 'Continue' : 'Create Hangout',
                  onPressed: _canContinue() ? _nextStep : null,
                  width: 160,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedActivity != null;
      case 1:
        return _selectedTiming.isNotEmpty;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildActivityStep();
      case 1:
        return _buildTimingStep();
      case 2:
        return _buildDetailsStep();
      case 3:
        return _buildInviteStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActivityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to do?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick an activity for your hangout',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _quickActivities.length,
            itemBuilder: (context, index) {
              final activity = _quickActivities[index];
              final isSelected = _selectedActivity == activity['name'];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedActivity = activity['name']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activity['color'].withAlpha(26)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected
                          ? activity['color']
                          : AppColors.lightGrey,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (activity['color'] as Color).withAlpha(51),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activity['icon'],
                        size: 32,
                        color: isSelected
                            ? activity['color']
                            : AppColors.mediumGrey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? activity['color']
                              : AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a time for your hangout',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(_timingOptions.length, (index) {
            final option = _timingOptions[index];
            final isSelected = _selectedTiming == option['value'];

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTiming = option['value']);
                if (option['value'] == 'custom') {
                  _showDateTimePicker();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withAlpha(26)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.lightGrey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withAlpha(26)
                            : AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        option['icon'],
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.mediumGrey,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.darkGrey,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (_selectedTiming == 'custom') ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, color: AppColors.primaryBlue),
                  const SizedBox(width: 10),
                  Text(
                    '${_customDate.month}/${_customDate.day}/${_customDate.year} at ${_customTime.format(context)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set the vibe for your hangout',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Group size
          Text(
            'Group size',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _groupSize.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8,
                  label: '$_groupSize people',
                  activeColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    setState(() => _groupSize = value.round());
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '$_groupSize',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Vibe
          Text(
            'Vibe',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vibeOptions.map((vibe) {
              final isSelected = _vibe == vibe;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _vibe = vibe);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.friendlyPurple.withAlpha(26)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.friendlyPurple
                          : AppColors.lightGrey,
                    ),
                  ),
                  child: Text(
                    vibe,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.friendlyPurple
                          : AppColors.darkGrey,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Friends only toggle
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                Icon(
                  _friendsOnly ? Icons.lock : Icons.public,
                  color: _friendsOnly
                      ? AppColors.friendlyTeal
                      : AppColors.mediumGrey,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _friendsOnly ? 'Friends only' : 'Open to everyone',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _friendsOnly
                            ? 'Only friends can join'
                            : 'Anyone nearby can join',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _friendsOnly,
                  onChanged: (value) {
                    setState(() => _friendsOnly = value);
                  },
                  activeColor: AppColors.friendlyTeal,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Note
          Text(
            'Add a note (optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., "Trying out that new cafe on Main St!"',
                hintStyle: TextStyle(color: AppColors.mediumGrey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteStep() {
    // Mock friends list
    final friends = [
      {'name': 'Alex', 'image': null},
      {'name': 'Jordan', 'image': null},
      {'name': 'Sam', 'image': null},
      {'name': 'Taylor', 'image': null},
      {'name': 'Morgan', 'image': null},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite friends',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Skip to make it open to anyone',
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Summary card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withAlpha(13),
                  AppColors.friendlyTeal.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _quickActivities.firstWhere(
                      (a) => a['name'] == _selectedActivity,
                      orElse: () => {'icon': Icons.event},
                    )['icon'],
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedActivity Hangout',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_vibe vibe · $_groupSize people max',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Friends list
          Text(
            'Your friends',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...friends.map((friend) {
            final isInvited = _invitedFriends.contains(friend['name']);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isInvited
                      ? AppColors.primaryBlue
                      : AppColors.lightGrey,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      friend['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isInvited) {
                          _invitedFriends.remove(friend['name']);
                        } else {
                          _invitedFriends.add(friend['name']!);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isInvited
                            ? AppColors.primaryBlue
                            : AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: Text(
                        isInvited ? 'Invited' : 'Invite',
                        style: TextStyle(
                          color: isInvited ? Colors.white : AppColors.darkGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (_invitedFriends.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${_invitedFriends.length} friend${_invitedFriends.length > 1 ? 's' : ''} will be notified',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _customTime,
      );

      if (time != null) {
        setState(() {
          _customDate = date;
          _customTime = time;
        });
      }
    }
  }
}

class _SuccessDialog extends StatelessWidget {
  final String activity;
  final String timing;
  final int groupSize;

  const _SuccessDialog({
    required this.activity,
    required this.timing,
    required this.groupSize,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Hangout Created!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $activity hangout is live.\nFriends will be notified!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'View Hangout',
                onPressed: () {
                  Get.back();
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
