/// Dark theme matching the Catppuccin-Mocha palette.
import 'package:flutter/material.dart';
import '../constants.dart';

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colorBackground,
    colorScheme: const ColorScheme.dark(
      primary: colorPrimary,
      surface: colorSurface,
      error: colorDanger,
      onPrimary: Colors.white,
      onSurface: colorText,
    ),
    cardTheme: CardThemeData(
      color: colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: colorBorder),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: colorPrimary,
      inactiveTrackColor: colorBorder,
      thumbColor: colorPrimary,
      overlayColor: Color(0x336C63FF),
      trackHeight: 6,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: colorPrimary,
      linearTrackColor: colorBorder,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: colorText, fontSize: 16),
      bodyMedium: TextStyle(color: colorText, fontSize: 14),
      bodySmall: TextStyle(color: colorTextDim, fontSize: 12),
      titleLarge: TextStyle(
        color: colorText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: colorText,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        minimumSize: const Size(200, 52),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: colorBackground,
      foregroundColor: colorText,
      elevation: 0,
    ),
  );
}
