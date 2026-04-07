import 'package:flutter/material.dart';

/// Primary brand colour — Pakistan motorway green.
const Color _kMotorwayGreen = Color(0xFF2E7D32);

/// Rahnuma Material theme.
final ThemeData rahnumaTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _kMotorwayGreen,
    primary: _kMotorwayGreen,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _kMotorwayGreen,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _kMotorwayGreen,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _kMotorwayGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  ),
);
