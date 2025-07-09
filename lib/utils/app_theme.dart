import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorDark = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  // Dark mode colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkPrimaryColor = Color(0xFF64B5F6);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Fix missing colors your UI code expects:
  static Color get cardColor => surfaceColor;
  static Color get textColor => textPrimary;
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    );
// Add these padding constants
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

// Add these padding constants
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

  // Custom input decoration for text form fields
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: TextStyle(color: Colors.grey[400]),
  );

  // Custom box shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryColor, primaryColorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = const LinearGradient(
    colors: [accentColor, Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border radius
  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);
  static BorderRadius smallBorderRadius = BorderRadius.circular(8);
  static BorderRadius largeBorderRadius = BorderRadius.circular(16);
}