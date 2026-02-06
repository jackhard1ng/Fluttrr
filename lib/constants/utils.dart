import 'package:flutter/material.dart';

/// App color constants - Brand colors from Fluttrr butterfly logo
class AppColors {
  AppColors._();

  // Primary brand colors (from butterfly logo)
  static const Color primaryBlue = Color(0xFF0080FF);  // Vibrant butterfly blue
  static const Color primaryDark = Color(0xFF0D1117);  // Deep navy background
  static const Color accentBlue = Color(0xFF38B6FF);   // Lighter blue accent

  // Secondary brand colors
  static const Color surfaceDark = Color(0xFF161B22);  // Card backgrounds dark mode
  static const Color surfaceLight = Color(0xFFF6F8FA); // Card backgrounds light mode

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF8B949E);
  static const Color lightGrey = Color(0xFFF0F3F6);
  static const Color darkGrey = Color(0xFF484F58);
  static const Color mediumGrey = Color(0xFF6E7681);

  // Friendship/social accent colors
  static const Color friendlyPink = Color(0xFFFF6B9D);   // Warm and welcoming
  static const Color friendlyTeal = Color(0xFF2DD4BF);   // Fresh and friendly
  static const Color friendlyPurple = Color(0xFF8B5CF6); // Creative and fun
  static const Color friendlyOrange = Color(0xFFFB923C); // Energetic
  static const Color warmYellow = Color(0xFFFBBF24);     // Warm and inviting

  // Background colors
  static const Color background = Color(0xFFF9FAFB);     // Light background
  static const Color backgroundDark = Color(0xFF0D1117); // Dark background

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Online status
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF6B7280);
  static const Color away = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);   // Gray 800
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textLight = Color(0xFF9CA3AF);     // Gray 400

  // Additional accent colors
  static const Color primaryPurple = Color(0xFF8B5CF6); // Purple 500
  static const Color primaryGreen = Color(0xFF22C55E);  // Green 500
}

/// App gradient constants
class AppGradients {
  AppGradients._();

  // Primary brand gradients
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryBlue, AppColors.primaryDark],
  );

  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accentBlue, AppColors.primaryBlue],
  );

  static const LinearGradient primaryDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentBlue, AppColors.primaryBlue],
  );

  static const RadialGradient primaryRadial = RadialGradient(
    colors: [AppColors.accentBlue, AppColors.primaryBlue],
  );

  // Splash/welcome gradient (matches logo background)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
  );

  // Vibrant button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0080FF), Color(0xFF38B6FF)],
  );

  // Friendly accent gradients for cards
  static const LinearGradient friendlyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.friendlyPink, AppColors.friendlyPurple],
  );

  // Card overlay gradient
  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
    stops: [0.4, 1.0],
  );

  // Business screen gradient - elegant dark with subtle blue
  static const LinearGradient businessGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A), // Slate 900
      Color(0xFF1E293B), // Slate 800
      Color(0xFF0F172A), // Slate 900
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Business screen gradient - with warm accent
  static const LinearGradient businessWarmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1917), // Stone 900
      Color(0xFF292524), // Stone 800
      Color(0xFF1C1917), // Stone 900
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Premium dark gradient with subtle glow effect
  static const LinearGradient premiumDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF18181B), // Zinc 900
      Color(0xFF27272A), // Zinc 800
      Color(0xFF18181B), // Zinc 900
    ],
    stops: [0.0, 0.4, 1.0],
  );

  // User login gradient - clean and friendly
  static const LinearGradient userLoginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC), // Slate 50
      Color(0xFFFFFFFF), // White
      Color(0xFFF1F5F9), // Slate 100
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // User login gradient dark mode
  static const LinearGradient userLoginDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1117), // Primary dark
      Color(0xFF161B22), // Surface dark
      Color(0xFF0D1117), // Primary dark
    ],
    stops: [0.0, 0.5, 1.0],
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
