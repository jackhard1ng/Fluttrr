import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryBlue = Color(0xFF007BFD);
  static const Color primaryDark = Color(0xFF20235A);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF65667D);
  static const Color lightGrey = Color(0xFFF1F1F1);
  static const Color darkGrey = Color(0xFF4D4D4D);

  // Secondary colors
  static const Color primaryGreen = Color(0xFF339003);
  static const Color primaryPurple = Color(0xFF6A5ACD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Online status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFFA726);
}

/// App gradient constants
class AppGradients {
  AppGradients._();

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryBlue, AppColors.primaryDark],
  );

  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryBlue, AppColors.primaryDark],
  );

  static const LinearGradient primaryDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryBlue, AppColors.primaryDark],
  );

  static const RadialGradient primaryRadial = RadialGradient(
    colors: [AppColors.primaryBlue, AppColors.primaryDark],
  );
}

/// App spacing constants
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App border radius constants
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 100.0;
}

/// App shadow constants
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withAlpha(13),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withAlpha(26),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withAlpha(38),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
