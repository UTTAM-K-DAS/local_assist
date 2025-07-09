import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color primaryColor = Color(0xFF007BFF);
  static const Color secondaryColor = Color(0xFF6C757D);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF212529);

  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 32.0;

  // Border Radius
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(8));

  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // Dark Theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.black,
    cardTheme: const CardTheme(
      color: Colors.grey,
      margin: EdgeInsets.all(defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: defaultBorderRadius,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}
