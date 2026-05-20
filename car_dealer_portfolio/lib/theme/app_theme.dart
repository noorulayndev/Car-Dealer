import 'package:flutter/material.dart';

class AppTheme {
  static const Color royalNavy = Color(0xFF0A1931);

  static const Color cardColor = Color(0xFF1F2A44);

  static const Color accentGold = Color(0xFFFFB703);

  static const Color cream = Color(0xFFF7F7F7);

  static ThemeData luxuryTheme = ThemeData(
    scaffoldBackgroundColor: royalNavy,
    primaryColor: royalNavy,
    appBarTheme: const AppBarTheme(
      backgroundColor: royalNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ));
  // App Bar Title
  static const TextStyle titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // Card Title
  static const TextStyle cardTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Subtitle
  static const TextStyle subtitleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 15,
  );
  static const TextStyle priceStyle=TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.teal,


  );
}