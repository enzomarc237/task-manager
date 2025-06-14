import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class AppTheme {
  // Color palette following macOS design guidelines
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color primaryYellow = Color(0xFFFFCC00);
  static const Color primaryPurple = Color(0xFFAF52DE);
  static const Color primaryPink = Color(0xFFFF2D92);
  static const Color primaryTeal = Color(0xFF5AC8FA);

  // Priority colors
  static const Color urgentColor = Color(0xFFFF3B30);
  static const Color highColor = Color(0xFFFF9500);
  static const Color mediumColor = Color(0xFFFFCC00);
  static const Color lowColor = Color(0xFF34C759);

  // Light theme
  static MacosThemeData get lightTheme {
    return MacosThemeData.light().copyWith(
      primaryColor: primaryBlue,
      canvasColor: const Color(0xFFF2F2F7),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      typography: MacosTypography.of(null).copyWith(
        largeTitle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        title1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
        ),
        title2: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
        title3: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.23,
        ),
        headline: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.08,
        ),
        body: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
        callout: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
        ),
        subheadline: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.06,
        ),
        footnote: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.12,
        ),
        caption1: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.12,
        ),
        caption2: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.12,
        ),
      ),
    );
  }

  // Dark theme
  static MacosThemeData get darkTheme {
    return MacosThemeData.dark().copyWith(
      primaryColor: primaryBlue,
      canvasColor: const Color(0xFF1C1C1E),
      scaffoldBackgroundColor: const Color(0xFF000000),
      typography: MacosTypography.of(null).copyWith(
        largeTitle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
          color: Colors.white,
        ),
        title1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          color: Colors.white,
        ),
        title2: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
          color: Colors.white,
        ),
        title3: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.23,
          color: Colors.white,
        ),
        headline: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.08,
          color: Colors.white,
        ),
        body: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
          color: Colors.white70,
        ),
        callout: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
          color: Colors.white70,
        ),
        subheadline: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.06,
          color: Colors.white60,
        ),
        footnote: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.12,
          color: Colors.white60,
        ),
        caption1: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.12,
          color: Colors.white60,
        ),
        caption2: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.12,
          color: Colors.white60,
        ),
      ),
    );
  }

  // Priority color helpers
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return urgentColor;
      case 'high':
        return highColor;
      case 'medium':
        return mediumColor;
      case 'low':
        return lowColor;
      default:
        return mediumColor;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return primaryGreen;
      case 'in_progress':
        return primaryBlue;
      case 'cancelled':
        return primaryRed;
      default:
        return Colors.grey;
    }
  }

  // Custom button styles
  static ButtonStyle get primaryButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(primaryBlue),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
    foregroundColor: WidgetStateProperty.all(primaryBlue),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: primaryBlue),
      ),
    ),
  );

  static ButtonStyle get destructiveButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(primaryRed),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );

  // Card styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: const Color(0xFF1C1C1E),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Input field styles
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border radius constants
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 6.0;
  static const double radiusLarge = 8.0;
  static const double radiusXLarge = 12.0;
}