import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WommiColors {
  // Background colors
  static const bg = Color(0xFFFFFFFF);
  static const bgSoft = Color(0xFFF6F5FB);
  static const lilac = Color(0xFFEFEAFA);

  // Matches the Rive journey map's own artboard background, so the home
  // screen doesn't show a seam where the map's canvas meets the page.
  // Deep purple per the Figma homepage redesign - was a light cyan before.
  static const riveBg = Color(0xFF552B82);

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

  // Celebration dialogs (e.g. the gem-earned win state)
  static const deepBlue = Color(0xFF10173A);
  static const deepBlueSoft = Color(0xFF232D6B);

  // Home header (Figma homepage redesign) - a brighter pink than [rose],
  // used only against the dark purple header background.
  static const homeSubtitlePink = Color(0xFFFF97E1);
  // Mission card ("Next ritual") - its own pink/dark pair, distinct from
  // [rose]/[ink] since the card sits on white rather than the purple header.
  static const missionLabelPink = Color(0xFFFF7295);
  static const missionTitleDark = Color(0xFF3D2635);

  // Achievements screen (Figma) - journey/bonus summary cards.
  static const achievementPink = Color(0xFFCF43A7);
  static const achievementPurple = Color(0xFFC28BFF);
  static const achievementGrey = Color(0xFFA8A8A8);
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
        bodyLarge: GoogleFonts.mulish(
          fontSize: 15,
          height: 1.6,
          color: WommiColors.inkDim,
        ),
        bodyMedium: GoogleFonts.mulish(
          fontSize: 13.5,
          height: 1.55,
          color: WommiColors.inkDim,
        ),
        labelLarge: GoogleFonts.mulish(
          fontSize: 11,
          letterSpacing: 1.54, // 0.14em
          color: WommiColors.inkDim,
        ),
        labelMedium: GoogleFonts.mulish(
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
