import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

/// Thème de l'application Battè
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs principales
      primaryColor: BatteColors.primary,
      scaffoldBackgroundColor: BatteColors.white,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: BatteColors.primary,
        secondary: BatteColors.secondary,
        error: BatteColors.destructive,
        background: BatteColors.white,
        surface: BatteColors.cardBackground,
        onPrimary: BatteColors.white,
        onSecondary: BatteColors.black,
        onError: BatteColors.destructiveForeground,
        onBackground: BatteColors.foreground,
        onSurface: BatteColors.foreground,
      ),
      
      // Typographie
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: BatteColors.foreground,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: BatteColors.foreground,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: BatteColors.foreground,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: BatteColors.foreground,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BatteColors.foreground,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BatteColors.foreground,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BatteColors.foreground,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BatteColors.foreground,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BatteColors.foreground,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: BatteColors.foreground,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: BatteColors.foreground,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: BatteColors.mutedForeground,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BatteColors.foreground,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BatteColors.foreground,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: BatteColors.mutedForeground,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: BatteColors.primary,
        foregroundColor: BatteColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BatteColors.white,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BatteColors.primary,
          foregroundColor: BatteColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BatteColors.primary,
          side: const BorderSide(color: BatteColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BatteColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BatteColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BatteColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BatteColors.destructive, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BatteColors.destructive, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: BatteColors.mutedForeground,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: BatteColors.mutedForeground,
        ),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: BatteColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: BatteColors.primary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: BatteColors.border,
        thickness: 1,
        space: 16,
      ),
    );
  }
}

