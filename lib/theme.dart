import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WommiColors {
  // Background colors
  static const bg = Color(0xFFFFFFFF);
  static const bgSoft = Color(0xFFF6F5FB);
  static const lilac = Color(0xFFEFEAFA);

  // Text colors
  static const ink = Color(0xFF1C1330);
  static const inkDim = Color(0xFF7A7189);

  // Border/line
  static const line = Color(0xFFE9E5F2);

  // Accent colors
  static const cyan = Color(0xFF00C6D7);
  static const cyanDark = Color(0xFF00A9BA);
  static const cyanInk = Color(0xFF003D44);

  static const gold = Color(0xFFE3A94D);
  static const goldSoft = Color(0xFFF6E3BE);

  static const rose = Color(0xFFF0839C);
  static const roseSoft = Color(0xFFFCE1E8);

  static const sage = Color(0xFF3FBE87);
}

class WommiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: WommiColors.bg,
      colorScheme: ColorScheme.light(
        primary: WommiColors.cyan,
        secondary: WommiColors.rose,
        surface: WommiColors.bg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: WommiColors.ink,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.unbounded(
          fontWeight: FontWeight.w800,
          fontSize: 52,
          height: 1.05,
          color: WommiColors.ink,
        ),
        displayMedium: GoogleFonts.unbounded(
          fontWeight: FontWeight.w800,
          fontSize: 24,
          height: 1.25,
          color: WommiColors.ink,
        ),
        headlineMedium: GoogleFonts.unbounded(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: WommiColors.ink,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          height: 1.6,
          color: WommiColors.inkDim,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13.5,
          height: 1.55,
          color: WommiColors.inkDim,
        ),
        labelLarge: GoogleFonts.spaceMono(
          fontSize: 11,
          letterSpacing: 1.54, // 0.14em
          color: WommiColors.inkDim,
        ),
        labelMedium: GoogleFonts.spaceMono(
          fontSize: 10.5,
          letterSpacing: 1.89, // 0.18em
          color: WommiColors.rose,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WommiColors.cyan,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: WommiColors.cyan.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.unbounded(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
