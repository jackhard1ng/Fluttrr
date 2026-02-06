import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../widgets/event_checkin.dart';
import '../../widgets/arrival_time.dart';

class AttendeesScreen extends StatefulWidget {
  final String eventName;
  final bool isHost;

  const AttendeesScreen({
    super.key,
    required this.eventName,
    this.isHost = false,
  });

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends State<AttendeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Attendee> _going = [
    _Attendee(name: 'Sarah Chen', status: AttendeeStatus.checkedIn, arrivalTime: ArrivalTime.early, isFriend: true),
    _Attendee(name: 'Mike Johnson', status: AttendeeStatus.checkedIn, arrivalTime: ArrivalTime.onTime, isFriend: true),
    _Attendee(name: 'Jordan Lee', status: AttendeeStatus.going, arrivalTime: ArrivalTime.onTime, isFriend: false),
    _Attendee(name: 'Alex Rivera', status: AttendeeStatus.going, arrivalTime: ArrivalTime.late, isFriend: false),
    _Attendee(name: 'Taylor Kim', status: AttendeeStatus.going, isFriend: true),
  ];

  final List<_Attendee> _maybe = [
    _Attendee(name: 'Chris Park', status: AttendeeStatus.maybe),
    _Attendee(name: 'Sam Wilson', status: AttendeeStatus.maybe),
  ];

  final List<_Attendee> _invited = [
    _Attendee(name: 'Emma Brown', status: AttendeeStatus.invited),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkedInCount = _going.where((a) => a.status == AttendeeStatus.checkedIn).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendees',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.eventName,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.mediumGrey,
          indicatorColor: AppColors.primaryBlue,
          tabs: [
            Tab(text: 'Going (${_going.length})'),
            Tab(text: 'Maybe (${_maybe.length})'),
            Tab(text: 'Invited (${_invited.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.lightGrey.withAlpha(77),
            child: Row(
              children: [
                CheckInCount(count: checkedInCount, total: _going.length),
                const Spacer(),
                ArrivalSummary(
                  earlyCount: _going.where((a) => a.arrivalTime == ArrivalTime.early).length,
                  onTimeCount: _going.where((a) => a.arrivalTime == ArrivalTime.onTime).length,
                  lateCount: _going.where((a) => a.arrivalTime == ArrivalTime.late).length,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_going),
                _buildList(_maybe),
                _buildList(_invited),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_Attendee> attendees) {
    if (attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.lightGrey),
            const SizedBox(height: 12),
            Text(
              'No one yet',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        return _AttendeeTile(
          attendee: attendees[index],
          isHost: widget.isHost,
        );
      },
    );
  }
}

class _Attendee {
  final String name;
  final AttendeeStatus status;
  final ArrivalTime? arrivalTime;
  final bool isFriend;

  _Attendee({
    required this.name,
    required this.status,
    this.arrivalTime,
    this.isFriend = false,
  });
}

enum AttendeeStatus {
  going,
  checkedIn,
  maybe,
  invited,
}

class _AttendeeTile extends StatelessWidget {
  final _Attendee attendee;
  final bool isHost;

  const _AttendeeTile({required this.attendee, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: attendee.isFriend
                      ? AppColors.friendlyPurple.withAlpha(26)
                      : AppColors.primaryBlue.withAlpha(26),
                ),
                child: Center(
                  child: Text(
                    attendee.name[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: attendee.isFriend
                          ? AppColors.friendlyPurple
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              if (attendee.status == AttendeeStatus.checkedIn)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      attendee.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (attendee.isFriend) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.friendlyPurple.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Text(
                          'Friend',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.friendlyPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (attendee.status == AttendeeStatus.checkedIn)
                      const CheckedInBadge()
                    else if (attendee.arrivalTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: attendee.arrivalTime!.color.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(attendee.arrivalTime!.emoji, style: const TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(
                              attendee.arrivalTime!.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: attendee.arrivalTime!.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (!attendee.isFriend && attendee.status != AttendeeStatus.invited)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
