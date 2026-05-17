import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ColorTokens.bgBase,
        colorScheme: const ColorScheme.dark(
          surface: ColorTokens.bgBase,
          primary: ColorTokens.accentCyan,
          secondary: ColorTokens.accentAmber,
          error: ColorTokens.accentRed,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorTokens.bgBase,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.syne(
            color: ColorTokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: ColorTokens.accentCyan,
          unselectedLabelColor: ColorTokens.textSecond,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: ColorTokens.accentCyan, width: 2),
          ),
          labelStyle: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.ibmPlexSans(fontSize: 13),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: ColorTokens.bgSurface,
          selectedColor: ColorTokens.bgElevated,
          side: const BorderSide(color: ColorTokens.bgBorder),
          labelStyle: GoogleFonts.ibmPlexSans(
            color: ColorTokens.textSecond,
            fontSize: 12,
          ),
        ),
        useMaterial3: true,
      );

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.syne(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.syne(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.syne(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.syne(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.ibmPlexSans(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.ibmPlexSans(
          color: ColorTokens.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.ibmPlexSans(
          color: ColorTokens.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          color: ColorTokens.textPrimary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.ibmPlexSans(
          color: ColorTokens.textSecond,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: ColorTokens.textSecond,
          fontSize: 11,
        ),
      );
}
