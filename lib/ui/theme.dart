import 'package:flutter/material.dart';

/// Single source of the app's colors and text styles; widgets read them via
/// `Theme.of(context)` and never define colors themselves.
abstract final class AppTheme {
  /// Seed for both color schemes, so light and dark mode feel like one app.
  static const _seedColor = Color(0xFF00897B);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    ),
  );
}
