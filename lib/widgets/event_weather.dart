import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Simple weather indicator for outdoor events
class EventWeather extends StatelessWidget {
  final WeatherType weather;
  final int temperature;
  final bool isCelsius;

  const EventWeather({
    super.key,
    required this.weather,
    required this.temperature,
    this.isCelsius = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: weather.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weather.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$temperature°${isCelsius ? 'C' : 'F'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: weather.textColor,
                ),
              ),
              Text(
                weather.label,
                style: TextStyle(
                  fontSize: 11,
                  color: weather.textColor.withAlpha(179),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum WeatherType {
  sunny('☀️', 'Sunny', Color(0xFFFFF3E0), Color(0xFFE65100)),
  partlyCloudy('⛅', 'Partly Cloudy', Color(0xFFE3F2FD), Color(0xFF1565C0)),
  cloudy('☁️', 'Cloudy', Color(0xFFECEFF1), Color(0xFF546E7A)),
  rainy('🌧️', 'Rainy', Color(0xFFE1F5FE), Color(0xFF0277BD)),
  stormy('⛈️', 'Stormy', Color(0xFFEDE7F6), Color(0xFF5E35B1)),
  snowy('❄️', 'Snowy', Color(0xFFE8EAF6), Color(0xFF3949AB)),
  windy('💨', 'Windy', Color(0xFFE0F7FA), Color(0xFF00838F)),
  perfect('🌤️', 'Perfect', Color(0xFFE8F5E9), Color(0xFF2E7D32));

  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const WeatherType(this.icon, this.label, this.backgroundColor, this.textColor);
}

/// Compact weather badge
class WeatherBadge extends StatelessWidget {
  final WeatherType weather;
  final int temperature;

  const WeatherBadge({
    super.key,
    required this.weather,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: weather.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weather.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$temperature°',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: weather.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weather alert for outdoor events
class WeatherAlert extends StatelessWidget {
  final WeatherType weather;
  final String message;
  final VoidCallback? onDismiss;

  const WeatherAlert({
    super.key,
    required this.weather,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = weather == WeatherType.rainy ||
        weather == WeatherType.stormy ||
        weather == WeatherType.snowy;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.friendlyOrange.withAlpha(26)
            : AppColors.friendlyTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isWarning
              ? AppColors.friendlyOrange.withAlpha(77)
              : AppColors.friendlyTeal.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Text(weather.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWarning ? 'Weather Alert' : 'Weather Update',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWarning
                        ? AppColors.friendlyOrange
                        : AppColors.friendlyTeal,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
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
