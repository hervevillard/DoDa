import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- African-inspired palette ---
const kColorPrimary    = Color(0xFFE8611A); // Terracotta orange
const kColorSecondary  = Color(0xFF2D8C5E); // Savanna green
const kColorAccent     = Color(0xFFF5C842); // Savanna gold
const kColorBackground = Color(0xFFFDF4E7); // Warm parchment
const kColorSurface    = Color(0xFFFFFFFF);
const kColorSuccess    = Color(0xFF3DAA6A); // Forest green
const kColorText       = Color(0xFF3A2010); // Deep earth brown
const kColorTextLight  = Color(0xFF7A5C3A); // Mid-earth
const kColorStar       = Color(0xFFFFD700); // Gold
const kColorLocked     = Color(0xFFB5A99A); // Dusty sand

// African accent colours used across screens
const kColorSunrise    = Color(0xFFF4845F); // Sunrise coral
const kColorNight      = Color(0xFF1B2A4A); // Night sky navy
const kColorKente1     = Color(0xFFD64E12); // Kente red
const kColorKente2     = Color(0xFF1A7A4A); // Kente green
const kColorKente3     = Color(0xFFF5C842); // Kente gold
const kColorEarth      = Color(0xFF8B5E3C); // Rich earth
const kColorSand       = Color(0xFFE8CFA0); // Light sand

final dodaTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kColorPrimary,
    background: kColorBackground,
    surface: kColorSurface,
  ),
  textTheme: GoogleFonts.nunitoTextTheme().copyWith(
    displayLarge: GoogleFonts.nunito(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      color: kColorText,
    ),
    headlineMedium: GoogleFonts.nunito(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: kColorText,
    ),
    titleLarge: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: kColorText,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 18,
      color: kColorText,
    ),
  ),
  scaffoldBackgroundColor: kColorBackground,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorPrimary,
      foregroundColor: Colors.white,
      minimumSize: const Size(120, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
);
