import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kColorPrimary = Color(0xFFFF6B35);
const kColorSecondary = Color(0xFF4ECDC4);
const kColorAccent = Color(0xFFFFE66D);
const kColorBackground = Color(0xFFFFF9F0);
const kColorSurface = Color(0xFFFFFFFF);
const kColorSuccess = Color(0xFF6BCB77);
const kColorText = Color(0xFF2D3436);
const kColorTextLight = Color(0xFF636E72);
const kColorStar = Color(0xFFFFD700);
const kColorLocked = Color(0xFFB2BEC3);

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
