import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Simple map preview widget (placeholder for real map)
class MapPreview extends StatelessWidget {
  final String location;
  final double? latitude;
  final double? longitude;
  final double height;
  final VoidCallback? onTap;
  final bool showDirections;

  const MapPreview({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
    this.height = 150,
    this.onTap,
    this.showDirections = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Stack(
          children: [
            // Placeholder map pattern
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CustomPaint(
                size: Size(double.infinity, height),
                painter: _MapPatternPainter(),
              ),
            ),
            // Location marker
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(77),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // Location label
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showDirections) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text(
                          'Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    const spacing = 20.0;
    for (var i = 0; i < size.width / spacing; i++) {
      canvas.drawLine(
        Offset(i * spacing, 0),
        Offset(i * spacing, size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height / spacing; i++) {
      canvas.drawLine(
        Offset(0, i * spacing),
        Offset(size.width, i * spacing),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Location picker input
class LocationPicker extends StatelessWidget {
  final String? selectedLocation;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const LocationPicker({
    super.key,
    this.selectedLocation,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: selectedLocation != null
              ? Border.all(color: AppColors.primaryBlue.withAlpha(51))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: selectedLocation != null
                  ? AppColors.primaryBlue
                  : AppColors.mediumGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLocation ?? 'Add location',
                style: TextStyle(
                  color: selectedLocation != null
                      ? AppColors.darkGrey
                      : AppColors.mediumGrey,
                  fontWeight: selectedLocation != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            if (selectedLocation != null && onClear != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClear!();
                },
                child: Icon(Icons.close, size: 20, color: AppColors.mediumGrey),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mediumGrey),
          ],
        ),
      ),
    );
  }
}

/// Nearby locations list
class NearbyLocations extends StatelessWidget {
  final List<NearbyLocation> locations;
  final Function(NearbyLocation)? onSelect;

  const NearbyLocations({
    super.key,
    required this.locations,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.near_me, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Nearby',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...locations.map((location) => _LocationTile(
          location: location,
          onTap: () => onSelect?.call(location),
        )),
      ],
    );
  }
}

class NearbyLocation {
  final String name;
  final String address;
  final String? category;
  final double? distance;

  NearbyLocation({
    required this.name,
    required this.address,
    this.category,
    this.distance,
  });
}

class _LocationTile extends StatelessWidget {
  final NearbyLocation location;
  final VoidCallback? onTap;

  const _LocationTile({
    required this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                _getCategoryIcon(location.category),
                size: 18,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (location.distance != null)
              Text(
                '${location.distance!.toStringAsFixed(1)} mi',
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

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'cafe':
      case 'coffee':
        return Icons.local_cafe;
      case 'bar':
        return Icons.local_bar;
      case 'park':
        return Icons.park;
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'store':
      case 'shop':
        return Icons.store;
      default:
        return Icons.place;
    }
  }
}

/// Distance indicator
class DistanceIndicator extends StatelessWidget {
  final double distance;
  final String? unit;

  const DistanceIndicator({
    super.key,
    required this.distance,
    this.unit = 'mi',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me, size: 12, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
          Text(
            '${distance.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
