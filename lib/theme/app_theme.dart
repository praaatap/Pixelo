import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0095F6);
  static const Color premiumBlack = Color(0xFF121212);
  static const Color surfaceGrey = Color(0xFF262626);
  static const Color borderGrey = Color(0xFF363636);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black, size: 24),
      titleTextStyle: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge: const TextStyle(color: Colors.black),
      bodyMedium: const TextStyle(color: Colors.black),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: primaryBlue,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEFEFEF),
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: const TextStyle(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: primaryBlue,
      surface: premiumBlack,
      onSurface: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: borderGrey,
      thickness: 1,
    ),
  );
}
