import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales (selon vos spécifications)
  static const Color primaryColor = Color(0xFF00A550);      // Vert principal
  static const Color secondaryColor = Color(0xFFFFD700);   // Or/jaune
  static const Color accentColor = Color(0xFFFF6B35);      // Orange vif
  static const Color successColor = Color(0xFF4CAF50);     // Vert succès
  static const Color warningColor = Color(0xFFFF9800);     // Orange avertissement
  static const Color errorColor = Color(0xFFF44336);       // Rouge erreur
  static const Color infoColor = Color(0xFF2196F3);        // Bleu info

  // Couleurs de fond
  static const Color backgroundColor = Color(0xFFF8F9FA);   // Fond principal
  static const Color surfaceColor = Color(0xFFFFFFFF);     // Surface des cartes
  static const Color cardColor = Color(0xFFFFFFFF);        // Couleur des cartes

  // Couleurs de texte
  static const Color onBackgroundColor = Color(0xFF212121); // Texte sur fond
  static const Color onSurfaceColor = Color(0xFF212121);   // Texte sur surface
  static const Color onPrimaryColor = Color(0xFFFFFFFF);   // Texte sur primaire
  static const Color onSecondaryColor = Color(0xFF000000); // Texte sur secondaire

  // Couleurs d'état
  static const Color disabledColor = Color(0xFFBDBDBD);    // Couleur désactivée
  static const Color dividerColor = Color(0xFFE0E0E0);    // Couleur des séparateurs
  static const Color shadowColor = Color(0x1F000000);     // Couleur des ombres

  // Couleurs spécifiques à l'application
  static const Color wastePlasticColor = Color(0xFF2196F3);    // Bleu pour plastique
  static const Color wasteOrganicColor = Color(0xFF4CAF50);    // Vert pour organique
  static const Color wasteGlassColor = Color(0xFF9C27B0);     // Violet pour verre
  static const Color wasteMetalColor = Color(0xFF607D8B);     // Bleu-gris pour métal
  static const Color wastePaperColor = Color(0xFFFF9800);     // Orange pour papier

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF008E3C)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFFFFC107)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFFE65100)],
  );

  // Ombres
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Thème de l'application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: onPrimaryColor,
        onSecondary: onSecondaryColor,
        onSurface: onSurfaceColor,
        onBackground: onBackgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: shadowColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: disabledColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
