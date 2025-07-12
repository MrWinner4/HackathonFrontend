import 'package:flutter/material.dart';

class AppColorScheme {
  // Primary colors (60% usage) - White background
  static const Color primary = Color(0xFFFFFFFF); // White - main background
  static const Color primaryVariant = Color(0xFFF5F5F5); // Light gray variant
  
  // Secondary colors (30% usage) - Black text and elements
  static const Color secondary = Color(0xFF000000); // Black - text, borders
  static const Color secondaryVariant = Color(0xFF424242); // Dark gray variant
  
  // Accent colors (10% usage) - Green for money
  static const Color accent = Color(0xFF4CAF50); // Green - highlights, buttons
  static const Color accentVariant = Color(0xFF388E3C); // Darker green
  
  // Additional utility colors
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color error = Color(0xFFD32F2F); // Red error
  static const Color onPrimary = Color(0xFF000000); // Black text on white
  static const Color onSecondary = Color(0xFFFFFFFF); // White text on black
  static const Color onSurface = Color(0xFF000000); // Black text on white surface
  static const Color onBackground = Color(0xFF000000); // Black text on white background
  static const Color onError = Color(0xFFFFFFFF); // White text on error
  static const Color onAccent = Color(0xFFFFFFFF); // White text on green
  
  // Material ColorScheme
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    error: error,
    onError: onError,
    background: background,
    onBackground: onBackground,
    surface: surface,
    onSurface: onSurface,
  );
}
