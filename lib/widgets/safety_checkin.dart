import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Safety check-in feature for events
/// Allows users to share their location and check-in status with trusted contacts
class SafetyCheckIn extends StatelessWidget {
  final String eventName;
  final String? eventLocation;
  final DateTime? eventTime;

  const SafetyCheckIn({
    super.key,
    required this.eventName,
    this.eventLocation,
    this.eventTime,
  });

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
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.friendlyTeal.withAlpha(77),
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
                  Icons.security,
                  color: AppColors.friendlyTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Check-In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Text(
                      'Let someone know where you\'ll be',
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

          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _SafetyActionButton(
                  icon: Icons.share_location,
                  label: 'Share Location',
                  onTap: () => _showShareLocationSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SafetyActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Check In',
                  onTap: () => _showCheckInSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareLocationSheet(BuildContext context) {
    // Guard against invalid context
    if (!context.mounted) return;
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _ShareLocationSheet(
          eventName: eventName,
          eventLocation: eventLocation,
          eventTime: eventTime,
        ),
      );
    } catch (e) {
      debugPrint('Error showing share location sheet: $e');
    }
  }

  void _showCheckInSheet(BuildContext context) {
    // Guard against invalid context
    if (!context.mounted) return;
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _CheckInSheet(eventName: eventName),
      );
    } catch (e) {
      debugPrint('Error showing check-in sheet: $e');
    }
  }
}

class _SafetyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SafetyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyTeal.withAlpha(77)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.friendlyTeal),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.friendlyTeal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareLocationSheet extends StatefulWidget {
  final String eventName;
  final String? eventLocation;
  final DateTime? eventTime;

  const _ShareLocationSheet({
    required this.eventName,
    this.eventLocation,
    this.eventTime,
  });

  @override
  State<_ShareLocationSheet> createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<_ShareLocationSheet> {
  final Set<String> _selectedContacts = {};
  Duration _shareDuration = const Duration(hours: 3);

  @override
  Widget build(BuildContext context) {
    // Mock trusted contacts
    final trustedContacts = [
      _TrustedContact(name: 'Mom', initial: 'M', color: AppColors.friendlyPurple),
      _TrustedContact(name: 'Best Friend', initial: 'B', color: AppColors.friendlyOrange),
      _TrustedContact(name: 'Roommate', initial: 'R', color: AppColors.friendlyTeal),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
                    Icon(Icons.share_location, color: AppColors.friendlyTeal),
                    const SizedBox(width: 8),
                    Text(
                      'Share Your Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Event info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withAlpha(128),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.eventName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (widget.eventLocation != null)
                              Text(
                                widget.eventLocation!,
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

                const SizedBox(height: 20),

                // Trusted contacts
                Text(
                  'Share with',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),

                if (trustedContacts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: AppColors.mediumGrey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No trusted contacts yet',
                                style: TextStyle(color: AppColors.mediumGrey),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Add Trusted Contact',
                                    'You can add trusted contacts in Settings > Safety',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.friendlyTeal,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Add someone you trust'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: trustedContacts.map((contact) {
                      final isSelected = _selectedContacts.contains(contact.name);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (isSelected) {
                              _selectedContacts.remove(contact.name);
                            } else {
                              _selectedContacts.add(contact.name);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? contact.color.withAlpha(26)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                            border: Border.all(
                              color: isSelected ? contact.color : AppColors.lightGrey,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: contact.color,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    contact.initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                contact.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? contact.color
                                      : AppColors.darkGrey,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: contact.color,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 20),

                // Duration selector
                Text(
                  'Share for',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _DurationChip(
                      label: '1 hour',
                      duration: const Duration(hours: 1),
                      isSelected: _shareDuration == const Duration(hours: 1),
                      onTap: () => setState(() => _shareDuration = const Duration(hours: 1)),
                    ),
                    const SizedBox(width: 8),
                    _DurationChip(
                      label: '3 hours',
                      duration: const Duration(hours: 3),
                      isSelected: _shareDuration == const Duration(hours: 3),
                      onTap: () => setState(() => _shareDuration = const Duration(hours: 3)),
                    ),
                    const SizedBox(width: 8),
                    _DurationChip(
                      label: 'Until I stop',
                      duration: Duration.zero,
                      isSelected: _shareDuration == Duration.zero,
                      onTap: () => setState(() => _shareDuration = Duration.zero),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Share button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedContacts.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            Get.snackbar(
                              'Location Shared',
                              'Your location is now being shared with ${_selectedContacts.length} contact${_selectedContacts.length > 1 ? 's' : ''}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.friendlyTeal,
                              colorText: Colors.white,
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.share_location),
                    label: const Text('Start Sharing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.friendlyTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: AppColors.lightGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _TrustedContact {
  final String name;
  final String initial;
  final Color color;

  _TrustedContact({
    required this.name,
    required this.initial,
    required this.color,
  });
}

class _DurationChip extends StatelessWidget {
  final String label;
  final Duration duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.friendlyTeal : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(
            color: isSelected ? AppColors.friendlyTeal : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.darkGrey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CheckInSheet extends StatelessWidget {
  final String eventName;

  const _CheckInSheet({required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick Check-In',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let your trusted contacts know you\'re okay',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Check-in options
                _CheckInOption(
                  icon: Icons.sentiment_very_satisfied,
                  label: 'Having a great time!',
                  color: AppColors.success,
                  onTap: () => _sendCheckIn(context, 'Having a great time'),
                ),
                const SizedBox(height: 12),
                _CheckInOption(
                  icon: Icons.home,
                  label: 'Heading home now',
                  color: AppColors.primaryBlue,
                  onTap: () => _sendCheckIn(context, 'Heading home'),
                ),
                const SizedBox(height: 12),
                _CheckInOption(
                  icon: Icons.schedule,
                  label: 'Staying a bit longer',
                  color: AppColors.friendlyOrange,
                  onTap: () => _sendCheckIn(context, 'Staying longer'),
                ),
                const SizedBox(height: 12),
                _CheckInOption(
                  icon: Icons.phone,
                  label: 'Call me please',
                  color: AppColors.error,
                  onTap: () => _sendCheckIn(context, 'Call me', urgent: true),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  void _sendCheckIn(BuildContext context, String status, {bool urgent = false}) {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    Get.snackbar(
      urgent ? 'Alert Sent!' : 'Check-In Sent!',
      urgent
          ? 'Your contacts have been notified to call you'
          : 'Your trusted contacts have been updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: urgent ? AppColors.error : AppColors.success,
      colorText: Colors.white,
      icon: Icon(
        urgent ? Icons.phone : Icons.check_circle,
        color: Colors.white,
      ),
    );
  }
}

class _CheckInOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CheckInOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

/// Compact safety reminder widget
class SafetyReminder extends StatelessWidget {
  final VoidCallback? onSetup;

  const SafetyReminder({super.key, this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.friendlyTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.friendlyTeal.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              color: AppColors.friendlyTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Safe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  'Add trusted contacts for check-ins',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSetup,
            child: Text(
              'Set Up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.friendlyTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
