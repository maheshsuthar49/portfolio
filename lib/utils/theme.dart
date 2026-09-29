import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgColor = Color(0xFF111111); // Dark background
  static const Color accentColor = Color(0xFFD4FF00); // Neon Lime Green
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFF888888);
  static const Color darkText = Color(0xFF111111); // For text on lime green

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      primaryColor: accentColor,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w900, fontSize: 80),
        displayMedium: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold, fontSize: 40),
        bodyLarge: GoogleFonts.inter(color: textColor, fontSize: 18),
        bodyMedium: GoogleFonts.inter(color: textSecondaryColor, fontSize: 16),
      ),
    );
  }
}
