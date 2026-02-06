import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Carpool coordination widget for events
class CarpoolSection extends StatelessWidget {
  final String eventId;
  final String eventLocation;
  final List<CarpoolOffer> offers;
  final List<CarpoolRequest> requests;
  final VoidCallback? onOfferRide;
  final VoidCallback? onRequestRide;

  const CarpoolSection({
    super.key,
    required this.eventId,
    required this.eventLocation,
    this.offers = const [],
    this.requests = const [],
    this.onOfferRide,
    this.onRequestRide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.friendlyTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carpool',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Share rides with other attendees',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.drive_eta,
                  label: 'Offer a Ride',
                  color: AppColors.friendlyTeal,
                  onTap: onOfferRide ?? () => _showOfferRideSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.hail,
                  label: 'Need a Ride',
                  color: AppColors.friendlyPurple,
                  onTap: onRequestRide ?? () => _showRequestRideSheet(context),
                ),
              ),
            ],
          ),

          // Available rides
          if (offers.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Available Rides',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyTeal.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Text(
                    '${offers.length} available',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.friendlyTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...offers.map((offer) => _RideOfferCard(offer: offer)),
          ],

          // People looking for rides
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Looking for Rides',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.friendlyPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                  child: Text(
                    '${requests.length} looking',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.friendlyPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...requests.map((request) => _RideRequestCard(request: request)),
          ],

          // Empty state
          if (offers.isEmpty && requests.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.mediumGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No carpool offers yet. Be the first to offer or request a ride!',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
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

  void _showOfferRideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OfferRideSheet(eventLocation: eventLocation),
    );
  }

  void _showRequestRideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RequestRideSheet(eventLocation: eventLocation),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarpoolOffer {
  final String id;
  final String driverName;
  final String? driverAvatar;
  final String departureLocation;
  final String departureTime;
  final int seatsAvailable;
  final int seatsTaken;
  final String? note;

  CarpoolOffer({
    required this.id,
    required this.driverName,
    this.driverAvatar,
    required this.departureLocation,
    required this.departureTime,
    required this.seatsAvailable,
    this.seatsTaken = 0,
    this.note,
  });
}

class CarpoolRequest {
  final String id;
  final String personName;
  final String? personAvatar;
  final String pickupLocation;
  final String? note;

  CarpoolRequest({
    required this.id,
    required this.personName,
    this.personAvatar,
    required this.pickupLocation,
    this.note,
  });
}

class _RideOfferCard extends StatelessWidget {
  final CarpoolOffer offer;

  const _RideOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final seatsLeft = offer.seatsAvailable - offer.seatsTaken;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Driver avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.friendlyTeal.withAlpha(51),
            ),
            child: Center(
              child: Icon(
                Icons.drive_eta,
                color: AppColors.friendlyTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      offer.driverName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: seatsLeft > 0
                            ? AppColors.success.withAlpha(26)
                            : AppColors.error.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: Text(
                        seatsLeft > 0 ? '$seatsLeft seat${seatsLeft > 1 ? 's' : ''} left' : 'Full',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: seatsLeft > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offer.departureLocation,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Leaving at ${offer.departureTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (seatsLeft > 0)
            GestureDetector(
              onTap: () => _requestSeat(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _requestSeat(BuildContext context) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Request Sent!',
      '${offer.driverName} will be notified',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.friendlyTeal,
      colorText: Colors.white,
    );
  }
}

class _RideRequestCard extends StatelessWidget {
  final CarpoolRequest request;

  const _RideRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Person avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.friendlyPurple.withAlpha(51),
            ),
            child: Center(
              child: Text(
                request.personName[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                  request.personName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Near ${request.pickupLocation}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (request.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '"${request.note}"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.mediumGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _offerRide(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Pick Up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _offerRide(BuildContext context) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Offer Sent!',
      '${request.personName} will be notified',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.friendlyPurple,
      colorText: Colors.white,
    );
  }
}

/// Sheet to offer a ride
class OfferRideSheet extends StatefulWidget {
  final String eventLocation;

  const OfferRideSheet({super.key, required this.eventLocation});

  @override
  State<OfferRideSheet> createState() => _OfferRideSheetState();
}

class _OfferRideSheetState extends State<OfferRideSheet> {
  final _locationController = TextEditingController();
  String _departureTime = '6:30 PM';
  int _seats = 3;

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
                      Icon(Icons.drive_eta, color: AppColors.friendlyTeal),
                      const SizedBox(width: 8),
                      Text(
                        'Offer a Ride',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Departure location
                  Text(
                    'Departing from',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Downtown area, North side',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Departure time
                  Text(
                    'Departure time',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['6:00 PM', '6:30 PM', '7:00 PM'].map((time) {
                      final isSelected = _departureTime == time;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _departureTime = time),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: time != '7:00 PM' ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.friendlyTeal
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.friendlyTeal
                                    : AppColors.lightGrey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Available seats
                  Text(
                    'Available seats',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_seats > 1) setState(() => _seats--);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.remove),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_seats',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_seats < 6) setState(() => _seats++);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Post button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.snackbar(
                          'Ride Posted!',
                          'Other attendees can now request a seat',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.friendlyTeal,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Post Ride Offer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.friendlyTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}

/// Sheet to request a ride
class RequestRideSheet extends StatefulWidget {
  final String eventLocation;

  const RequestRideSheet({super.key, required this.eventLocation});

  @override
  State<RequestRideSheet> createState() => _RequestRideSheetState();
}

class _RequestRideSheetState extends State<RequestRideSheet> {
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

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
                      Icon(Icons.hail, color: AppColors.friendlyPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Request a Ride',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pickup area
                  Text(
                    'Where can you be picked up?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Near Central Station',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Note
                  Text(
                    'Add a note (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Can be flexible with time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  // Post button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.snackbar(
                          'Request Posted!',
                          'Drivers will see your request',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.friendlyPurple,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Post Ride Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.friendlyPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}

/// Compact carpool indicator for event cards
class CarpoolIndicator extends StatelessWidget {
  final int ridesAvailable;
  final VoidCallback? onTap;

  const CarpoolIndicator({
    super.key,
    required this.ridesAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (ridesAvailable == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.friendlyTeal.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(color: AppColors.friendlyTeal.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car,
              size: 14,
              color: AppColors.friendlyTeal,
            ),
            const SizedBox(width: 4),
            Text(
              '$ridesAvailable ride${ridesAvailable > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.friendlyTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
