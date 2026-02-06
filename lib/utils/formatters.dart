import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateTimeFormatter {
  /// Format date as "Mon, Jan 15"
  static String formatShortDate(DateTime date) {
    return DateFormat('E, MMM d').format(date);
  }

  /// Format date as "January 15, 2024"
  static String formatLongDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format date as "01/15/2024"
  static String formatNumericDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format time as "7:00 PM"
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Format time range as "7:00 PM - 10:00 PM"
  static String formatTimeRange(TimeOfDay start, TimeOfDay? end) {
    if (end == null) {
      return formatTime(start);
    }
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Format as relative time (e.g., "2 hours ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      // Future date
      final futureDiff = date.difference(now);
      if (futureDiff.inMinutes < 60) {
        return 'in ${futureDiff.inMinutes} min';
      } else if (futureDiff.inHours < 24) {
        return 'in ${futureDiff.inHours} hours';
      } else if (futureDiff.inDays == 1) {
        return 'Tomorrow';
      } else if (futureDiff.inDays < 7) {
        return 'in ${futureDiff.inDays} days';
      } else {
        return formatShortDate(date);
      }
    }

    // Past date
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else {
      return '${(diff.inDays / 365).floor()}y ago';
    }
  }

  /// Format countdown (e.g., "2d 5h 30m")
  static String formatCountdown(DateTime targetDate) {
    final diff = targetDate.difference(DateTime.now());

    if (diff.isNegative) {
      return 'Now';
    }

    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Starting soon';
    }
  }

  /// Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final mins = duration.inMinutes % 60;
      if (mins > 0) {
        return '${duration.inHours}h ${mins}m';
      }
      return '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }
}

/// Number formatting utilities
class NumberFormatter {
  /// Format number with commas (e.g., "1,234,567")
  static String formatWithCommas(num number) {
    return NumberFormat('#,###').format(number);
  }

  /// Format as compact (e.g., "1.2K", "3.4M")
  static String formatCompact(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format currency
  static String formatCurrency(num amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format percentage
  static String formatPercentage(num value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format ordinal (e.g., "1st", "2nd", "3rd")
  static String formatOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

/// Distance formatting utilities
class DistanceFormatter {
  /// Format distance in miles
  static String formatMiles(double miles) {
    if (miles < 0.1) {
      final feet = (miles * 5280).round();
      return '$feet ft';
    } else if (miles < 10) {
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      return '${miles.round()} mi';
    }
  }

  /// Format distance in kilometers
  static String formatKilometers(double km) {
    if (km < 1) {
      final meters = (km * 1000).round();
      return '$meters m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${km.round()} km';
    }
  }

  /// Format distance based on unit preference
  static String format(double miles, {bool useMetric = false}) {
    if (useMetric) {
      return formatKilometers(miles * 1.60934);
    }
    return formatMiles(miles);
  }
}

/// Text formatting utilities
class TextFormatter {
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Format name initials (e.g., "John Doe" -> "JD")
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Format phone number (e.g., "(555) 123-4567")
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  /// Pluralize word based on count
  static String pluralize(int count, String singular, [String? plural]) {
    if (count == 1) return singular;
    return plural ?? '${singular}s';
  }

  /// Format count with label (e.g., "5 friends", "1 friend")
  static String formatCount(int count, String singular, [String? plural]) {
    return '$count ${pluralize(count, singular, plural)}';
  }
}
