import 'package:flutter/material.dart';

class BoColors {
  BoColors._();

  static const Color primary = Color(0xFF0B6E4F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F7F6);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color error = Color(0xFFB3261E);

  static const Color scaffoldGray = Color(0xFFF2F3F5);
  static const Color navy = Color(0xFF1B2A4A);
  static const Color infoBanner = Color(0xFFD6EAF8);
  static const Color navIndicator = Color(0xFFD4EDDA);
  static const Color houseMargin = Color(0xFFC62828);
  static const Color spinStart = Color(0xFFFF8A00);
  static const Color spinEnd = Color(0xFFFFC107);
  static const Color callNow = Color(0xFF2E7D32);
  static const Color winRateFill = Color(0xFF66BB6A);
}

class BoTheme {
  BoTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: BoColors.primary,
      primary: BoColors.primary,
      onPrimary: BoColors.onPrimary,
      surface: BoColors.surface,
      onSurface: BoColors.onSurface,
      error: BoColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BoColors.scaffoldGray,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
    );
  }
}
